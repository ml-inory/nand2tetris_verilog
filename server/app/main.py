#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""nand2tetris_verilog 在线判题服务（FastAPI）。

接口：
  GET  /api/problems            题目列表
  GET  /api/problems/{id}       单题详情（含初始代码/端口/说明）
  POST /api/submit              {id, code} -> 判题结果
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

from .judge import PROBLEMS, BY_ID, judge, ROOT

HERE = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.join(os.path.dirname(HERE), 'web')

app = FastAPI(title='nand2tetris Verilog Judge', version='0.2.0')

# ---- 最近判题（内存，匿名；重启即清空）----
RECENT = deque(maxlen=50)

# ---- 提交限流：每 IP 每 60s 最多 SUBMIT_LIMIT 次（环境变量可调）----
SUBMIT_LIMIT = int(os.environ.get('SUBMIT_LIMIT', '60'))
_hits = {}


class Submit(BaseModel):
    id: str
    code: str


@app.get('/api/problems')
def list_problems():
    return [{'id': p['id'], 'title': p['title'], 'project': p['project'], 'module': p['module']}
            for p in PROBLEMS]


@app.get('/api/problems/{pid}')
def get_problem(pid: str):
    p = BY_ID.get(pid)
    if p is None:
        raise HTTPException(404, 'problem not found')
    return {
        'id': p['id'], 'title': p['title'], 'project': p['project'], 'module': p['module'],
        'ports': p['ports'], 'probes': p['probes'], 'description': p['description'],
        'initial_code': p['initial_code'], 'deps': len(p['deps']),
    }


@app.middleware('http')
async def rate_limit(request: Request, call_next):
    if request.url.path == '/api/submit':
        ip = request.client.host if request.client else 'unknown'
        now = time.time()
        q = _hits.setdefault(ip, deque())
        while q and now - q[0] > 60:
            q.popleft()
        if len(q) >= SUBMIT_LIMIT:
            return JSONResponse({'status': 'error', 'error': 'rate limited: too many submissions'},
                                status_code=429)
        q.append(now)
    return await call_next(request)


@app.get('/api/recent')
def recent():
    return list(RECENT)


@app.get('/api/problems/{pid}/tb')
def get_tb(pid: str):
    p = BY_ID.get(pid)
    if p is None:
        raise HTTPException(404, 'problem not found')
    try:
        text = open(os.path.join(ROOT, p['tb']), encoding='utf-8').read()
    except OSError:
        raise HTTPException(500, 'tb file missing')
    return {'tb': text}


@app.post('/api/submit')
def submit(body: Submit):
    result = judge(body.id, body.code)
    RECENT.appendleft({'time': int(time.time()), 'problem': body.id, 'status': result['status']})
    return result


@app.get('/')
def index():
    return FileResponse(os.path.join(WEB, 'index.html'))


app.mount('/', StaticFiles(directory=WEB), name='web')
