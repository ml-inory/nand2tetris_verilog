#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
db.py — SQLite 存储：用户、会话、提交历史。

- 密码：PBKDF2-HMAC-SHA256（stdlib，无额外依赖），每用户随机盐
- 会话：随机 token 存库，30 天过期
- 提交历史：含完整判题结果 JSON（含波形），供“我的提交”回看

数据库文件：server/data/judge.db（Docker 部署时挂载数据卷持久化）。
"""
import hashlib
import json
import os
import secrets
import sqlite3
import time

HERE = os.path.dirname(os.path.abspath(__file__))
SERVER = os.path.dirname(HERE)
DATA_DIR = os.path.join(SERVER, 'data')
DB_PATH = os.path.join(DATA_DIR, 'judge.db')

SESSION_DAYS = 30
PBKDF2_ITER = 200_000


def _conn():
    os.makedirs(DATA_DIR, exist_ok=True)
    c = sqlite3.connect(DB_PATH, timeout=10)
    c.row_factory = sqlite3.Row
    return c


def init_db():
    with _conn() as c:
        c.executescript('''
        CREATE TABLE IF NOT EXISTS users (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            username   TEXT UNIQUE NOT NULL,
            pass_hash  TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );
        CREATE TABLE IF NOT EXISTS sessions (
            token      TEXT PRIMARY KEY,
            user_id    INTEGER NOT NULL REFERENCES users(id),
            created_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL
        );
        CREATE TABLE IF NOT EXISTS submissions (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id    INTEGER NOT NULL REFERENCES users(id),
            problem    TEXT NOT NULL,
            code       TEXT NOT NULL,
            status     TEXT NOT NULL,
            summary    TEXT,
            error      TEXT,
            time_ms    INTEGER,
            result     TEXT,
            created_at INTEGER NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_submissions_user ON submissions(user_id, id DESC);
        ''')


# ---------------- 密码 ----------------
def hash_pw(password, salt=None):
    salt = salt or secrets.token_bytes(16)
    dk = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt, PBKDF2_ITER)
    return salt.hex() + '$' + dk.hex()


def verify_pw(password, stored):
    try:
        salt_hex, dk_hex = stored.split('$', 1)
        return hash_pw(password, bytes.fromhex(salt_hex)) == stored
    except Exception:
        return False


# ---------------- 用户 ----------------
def create_user(username, password):
    """返回 (user_id, None) 或 (None, 错误信息)。"""
    if not username or not (3 <= len(username) <= 24):
        return None, '用户名需 3-24 个字符'
    if not all(ch.isalnum() or ch == '_' for ch in username):
        return None, '用户名只能包含字母、数字、下划线'
    if not password or len(password) < 6:
        return None, '密码至少 6 位'
    with _conn() as c:
        try:
            cur = c.execute('INSERT INTO users (username, pass_hash, created_at) VALUES (?,?,?)',
                            (username, hash_pw(password), int(time.time())))
            return cur.lastrowid, None
        except sqlite3.IntegrityError:
            return None, '用户名已存在'


def verify_user(username, password):
    row = _conn().execute('SELECT id, pass_hash FROM users WHERE username = ?', (username,)).fetchone()
    if row is None or not verify_pw(password, row['pass_hash']):
        return None
    return row['id']


def user_by_id(uid):
    row = _conn().execute('SELECT id, username FROM users WHERE id = ?', (uid,)).fetchone()
    return dict(row) if row else None


# ---------------- 会话 ----------------
def create_session(user_id):
    with _conn() as c:
        c.execute('DELETE FROM sessions WHERE expires_at < ?', (int(time.time()),))
        token = secrets.token_urlsafe(32)
        now = int(time.time())
        c.execute('INSERT INTO sessions (token, user_id, created_at, expires_at) VALUES (?,?,?,?)',
                  (token, user_id, now, now + SESSION_DAYS * 86400))
        return token


def user_by_token(token):
    if not token:
        return None
    row = _conn().execute(
        'SELECT u.id AS id, u.username AS username FROM sessions s '
        'JOIN users u ON u.id = s.user_id WHERE s.token = ? AND s.expires_at > ?',
        (token, int(time.time()))).fetchone()
    return dict(row) if row else None


def delete_session(token):
    with _conn() as c:
        c.execute('DELETE FROM sessions WHERE token = ?', (token,))


# ---------------- 提交历史 ----------------
def add_submission(user_id, problem, code, result):
    with _conn() as c:
        cur = c.execute(
            'INSERT INTO submissions (user_id, problem, code, status, summary, error, time_ms, result, created_at) '
            'VALUES (?,?,?,?,?,?,?,?,?)',
            (user_id, problem, code, result['status'],
             json.dumps(result.get('summary'), ensure_ascii=False) if result.get('summary') else None,
             result.get('error'), result.get('time_ms'),
             json.dumps(result, ensure_ascii=False), int(time.time())))
        return cur.lastrowid


def list_submissions(user_id, limit=50):
    rows = _conn().execute(
        'SELECT id, problem, status, summary, error, time_ms, created_at FROM submissions '
        'WHERE user_id = ? ORDER BY id DESC LIMIT ?', (user_id, limit)).fetchall()
    return [dict(r) for r in rows]


def get_submission(user_id, sid):
    row = _conn().execute(
        'SELECT id, problem, code, status, summary, error, time_ms, result, created_at '
        'FROM submissions WHERE id = ? AND user_id = ?', (sid, user_id)).fetchone()
    if row is None:
        return None
    d = dict(row)
    d['result'] = json.loads(d['result']) if d['result'] else None
    return d


init_db()
