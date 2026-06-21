(function () {
  'use strict';

  // ── DOM helpers ────────────────────────────────────────────────────────────

  function el(tag, attrs) {
    var node = document.createElement(tag);
    Object.keys(attrs || {}).forEach(function (k) {
      if (k === 'disabled') { node.disabled = !!attrs[k]; }
      else if (k === 'style') { node.style.cssText = attrs[k]; }
      else { node.setAttribute(k, attrs[k]); }
    });
    return node;
  }

  function esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  // ── Modal shell ────────────────────────────────────────────────────────────

  function buildModal(title) {
    var backdrop = el('div', {
      style: 'position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:10000;display:flex;align-items:center;justify-content:center'
    });

    var dialog = el('div', {
      style: 'background:#fff;border-radius:4px;width:560px;max-width:95vw;box-shadow:0 6px 30px rgba(0,0,0,.35);display:flex;flex-direction:column'
    });

    var header = el('div', { style: 'padding:14px 20px;background:#242424;border-radius:4px 4px 0 0;flex-shrink:0' });
    header.innerHTML = '<h3 style="margin:0;color:#fff;font-size:15px;font-weight:600">' + esc(title) + '</h3>';

    var body = el('div', { style: 'padding:20px;min-height:90px' });

    var footer = el('div', {
      style: 'padding:12px 20px;border-top:1px solid #e0e0e0;display:flex;justify-content:flex-end;gap:8px;flex-shrink:0'
    });

    var cancelBtn = el('button', {
      style: 'padding:7px 16px;border:1px solid #ccc;background:#f5f5f5;border-radius:3px;cursor:pointer;font-size:13px'
    });
    cancelBtn.textContent = 'Cancel';
    cancelBtn.onclick = function () { document.body.removeChild(backdrop); };

    var submitBtn = el('button', {
      disabled: true,
      style: 'padding:7px 16px;background:#242424;color:#fff;border:none;border-radius:3px;font-size:13px;cursor:not-allowed;opacity:.45'
    });
    submitBtn.textContent = 'Download';

    footer.append(cancelBtn, submitBtn);
    dialog.append(header, body, footer);
    backdrop.append(dialog);
    document.body.append(backdrop);

    backdrop.addEventListener('click', function (e) {
      if (e.target === backdrop) document.body.removeChild(backdrop);
    });

    return { backdrop: backdrop, body: body, submitBtn: submitBtn };
  }

  // ── Content states ─────────────────────────────────────────────────────────

  function showSpinner(body) {
    body.innerHTML =
      '<div style="display:flex;align-items:center;gap:10px;color:#666;padding:16px 0">' +
      '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">' +
      '<path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>' +
      '</svg>Probing schedule endpoints…</div>';
  }

  function showError(body, msg) {
    body.innerHTML =
      '<p style="color:#932419;margin:12px 0"><strong>Error:</strong> ' + esc(msg) + '</p>';
  }

  function showFormats(body, submitBtn, formats, actionUrl) {
    if (!formats || formats.length === 0) {
      showError(body, 'No schedule endpoints could be reached for this URL.');
      return;
    }

    var intro = el('div', { style: 'font-size:13px;color:#555;margin-bottom:14px' });
    intro.textContent = 'Select the schedule format to import:';
    body.innerHTML = '';
    body.append(intro);

    formats.forEach(function (fmt) {
      var avail = fmt.available;

      var row = el('label', {
        style: [
          'display:flex;align-items:flex-start;gap:10px;padding:10px 12px;margin-bottom:8px',
          'border:1px solid ' + (avail ? '#c3dfc3' : '#e0c8c8'),
          'border-radius:4px;background:' + (avail ? '#f6fdf6' : '#fdf6f6'),
          'cursor:' + (avail ? 'pointer' : 'default') + ';opacity:' + (avail ? '1' : '0.55')
        ].join(';')
      });

      var radio = el('input', { type: 'radio', name: 'schedule_format', value: fmt.url });
      radio.disabled = !avail;
      radio.style.marginTop = '3px';
      radio.style.flexShrink = '0';

      var badge = el('span', {
        style: 'font-size:11px;font-weight:700;margin-left:6px;' +
               (avail ? 'color:#1a7a1a' : 'color:#932419')
      });
      badge.textContent = avail ? '✓ available' : '✗ not found';

      var titleLine = el('div', { style: 'font-weight:600;font-size:13px' });
      titleLine.textContent = fmt.label;
      titleLine.append(badge);

      var info = el('div', { style: 'flex:1;min-width:0' });
      info.append(titleLine);

      if (fmt.upstream) {
        var upLine = el('div', { style: 'font-size:11px;color:#444;margin-top:3px' });
        upLine.textContent = 'Upstream: ' + fmt.upstream;
        info.append(upLine);
      }

      var urlLine = el('div', { style: 'font-size:11px;color:#999;margin-top:2px;word-break:break-all' });
      urlLine.textContent = fmt.url;
      info.append(urlLine);

      row.append(radio, info);
      body.append(row);
    });

    // Pre-select first available
    var firstAvail = body.querySelector('input[name="schedule_format"]:not(:disabled)');
    if (firstAvail) {
      firstAvail.checked = true;
      unlockSubmit(submitBtn);
    }

    body.addEventListener('change', function () { unlockSubmit(submitBtn); });

    submitBtn.onclick = function () {
      var sel = body.querySelector('input[name="schedule_format"]:checked');
      if (!sel) return;
      postTo(actionUrl, { schedule_url: sel.value });
    };
  }

  // ── Utilities ──────────────────────────────────────────────────────────────

  function unlockSubmit(btn) {
    btn.disabled = false;
    btn.style.opacity = '1';
    btn.style.cursor = 'pointer';
  }

  function postTo(action, fields) {
    var form = el('form', { method: 'post', action: action });
    var meta = document.querySelector('meta[name="csrf-token"]');
    if (meta) form.append(el('input', { type: 'hidden', name: 'authenticity_token', value: meta.getAttribute('content') }));
    Object.keys(fields).forEach(function (k) {
      form.append(el('input', { type: 'hidden', name: k, value: fields[k] }));
    });
    document.body.append(form);
    form.submit();
  }

  // ── Schedule status indicator ──────────────────────────────────────────────

  var STATE_LABELS = {
    not_present: 'not present',
    new:         'queued',
    downloading: 'downloading…',
    downloaded:  'downloaded ✓'
  };

  var STATE_COLORS = {
    not_present: '#999',
    new:         '#b07800',
    downloading: '#38678b',
    downloaded:  '#1a7a1a'
  };

  function spinnerSvg(color) {
    return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="' + color + '" stroke-width="2.5" style="animation:sched-spin 1s linear infinite;flex-shrink:0;vertical-align:middle">' +
      '<path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>' +
      '</svg>';
  }

  function injectSpinnerStyles() {
    if (document.getElementById('sched-spin-style')) return;
    var s = document.createElement('style');
    s.id = 'sched-spin-style';
    s.textContent = '@keyframes sched-spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}';
    document.head.append(s);
  }

  function renderStatusBadge(indicator, state) {
    var color = STATE_COLORS[state] || '#666';
    var label = STATE_LABELS[state] || state;
    var active = state === 'downloading' || state === 'new';

    indicator.style.cssText =
      'display:inline-flex;align-items:center;gap:6px;padding:5px 10px;' +
      'border:1px solid ' + color + ';border-radius:4px;color:' + color + ';' +
      'font-size:12px;font-weight:600;background:' + color + '18';

    indicator.innerHTML = (active ? spinnerSvg(color) : '') + esc(label);
    indicator.dataset.state = state;
  }

  function initStatusIndicator(indicator) {
    injectSpinnerStyles();
    var pollUrl = indicator.dataset.pollUrl;
    var state   = indicator.dataset.state;

    renderStatusBadge(indicator, state);

    if (state !== 'downloading' && state !== 'new') return;

    var timer = setInterval(function () {
      fetch(pollUrl, { headers: { Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest' } })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          renderStatusBadge(indicator, data.state);
          if (data.state !== 'downloading' && data.state !== 'new') {
            clearInterval(timer);
            if (data.state === 'downloaded') {
              // brief pause so the ✓ is visible, then reload to show the XML preview
              setTimeout(function () { window.location.reload(); }, 1200);
            }
          }
        })
        .catch(function () { clearInterval(timer); });
    }, 2500);
  }

  // ── Bootstrap ─────────────────────────────────────────────────────────────

  document.addEventListener('DOMContentLoaded', function () {
    // Status indicator (auto-polling when downloading/queued)
    var indicator = document.querySelector('[data-schedule-status-indicator]');
    if (indicator) initStatusIndicator(indicator);

    document.addEventListener('click', function (e) {
      var trigger = e.target.closest('[data-schedule-dialog]');
      if (!trigger) return;
      e.preventDefault();

      var probeUrl  = trigger.dataset.probeUrl;
      var actionUrl = trigger.dataset.actionUrl;
      var acronym   = trigger.dataset.acronym || '';

      var modal = buildModal('Download Schedule — ' + acronym);
      showSpinner(modal.body);

      fetch(probeUrl, {
        headers: { Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest' }
      })
        .then(function (r) {
          if (!r.ok) throw new Error('Probe failed (' + r.status + ' ' + r.statusText + ')');
          return r.json();
        })
        .then(function (data) { showFormats(modal.body, modal.submitBtn, data.formats, actionUrl); })
        .catch(function (err) { showError(modal.body, err.message); });
    });
  });
})();
