'use strict';

let problems = [];
let detail = null;
let editor = null;
let editorReady = false;
let currentId = null;
let authUser = null;
let solvedSet = new Set();          // 已通过题目（后端按账号同步）
let draftCache = {};                // id -> 后端草稿（null 表示无）
let draftTimers = {};

const $ = (id) => document.getElementById(id);
const dirName = (d) => ({in: '输入', out: '输出', clk: '时钟'}[d] || d);
const TOKEN_KEY = 'n2t-token';
const USER_KEY = 'n2t-user';

function esc(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function getToken() { try { return localStorage.getItem(TOKEN_KEY); } catch (e) { return null; } }

async function api(path, opts = {}) {
  const headers = Object.assign({'Content-Type': 'application/json'}, opts.headers || {});
  const token = getToken();
  if (token) headers['Authorization'] = 'Bearer ' + token;
  const r = await fetch(path, Object.assign({}, opts, {headers}));
  if (!r.ok) {
    let msg = 'HTTP ' + r.status;
    try { const j = await r.json(); if (j.detail) msg = j.detail; else if (j.error) msg = j.error; } catch (e) {}
    if (r.status === 401) onAuthExpired();
    throw new Error(msg);
  }
  return r.json();
}

// ---------------- 页面切换：登录页 / 做题页 ----------------
function showLogin() {
  $('login-view').classList.remove('hidden');
  $('layout').classList.add('hidden');
  $('auth-area').classList.add('hidden');
  $('login-user').focus();
}

function showApp() {
  $('login-view').classList.add('hidden');
  $('layout').classList.remove('hidden');
  $('auth-area').classList.remove('hidden');
  $('auth-user').textContent = '你好，' + authUser;
}

// ---------------- 认证 ----------------
async function doAuth(action) {
  const username = $('login-user').value.trim();
  const password = $('login-pass').value;
  $('login-msg').textContent = '';
  if (!username || !password) { $('login-msg').textContent = '请输入用户名和密码'; return; }
  try {
    const r = await api('/api/' + action, {method: 'POST', body: JSON.stringify({username, password})});
    localStorage.setItem(TOKEN_KEY, r.token);
    localStorage.setItem(USER_KEY, r.username);
    authUser = r.username;
    $('login-pass').value = '';
    showApp();
    await initApp();
  } catch (e) {
    $('login-msg').textContent = (action === 'login' ? '登录失败：' : '注册失败：') + e.message;
  }
}

function onAuthExpired() {
  if (authUser || getToken()) {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    authUser = null;
    showLogin();
    $('login-msg').textContent = '登录已过期，请重新登录';
  }
}

async function logout() {
  try { await api('/api/logout', {method: 'POST'}); } catch (e) {}
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
  authUser = null;
  showLogin();
  $('login-msg').textContent = '';
}

// ---------------- 进度（后端按账号，跨浏览器同步）----------------
function markSolved(id) { solvedSet.add(id); }

// ---------------- 题目列表 ----------------
function renderList() {
  $('progress').textContent = solvedSet.size + '/' + problems.length;
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
      b.innerHTML = (solvedSet.has(p.id) ? '<span class="done">✓</span> ' : '') + esc(p.title);
      b.onclick = () => loadProblem(p.id);
      box.appendChild(b);
    }
  }
}

// ---------------- 我的提交 ----------------
function renderSubList(list) {
  const box = $('sub-list');
  if (!list || !list.length) { box.innerHTML = '<span class="muted">还没有提交记录</span>'; return; }
  box.innerHTML = '';
  for (const s of list.slice(0, 20)) {
    const btn = document.createElement('button');
    btn.className = 'sub-row';
    const cls = s.status === 'pass' ? 'st-pass' : s.status === 'fail' ? 'st-fail' : 'st-error';
    const label = s.status === 'pass' ? '通过' : s.status === 'fail' ? '未过' : '错误';
    const t = new Date(s.created_at * 1000);
    const hh = String(t.getHours()).padStart(2, '0');
    const mm = String(t.getMinutes()).padStart(2, '0');
    btn.innerHTML = `<div class="top"><span>${esc(s.problem)}</span><span class="${cls}">${label}</span></div>
      <div class="meta">${s.summary ? s.summary.passed + '/' + s.summary.total + ' 项' : ''} ${hh}:${mm}</div>`;
    btn.onclick = () => openSubmission(s);
    box.appendChild(btn);
  }
}

