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
let expectedWave = null;            // 参考实现波形（HDLBits 对比用）
let actualWave = null;              // 当前提交的实际波形
let highlightStep = null;           // 失败详情里点击的 step（聚焦波形）

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
  const r = await fetch(path, Object.assign({}, opts, {headers, cache: 'no-store'}));
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

async function refreshProblems() {
  const btn = $('btn-refresh-list');
  btn.disabled = true;
  btn.textContent = '…';
  try {
    problems = await api('/api/problems');
    solvedSet = new Set((await api('/api/solved')).solved);
    renderList();
    btn.textContent = '✓';
  } catch (e) {
    btn.textContent = '!';
  } finally {
    setTimeout(() => { btn.disabled = false; btn.textContent = '刷新'; }, 800);
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

function renderWave(waveJson, boxId, index) {
  index = index || 0;
  const box = $(boxId);
  box.innerHTML = '';
  if (!waveJson || !waveJson.signal || !waveJson.signal.length) return;
  const holder = document.createElement('div');
  holder.id = boxId + index;
  box.appendChild(holder);
  try {
    // WaveDrom 3.x 暴露 RenderWaveForm（大写 R），2.x 为 renderWaveForm
    const wf = window.WaveDrom && (window.WaveDrom.RenderWaveForm || window.WaveDrom.renderWaveForm);
    if (wf) {
      wf.call(window.WaveDrom, index, waveJson, boxId);
    } else {
      holder.textContent = JSON.stringify(waveJson);
    }
  } catch (e) {
    holder.textContent = JSON.stringify(waveJson);
  }
}

function sigMap(arr) {
  const m = {};
  for (const s of (arr || [])) m[s.name] = s;
  return m;
}

function expandWave(sig, len) {
  const vals = [];
  let prev = 'x';
  let di = 0;
  for (const ch of (sig.wave || '')) {
    let v;
    if (ch === '.') v = prev;
    else if (ch === '=') { v = sig.data && sig.data[di] != null ? sig.data[di] : '='; di++; }
    else v = ch;
    vals.push(v);
    if (ch !== '.') prev = v;
  }
  while (vals.length < len) vals.push(prev);
  return vals;
}

const WAVE_BLUE = '#1a4fd1';
const WAVE_CELL = 28;
const WAVE_LABEL = 150;
const WAVE_ROWH = 30;
const WAVE_HEADH = 14;
const WAVE_AXISH = 16;

function drawSignalWave(vals, x0, y, cell, rowh) {
  let s = '';
  const top = y + 3;
  const bottom = y + rowh - 5;
  const mid = y + rowh / 2;
  const isBus = vals.some(v => v !== '0' && v !== '1' && v !== 'x' && v !== 'z');
  if (isBus) {
    let i = 0;
    while (i < vals.length) {
      let j = i;
      while (j + 1 < vals.length && vals[j + 1] === vals[i]) j++;
      const x = x0 + i * cell;
      const w = (j - i + 1) * cell;
      const v = vals[i];
      if (v === 'x' || v === 'z') {
        s += `<rect x="${x + 0.5}" y="${top}" width="${w - 1}" height="${bottom - top}" fill="#ddd" stroke="#000"/>`;
      } else {
        s += `<rect x="${x + 0.5}" y="${top}" width="${w - 1}" height="${bottom - top}" fill="#fff" stroke="#000"/>`;
        if (w >= 18) {
          s += `<text x="${x + w / 2}" y="${mid + 3}" font-size="8" text-anchor="middle">${esc(String(v))}</text>`;
        }
      }
      i = j + 1;
    }
  } else {
    let prev = null;
    for (let i = 0; i < vals.length; i++) {
      const v = vals[i];
      let level;
      if (v === '1') level = top;
      else if (v === '0') level = bottom;
      else level = mid;
      if (prev !== null && level !== prev) {
        s += `<line x1="${x0 + i * cell}" y1="${prev}" x2="${x0 + i * cell}" y2="${level}" stroke="#000"/>`;
      }
      s += `<line x1="${x0 + i * cell}" y1="${level}" x2="${x0 + (i + 1) * cell}" y2="${level}" stroke="#000"/>`;
      if (v === 'x' || v === 'z') {
        s += `<line x1="${x0 + i * cell}" y1="${top}" x2="${x0 + (i + 1) * cell}" y2="${bottom}" stroke="#999" stroke-dasharray="2,2"/>`;
      }
      prev = level;
    }
  }
  return s;
}

function drawMismatchRow(a, e, x0, y, cell, rowh) {
  let s = '';
  for (let i = 0; i < Math.max(a.length, e.length); i++) {
    if (a[i] !== e[i]) {
      s += `<rect x="${x0 + i * cell + 0.5}" y="${y + 3}" width="${cell - 1}" height="${rowh - 6}" fill="#f44336"/>`;
    }
  }
  return s;
}

function renderHDLBits(actual, expected, focusStep) {
  const box = $('wave-compare');
  box.innerHTML = '';
  if (!actual || !expected || !actual.signal || !expected.signal) {
    box.textContent = '波形数据缺失';
    return;
  }
  const normName = (n) => (n === 'rst' ? 'arst' : n);
  const am = {};
  const em = {};
  for (const s of actual.signal) am[normName(s.name)] = s;
  for (const s of expected.signal) em[normName(s.name)] = s;
  const ports = detail.ports || [];
  const inputs = [];
  const outputs = [];
  for (const p of ports) {
    if (!am[p.name] || !em[p.name]) continue;
    if (p.dir === 'out') outputs.push(p.name);
    else inputs.push(p.name);
  }
  for (const n of Object.keys(am)) {
    if (em[n] && !inputs.includes(n) && !outputs.includes(n)) outputs.push(n);
  }

  let len = 1;
  for (const n of inputs.concat(outputs)) {
    len = Math.max(len, am[n].wave ? am[n].wave.length : 0, em[n].wave ? em[n].wave.length : 0);
  }

  let start = 0;
  let end = len;
  let localFocus = -1;
  if (focusStep != null && focusStep >= 1) {
    const idx = Math.max(0, focusStep - 1);
    start = Math.max(0, idx - 3);
    end = Math.min(len, idx + 4);
    localFocus = idx - start;
  }
  const viewLen = end - start;
  const slice = (vals) => vals.slice(start, end);

  const rowCount = WAVE_HEADH + inputs.length * WAVE_ROWH +
    WAVE_HEADH + outputs.length * WAVE_ROWH +
    WAVE_HEADH + outputs.length * WAVE_ROWH +
    WAVE_HEADH + outputs.length * WAVE_ROWH;
  const W = WAVE_LABEL + viewLen * WAVE_CELL + 24;
  const H = rowCount + WAVE_AXISH + 8;

  let s = `<svg width="${W}" height="${H}" xmlns="http://www.w3.org/2000/svg" style="background:#fff;display:block">`;
  for (let i = 1; i <= viewLen; i++) {
    s += `<line x1="${WAVE_LABEL + i * WAVE_CELL}" y1="0" x2="${WAVE_LABEL + i * WAVE_CELL}" y2="${H - WAVE_AXISH}" stroke="#e8e8e8" stroke-dasharray="2,2"/>`;
  }
  if (localFocus >= 0) {
    s += `<rect x="${WAVE_LABEL + localFocus * WAVE_CELL}" y="0" width="${WAVE_CELL}" height="${H - WAVE_AXISH}" fill="#f44336" opacity="0.18"/>`;
  }

  let y = 0;
  const addGroup = (label) => {
    s += `<text x="12" y="${y + 9}" font-size="11" font-weight="bold" fill="${WAVE_BLUE}">${esc(label)}</text>`;
    y += WAVE_HEADH;
  };
  const addRow = (label, vals) => {
    s += `<text x="12" y="${y + 13}" font-size="10" fill="${WAVE_BLUE}">${esc(label)}</text>`;
    s += drawSignalWave(vals, WAVE_LABEL, y, WAVE_CELL, WAVE_ROWH);
    y += WAVE_ROWH;
  };

  addGroup('inputs');
  for (const n of inputs) {
    if (!am[n] || !em[n]) continue;
    addRow(n, slice(expandWave(am[n], len)));
  }

  addGroup('Yours');
  for (const n of outputs) {
    if (!am[n] || !em[n]) continue;
    addRow(n + ' (Yours)', slice(expandWave(am[n], len)));
  }

  addGroup('Ref');
  for (const n of outputs) {
    if (!am[n] || !em[n]) continue;
    addRow(n + ' (Ref)', slice(expandWave(em[n], len)));
  }

  addGroup('Mismatch');
  for (const n of outputs) {
    if (!am[n] || !em[n]) continue;
    s += `<text x="12" y="${y + 13}" font-size="10" fill="${WAVE_BLUE}">Mismatch: ${esc(n)}</text>`;
    s += drawMismatchRow(slice(expandWave(am[n], len)), slice(expandWave(em[n], len)),
                         WAVE_LABEL, y, WAVE_CELL, WAVE_ROWH);
    y += WAVE_ROWH;
  }

  for (let i = 0; i <= viewLen; i += 1) {
    s += `<text x="${WAVE_LABEL + i * WAVE_CELL}" y="${H - 4}" font-size="8" fill="#999" text-anchor="middle">${i + start + 1}</text>`;
  }
  s += '</svg>';
  if (focusStep != null) {
    box.innerHTML = '<div style="margin-bottom:6px"><button class="mini" onclick="clearWaveFocus()">显示完整波形</button></div>' + s;
  } else {
    box.innerHTML = s;
  }
}

function clearWaveFocus() {
  highlightStep = null;
  if (expectedWave && actualWave) renderHDLBits(actualWave, expectedWave, null);
}

function focusFailStep(step) {
  highlightStep = (highlightStep === step) ? null : step;
  if (expectedWave && actualWave) renderHDLBits(actualWave, expectedWave, highlightStep);
  const wb = $('wave-box');
  if (wb) wb.scrollIntoView({behavior: 'smooth', block: 'nearest'});
}

async function loadExpectedWave(waveArg) {
  const box = $('wave-compare');
  box.innerHTML = '<span class="muted">正在生成期望波形…</span>';
  expectedWave = null;
  actualWave = waveArg;
  if (!currentId) return;
  try {
    const r = await api('/api/problems/' + currentId + '/expected_wave');
    if (r.wave && r.wave.signal && r.wave.signal.length) {
      expectedWave = r.wave;
      renderHDLBits(actualWave, expectedWave, highlightStep);
    } else {
      box.textContent = '期望波形生成失败';
    }
  } catch (e) {
    box.textContent = '期望波形生成失败: ' + e.message;
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
  // 失败详情：step / 信号 / 期望 / 实际
  const fd = $('fail-detail');
  const ft = $('fail-table');
  if (r.fails && r.fails.length) {
    ft.innerHTML = '<tr><th>step</th><th>信号</th><th>期望</th><th>实际</th><th>波形</th></tr>';
    const shown = r.fails.slice(0, 100);
    for (const f of shown) {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${f.step}</td><td><code>${esc(f.signal)}</code></td>` +
        `<td class="ok">${esc(f.exp)}</td><td class="bad">${esc(f.got)}</td>` +
        `<td><button class="mini" onclick="focusFailStep(${f.step})">查看</button></td>`;
      ft.appendChild(tr);
    }
    if (r.fails.length > shown.length) {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td colspan="5" class="muted">仅显示前 ${shown.length} 条失败（共 ${r.fails.length} 条）</td>`;
      ft.appendChild(tr);
    }
    fd.classList.remove('hidden');
  } else {
    fd.classList.add('hidden');
  }
  const logParts = [];
  if (r.compile && !r.compile.ok) logParts.push('--- 编译错误 ---\n' + r.compile.log);
  if (r.log) logParts.push('--- 仿真输出 ---\n' + r.log);
  $('res-log').textContent = logParts.join('\n\n') || '(无输出)';
  const wb = $('wave-box');
  if (r.wave && r.wave.signal && r.wave.signal.length) {
    wb.classList.remove('hidden');
    loadExpectedWave(r.wave);
    $('wave-internal').classList.add('hidden');
    $('wave-signals').value = '';
    $('wave-msg').textContent = '';
  } else {
    wb.classList.add('hidden');
  }
}

// ---------------- 内部信号波形 ----------------
async function showInternalWave() {
  if (!currentId) return;
  const input = $('wave-signals').value;
  if (!input.trim()) { $('wave-msg').textContent = '请先填写信号路径'; return; }
  const msg = $('wave-msg');
  msg.textContent = '生成中…';
  try {
    const r = await api('/api/wave', {
      method: 'POST',
      body: JSON.stringify({id: currentId, code: getCode(), signals: input}),
    });
    const box = $('wave-internal');
    if (r.signal && r.signal.length) {
      box.classList.remove('hidden');
      renderWave(r, 'wave-internal', 1);
      msg.textContent = '';
    } else {
      box.classList.add('hidden');
      msg.textContent = '没有可显示的变化';
    }
  } catch (e) {
    msg.textContent = e.message;
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
  $('btn-refresh-list').onclick = refreshProblems;
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
  $('btn-wave-signals').onclick = showInternalWave;
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
