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
# ============================================================================
# CẤU TRÚC 2 TẦNG: 8 PHA → 23 SUB-STAGE → mỗi sub-stage 1 BỘ HÀNH TRANG (bundle)
# Mỗi dòng: phase|substage|agent|skill|rules|knowledge|framework|flag
#   rules     = file rule cứng phải tuân (trong decision-gates/references/tech/ hoặc playbook)
#   knowledge = nguồn kiến thức để tra cứu
#   framework = mental-model / template chính
#   flag      = HUMAN | VALIDATION-GATE | MVP-GATE | BLUEPRINT-GATE | AUDIT-GATE | "" 
# ============================================================================
SUBSTAGES=(
  # PHA 1 — DISCOVER
  "1-discover|1-problem-framing|product|product-discovery|playbook:GĐ1|none|Problem-Statement + 5-Whys + Riskiest-Assumption|"
  "1-discover|2-market-competitor|researcher|product-discovery|playbook:GĐ2|web-research|TAM-SAM-SOM + Competitor-Matrix + Gap|"
  "1-discover|3-audience-personas|researcher|product-discovery|playbook:GĐ3|none|Segmentation + Beachhead + JTBD-Personas|"
  # PHA 2 — VALIDATE
  "2-validate|1-user-interviews|product-validator|product-discovery|playbook:GĐ4|none|The-Mom-Test (hỏi quá khứ, không pitch)|HUMAN"
  "2-validate|2-idea-experiments|product-validator|product-discovery|playbook:GĐ5|none|Experiment-Battery (smoke/wizard/concierge/fake-door/pre-sale)|"
  "2-validate|3-demand-waitlist|product-validator|product-discovery|playbook:GĐ6|none|Demand-Signal + Waitlist + GO/PIVOT/KILL|VALIDATION-GATE"
  # PHA 3 — DEFINE
  "3-define|1-requirements-scope|product|decision-gates|playbook:GĐ7|none|User-Stories + In/Out-Scope + NFR|HUMAN"
  "3-define|2-feature-prioritization|product|product-discovery|playbook:GĐ8|none|MoSCoW / RICE / Kano + MVP-cut|MVP-GATE"
  # PHA 4 — DECIDE
  "4-decide|1-solution-options|architect|decision-gates|tech/01-architecture-rules.md|tech-knowledge-base.md|Diverge: 2-3 options + tradeoff|"
  "4-decide|2-shaping-decisions|orchestrator|decision-gates|tech/01-architecture-rules.md|tech-knowledge-base.md|Converge: chọn + ghi ADR (platform/arch/tech)|HUMAN"
  "4-decide|3-threat-modeling|security|decision-gates|tech/03-concurrency-scaling-rules.md|tech-knowledge-base.md|STRIDE + risk register|"
  # PHA 5 — BLUEPRINT (viên ngọc)
  "5-blueprint|1-architecture-data|architect|ssot-context-sync|tech/01-architecture-rules.md+04-database-rules.md|tech-knowledge-base.md|C4 + data-model + api-contract|"
  "5-blueprint|2-ux-ui-design|architect|ssot-context-sync|tech/05-frontend-rules.md|tech-knowledge-base.md|Design-System + UX-flows + a11y|"
  "5-blueprint|3-planning-rules|product|quality-gates|tech/02-clean-code-rules.md|tech-knowledge-base.md|Task-breakdown + coding-standards + DoD|BLUEPRINT-GATE"
  # PHA 6 — BUILD
  "6-build|1-scaffolding|backend-engineer|harness-integration|tech/06-devops-rules.md|tech-knowledge-base.md|Repo + CI skeleton + dev-env|"
  "6-build|2-spike|backend-engineer|ssot-context-sync|tech/02-clean-code-rules.md|tech-knowledge-base.md|Throwaway PoC validate giả định kỹ thuật|"
  "6-build|3-development|backend-engineer|ssot-context-sync|tech/02-clean-code-rules.md+03-concurrency-scaling-rules.md|tech-knowledge-base.md|Feature-increment + Hydrate→Write-back|"
  "6-build|4-testing-qa|qa|quality-gates|tech/02-clean-code-rules.md|tech-knowledge-base.md|Test-pyramid (unit/integration/e2e)|"
  # PHA 7 — HARDEN
  "7-harden|1-staging|backend-engineer|harness-integration|tech/06-devops-rules.md|tech-knowledge-base.md|CI/CD + staging + smoke-test|"
  "7-harden|2-deep-audit|auditor|deep-audit|none|none|Audit 3 phần A/B/C (isolate sessions)|"
  "7-harden|3-remediation|architect|deep-audit|none|none|Fix findings + re-audit (circuit-breaker)|AUDIT-GATE"
  # PHA 8 — LAUNCH
  "8-launch|1-release-readiness|release-manager|decision-gates|tech/06-devops-rules.md|none|UAT + go/no-go + rollout/rollback|HUMAN"
  "8-launch|2-production|orchestrator|deep-audit|tech/06-devops-rules.md|none|Monitoring + golden-signals + incident|"
  "8-launch|3-retrospective|orchestrator|product-discovery|none|none|Retro + 10/10 verdict + backlog-next → ↩PHA1|"
)

