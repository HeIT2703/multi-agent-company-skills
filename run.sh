#!/usr/bin/env bash
# run.sh — Orchestrator CLI cho Multi-Agent Company.
# Biến skill từ "tài liệu" thành "chạy được": cho biết đang ở đâu, gate gì, lệnh tiếp theo.
# Không phụ thuộc thư viện ngoài (bash + python3 stdlib).
#
# Lệnh:
#   run.sh init <repo> "<name>" <size> <type>   Khởi tạo .context/
#   run.sh status <repo>                         Trạng thái + gate + lệnh tiếp theo
#   run.sh gate <repo>                           Xem checklist gate giai đoạn hiện tại
#   run.sh advance <repo>                         Qua cổng -> sang giai đoạn kế
#   run.sh validate <repo> <go|pivot|kill>        Quyết định cổng validation (GĐ6)
#   run.sh agent <repo>                           Agent nào phụ trách giai đoạn hiện tại
#   run.sh map                                    In bản đồ 24 giai đoạn
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CMD="${1:-help}"

# Danh sách 24 sub-stage (thứ tự) | id | agent | flag
SUBSTAGES=(
  "1-discover/1-problem-framing|product|"
  "1-discover/2-market-competitor|researcher|"
  "1-discover/3-audience-personas|researcher|"
  "2-validate/1-user-interviews|product-validator|HUMAN"
  "2-validate/2-idea-experiments|product-validator|"
  "2-validate/3-demand-waitlist|product-validator|VALIDATION-GATE"
  "3-define/1-requirements-scope|product|HUMAN"
  "3-define/2-feature-prioritization|product|MVP-GATE"
  "4-decide/1-solution-options|architect|"
  "4-decide/2-shaping-decisions|orchestrator|HUMAN"
  "4-decide/3-threat-modeling|security|"
  "5-blueprint/1-architecture-data|architect|"
  "5-blueprint/2-ux-ui-design|architect|"
  "5-blueprint/3-planning-rules|product|BLUEPRINT-GATE"
  "6-build/1-scaffolding|backend-engineer|"
  "6-build/2-spike|backend-engineer|"
  "6-build/3-development|backend-engineer|"
  "6-build/4-testing-qa|qa|"
  "7-harden/1-staging|backend-engineer|"
  "7-harden/2-deep-audit|auditor|"
  "7-harden/3-remediation|architect|AUDIT-GATE"
  "8-launch/1-release-readiness|release-manager|HUMAN"
  "8-launch/2-production|orchestrator|"
  "8-launch/3-retrospective|orchestrator|"
)

stage_index() {  # $1 = sub-stage id -> echo index (0-based) hoặc -1
  local i=0
  for entry in "${SUBSTAGES[@]}"; do
    [[ "${entry%%|*}" == "$1" ]] && { echo "$i"; return; }
    i=$((i+1))
  done
  echo "-1"
}

get_current_stage() {  # $1 = .context dir
  grep -E '^current_stage:' "$1/project/state.yaml" | head -1 | sed 's/current_stage:[[:space:]]*//; s/[[:space:]]*#.*//'
}

field() {  # $1 = .context, $2 = key -> value
  grep -E "^$2:" "$1/project/state.yaml" | head -1 | sed "s/$2:[[:space:]]*//; s/[[:space:]]*#.*//"
}

require_ctx() {
  local ctx="$1/.context"
  [[ -d "$ctx" ]] || { echo "ERROR: không thấy $ctx. Chạy: run.sh init <repo> ..." >&2; exit 1; }
  echo "$ctx"
}

