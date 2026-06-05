#!/usr/bin/env bash
# init-context.sh — scaffold SSOT .context/ vào một repo.
# Dùng: bash init-context.sh <repo-dir> <project-name> <size> <type>
#   size: super-large | small | personal
#   type: application | web | saas | tool
set -euo pipefail

REPO_DIR="${1:-.}"
PROJECT_NAME="${2:-Untitled Project}"
SIZE="${3:-small}"
TYPE="${4:-saas}"
TODAY="$(date +%F)"

CTX="$REPO_DIR/.context"
if [[ -d "$CTX" ]]; then
  echo "ERROR: $CTX đã tồn tại. Hủy để tránh ghi đè." >&2
  exit 1
fi

echo "Scaffolding $CTX ..."

mkdir -p \
  "$CTX/global" \
  "$CTX/project" \
  "$CTX/docs/backend" "$CTX/docs/frontend" "$CTX/docs/database" \
  "$CTX/agents" \
  "$CTX/audits" "$CTX/decisions" "$CTX/sessions" "$CTX/knowledge" \
  "$CTX/templates" "$CTX/schemas" "$CTX/scripts"

# 13 stages
STAGES=(
  01-ideation-research 02-requirements-scope 03-feasibility-tech-strategy
  04-system-design 05-ux-ui-design 06-planning-breakdown 07-development
  08-testing-qa 09-integration-staging 10-deep-audit 11-remediation-upgrade
  12-production-operations 13-final-release
)
for s in "${STAGES[@]}"; do
  mkdir -p "$CTX/stages/$s"
  cat > "$CTX/stages/$s/gate.md" <<EOF
# Gate — $s

## Definition of Ready (DoR)
- [ ] <điều kiện đủ để BẮT ĐẦU giai đoạn này>

## Definition of Done (DoD)
- [ ] <điều kiện đủ để KẾT THÚC và đi tiếp>
EOF
done

# project-profile.yaml
cat > "$CTX/project/project-profile.yaml" <<EOF
project:
  name: "$PROJECT_NAME"
  size: $SIZE
  type: $TYPE

execution:
  allow_fast_track: false
  max_remediation_loops: 3
  escalate_to_human: true
  parallel_agents: true

audit:
  threshold_composite:
    super-large: 9.5
    small: 8.5
    personal: 8.0
  block_on:
    super-large: [critical, high]
    small: [critical, high]
    personal: [critical]
  parts_required:
    super-large: [A, B, C]
    small: [A, B, C]
    personal: [A, C]
  isolate_parts: true
EOF

# state.yaml
cat > "$CTX/project/state.yaml" <<EOF
current_stage: 01-ideation-research
status: not-started
active_agents: []
last_gate_passed: none
remediation_loops: 0
escalated: false
updated: $TODAY
EOF

# manifest.yaml — bản đồ điều hướng
cat > "$CTX/manifest.yaml" <<EOF
# Bản đồ SSOT. Agent ĐỌC FILE NÀY ĐẦU TIÊN mỗi phiên.
read_first: [manifest.yaml, project/state.yaml, progress.md]
layers:
  L0_global: global/
  L1_project: project/
  L1_docs: docs/
  L2_stages: stages/
  L3_sessions: sessions/
canonical_sources:
  api: project/api-contract.md
  data: project/data-model.md
  architecture: project/architecture.md
  glossary: project/glossary.md
protocol: global/context-protocol.md
do_not_index: [sessions/, audits/, knowledge/]
updated: $TODAY
EOF

# progress + changelog
cat > "$CTX/progress.md" <<EOF
# Progress — "ván cờ hiện tại"

- Stage: 01-ideation-research
- Status: not-started
- Next: nạp ý tưởng & nghiên cứu (GĐ1)
EOF
printf '# Changelog\n\n- %s init: scaffolded .context/\n' "$TODAY" > "$CTX/changelog.md"

# context-protocol (L0)
cat > "$CTX/global/context-protocol.md" <<'EOF'
# Context Protocol (LUẬT bắt buộc cho mọi agent)

Mỗi phiên: HYDRATE -> VALIDATE -> EXECUTE -> WRITE-BACK.
- Ghi file máy đọc qua scripts/, không sửa text YAML trực tiếp.
- KHÔNG bọc YAML trong code fence; thụt lề 2 spaces.
- Single-writer theo front-matter `writers`; log là append-only.
EOF

