# Pipeline 24 giai đoạn — Chi tiết

8 pha × 3: **DISCOVER → VALIDATE → DEFINE → DECIDE → BLUEPRINT → BUILD → HARDEN → LAUNCH**.

## Bảng tổng

| # | Giai đoạn | Pha | Agent | Artifact gốc |
|---|-----------|-----|-------|--------------|
| 1 | Thinking & Problem Framing | DISCOVER | product | validation/problem-statement.md |
| 2 | Market & Competitor Research | DISCOVER | researcher | validation/competitor-analysis.md |
| 3 | Audience Segmentation & Personas | DISCOVER | researcher | validation/audience-personas.md |
| 4 | User Conversations First 🧑 | VALIDATE | product-validator | validation/user-interviews.md |
| 5 | Idea Validation Battery | VALIDATE | product-validator | validation/validation-experiments.md |
| 6 | Demand Validation & Waitlist | VALIDATE | product-validator | validation/demand-signals.md, waitlist.md |
| 7 | Requirements & Scope 🧑 | DEFINE | product | requirements.md, scope.md |
| 8 | Feature Prioritization | DEFINE | product | priority-matrix.md, requirements(MVP) |
| 9 | Feasibility & Solution Options | DEFINE | architect | options/*.md |
| 10 | Shaping & Decisions 🧑 | DECIDE | orchestrator | decisions/ADR-* |
| 11 | Threat Modeling | DECIDE | security | threat-model.md, risks.md |
| 12 | Architecture & Data Design | BLUEPRINT ⭐ | architect | architecture, data-model, api-contract |
| 13 | UX/UI & Design System | BLUEPRINT ⭐ | (design) | design-system, ux-flows |
| 14 | Planning, Rules & Breakdown | BLUEPRINT ⭐ | product+architect | tasks, milestones, coding-standards |
| 15 | Environment & Scaffolding | BUILD | (devops) | repo, CI skeleton, dev-env |
| 16 | Prototype & Spike | BUILD | engineering | spike-report |
| 17 | Development (feedback-loop) | BUILD | engineering | code, ADR, write-back |
| 18 | Testing & QA | BUILD | qa | test-report, coverage |
| 19 | Integration & Staging | HARDEN | (devops) | deploy.md, staging |
| 20 | Deep Audit (3 phần) | HARDEN | auditor | scorecard, findings |
| 21 | Remediation & Upgrade ⟲ | HARDEN | engineering+architect | tasks, upgrade-plan |
| 22 | Release Readiness 🧑 | LAUNCH | release-manager | uat-report, go-no-go |
| 23 | Production & Operations | LAUNCH | (sre) | release-notes, monitoring |
| 24 | Retrospective, 10/10 & Evolve | LAUNCH | orchestrator | retrospective, backlog-next → ↩GĐ1 |

## Pha DISCOVER + VALIDATE (GĐ1-6) — Build-Measure-Learn

```
GĐ1 Thinking ──► GĐ2 Research ──► GĐ3 Personas
                                       │
                                       ▼
GĐ4 Interviews🧑 ──► GĐ5 Validation ──► GĐ6 Demand+Waitlist
                                            │
                              ┌─────────────┼─────────────┐
                            GO          PIVOT           KILL
                              │            │              │
                              ▼      (↩GĐ1-3,         (dừng,
                          GĐ7 DEFINE  max 3 vòng)      ADR lý do)
```

Chi tiết playbook: skill `product-discovery` + `references/validation-playbook.md`.

## Pha DECIDE (GĐ9-10) — Discover⇄Decide loop

```
GĐ9 Sinh phương án → GĐ10 Quyết định🧑 → hội tụ? → GĐ11 | chưa → ↩ (max 3)
```

## Pha BLUEPRINT (GĐ12-14) — cổng nghiêm nhất

"Không dòng code nào trước khi BLUEPRINT PASS." Xem `../SKILL.md` + `../../docs/blueprint.md`.

## Dòng chảy GĐ20-21 (audit + khắc phục)

```
GĐ20 Audit → findings (BLOCKED) → GĐ21 fix → RE-AUDIT → PASS → GĐ22 | BLOCKED → loop (max 3)
```
