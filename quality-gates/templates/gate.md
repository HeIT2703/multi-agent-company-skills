---
id: stage.<NN-stage>.gate
layer: L2
owner: orchestrator
writers: [orchestrator]
readers: [orchestrator, product, architect, backend, frontend, database, qa, auditor]
status: draft
version: 1.0.0
updated: <YYYY-MM-DD>
canonical: true
related: []
---

# Gate — <NN-stage>

## Definition of Ready (DoR) — đủ để BẮT ĐẦU
- [ ] <điều kiện 1 — kiểm chứng bằng artifact nào>
- [ ] <điều kiện 2>

## Definition of Done (DoD) — đủ để KẾT THÚC & đi tiếp
- [ ] <điều kiện 1 — kiểm chứng bằng artifact nào>
- [ ] <điều kiện 2>

## Co giãn theo size
- super-large: <mục bắt buộc thêm>
- small: <mục có thể bỏ>
- personal: <mục có thể gộp/bỏ nếu fast-track>

## Quyết định cổng
- PASS → cập nhật state.yaml: `--gate-passed <NN-stage>` rồi chuyển stage kế.
- BLOCKED → ghi progress.md (thiếu gì) + trả về stage chịu trách nhiệm.