case "$CMD" in
  init)
    REPO="${2:?repo dir}"; NAME="${3:-Untitled}"; SIZE="${4:-small}"; TYPE="${5:-saas}"
    bash "$HERE/ssot-context-sync/scripts/init-context.sh" "$REPO" "$NAME" "$SIZE" "$TYPE"
    echo ""
    echo ">>> Xong. Tiếp theo: bash run.sh status $REPO"
    ;;

  status)
    CTX="$(require_ctx "${2:?repo dir}")"
    CUR="$(get_current_stage "$CTX")"
    IDX="$(stage_index "$CUR")"
    STATUS="$(field "$CTX" status)"
    GATE_PASSED="$(field "$CTX" last_gate_passed)"
    entry="${SUBSTAGES[$IDX]}"
    IFS='|' read -r sid agent flag <<< "$entry"
    phase="${sid%%/*}"
    NUM=$((IDX+1))
    echo "=============================================================="
    echo " MULTI-AGENT COMPANY — STATUS"
    echo "=============================================================="
    echo " Sub-stage:   $NUM/24  ($sid)"
    echo " Pha:         $phase"
    echo " Trạng thái:  $STATUS"
    echo " Agent:       $agent"
    echo " Gate cuối:   $GATE_PASSED"
    [[ -n "$flag" ]] && echo " ⚠ ĐẶC BIỆT:  $flag"
    echo "--------------------------------------------------------------"
    echo " Bundle giai đoạn này: stages/$sid/"
    echo "   instructions.md · rules.md · framework.md · knowledge.md · gate.md"
    case "$flag" in
      HUMAN)            echo " 🧑 Cần CON NGƯỜI duyệt trước khi qua." ;;
      VALIDATION-GATE)  echo " 🚦 CỔNG VALIDATION: bash run.sh validate ${2} <go|pivot|kill>" ;;
      MVP-GATE)         echo " 🚦 CỔNG MVP: phải chốt MVP + truy vết JTBD trước khi advance." ;;
      BLUEPRINT-GATE)   echo " 🚦 CỔNG BLUEPRINT (nghiêm nhất): cover 100% requirements." ;;
      AUDIT-GATE)       echo " 🚦 CỔNG AUDIT: scorecard PASS mới được advance." ;;
    esac
    echo "--------------------------------------------------------------"
    echo " LỆNH TIẾP THEO:"
    echo "   bash run.sh gate ${2}      # xem checklist cổng"
    echo "   bash run.sh advance ${2}   # qua cổng -> giai đoạn kế"
    echo "=============================================================="
    ;;

  gate)
    CTX="$(require_ctx "${2:?repo dir}")"
    CUR="$(get_current_stage "$CTX")"
    echo "=== Bundle: $CUR ==="
    cat "$CTX/stages/$CUR/gate.md"
    ;;

  agent)
    CTX="$(require_ctx "${2:?repo dir}")"
    CUR="$(get_current_stage "$CTX")"
    IDX="$(stage_index "$CUR")"
    IFS='|' read -r sid agent flag <<< "${SUBSTAGES[$IDX]}"
    echo "Agent phụ trách sub-stage hiện tại ($sid): $agent"
    echo "Charter: .context/agents/$agent.md"
    [[ -f "$CTX/agents/$agent.md" ]] && { echo "---"; cat "$CTX/agents/$agent.md"; }
    ;;

  advance)
    CTX="$(require_ctx "${2:?repo dir}")"
    CUR="$(get_current_stage "$CTX")"
    IDX="$(stage_index "$CUR")"
    IFS='|' read -r sid agent flag <<< "${SUBSTAGES[$IDX]}"
    # chặn cổng validation phải dùng lệnh validate
    if [[ "$flag" == "VALIDATION-GATE" ]]; then
      echo "⚠ Đây là CỔNG VALIDATION. Dùng: bash run.sh validate ${2} <go|pivot|kill>" >&2
      exit 1
    fi
    NEXT_IDX=$((IDX+1))
    if [[ "$NEXT_IDX" -ge "${#SUBSTAGES[@]}" ]]; then
      echo "🎉 Đã ở sub-stage cuối (8-launch/3-retrospective). Hoàn tất vòng. Feedback -> ↩ pha 1 cho version sau."
      bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" --status done --gate-passed "$sid" >/dev/null
      exit 0
    fi
    NEXT_SID="${SUBSTAGES[$NEXT_IDX]%%|*}"
    NEXT_PHASE="${NEXT_SID%%/*}"
    bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" \
      --gate-passed "$sid" --stage "$NEXT_SID" --phase "$NEXT_PHASE" --status in-progress >/dev/null
    echo "✅ Qua cổng $sid. Giờ ở: $NEXT_SID"
    echo ">>> bash run.sh status ${2}"
    ;;

  validate)
    CTX="$(require_ctx "${2:?repo dir}")"
    DECISION="${3:?go|pivot|kill}"
    CUR="$(get_current_stage "$CTX")"
    case "$DECISION" in
      go)
        bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" \
          --gate-passed "$CUR" --stage "3-define/1-requirements-scope" --phase "3-define" --status in-progress >/dev/null
        echo "✅ VALIDATION = GO. Demand đủ. Sang 3-define/1-requirements-scope."
        ;;
      pivot)
        ITER="$(field "$CTX" validation_iteration)"; ITER=$(( ${ITER:-0} + 1 ))
        bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" \
          --stage "1-discover/1-problem-framing" --phase "1-discover" --status in-progress >/dev/null
        echo "🔄 VALIDATION = PIVOT (lần $ITER). Quay lại 1-discover/1-problem-framing với góc nhìn mới."
        ;;
      kill)
        bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" \
          --status blocked --escalate true >/dev/null
        echo "🛑 VALIDATION = KILL. Dừng dự án. BẮT BUỘC ghi ADR lý do trong decisions/."
        ;;
      *) echo "ERROR: dùng go | pivot | kill" >&2; exit 1 ;;
    esac
    ;;

  map)
    echo "=== Bản đồ 8 pha → 24 sub-stage ==="
    n=0; lastphase=""
    for entry in "${SUBSTAGES[@]}"; do
      IFS='|' read -r sid agent flag <<< "$entry"
      phase="${sid%%/*}"
      n=$((n+1))
      [[ "$phase" != "$lastphase" ]] && { echo ""; echo "[$phase]"; lastphase="$phase"; }
      mark=""; [[ -n "$flag" ]] && mark="   <-- $flag"
      printf "  %-2d %-34s (%s)%s\n" "$n" "$sid" "$agent" "$mark"
    done
    ;;

  *)
    echo "Multi-Agent Company — Orchestrator CLI"
    echo ""
    echo "Lệnh:"
    echo "  init <repo> \"<name>\" <size> <type>   Khởi tạo .context/"
    echo "  status <repo>                          Trạng thái + gate + lệnh kế"
    echo "  gate <repo>                            Checklist gate hiện tại"
    echo "  agent <repo>                           Agent phụ trách GĐ hiện tại"
    echo "  advance <repo>                         Qua cổng -> GĐ kế"
    echo "  validate <repo> <go|pivot|kill>        Quyết định cổng validation (GĐ6)"
    echo "  map                                    In bản đồ 24 giai đoạn"
    ;;
esac
