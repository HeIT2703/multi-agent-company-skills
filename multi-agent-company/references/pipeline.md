# Pipeline 18 giai đoạn — Chi tiết

6 pha × 3: **DISCOVER → DECIDE → BLUEPRINT → BUILD → VERIFY & HARDEN → LAUNCH & EVOLVE**.

## Bảng tổng

| # | Giai đoạn | Pha | Agent | Artifact gốc |
|---|-----------|-----|-------|--------------|
| 1 | Ý tưởng & Nghiên cứu thị trường | DISCOVER | Research+Product | vision.md, research.md |
| 2 | Thu thập Yêu cầu người dùng 🧑 | DISCOVER | Product | requirements.md, scope.md |
| 3 | Phân tích Khả thi & Sinh phương án | DISCOVER | Architect | feasibility.md, options/*.md |
| 4 | Định hình & Quyết định 🧑 | DECIDE | Orchestrator | ADR (platform, arch, tech, priority) |
| 5 | Mô hình hóa Rủi ro & Mối đe dọa | DECIDE | Security | threat-model.md, risks.md |
| 6 | Prototype & Spike | DECIDE | Engineering | spike-report.md |
| 7 | Thiết kế Kiến trúc & Dữ liệu | BLUEPRINT ⭐ | Architect | architecture, data-model, api-contract, ADR |
| 8 | Thiết kế UX/UI & Design System | BLUEPRINT ⭐ | Design | design-system, ux-flows, wireframes |
| 9 | Lập kế hoạch, Phân rã & Quy tắc | BLUEPRINT ⭐ | PM+Tech Lead | tasks, milestones, dependencies, coding-standards |
| 10 | Môi trường & Scaffolding | BUILD | DevOps | repo, CI skeleton, dev-env |
| 11 | Phát triển / Code | BUILD | Engineering | code, ADR, write-back spec |
| 12 | Kiểm thử & QA | BUILD | QA | test-report, coverage, bugs |
| 13 | Tích hợp & Staging | VERIFY | DevOps | deploy.md, staging env |
| 14 | 🔍 Audit sâu (3 phần) | VERIFY | Auditor | scorecard, findings, part-a/b/c |
| 15 | 🔧 Khắc phục & Nâng cấp ⟲ | VERIFY | Engineering+Architect | tasks, upgrade-plan, ADR |
| 16 | Sẵn sàng Ra mắt 🧑 | LAUNCH | Release Manager | UAT-report, go-no-go, rollout-plan |
| 17 | Production & Vận hành | LAUNCH | SRE | release-notes, monitoring, runbook |
| 18 | Retrospective, 10/10 & Cải tiến | LAUNCH | Orchestrator | retrospective, backlog-next → ↩GĐ1 |

## Vòng lặp Discover ⇄ Decide (GĐ1–6)

```
GĐ1 Nghiên cứu → GĐ2 Hỏi người dùng🧑 → GĐ3 Sinh phương án
                                                   ↓
     ← (chưa hội tụ) ← GĐ4 Quyết định🧑 ←───────┘
                              ↓ (hội tụ)
                         GĐ5 Threat Model → GĐ6 Spike
                                                ↓
                    ← (spike fail → GĐ3) ←  ĐẠT? → sang GĐ7
```

Max loop: `max_discover_decide_loops` (mặc định 3).

## Dòng chảy GĐ14–15 (audit + khắc phục)

```
GĐ14 Audit → findings (BLOCKED)
  → GĐ15 fix → RE-AUDIT → PASS → GĐ16 | BLOCKED → loop (max 3)
```

## Pha BLUEPRINT (GĐ7–9) — cổng nghiêm nhất

Xem `../SKILL.md` phần "Pha BLUEPRINT" và `../../docs/blueprint.md` §3 để biết tiêu chí
gate chi tiết. Nguyên tắc: "không dòng code nào trước khi BLUEPRINT PASS".
