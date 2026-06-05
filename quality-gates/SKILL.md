---
name: quality-gates
description: >
  Áp cổng chất lượng (Definition of Ready / Definition of Done) giữa các giai đoạn của
  pipeline 13 giai đoạn, để không bao giờ "code trên nền móng lung lay". Dùng khi cần
  quyết định có cho một giai đoạn bắt đầu hay kết thúc hay không, khi kiểm tra điều kiện
  vào/ra của một stage, hoặc khi orchestrator cần chặn/cho-qua việc chuyển giai đoạn.
---

# Quality Gates

Mỗi giai đoạn có một `gate.md` với 2 danh sách: **DoR** (đủ điều kiện bắt đầu) và
**DoD** (đủ điều kiện kết thúc & đi tiếp). Không đủ → orchestrator **không cho qua**,
trả về giai đoạn trước.

## Cách kiểm một cổng

1. Đọc `stages/<NN-stage>/gate.md`.
2. Với mỗi mục DoR/DoD: kiểm chứng bằng artifact thật trong SSOT, không phỏng đoán.
3. Nếu mọi DoD ✅ → cập nhật `state.yaml` (`--gate-passed <stage>`), chuyển stage kế.
4. Nếu thiếu → ghi `progress.md` rõ thiếu gì, trả về stage chịu trách nhiệm.

## Độ nghiêm co giãn theo size

- `super-large`: mọi mục bắt buộc, không châm chước.
- `small`: bỏ các mục multi-region/i18n nếu không áp dụng.
- `personal` + `allow_fast_track: true`: được gộp cổng GĐ 01–06 thành một nếu task nhỏ.

## Ví dụ cổng GĐ 6 → 7 (trước khi code)

- DoR(7): `requirements.md` đã chốt; `api-contract.md` + `data-model.md` tồn tại; `tasks.md` có tiêu chí nghiệm thu; `glossary.md` thống nhất.
- DoD(7): code khớp `api-contract.md`; test GĐ8 sẵn sàng chạy; spec đã write-back nếu có lệch; `progress.md` cập nhật.

## Cổng đặc biệt: GĐ 10 (audit) → GĐ 12 (production)

Chỉ PASS khi `scorecard.yaml.gate == PASS` (composite ≥ threshold theo size **và** sạch
severity trong `block_on`). Xem skill `deep-audit`.

Template tạo cổng mới: `templates/gate.md` (cùng định dạng `scripts/init-context.sh` sinh ra).
