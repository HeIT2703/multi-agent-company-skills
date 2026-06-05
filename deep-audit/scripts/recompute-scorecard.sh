#!/usr/bin/env bash
# recompute-scorecard.sh — tính lại composite + đếm open severity + set cổng gate.
# Không phụ thuộc thư viện ngoài (chỉ python3). KHÔNG tính tay.
# Dùng: bash recompute-scorecard.sh <audit-run-dir>
#   block_on tùy chỉnh: BLOCK_ON="critical,high" bash recompute-scorecard.sh <dir>
set -euo pipefail

DIR="${1:?Thiếu audit-run-dir}"
SC="$DIR/scorecard.yaml"; FD="$DIR/findings.yaml"
[[ -f "$SC" ]] || { echo "ERROR: không thấy $SC" >&2; exit 1; }

python3 - "$SC" "$FD" "${BLOCK_ON:-critical,high}" <<'PY'
import sys, os, re
sc_path, fd_path, block_on = sys.argv[1], sys.argv[2], sys.argv[3]
block = {x.strip() for x in block_on.split(",") if x.strip()}

def strip_comment(s):
    # bỏ inline comment '# ...' nằm ngoài chuỗi trích dẫn
    out, q = [], None
    for ch in s:
        if q:
            out.append(ch)
            if ch == q: q = None
        elif ch in ('"', "'"):
            q = ch; out.append(ch)
        elif ch == "#":
            break
        else:
            out.append(ch)
    return "".join(out).strip()

# ---- parse scorecard.yaml (schema cố định, indent 2 spaces) ----
parts, threshold, audit_run, section, cur = {}, None, None, None, None
for raw in open(sc_path, encoding="utf-8"):
    if not raw.strip() or raw.lstrip().startswith("#"):
        continue
    indent = len(raw) - len(raw.lstrip(" "))
    k, _, val = raw.strip().partition(":")
    k, val = k.strip(), strip_comment(val)
    if indent == 0:
        section = k
        if k == "audit_run": audit_run = val
        elif k == "threshold": threshold = float(val)
        cur = None
    elif indent == 2 and section == "parts":
        cur = k; parts[cur] = {}
    elif indent == 4 and section == "parts" and cur:
        parts[cur][k] = float(val)

composite = round(sum(p.get("score", 0.0) * p.get("weight", 0.0) for p in parts.values()), 2)

# ---- parse findings.yaml ----
open_crit = open_high = blocked_open = 0
if os.path.exists(fd_path):
    recs, c = [], None
    for raw in open(fd_path, encoding="utf-8"):
        s = raw.strip()
        if not s or s.startswith("#"):
            continue
        if s.startswith("- "):
            c = {}; recs.append(c); s = s[2:].strip()
        if c is not None and ":" in s:
            kk, _, vv = s.partition(":")
            c[kk.strip()] = strip_comment(vv)
    for r in recs:
        if r.get("status") == "open":
            sv = r.get("severity")
            if sv == "critical": open_crit += 1
            if sv == "high":     open_high += 1
            if sv in block:      blocked_open += 1

gate = "PASS" if (threshold is not None and composite >= threshold and blocked_open == 0) else "BLOCKED"

# ---- write scorecard.yaml lại ----
out = [f"audit_run: {audit_run}", "parts:"]
for name, pv in parts.items():
    out += [f"  {name}:",
            f"    score: {pv.get('score', 0.0)}",
            f"    weight: {pv.get('weight', 0.0)}"]
out += [f"composite: {composite}",
        f"threshold: {threshold}",
        f"open_critical: {open_crit}",
        f"open_high: {open_high}",
        f"gate: {gate}"]
open(sc_path, "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"composite={composite} threshold={threshold} open_critical={open_crit} "
      f"open_high={open_high} gate={gate}")
PY
