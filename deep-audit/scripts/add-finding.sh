#!/usr/bin/env bash
# add-finding.sh — thêm 1 finding vào findings.yaml (append-only, tự cấp ID F-####).
# Không phụ thuộc thư viện ngoài (chỉ python3).
# Dùng: bash add-finding.sh <findings.yaml> <A|B|C> <severity> "<title>" [owner] [recommendation] [evidence]
set -euo pipefail

FILE="${1:?Thiếu findings.yaml}"; PART="${2:?part A|B|C}"; SEV="${3:?severity}"; TITLE="${4:?title}"
OWNER="${5:-null}"; REC="${6:-null}"; EV="${7:-null}"
[[ -f "$FILE" ]] || printf 'findings:\n' > "$FILE"

python3 - "$FILE" "$PART" "$SEV" "$TITLE" "$OWNER" "$REC" "$EV" <<'PY'
import sys, re
path, part, sev, title, owner, rec, ev = sys.argv[1:8]
text = open(path, encoding="utf-8").read()
ids = [int(m) for m in re.findall(r'id:\s*F-(\d{4})', text)]
fid = f"F-{(max(ids)+1 if ids else 1):04d}"

def q(s):  return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'
def v(s):  return "null" if s == "null" else q(s)

block = (
    f"  - id: {fid}\n"
    f"    part: {part}\n"
    f"    severity: {sev}\n"
    f"    title: {q(title)}\n"
    f"    evidence: {v(ev)}\n"
    f"    recommendation: {v(rec)}\n"
    f"    status: open\n"
    f"    owner: {v(owner)}\n"
    f"    task: null\n"
    f"    adr: null\n"
)
if not text.strip():
    text = "findings:\n"
if not text.endswith("\n"):
    text += "\n"
open(path, "w", encoding="utf-8").write(text + block)
print(fid)
PY
