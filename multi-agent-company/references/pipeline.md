# Pipeline 13 giai đoạn — chi tiết

Chia 5 nhóm: **Conceive → Design → Build → Verify & Harden → Launch & Evolve**.

| # | Giai đoạn | Nhóm | Agent chủ trì | Artifact gốc |
|---|-----------|------|---------------|--------------|
| 1 | Ý tưởng & Nghiên cứu | Conceive | Research + Product | `vision.md`, `research.md` |
| 2 | Yêu cầu & Phạm vi | Conceive | Product (PM) | `requirements.md`, `scope.md` |
| 3 | Khả thi & Chiến lược kỹ thuật | Conceive | Architect | `feasibility.md`, `tech-strategy.md`, `risks.md` |
| 4 | Thiết kế hệ thống & Kiến trúc | Design | Architect | `architecture.md`, `data-model.md`, `api-contract.md`, ADR |
| 5 | Thiết kế UX/UI | Design | Design | `design-system.md`, `ux-flows.md` |
| 6 | Lập kế hoạch & Phân rã | Design | PM + Tech Lead | `tasks.md`, `milestones.md`, `dependencies.md` |
| 7 | Phát triển / Code | Build | Engineering (FE/BE/DB) | `code`, ADR, write-back spec, `progress.md` |
| 8 | Kiểm thử & QA | Build | QA | `test-report.md`, `coverage.md`, `bugs.md` |
| 9 | Tích hợp & Staging | Verify & Harden | DevOps | `deploy.md`, môi trường staging |
| 10 | 🔍 Audit sâu (3 phần) | Verify & Harden | Auditor (độc lập) | `audits/<run>/...`, `scorecard.yaml`, `findings.yaml` |
| 11 | 🔧 Khắc phục & Nâng cấp | Verify & Harden | Engineering + Architect | remediation `tasks.md`, `upgrade-plan.md` |
| 12 | Ra mắt Production & Vận hành | Launch & Evolve | SRE + Product | `release-notes.md`, `monitoring.md`, `runbook.md` |
| 13 | Sản phẩm 10/10 & Cải tiến | Launch & Evolve | CEO / Orchestrator | `retrospective.md`, `backlog-next.md` |

## Điểm khóa

- GĐ 1 = nạp ý tưởng/nghiên cứu; GĐ 13 = sản phẩm 10/10.
- "10/10" = composite score của GĐ 10 (sau re-audit) đạt ngưỡng — có bằng chứng, không cảm tính.
- GĐ 13 không phải điểm kết thúc mà là điểm khép vòng về GĐ 1.

## Dòng chảy GĐ 10 → 11 (tóm tắt; chi tiết ở skill deep-audit)

```
GĐ10 Audit ─► findings.yaml (scorecard BLOCKED)
   └─► GĐ11 Khắc phục: mỗi finding → 1 task; "cái chưa làm được" → upgrade-plan.md
        └─► RE-AUDIT ─► PASS → GĐ12 | BLOCKED → quay lại GĐ11 (tối đa max_remediation_loops)
```