async function refreshSubmissions() {
  try { renderSubList(await api('/api/submissions')); } catch (e) {}
}

async function openSubmission(s) {
  try {
    const full = await api('/api/submissions/' + s.id);
    await loadProblem(full.problem);
    setCode(full.code || detail.initial_code);
    if (full.result) showResult(full.result);
    $('status-msg').textContent = '已载入提交 #' + s.id;
  } catch (e) {
    $('status-msg').textContent = '加载提交失败: ' + e.message;
  }
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

let editorSetupDone = false;
function setupEditor() {
  const el = $('editor');
  const fb = $('editor-fallback');
  if (!(window.monaco && window.monaco.editor)) {
    // Monaco 尚未就绪：先退回 textarea，monaco-ready 到来后再升级为 Monaco
    editorReady = false;
    el.classList.add('hidden');
    fb.classList.remove('hidden');
    if (detail) fb.value = getSaved(detail.id) || detail.initial_code;
    return;
  }
  if (editorSetupDone) return;   // monaco-ready 与 DOMContentLoaded 可能各触发一次
  editorSetupDone = true;
  const carry = (!fb.classList.contains('hidden') && fb.value) ? fb.value : '';
  editor = window.monaco.editor.create(el, {
    value: carry, language: 'verilog', theme: 'vs-dark',
    automaticLayout: true, minimap: {enabled: false},
    fontSize: 14, scrollBeyondLastLine: false,
  });
  editorReady = true;
  fb.classList.add('hidden');
  el.classList.remove('hidden');
  // 与 fallback 一致：编辑即存草稿，防止刷新/误操作丢代码
  editor.onDidChangeModelContent(() => { if (currentId) saveCode(currentId, editor.getValue()); });
  if (!carry && detail) setCode(getSaved(detail.id) || detail.initial_code);
}
window.addEventListener('monaco-ready', () => setupEditor());
window.addEventListener('DOMContentLoaded', () => {
  if (window.monaco && window.monaco.editor) setupEditor();
  else setTimeout(setupEditor, 4000);
});

function getLocalSaved(id) {
  // localStorage 兜底草稿：空历史/纯空白返回 null（用初始模板）；
  // 只写了实现体（如 assign out = ~in;）-> 用模板模块头补齐再恢复。
  try {
    const v = localStorage.getItem('n2t-code-' + id);
    if (!v || !v.trim()) return null;
    if (/\bmodule\s+n2t_/.test(v)) return v;
    if (detail && detail.initial_code) {
      const m = detail.initial_code.match(/\bmodule\b[\s\S]*?\)\s*;/);
      if (m) return m[0] + '\n    ' + v.trim() + '\nendmodule\n';
    }
    return v;
  } catch (e) { return null; }
}

function getSaved(id) {
  // 优先后端草稿（draftCache 在 loadProblem 时填充），其次 localStorage 兜底。
  if (draftCache.hasOwnProperty(id)) return draftCache[id] || null;
  return getLocalSaved(id);
}

function scheduleDraftSync(id, code) {
  clearTimeout(draftTimers[id]);
  draftTimers[id] = setTimeout(() => {
    api('/api/drafts/' + id, {method: 'PUT', body: JSON.stringify({code})}).catch(() => {});
  }, 500);
}

