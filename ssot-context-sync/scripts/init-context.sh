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
  "$CTX/validation" \
  "$CTX/docs/backend" "$CTX/docs/frontend" "$CTX/docs/database" \
  "$CTX/agents" \
  "$CTX/audits" "$CTX/decisions" "$CTX/sessions" "$CTX/knowledge" \
  "$CTX/templates" "$CTX/schemas" "$CTX/scripts"

# 24 stages (8 pha)
STAGES=(
  01-thinking-problem-framing 02-market-competitor-research 03-audience-segmentation
  04-user-conversations 05-idea-validation 06-demand-validation-waitlist
  07-requirements-scope 08-feature-prioritization 09-feasibility-options
  10-shaping-decisions 11-threat-modeling
  12-architecture-data-design 13-ux-ui-design 14-planning-rules-breakdown
  15-environment-scaffolding 16-prototype-spike 17-development 18-testing-qa
  19-integration-staging 20-deep-audit 21-remediation-upgrade
  22-release-readiness 23-production-operations 24-retrospective-final
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
  max_validation_iterations: 3
  escalate_to_human: true
  parallel_agents: true

stages:
  total: 24
  human_checkpoints: [4, 7, 10, 22]
  skip_if_low_risk: [11, 16]
  validation_gate: 6          # GĐ6: phải đạt demand signal mới được sang DEFINE
  prioritization_gate: 8      # GĐ8: phải prioritize xong mới được code

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
current_stage: 01-thinking-problem-framing
status: not-started
active_agents: []
last_gate_passed: none
discover_decide_iteration: 0
validation_iteration: 0
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
  L1_validation: validation/
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
human_checkpoints: [04-user-conversations, 07-requirements-scope, 10-shaping-decisions, 22-release-readiness]
do_not_index: [sessions/, audits/, knowledge/]
updated: $TODAY
EOF

# progress + changelog
cat > "$CTX/progress.md" <<EOF
# Progress — "ván cờ hiện tại"

- Stage: 01-thinking-problem-framing
- Status: not-started
- Next: tư duy & đóng khung vấn đề (GĐ1) — chưa code, validate trước
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

# options/ placeholders (sinh ở GĐ9, người dùng chọn ở GĐ10)
for f in platform-options architecture-options tech-stack-options priority-matrix; do
  printf -- '---\nstatus: draft\nupdated: %s\n---\n\n# %s\n\n(Sinh ở GĐ9 Feasibility, người dùng chọn ở GĐ10 Shaping)\n' "$TODAY" "$f" > "$CTX/options/$f.md"
done

# validation/ placeholders (pha VALIDATE — GĐ4-6)
for f in problem-statement competitor-analysis audience-personas user-interviews validation-experiments demand-signals waitlist; do
  printf -- '---\nstatus: draft\nupdated: %s\n---\n\n# %s\n\n(Pha VALIDATE — GĐ4-6)\n' "$TODAY" "$f" > "$CTX/validation/$f.md"
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
  "tất cả (điều phối + đóng/mở cổng + serial hóa state + kiểm hội tụ + vòng validation)" \
  "project/state.yaml, manifest.yaml, progress.md, stages/*/gate.md" \
  "toàn bộ SSOT" \
  "Điều phối pipeline 24 giai đoạn, mở/đóng cổng + human-checkpoint, phân giải xung đột, kiểm tra hội tụ + demand signal."
make_agent product \
  "1 (thinking), 7 (yêu cầu🧑), 8 (prioritization), 24 (cải tiến)" \
  "project/vision.md, project/requirements.md, validation/problem-statement.md, scope, project/glossary.md, backlog-next.md" \
  "toàn bộ SSOT" \
  "Chủ 'CÁI GÌ' và 'VÌ SAO': tư duy vấn đề, yêu cầu, ưu tiên feature, mục tiêu kinh doanh."
make_agent researcher \
  "2 (market & competitor research), 3 (audience segmentation)" \
  "validation/competitor-analysis.md, validation/audience-personas.md, project/research.md" \
  "toàn bộ SSOT + internet" \
  "Nghiên cứu thị trường, đối thủ, phân khúc khách hàng + persona. Cung cấp dữ kiện cho product."
make_agent product-validator \
  "4 (user conversations🧑), 5 (idea validation), 6 (demand validation & waitlist)" \
  "validation/user-interviews.md, validation/validation-experiments.md, validation/demand-signals.md, validation/waitlist.md" \
  "toàn bộ SSOT" \
  "Chạy battery validation: phỏng vấn user, thử nghiệm idea, đo demand signal, dựng waitlist. Build-Measure-Learn."
make_agent architect \
  "9 (sinh phương án), 12 (thiết kế kiến trúc & dữ liệu)" \
  "project/architecture.md, project/data-model.md, project/api-contract.md, options/*.md, decisions/ADR-*" \
  "project/*, docs/*" \
  "Sinh phương án (GĐ9), thiết kế kiến trúc+API+data-model (GĐ12). Chủ canonical sources."
make_agent backend-engineer \
  "16 (spike), 17 (code BE)" \
  "docs/backend/*, mã nguồn backend" \
  "project/api-contract.md, project/data-model.md, project/architecture.md" \
  "Hiện thực backend đáp ứng api-contract. Lệch thiết kế → tạo ADR + write-back spec."
make_agent frontend-engineer \
  "16 (spike), 17 (code FE)" \
  "docs/frontend/*, mã nguồn frontend" \
  "project/api-contract.md, project/design-system.md" \
  "Hiện thực frontend tiêu thụ api-contract theo design-system."
make_agent database-engineer \
  "17 (schema + truy cập dữ liệu)" \
  "docs/database/*, schema vật lý, migration" \
  "project/data-model.md, project/api-contract.md" \
  "Hiện thực schema vật lý bám data-model logic; tối ưu index/truy vấn."
make_agent security \
  "11 (threat modeling), 20 (audit phần B)" \
  "project/threat-model.md, project/risks.md (phần security)" \
  "project/architecture.md, project/api-contract.md, mã nguồn" \
  "Mô hình hóa rủi ro & đe dọa (GĐ11). Review security trong audit (GĐ20 Part B)."
make_agent qa \
  "18 (kiểm thử & QA)" \
  "stages/18-testing-qa/* (test-report, coverage, bugs)" \
  "project/requirements.md, mã nguồn" \
  "Kiểm thử unit/integration/e2e + performance; đối chiếu phủ requirements."
make_agent auditor \
  "20 (audit sâu 3 phần) — ĐỘC LẬP" \
  "audits/<run>/* (scorecard.yaml, findings.yaml, part-a/b/c)" \
  "toàn bộ SSOT + mã nguồn (chỉ đọc)" \
  "Kiểm toán độc lập (KHÔNG viết code). Chấm A/B/C ở các session riêng (isolate_parts)."
make_agent reconciliation \
  "17 (liên tục) — đối soát" \
  "tạo task đồng bộ; gắn cờ lệch spec↔code (không tự sửa code)" \
  "mã nguồn + project/* + docs/*" \
  "So code thực tế với spec cuối mỗi giai đoạn code; lệch = bug → tạo task đồng bộ."
make_agent release-manager \
  "22 (sẵn sàng ra mắt🧑)" \
  "stages/22-release-readiness/* (uat-report, go-no-go, rollout-plan)" \
  "audits/*, project/*, stages/21-*" \
  "Trình UAT report + release checklist. Dừng chờ người duyệt go/no-go."

echo "OK: SSOT đã tạo tại $CTX"
echo "Tiếp theo: tư duy & đóng khung vấn đề (GĐ1), validate trước khi code."
