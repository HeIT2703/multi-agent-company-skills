---
name: deep-audit
description: >
  Chạy audit sâu 3 phần (A=kỹ thuật, B=bảo mật & tuân thủ, C=sản phẩm & đồng bộ) cho
  GĐ10, chấm điểm 0-10 mỗi phần, tổng hợp scorecard với cổng PASS/BLOCKED, rồi điều khiển
  vòng khắc phục GĐ11 có circuit-breaker. Dùng khi chuẩn bị release, khi cần đánh giá
  sản phẩm có đạt 10/10 không, khi kiểm tra SSOT có khớp code thật không, hoặc khi quản lý
  vòng fix→re-audit. Auditor PHẢI là agent độc lập, không phải agent đã viết code.
---

# Deep Audit (GĐ 10) + Remediation (GĐ 11)

## Nguyên tắc

- **Auditor độc lập**: không phải agent đã viết code (như kiểm toán ngoài).
- **Tách session theo phần** (`isolate_parts: true`): chạy A, B, C ở các session RIÊNG,
  clear context giữa các phần — chống tràn token & "Lost in the Middle". Mỗi phần chỉ nạp
  artifact + vùng code liên quan.

## 3 phần audit

| Phần | Tên | Câu hỏi | Soi gì |
|------|-----|---------|--------|
| **A** | Kỹ thuật | "Nó có vững không?" | Khớp `architecture.md`, chất lượng code, nợ kỹ thuật, hiệu năng p95/p99, coverage, scale |
| **B** | Bảo mật & Tuân thủ | "Nó có an toàn không?" | SAST/DAST, CVE phụ thuộc, secrets, auth/RBAC, mã hóa, quyền riêng tư, compliance |
| **C** | Sản phẩm & Đồng bộ | "Đúng lời hứa & đồng bộ không?" | Phủ `requirements.md`, **SSOT khớp code thật** (spec↔code↔docs), UX/a11y, glossary, mục tiêu KD |

Mỗi finding ghi vào `audits/<run>/findings.yaml`; điểm vào `scorecard.yaml`.

## Chấm điểm & cổng

- Mỗi phần điểm 0–10 + weight. `composite = Σ(score×weight)`.
- `threshold` lấy theo `size` trong `project-profile.yaml`.
- `gate = PASS` chỉ khi: `composite ≥ threshold` **VÀ** không còn finding `open` ở severity nằm trong `block_on`.
- Dùng `scripts/recompute-scorecard.sh <audit-run-dir>` để tính lại composite + cờ gate (không tính tay).

## Vòng lặp khắc phục GĐ11 + circuit-breaker

```
Audit -> findings.yaml (BLOCKED)
  -> mỗi finding -> 1 task (gắn owner); "cái chưa làm được" -> upgrade-plan.md
  -> RE-AUDIT -> PASS -> GĐ12 | BLOCKED -> lặp lại
```

- Mỗi vòng tăng `remediation_loops` (qua `update-state.sh --inc-loop`).
- Chạm `execution.max_remediation_loops` (mặc định 3) → set `escalated: true`, **dừng**, chờ người.
- **Tuyệt đối không hạ `threshold`** để qua cổng (chất lượng > tiền) — xem `references/audit-parts.md`.
- Finding chấp nhận rủi ro: `status: accepted-risk` **kèm ADR** giải thích + mitigation.

## Tài nguyên

- Chi tiết 3 phần + thang điểm + 3 ADR rủi ro nền tảng: `references/audit-parts.md`.
- Template: `templates/findings.yaml`, `templates/scorecard.yaml`.
- Tooling: `scripts/add-finding.sh`, `scripts/recompute-scorecard.sh`.
- Validate inline: `schemas/findings.schema.json`, `schemas/scorecard.schema.json`.
