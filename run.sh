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

# Danh sách 24 stage (thứ tự) + pha + agent chủ trì + human-checkpoint
STAGES=(
  "01-thinking-problem-framing|DISCOVER|product|"
  "02-market-competitor-research|DISCOVER|researcher|"
  "03-audience-segmentation|DISCOVER|researcher|"
  "04-user-conversations|VALIDATE|product-validator|HUMAN"
  "05-idea-validation|VALIDATE|product-validator|"
  "06-demand-validation-waitlist|VALIDATE|product-validator|VALIDATION-GATE"
  "07-requirements-scope|DEFINE|product|HUMAN"
  "08-feature-prioritization|DEFINE|product|MVP-GATE"
  "09-feasibility-options|DEFINE|architect|"
  "10-shaping-decisions|DECIDE|orchestrator|HUMAN"
  "11-threat-modeling|DECIDE|security|"
  "12-architecture-data-design|BLUEPRINT|architect|"
  "13-ux-ui-design|BLUEPRINT|architect|"
  "14-planning-rules-breakdown|BLUEPRINT|product|BLUEPRINT-GATE"
  "15-environment-scaffolding|BUILD|backend-engineer|"
  "16-prototype-spike|BUILD|backend-engineer|"
  "17-development|BUILD|backend-engineer|"
  "18-testing-qa|BUILD|qa|"
  "19-integration-staging|HARDEN|backend-engineer|"
  "20-deep-audit|HARDEN|auditor|"
  "21-remediation-upgrade|HARDEN|architect|AUDIT-GATE"
  "22-release-readiness|LAUNCH|release-manager|HUMAN"
  "23-production-operations|LAUNCH|orchestrator|"
  "24-retrospective-final|LAUNCH|orchestrator|"
)

stage_index() {  # $1 = stage id -> echo index (0-based) hoặc -1
  local i=0
  for entry in "${STAGES[@]}"; do
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
    entry="${STAGES[$IDX]}"
    IFS='|' read -r sid phase agent flag <<< "$entry"
    NUM=$((IDX+1))
    echo "=============================================================="
    echo " MULTI-AGENT COMPANY — STATUS"
    echo "=============================================================="
    echo " Giai đoạn:   GĐ$NUM/24  ($sid)"
    echo " Pha:         $phase"
    echo " Trạng thái:  $STATUS"
    echo " Agent:       $agent"
    echo " Gate cuối:   $GATE_PASSED"
    [[ -n "$flag" ]] && echo " ⚠ ĐẶC BIỆT:  $flag"
    echo "--------------------------------------------------------------"
    echo " Artifact giai đoạn này: stages/$sid/"
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
    echo "=== Gate: $CUR ==="
    cat "$CTX/stages/$CUR/gate.md"
    ;;

  agent)
    CTX="$(require_ctx "${2:?repo dir}")"
    CUR="$(get_current_stage "$CTX")"
    IDX="$(stage_index "$CUR")"
    IFS='|' read -r sid phase agent flag <<< "${STAGES[$IDX]}"
    echo "Agent phụ trách GĐ hiện tại ($sid): $agent"
    echo "Charter: .context/agents/$agent.md"
    [[ -f "$CTX/agents/$agent.md" ]] && { echo "---"; cat "$CTX/agents/$agent.md"; }
    ;;

  advance)
    CTX="$(require_ctx "${2:?repo dir}")"
    CUR="$(get_current_stage "$CTX")"
    IDX="$(stage_index "$CUR")"
    IFS='|' read -r sid phase agent flag <<< "${STAGES[$IDX]}"
    # chặn cổng validation phải dùng lệnh validate
    if [[ "$flag" == "VALIDATION-GATE" ]]; then
      echo "⚠ GĐ6 là CỔNG VALIDATION. Dùng: bash run.sh validate ${2} <go|pivot|kill>" >&2
      exit 1
    fi
    NEXT_IDX=$((IDX+1))
    if [[ "$NEXT_IDX" -ge "${#STAGES[@]}" ]]; then
      echo "🎉 Đã ở giai đoạn cuối (GĐ24). Hoàn tất vòng. Feedback -> quay lại GĐ1 cho version sau."
      bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" --status done --gate-passed "$sid" >/dev/null
      exit 0
    fi
    NEXT_SID="${STAGES[$NEXT_IDX]%%|*}"
    bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" \
      --gate-passed "$sid" --stage "$NEXT_SID" --status in-progress >/dev/null
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
          --gate-passed "$CUR" --stage "07-requirements-scope" --status in-progress >/dev/null
        echo "✅ VALIDATION = GO. Demand đủ. Sang GĐ7 (Requirements)."
        ;;
      pivot)
        ITER="$(field "$CTX" validation_iteration)"; ITER=$(( ${ITER:-0} + 1 ))
        bash "$HERE/ssot-context-sync/scripts/update-state.sh" "$CTX/project/state.yaml" \
          --stage "01-thinking-problem-framing" --status in-progress >/dev/null
        echo "🔄 VALIDATION = PIVOT (lần $ITER). Quay lại GĐ1 với góc nhìn mới."
        echo "   (Sửa validation_iteration=$ITER thủ công nếu cần, hoặc ghi ADR lý do pivot.)"
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
    echo "=== Bản đồ 24 giai đoạn (8 pha) ==="
    n=0; lastphase=""
    for entry in "${STAGES[@]}"; do
      IFS='|' read -r sid phase agent flag <<< "$entry"
      n=$((n+1))
      [[ "$phase" != "$lastphase" ]] && { echo ""; echo "[$phase]"; lastphase="$phase"; }
      mark=""; [[ -n "$flag" ]] && mark="   <-- $flag"
      printf "  GĐ%-2d %-32s (%s)%s\n" "$n" "$sid" "$agent" "$mark"
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