for entry in "${SUBSTAGES[@]}"; do
  IFS='|' read -r phase sub agent skill rules knowledge framework flag <<< "$entry"
  dir="$CTX/stages/$phase/$sub"
  mkdir -p "$dir"

  # 1. instructions.md — các bước agent phải làm
  cat > "$dir/instructions.md" <<EOF
---
phase: $phase
substage: $sub
owner_agent: $agent
primary_skill: $skill
flag: ${flag:-none}
updated: $TODAY
---

# Instructions — $phase / $sub

> Agent phụ trách: **$agent**. Skill chính: **$skill**.
> ĐỌC TRƯỚC KHI LÀM: rules.md, framework.md, knowledge.md (cùng thư mục) + charter agents/$agent.md.

## Các bước (điền/điều chỉnh theo bối cảnh dự án)
1. HYDRATE: đọc state.yaml, charter, rules.md, framework.md của sub-stage này.
2. EXECUTE theo framework: $framework
3. Tạo artifact đầu ra (xem gate.md để biết artifact bắt buộc).
4. WRITE-BACK: cập nhật progress.md + sessions/ + state.yaml (qua scripts/).
$( [[ "$flag" == "HUMAN" ]] && echo "5. 🧑 DỪNG — trình con người duyệt trước khi advance." )
$( [[ "$flag" == *GATE* ]] && echo "5. 🚦 Đây là CỔNG CHẶN ($flag) — phải đạt mới được advance." )
EOF

  # 2. rules.md — bộ luật cứng phải tuân (trỏ tới rule file thật)
  cat > "$dir/rules.md" <<EOF
---
phase: $phase
substage: $sub
updated: $TODAY
---

# Rules (LUẬT CỨNG) — $phase / $sub

Bộ luật BẮT BUỘC cho sub-stage này. Vi phạm = finding ở pha HARDEN (audit).

## Nguồn luật áp dụng
- **$rules**
$( [[ "$rules" == none ]] && echo "  (sub-stage này theo playbook quy trình, xem primary_skill: $skill)" )

## Cách áp dụng
- Mở file luật ở trên trong decision-gates/references/ (hoặc playbook của skill $skill).
- Mọi quyết định/đầu ra PHẢI nằm trong ranh giới luật đó.
- Lệch luật → BẮT BUỘC tạo ADR giải trình trong decisions/.
EOF

  # 3. framework.md — bộ khung / mental model
  cat > "$dir/framework.md" <<EOF
---
phase: $phase
substage: $sub
updated: $TODAY
---

