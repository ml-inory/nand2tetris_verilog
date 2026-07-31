'use strict';

let problems = [];
let detail = null;
let editor = null;
let editorReady = false;
let currentId = null;

const $ = (id) => document.getElementById(id);
const dirName = (d) => ({in: '输入', out: '输出', clk: '时钟'}[d] || d);

function esc(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

async function api(path, opts) {
  const r = await fetch(path, opts);
  if (!r.ok) {
    let msg = 'HTTP ' + r.status;
    try { const j = await r.json(); if (j.error) msg = j.error; } catch (e) {}
    throw new Error(msg);
  }
  return r.json();
}

// ---------------- 进度（localStorage）----------------
function getSolved() {
  try { return JSON.parse(localStorage.getItem('n2t-solved') || '[]'); } catch (e) { return []; }
}
function setSolved(id) {
  const s = getSolved();
  if (!s.includes(id)) { s.push(id); localStorage.setItem('n2t-solved', JSON.stringify(s)); }
}

// ---------------- 题目列表 ----------------
function renderList() {
  const solved = getSolved();
  $('progress').textContent = solved.length + '/' + problems.length;
  const box = $('problem-list');
  box.innerHTML = '';
  const byProj = {};
  for (const p of problems) (byProj[p.project] = byProj[p.project] || []).push(p);
  for (const proj of Object.keys(byProj).sort()) {
    const h = document.createElement('div');
    h.className = 'proj';
    h.textContent = 'Project ' + proj;
    box.appendChild(h);
    for (const p of byProj[proj]) {
      const b = document.createElement('button');
      b.className = 'proj-item' + (p.id === currentId ? ' active' : '');
      b.innerHTML = (solved.includes(p.id) ? '<span class="done">✓</span> ' : '') + esc(p.title);
      b.onclick = () => loadProblem(p.id);
      box.appendChild(b);
    }
  }
}

// ---------------- 最近判题 ----------------
async function refreshRecent() {
  try {
    const list = await api('/api/recent');
    const box = $('recent-list');
    if (!list.length) { box.innerHTML = '<span class="muted">暂无</span>'; return; }
    box.innerHTML = list.slice(0, 10).map(r => {
      const cls = r.status === 'pass' ? 'ok' : r.status === 'fail' ? 'no' : 'er';
      const label = r.status === 'pass' ? '通过' : r.status === 'fail' ? '未过' : '错误';
      const t = new Date(r.time * 1000);
      const hh = String(t.getHours()).padStart(2, '0');
      const mm = String(t.getMinutes()).padStart(2, '0');
      return `<div class="row"><span>${esc(r.problem)}</span><span class="${cls}">${label} ${hh}:${mm}</span></div>`;
    }).join('');
  } catch (e) { /* 忽略 */ }
}

// ---------------- 编辑器 ----------------
function getCode() {
  if (editorReady && editor) return editor.getValue();
  return $('editor-fallback').value;
}
function setCode(code) {
  if (editorReady && editor) editor.setValue(code);
  else $('editor-fallback').value = code;
}

function setupEditor() {
  const el = $('editor');
  if (window.monaco && window.monaco.editor) {
    editor = window.monaco.editor.create(el, {
      value: '', language: 'verilog', theme: 'vs-dark',
      automaticLayout: true, minimap: {enabled: false},
      fontSize: 14, scrollBeyondLastLine: false,
    });
    editorReady = true;
    $('editor-fallback').classList.add('hidden');
    el.classList.remove('hidden');
    if (detail) setCode(getSaved(detail.id) || detail.initial_code);
  } else {
    editorReady = false;
    $('editor').classList.add('hidden');
    $('editor-fallback').classList.remove('hidden');
    if (detail) $('editor-fallback').value = getSaved(detail.id) || detail.initial_code;
  }
}
window.addEventListener('monaco-ready', () => setupEditor());
window.addEventListener('DOMContentLoaded', () => {
  if (window.monaco && window.monaco.editor) setupEditor();
  else setTimeout(setupEditor, 4000);
});

function getSaved(id) { try { return localStorage.getItem('n2t-code-' + id); } catch (e) { return null; } }
function saveCode(id, code) { try { localStorage.setItem('n2t-code-' + id, code); } catch (e) {} }

// ---------------- 题目详情 ----------------
function renderPorts() {
  const t = $('p-ports');
  t.innerHTML = '<tr><th>端口</th><th>方向</th><th>位宽</th></tr>';
  for (const p of detail.ports) {
    const tr = document.createElement('tr');
    tr.innerHTML = `<td><code>${esc(p.name)}</code></td><td>${dirName(p.dir)}</td><td>${p.width === 1 ? '1' : p.width}</td>`;
    t.appendChild(tr);
  }
  const pw = $('p-probes-wrap');
  if (detail.probes && detail.probes.length) {
    $('p-probes').textContent = detail.probes.map(x => `${x.name}  (${x.width} bit)`).join('\n');
    pw.classList.remove('hidden');
  } else pw.classList.add('hidden');
}

function renderWave(waveJson) {
  const box = $('wave');
  box.innerHTML = '';
  if (!waveJson || !waveJson.signal || !waveJson.signal.length) return;
  const holder = document.createElement('div');
  holder.id = 'wave0';
  box.appendChild(holder);
  try {
    if (window.WaveDrom && window.WaveDrom.renderWaveForm) {
      WaveDrom.renderWaveForm(0, waveJson, 'wave');
    } else {
      holder.textContent = JSON.stringify(waveJson);
    }
  } catch (e) {
    holder.textContent = JSON.stringify(waveJson);
  }
}

function showResult(r) {
  const box = $('result');
  box.classList.remove('hidden');
  const badge = $('res-badge');
  const cls = r.status === 'pass' ? 'pass' : r.status === 'fail' ? 'fail' : 'error';
  const label = r.status === 'pass' ? '通过' : r.status === 'fail' ? '未通过' : '错误';
  badge.className = 'badge ' + cls;
  badge.textContent = label;
  $('res-summary').textContent = r.summary
    ? `检查 ${r.summary.total} 项，通过 ${r.summary.passed}，失败 ${r.summary.failed}`
    : (r.error || '');
  $('res-time').textContent = r.time_ms != null ? `${r.time_ms} ms` : '';
  const logParts = [];
  if (r.compile && !r.compile.ok) logParts.push('--- 编译错误 ---\n' + r.compile.log);
  if (r.log) logParts.push('--- 仿真输出 ---\n' + r.log);
  $('res-log').textContent = logParts.join('\n\n') || '(无输出)';
  const wb = $('wave-box');
  if (r.wave && r.wave.signal && r.wave.signal.length) {
    wb.classList.remove('hidden');
    renderWave(r.wave);
  } else {
    wb.classList.add('hidden');
  }
}

async function loadProblem(id) {
  currentId = id;
  localStorage.setItem('n2t-last', id);
  const saved = getSaved(id);
  if (saved != null) setCode(saved);
  detail = await api('/api/problems/' + id);
  $('p-title').textContent = detail.title;
  $('p-badge').textContent = 'Project ' + detail.project;
  $('p-module').textContent = detail.module;
  $('p-desc').textContent = detail.description || '（无说明）';
  renderPorts();
  if (!saved) setCode(detail.initial_code);
  renderList();
  $('result').classList.add('hidden');
  $('status-msg').textContent = '';
}

// ---------------- 测试台查看 ----------------
async function showTb() {
  if (!currentId) return;
  try {
    const r = await api('/api/problems/' + currentId + '/tb');
    $('modal-title').textContent = detail.title + ' 官方测试台';
    $('modal-body').textContent = r.tb;
    $('modal').classList.remove('hidden');
  } catch (e) {
    $('status-msg').textContent = '获取测试台失败: ' + e.message;
  }
}

// ---------------- 判题 ----------------
async function submit() {
  if (!currentId) return;
  const btn = $('btn-submit');
  btn.disabled = true;
  const status = $('status-msg');
  status.textContent = '判题中…';
  try {
    const code = getCode();
    saveCode(currentId, code);
    const r = await api('/api/submit', {
      method: 'POST', headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({id: currentId, code}),
    });
    showResult(r);
    status.textContent = '完成';
    if (r.status === 'pass') {
      setSolved(currentId);
      renderList();
    }
    refreshRecent();
  } catch (e) {
    status.textContent = '请求失败: ' + e.message;
  } finally {
    btn.disabled = false;
  }
}

// ---------------- 初始化 ----------------
async function init() {
  $('btn-submit').onclick = submit;
  $('btn-tb').onclick = showTb;
  $('btn-reset').onclick = () => {
    if (detail && confirm('恢复初始模板？当前代码将被覆盖。')) {
      setCode(detail.initial_code);
      localStorage.removeItem('n2t-code-' + detail.id);
    }
  };
  $('modal-close').onclick = () => $('modal').classList.add('hidden');
  $('modal').onclick = (e) => { if (e.target === $('modal')) $('modal').classList.add('hidden'); };
  $('editor-fallback').addEventListener('input', () => { if (currentId) saveCode(currentId, $('editor-fallback').value); });
  try {
    problems = await api('/api/problems');
  } catch (e) {
    $('p-title').textContent = '无法连接后端服务';
    return;
  }
  const first = localStorage.getItem('n2t-last') || problems[0].id;
  await loadProblem(first);
  refreshRecent();
}
window.addEventListener('DOMContentLoaded', init);
