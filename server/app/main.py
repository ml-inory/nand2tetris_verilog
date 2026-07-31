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

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from .judge import PROBLEMS, BY_ID, judge

HERE = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.join(os.path.dirname(HERE), 'web')

app = FastAPI(title='nand2tetris Verilog Judge', version='0.1.0')


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


@app.post('/api/submit')
def submit(body: Submit):
    return judge(body.id, body.code)


@app.get('/')
def index():
    return FileResponse(os.path.join(WEB, 'index.html'))


app.mount('/', StaticFiles(directory=WEB), name='web')
