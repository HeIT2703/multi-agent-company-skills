#!/usr/bin/env bash
# update-state.sh — cập nhật .context/project/state.yaml CHUẨN XÁC (không để LLM sửa text).
# Không phụ thuộc thư viện ngoài (chỉ cần python3). Schema state.yaml cố định.
# Dùng:
#   bash update-state.sh <state.yaml> --stage 07-development --status in-progress
#   bash update-state.sh <state.yaml> --agents backend-engineer,frontend-engineer
#   bash update-state.sh <state.yaml> --gate-passed 06-planning-breakdown
#   bash update-state.sh <state.yaml> --inc-loop          # tăng remediation_loops
#   bash update-state.sh <state.yaml> --escalate true
set -euo pipefail

FILE="${1:?Thiếu đường dẫn state.yaml}"; shift
[[ -f "$FILE" ]] || { echo "ERROR: không thấy $FILE" >&2; exit 1; }

python3 - "$FILE" "$@" <<'PY'
import sys, datetime

path = sys.argv[1]
args = sys.argv[2:]

keys = ["current_phase","current_stage","status","active_agents","last_gate_passed",
        "remediation_loops","escalated","updated"]
data = {k: None for k in keys}
extra = {}

with open(path, encoding="utf-8") as f:
    for line in f:
        s = line.strip()
        if not s or s.startswith("#") or ":" not in line:
            continue
        k, _, v = line.partition(":")
        k, v = k.strip(), v.strip()
        (data if k in data else extra)[k] = v

i = 0
while i < len(args):
    a = args[i]
    if a == "--stage":         data["current_stage"] = args[i+1]; i += 2
    elif a == "--phase":       data["current_phase"] = args[i+1]; i += 2
    elif a == "--status":      data["status"] = args[i+1]; i += 2
    elif a == "--gate-passed": data["last_gate_passed"] = args[i+1]; i += 2
    elif a == "--agents":
        lst = [x.strip() for x in args[i+1].split(",") if x.strip()]
        data["active_agents"] = "[" + ", ".join(lst) + "]"; i += 2
    elif a == "--inc-loop":
        data["remediation_loops"] = str(int(data.get("remediation_loops") or "0") + 1); i += 1
    elif a == "--escalate":
        data["escalated"] = "true" if args[i+1].lower() == "true" else "false"; i += 2
    else:
        sys.exit(f"Tham số lạ: {a}")

if data["active_agents"] is None:     data["active_agents"] = "[]"
if data["remediation_loops"] is None: data["remediation_loops"] = "0"
if data["escalated"] is None:         data["escalated"] = "false"
data["updated"] = datetime.date.today().isoformat()

out = [f"{k}: {data[k] if data[k] is not None else ''}" for k in keys if data[k] is not None]
out += [f"{k}: {v}" for k, v in extra.items()]
with open(path, "w", encoding="utf-8") as f:
    f.write("\n".join(out) + "\n")
print(f"OK: cập nhật {path}")
PY