function saveCode(id, code) {
  try {
    let v = code;
    if (v && v.trim() && !/\bmodule\s+n2t_/.test(v) && detail && detail.initial_code) {
      const m = detail.initial_code.match(/\bmodule\b[\s\S]*?\)\s*;/);
      if (m) v = m[0] + '\n    ' + v.trim() + '\nendmodule\n';
    }
    localStorage.setItem('n2t-code-' + id, v);
    draftCache[id] = v;
    scheduleDraftSync(id, v);
  } catch (e) {}
}

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
    // WaveDrom 3.x 暴露 RenderWaveForm（大写 R），2.x 为 renderWaveForm
    const wf = window.WaveDrom && (window.WaveDrom.RenderWaveForm || window.WaveDrom.renderWaveForm);
    if (wf) {
      wf.call(window.WaveDrom, 0, waveJson, 'wave');
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
  detail = await api('/api/problems/' + id);
  // 拉后端草稿；没有则把旧 localStorage 草稿迁移到后端（跨浏览器可见）
  try {
    const d = await api('/api/drafts/' + id);
    draftCache[id] = d.code || null;
  } catch (e) {
    draftCache[id] = null;
  }
  if (!draftCache[id]) {
    const local = getLocalSaved(id);
    if (local) {
      draftCache[id] = local;
      scheduleDraftSync(id, local);
    }
  }
  const saved = getSaved(id);
  const last = detail.last_submission || null;
  // 默认显示最近一次提交的代码（草稿优先于最近提交，再回退到初始模板）
  setCode(saved != null ? saved : (last && last.code ? last.code : detail.initial_code));
  $('p-title').textContent = detail.title;
  $('p-badge').textContent = 'Project ' + detail.project;
  $('p-module').textContent = detail.module;
  $('p-desc').textContent = detail.description || '（无说明）';
  renderPorts();
  renderList();
  $('result').classList.add('hidden');
  if (last) {
    const st = last.status === 'pass' ? '通过' : last.status === 'fail' ? '未通过' : '错误';
    const t = new Date(last.created_at * 1000);
    const pad = (n) => String(n).padStart(2, '0');
    const label = '最近提交：' + st + '（' +
      (t.getMonth() + 1) + '-' + pad(t.getDate()) + ' ' + pad(t.getHours()) + ':' + pad(t.getMinutes()) + '）';
    $('status-msg').textContent = label;
  } else {
    $('status-msg').textContent = '';
  }
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
      method: 'POST', body: JSON.stringify({id: currentId, code}),
    });
    showResult(r);
    status.textContent = '完成';
    if (r.status === 'pass') {
      markSolved(currentId);
      renderList();
    }
    refreshSubmissions();
  } catch (e) {
    status.textContent = '请求失败: ' + e.message;
  } finally {
    btn.disabled = false;
  }
}

// ---------------- 初始化 ----------------
async function initApp() {
  try {
    problems = await api('/api/problems');
  } catch (e) {
    $('p-title').textContent = '无法连接后端服务';
    return;
  }
  try {
    solvedSet = new Set((await api('/api/solved')).solved);
  } catch (e) { solvedSet = new Set(); }
  const first = localStorage.getItem('n2t-last') || problems[0].id;
  await loadProblem(first);
  renderSubList([]);
  refreshSubmissions();
}

async function init() {
  $('btn-submit').onclick = submit;
  $('btn-tb').onclick = showTb;
  $('btn-reset').onclick = () => {
    if (detail && confirm('恢复初始模板？当前代码将被覆盖。')) {
      setCode(detail.initial_code);
      localStorage.removeItem('n2t-code-' + detail.id);
    }
  };
  $('btn-login').onclick = () => doAuth('login');
  $('btn-register').onclick = () => doAuth('register');
  $('btn-logout').onclick = logout;
  $('btn-refresh-sub').onclick = refreshSubmissions;
  $('modal-close').onclick = () => $('modal').classList.add('hidden');
  $('modal').onclick = (e) => { if (e.target === $('modal')) $('modal').classList.add('hidden'); };
  $('editor-fallback').addEventListener('input', () => { if (currentId) saveCode(currentId, $('editor-fallback').value); });
  $('login-pass').addEventListener('keydown', (e) => { if (e.key === 'Enter') doAuth('login'); });

  // 恢复登录态
  authUser = null;
  const savedUser = localStorage.getItem(USER_KEY);
  const savedToken = getToken();
  if (savedToken) {
    try {
      const me = await api('/api/me');
      authUser = me.username;
      localStorage.setItem(USER_KEY, authUser);
    } catch (e) { /* token 失效，走登录页 */ }
  } else if (savedUser) {
    localStorage.removeItem(USER_KEY);
  }
  if (authUser) {
    showApp();
    await initApp();
  } else {
    showLogin();
  }
}
window.addEventListener('DOMContentLoaded', init);