# placeholder L1 canonical files
for f in vision requirements architecture data-model api-contract design-system glossary risks; do
  printf -- '---\nstatus: draft\ncanonical: true\nupdated: %s\n---\n\n# %s\n\nTODO\n' "$TODAY" "$f" > "$CTX/project/$f.md"
done

# agent charters (RBAC) — ai làm gì, ghi được file nào
make_agent() {
  local role="$1" stages="$2" writes="$3" reads="$4" desc="$5"
  cat > "$CTX/agents/$role.md" <<EOF
---
id: agent.$role
layer: L1
owner: orchestrator
writers: [orchestrator]
readers: [all]
status: approved
updated: $TODAY
canonical: true
---

# Agent: $role

## Vai trò
$desc

## Giai đoạn phụ trách
$stages

## Quyền GHI (writers) — CHỈ được ghi các artifact này
$writes

## ĐỌC
$reads

## Escalation
- Mâu thuẫn/blocker → báo orchestrator, DỪNG, không tự ý vượt quyền.
- Tuân thủ global/context-protocol.md (Hydrate→Validate→Execute→Write-back).
EOF
}

make_agent orchestrator \
  "tất cả (điều phối + đóng/mở cổng)" \
  "project/state.yaml, manifest.yaml, progress.md, stages/*/gate.md" \
  "toàn bộ SSOT" \
  "Điều phối pipeline 13 giai đoạn, mở/đóng cổng chất lượng, phân giải xung đột, serial hóa việc ghi state."
make_agent product \
  "1 (ý tưởng), 2 (yêu cầu), 13 (cải tiến)" \
  "project/vision.md, project/requirements.md, scope, project/glossary.md, backlog-next.md" \
  "toàn bộ SSOT" \
  "Chủ sở hữu 'CÁI GÌ' và 'VÌ SAO': ý tưởng, yêu cầu, phạm vi, mục tiêu kinh doanh."
make_agent architect \
  "3 (chiến lược), 4 (thiết kế hệ thống)" \
  "project/architecture.md, project/data-model.md, project/api-contract.md, tech-strategy, decisions/ADR-*" \
  "project/*, docs/*" \
  "Chủ sở hữu kiến trúc tổng + hợp đồng API + data-model logic (canonical)."
make_agent backend-engineer \
  "7 (code BE)" \
  "docs/backend/*, mã nguồn backend" \
  "project/api-contract.md, project/data-model.md, project/architecture.md" \
  "Hiện thực backend đáp ứng api-contract. Lệch thiết kế → tạo ADR + write-back spec."
make_agent frontend-engineer \
  "7 (code FE)" \
  "docs/frontend/*, mã nguồn frontend" \
  "project/api-contract.md, project/design-system.md" \
  "Hiện thực frontend tiêu thụ api-contract theo design-system."
make_agent database-engineer \
  "7 (schema + truy cập dữ liệu)" \
  "docs/database/*, schema vật lý, migration" \
  "project/data-model.md, project/api-contract.md" \
  "Hiện thực schema vật lý bám data-model logic; tối ưu index/truy vấn."
make_agent qa \
  "8 (kiểm thử & QA)" \
  "stages/08-testing-qa/* (test-report, coverage, bugs)" \
  "project/requirements.md, mã nguồn" \
  "Kiểm thử unit/integration/e2e + performance; đối chiếu phủ requirements."
make_agent auditor \
  "10 (audit sâu 3 phần) — ĐỘC LẬP" \
  "audits/<run>/* (scorecard.yaml, findings.yaml, part-a/b/c)" \
  "toàn bộ SSOT + mã nguồn (chỉ đọc)" \
  "Kiểm toán độc lập (KHÔNG viết code). Chấm A/B/C ở các session riêng (isolate_parts)."
make_agent reconciliation \
  "7 (liên tục) — đối soát" \
  "tạo task đồng bộ; gắn cờ lệch spec↔code (không tự sửa code)" \
  "mã nguồn + project/* + docs/*" \
  "So code thực tế với spec cuối mỗi giai đoạn code; lệch = bug → tạo task đồng bộ."

echo "OK: SSOT đã tạo tại $CTX"
echo "Tiếp theo: điền project/vision.md và chạy giai đoạn 1."
