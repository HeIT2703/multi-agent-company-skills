# Ví dụ chạy thật: dự án `personal / tool` từ GĐ1 → GĐ13

Minh họa một lượt vận hành đầy đủ cho dự án nhỏ (build một CLI tool cá nhân), có bật
`fast-track`. Mục tiêu: thấy luồng + các lệnh tooling thực tế.

## Bước 0 — Tích hợp & scaffold

```bash
# scaffold SSOT
bash .context-skills/ssot-context-sync/scripts/init-context.sh ./my-tool "Slugify CLI" personal tool
cp -r .context-skills/*/schemas/*.json my-tool/.context/schemas/ 2>/dev/null
cp .context-skills/*/scripts/*.sh       my-tool/.context/scripts/ && chmod +x my-tool/.context/scripts/*.sh
```

Bật fast-track cho dự án nhỏ: sửa `project/project-profile.yaml` →
`execution.allow_fast_track: true`. Tạo entry-point + `.cursorignore` ở gốc (xem skill
`harness-integration`).

## GĐ1–6 (fast-track gộp 1 cổng)

Vì `personal` + `allow_fast_track`, orchestrator gộp ý tưởng→kế hoạch thành một phiên gọn:

```bash
# product viết vision + requirements; architect chốt api-contract tối thiểu
bash my-tool/.context/scripts/update-state.sh my-tool/.context/project/state.yaml \
  --stage 06-planning-breakdown --status done --gate-passed 06-planning-breakdown
```

## GĐ7 — Code

```bash
bash .../update-state.sh .../state.yaml --stage 07-development --status in-progress \
  --agents backend-engineer
# ... code ... nếu lệch thiết kế: tạo decisions/ADR-0001-*.md + cập nhật api-contract.md (write-back)
```

`reconciliation` chạy cuối GĐ7: so code ↔ spec, không lệch → qua.

## GĐ8–9 — QA & Staging

```bash
bash .../update-state.sh .../state.yaml --stage 08-testing-qa --status done --gate-passed 08-testing-qa
bash .../update-state.sh .../state.yaml --stage 09-integration-staging --status done --gate-passed 09-integration-staging
```

## GĐ10 — Audit sâu (3 phần, auditor độc lập)

`personal` chỉ bắt buộc phần A + C (`parts_required.personal: [A, C]`); threshold 8.0.

```bash
RUN=my-tool/.context/audits/$(date +%F)-pre-release; mkdir -p "$RUN"
cp .context-skills/deep-audit/templates/scorecard.yaml "$RUN/scorecard.yaml"   # rồi điền điểm A,C
printf 'findings:\n' > "$RUN/findings.yaml"

# auditor ghi finding (mỗi phần một session riêng — isolate_parts)
bash .../add-finding.sh "$RUN/findings.yaml" C medium "README thiếu ví dụ dùng" product "Thêm mục Usage"
bash .../recompute-scorecard.sh "$RUN"
# => composite=... gate=BLOCKED (vì còn finding) hoặc PASS nếu sạch & đạt threshold
```

## GĐ11 — Khắc phục (vòng lặp + circuit-breaker)

```bash
# mỗi finding -> 1 task; sửa xong set status: fixed trong findings.yaml
bash .../update-state.sh .../state.yaml --stage 11-remediation-upgrade --status in-progress --inc-loop
# RE-AUDIT:
bash .../recompute-scorecard.sh "$RUN"     # gate=PASS -> đi tiếp; BLOCKED -> lặp (tối đa max_remediation_loops)
```

Nếu `remediation_loops` chạm trần (mặc định 3): `update-state.sh ... --escalate true` → dừng, chờ người.

## GĐ12–13 — Production & 10/10

```bash
bash .../update-state.sh .../state.yaml --stage 12-production-operations --status done --gate-passed 12-production-operations
bash .../update-state.sh .../state.yaml --stage 13-final-release --status done --gate-passed 13-final-release
```

GĐ13 chỉ tuyên bố **10/10** vì `scorecard.yaml.gate == PASS` (composite ≥ threshold, sạch
severity trong `block_on`) — có bằng chứng, không cảm tính. Feedback → `backlog-next.md` → khép vòng về GĐ1.
