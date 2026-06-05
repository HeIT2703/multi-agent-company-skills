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
  "$CTX/options" \
  "$CTX/docs/backend" "$CTX/docs/frontend" "$CTX/docs/database" \
  "$CTX/agents" \
  "$CTX/audits" "$CTX/decisions" "$CTX/sessions" "$CTX/knowledge" \
  "$CTX/templates" "$CTX/schemas" "$CTX/scripts"

# 18 stages (6 pha × 3)
STAGES=(
  01-ideation-research 02-requirements-gathering 03-feasibility-options
  04-shaping-decisions 05-threat-modeling 06-prototype-spike
  07-architecture-data-design 08-ux-ui-design 09-planning-rules-breakdown
  10-environment-scaffolding 11-development 12-testing-qa
  13-integration-staging 14-deep-audit 15-remediation-upgrade
  16-release-readiness 17-production-operations 18-retrospective-final
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
  platform: []
  decision_mode: interactive

execution:
  allow_fast_track: false
  max_remediation_loops: 3
  max_discover_decide_loops: 3
  escalate_to_human: true
  parallel_agents: true

stages:
  total: 18
  human_checkpoints: [2, 4, 16]
  skip_if_low_risk: [5, 6]

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
discover_decide_iteration: 0
convergence: false
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
  L1_options: options/
  L1_docs: docs/
  L2_stages: stages/
  L3_sessions: sessions/
canonical_sources:
  api: project/api-contract.md
  data: project/data-model.md
  architecture: project/architecture.md
  glossary: project/glossary.md
  threat_model: project/threat-model.md
protocol: global/context-protocol.md
human_checkpoints: [02-requirements-gathering, 04-shaping-decisions, 16-release-readiness]
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

## HYDRATE
- Đọc manifest.yaml + project/state.yaml + progress.md.
- Đọc L0 (global/) -> L1 (project/ + docs/) -> L2 (stages/) -> L3 (sessions/ liên quan).
- Không bao giờ bắt đầu "từ trí nhớ".

## VALIDATE
- Đối chiếu việc sắp làm với requirements.md / architecture.md / glossary.md.
- Mâu thuẫn -> DỪNG, báo orchestrator.

## EXECUTE
- Làm task trong quyền ghi (front-matter writers).

## WRITE-BACK
- sessions/ (append-only).
- progress.md (cập nhật).
- ADR nếu quyết định lớn.
- Cập nhật ngược spec nếu buộc lệch thiết kế.
- changelog.md (append-only).

## Kỷ luật ghi YAML
- ƯU TIÊN ghi qua scripts/, KHÔNG sửa text YAML trực tiếp.
- NGHIÊM CẤM bọc YAML trong code fence markdown.
- Thụt lề ĐÚNG 2 spaces, không tab.
- Single-writer theo front-matter writers; log là append-only.
- Ghi state.yaml serial hóa qua orchestrator.

## Human-Checkpoint
- GĐ có human-checkpoint: agent DỪNG sau khi trình phương án, ĐỢI người chốt.
- decision_mode=autonomous: tự chọn default + ghi decided_by=agent.
EOF

# placeholder L1 canonical files
for f in vision requirements architecture data-model api-contract design-system glossary risks threat-model; do
  printf -- '---\nstatus: draft\ncanonical: true\nupdated: %s\n---\n\n# %s\n\nTODO\n' "$TODAY" "$f" > "$CTX/project/$f.md"
done

# options/ placeholders
for f in platform-options architecture-options tech-stack-options priority-matrix; do
  printf -- '---\nstatus: draft\nupdated: %s\n---\n\n# %s\n\n(Sinh ở GĐ3, người dùng chọn ở GĐ4)\n' "$TODAY" "$f" > "$CTX/options/$f.md"
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
  "tất cả (điều phối + đóng/mở cổng + serial hóa state + kiểm hội tụ Discover⇄Decide)" \
  "project/state.yaml, manifest.yaml, progress.md, stages/*/gate.md" \
  "toàn bộ SSOT" \
  "Điều phối pipeline 18 giai đoạn, mở/đóng cổng + human-checkpoint, phân giải xung đột, kiểm tra hội tụ."
make_agent product \
  "1 (ý tưởng), 2 (yêu cầu🧑), 18 (cải tiến)" \
  "project/vision.md, project/requirements.md, scope, project/glossary.md, backlog-next.md" \
  "toàn bộ SSOT" \
  "Chủ sở hữu 'CÁI GÌ' và 'VÌ SAO': ý tưởng, yêu cầu, phỏng vấn người dùng, mục tiêu kinh doanh."
make_agent architect \
  "3 (sinh phương án), 7 (thiết kế kiến trúc & dữ liệu)" \
  "project/architecture.md, project/data-model.md, project/api-contract.md, options/*.md, decisions/ADR-*" \
  "project/*, docs/*" \
  "Sinh phương án (GĐ3), thiết kế kiến trúc+API+data-model (GĐ7). Chủ canonical sources."
make_agent backend-engineer \
  "11 (code BE)" \
  "docs/backend/*, mã nguồn backend" \
  "project/api-contract.md, project/data-model.md, project/architecture.md" \
  "Hiện thực backend đáp ứng api-contract. Lệch thiết kế → tạo ADR + write-back spec."
make_agent frontend-engineer \
  "11 (code FE)" \
  "docs/frontend/*, mã nguồn frontend" \
  "project/api-contract.md, project/design-system.md" \
  "Hiện thực frontend tiêu thụ api-contract theo design-system."
make_agent database-engineer \
  "11 (schema + truy cập dữ liệu)" \
  "docs/database/*, schema vật lý, migration" \
  "project/data-model.md, project/api-contract.md" \
  "Hiện thực schema vật lý bám data-model logic; tối ưu index/truy vấn."
make_agent security \
  "5 (threat modeling), 14 (audit phần B)" \
  "project/threat-model.md, project/risks.md (phần security)" \
  "project/architecture.md, project/api-contract.md, mã nguồn" \
  "Mô hình hóa rủi ro & đe dọa (GĐ5). Review security trong audit (GĐ14 Part B)."
make_agent qa \
  "12 (kiểm thử & QA)" \
  "stages/12-testing-qa/* (test-report, coverage, bugs)" \
  "project/requirements.md, mã nguồn" \
  "Kiểm thử unit/integration/e2e + performance; đối chiếu phủ requirements."
make_agent auditor \
  "14 (audit sâu 3 phần) — ĐỘC LẬP" \
  "audits/<run>/* (scorecard.yaml, findings.yaml, part-a/b/c)" \
  "toàn bộ SSOT + mã nguồn (chỉ đọc)" \
  "Kiểm toán độc lập (KHÔNG viết code). Chấm A/B/C ở các session riêng (isolate_parts)."
make_agent reconciliation \
  "11 (liên tục) — đối soát" \
  "tạo task đồng bộ; gắn cờ lệch spec↔code (không tự sửa code)" \
  "mã nguồn + project/* + docs/*" \
  "So code thực tế với spec cuối mỗi giai đoạn code; lệch = bug → tạo task đồng bộ."
make_agent release-manager \
  "16 (sẵn sàng ra mắt🧑)" \
  "stages/16-release-readiness/* (uat-report, go-no-go, rollout-plan)" \
  "audits/*, project/*, stages/15-*" \
  "Trình UAT report + release checklist. Dừng chờ người duyệt go/no-go."

echo "OK: SSOT đã tạo tại $CTX"
echo "Tiếp theo: điền project/vision.md và chạy giai đoạn 1."