# Framework (KHUÔN) — $phase / $sub

## Mental model / template chính
**$framework**

## Cách dùng
- Đây là khuôn tư duy bắt buộc cho sub-stage. KHÔNG tự nghĩ khuôn khác.
- Template chi tiết: xem skill $skill (SKILL.md + references/).
EOF

  # 4. knowledge.md — nguồn kiến thức tra cứu
  cat > "$dir/knowledge.md" <<EOF
---
phase: $phase
substage: $sub
updated: $TODAY
---

# Knowledge (KIẾN THỨC) — $phase / $sub

## Nguồn tra cứu cho sub-stage này
- **$knowledge**
$( [[ "$knowledge" == "tech-knowledge-base.md" ]] && echo "  → decision-gates/references/tech-knowledge-base.md (catalog platform/arch/tech/db/security)" )
$( [[ "$knowledge" == "web-research" ]] && echo "  → dùng web search; ghi nguồn (URL + ngày) vào artifact." )
$( [[ "$knowledge" == none ]] && echo "  → không cần KB ngoài; theo framework + interview/data thực tế." )

## Quy tắc
- Tra cứu TRƯỚC khi quyết định. KHÔNG bịa.
- Trích nguồn vào artifact để truy vết.
EOF

  # 5. gate.md — DoR/DoD
  gateline=""
  [[ -n "$flag" ]] && gateline="
## ⚠ CỔNG ĐẶC BIỆT: $flag"
  cat > "$dir/gate.md" <<EOF
# Gate — $phase / $sub
$gateline

## Definition of Ready (DoR) — đủ để BẮT ĐẦU
- [ ] Đã đọc instructions.md, rules.md, framework.md, knowledge.md.
- [ ] Sub-stage trước đã PASS (last_gate_passed khớp).

## Definition of Done (DoD) — đủ để KẾT THÚC
- [ ] Artifact đầu ra hoàn thành theo framework.
- [ ] Tuân thủ rules.md (không vi phạm, hoặc có ADR cho ngoại lệ).
- [ ] progress.md + state.yaml đã write-back.
$( [[ "$flag" == "HUMAN" ]] && echo "- [ ] 🧑 Con người đã duyệt." )
$( [[ "$flag" == "VALIDATION-GATE" ]] && echo "- [ ] 🚦 Demand đạt ngưỡng → GO (nếu không: PIVOT/KILL)." )
$( [[ "$flag" == "MVP-GATE" ]] && echo "- [ ] 🚦 MVP chốt + mọi feature truy vết JTBD." )
$( [[ "$flag" == "BLUEPRINT-GATE" ]] && echo "- [ ] 🚦 Architecture cover 100% requirements; api-contract đủ để code độc lập; glossary thống nhất." )
$( [[ "$flag" == "AUDIT-GATE" ]] && echo "- [ ] 🚦 scorecard.yaml = PASS (composite ≥ threshold, sạch block_on)." )
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
current_phase: 1-discover
current_stage: 1-discover/1-problem-framing
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
structure: "8 phases -> 23 sub-stages; mỗi sub-stage có bundle: instructions/rules/framework/knowledge/gate"
human_checkpoints: [2-validate/1-user-interviews, 3-define/1-requirements-scope, 4-decide/2-shaping-decisions, 8-launch/1-release-readiness]
blocking_gates: [2-validate/3-demand-waitlist, 3-define/2-feature-prioritization, 5-blueprint/3-planning-rules, 7-harden/3-remediation]
do_not_index: [sessions/, audits/, knowledge/]
updated: $TODAY
EOF

# progress + changelog
cat > "$CTX/progress.md" <<EOF
# Progress — "ván cờ hiện tại"

- Phase: 1-discover
- Sub-stage: 1-discover/1-problem-framing
- Status: not-started
- Next: tư duy & đóng khung vấn đề — đọc bundle stages/1-discover/1-problem-framing/
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
