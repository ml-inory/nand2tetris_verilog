#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""nand2tetris_verilog 在线判题服务（FastAPI）。

接口：
  GET  /api/problems            题目列表
  GET  /api/problems/{id}       单题详情（含初始代码/端口/说明）
  GET  /api/problems/{id}/tb    官方 testbench 原文
  POST /api/register            注册 {username, password} -> {token, username}
  POST /api/login               登录 -> {token, username}
  POST /api/logout              退出（Bearer token）
  GET  /api/me                  当前用户
  POST /api/submit              判题 {id, code}（需登录）
  GET  /api/submissions         我的提交历史
  GET  /api/submissions/{sid}   某次提交详情（代码 + 结果）
  GET  /api/solved              我已通过的题目（跨浏览器同步）
  GET  /api/drafts/{id}         我的题目草稿
  PUT  /api/drafts/{id}         保存我的题目草稿
  POST /api/wave                按指定内部信号生成波形 {id, code, signals}
  GET  /api/recent              全局最近判题（匿名）
  GET  /                        前端单页（web/）
"""
import json
import os
import time
from collections import deque

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from . import db
from .judge import PROBLEMS, BY_ID, judge, ROOT

HERE = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.join(os.path.dirname(HERE), 'web')

app = FastAPI(title='nand2tetris Verilog Judge', version='0.3.0')


@app.middleware('http')
async def no_cache_api(request, call_next):
    response = await call_next(request)
    if request.url.path.startswith('/api/'):
        response.headers['Cache-Control'] = 'no-store'
    return response


# ---- 全局最近判题（匿名，内存；重启即清空）----
RECENT = deque(maxlen=50)

# ---- 提交限流：每 IP 每 60s 最多 SUBMIT_LIMIT 次（环境变量可调）----
SUBMIT_LIMIT = int(os.environ.get('SUBMIT_LIMIT', '60'))
AUTH_LIMIT = 20
_hits = {}


class AuthBody(BaseModel):
    username: str
    password: str


class Submit(BaseModel):
    id: str
    code: str


class DraftBody(BaseModel):
    code: str


class WaveBody(BaseModel):
    id: str
    code: str
    signals: str = ''


def current_user(request: Request):
    auth = request.headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        return db.user_by_token(auth[7:].strip())
    return None


@app.middleware('http')
async def rate_limit(request: Request, call_next):
    if request.url.path in ('/api/submit', '/api/register', '/api/login'):
        ip = request.client.host if request.client else 'unknown'
        limit = SUBMIT_LIMIT if request.url.path == '/api/submit' else AUTH_LIMIT
        now = time.time()
        q = _hits.setdefault(ip, deque())
        while q and now - q[0] > 60:
            q.popleft()
        if len(q) >= limit:
            return JSONResponse({'status': 'error', 'error': 'rate limited: too many requests'},
                                status_code=429)
        q.append(now)
    return await call_next(request)


# ---------------- 认证 ----------------
@app.post('/api/register')
def register(body: AuthBody):
    uid, err = db.create_user(body.username.strip(), body.password)
    if uid is None:
        raise HTTPException(400, err)
    token = db.create_session(uid)
    return {'token': token, 'username': body.username.strip()}


@app.post('/api/login')
def login(body: AuthBody):
    uid = db.verify_user(body.username.strip(), body.password)
    if uid is None:
        raise HTTPException(401, '用户名或密码错误')
    token = db.create_session(uid)
    return {'token': token, 'username': body.username.strip()}


@app.post('/api/logout')
def logout(request: Request):
    auth = request.headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        db.delete_session(auth[7:].strip())
    return {'ok': True}


@app.get('/api/me')
def me(request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, 'not logged in')
    return {'username': u['username']}


# ---------------- 题目 ----------------
@app.get('/api/problems')
def list_problems(request: Request):
    if current_user(request) is None:
        raise HTTPException(401, '请先登录')
    return [{'id': p['id'], 'title': p['title'], 'project': p['project'], 'module': p['module']}
            for p in PROBLEMS]


@app.get('/api/problems/{pid}')
def get_problem(pid: str, request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, '请先登录')
    p = BY_ID.get(pid)
    if p is None:
        raise HTTPException(404, 'problem not found')
    last = db.get_last_submission(u['id'], pid)
    return {
        'id': p['id'], 'title': p['title'], 'project': p['project'], 'module': p['module'],
        'ports': p['ports'], 'probes': p['probes'], 'description': p['description'],
        'initial_code': p['initial_code'], 'deps': len(p['deps']),
        'last_submission': last,
    }


@app.get('/api/problems/{pid}/tb')
def get_tb(pid: str, request: Request):
    if current_user(request) is None:
        raise HTTPException(401, '请先登录')
    p = BY_ID.get(pid)
    if p is None:
        raise HTTPException(404, 'problem not found')
    try:
        text = open(os.path.join(ROOT, p['tb']), encoding='utf-8').read()
    except OSError:
        raise HTTPException(500, 'tb file missing')
    return {'tb': text}


# ---------------- 判题 ----------------
@app.post('/api/submit')
def submit(request: Request, body: Submit):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, '请先登录')
    result = judge(body.id, body.code)
    try:
        db.add_submission(u['id'], body.id, body.code, result)
    except Exception:
        pass  # 历史入库失败不阻塞判题
    RECENT.appendleft({'time': int(time.time()), 'problem': body.id, 'status': result['status'],
                       'user': u['username']})
    return result


@app.get('/api/submissions')
def my_submissions(request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, 'not logged in')
    rows = db.list_submissions(u['id'])
    out = []
    for r in rows:
        try:
            summary = json.loads(r['summary']) if r['summary'] else None
        except Exception:
            summary = None
        out.append({'id': r['id'], 'problem': r['problem'], 'status': r['status'],
                    'summary': summary, 'error': r['error'], 'time_ms': r['time_ms'],
                    'created_at': r['created_at']})
    return out


@app.get('/api/submissions/{sid}')
def submission_detail(sid: int, request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, 'not logged in')
    row = db.get_submission(u['id'], sid)
    if row is None:
        raise HTTPException(404, 'submission not found')
    return row


@app.get('/api/solved')
def my_solved(request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, 'not logged in')
    return {'solved': db.list_solved(u['id'])}


@app.get('/api/drafts/{pid}')
def get_draft(pid: str, request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, 'not logged in')
    return {'code': db.get_draft(u['id'], pid)}


@app.put('/api/drafts/{pid}')
def put_draft(pid: str, body: DraftBody, request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, 'not logged in')
    if len(body.code) > 64 * 1024:
        raise HTTPException(400, '草稿过长')
    db.set_draft(u['id'], pid, body.code)
    return {'ok': True}


@app.post('/api/wave')
def wave_view(body: WaveBody, request: Request):
    u = current_user(request)
    if u is None:
        raise HTTPException(401, 'not logged in')
    sigs = [s.strip() for s in body.signals.split(',') if s.strip()]
    if not sigs:
        raise HTTPException(400, '请填写要查看的信号路径，如 mem[5], u1.out')
    from .wave import run_wave_for_code
    r = run_wave_for_code(body.id, body.code, sigs)
    if r.get('error'):
        raise HTTPException(400, r['error'])
    return r


@app.get('/api/recent')
def recent(request: Request):
    if current_user(request) is None:
        raise HTTPException(401, '请先登录')
    return list(RECENT)


@app.get('/')
@app.head('/')
def index():
    return FileResponse(os.path.join(WEB, 'index.html'),
                        headers={'Cache-Control': 'no-store'})


app.mount('/', StaticFiles(directory=WEB), name='web')
