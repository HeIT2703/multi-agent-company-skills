# Validation Playbook — Khuôn mẫu & Template chi tiết

> Template cứng cho từng artifact của pha DISCOVER + VALIDATE. Agent điền theo đúng cấu trúc.

---

## Template: problem-statement.md (GĐ1)

```markdown
# Problem Statement

## Câu phát biểu vấn đề
[Đối tượng] gặp [vấn đề] khi [bối cảnh].
Hiện tại họ [giải pháp tạm thời].
Điều đó tệ vì [hậu quả/chi phí].

## Root cause (5 Whys)
1. Tại sao? ...
2. Tại sao? ...
(đào tới gốc)

## Assumptions (giả định đang TIN nhưng CHƯA chứng minh)
- A1: [giả định] — mức rủi ro: cao/trung/thấp
- A2: ...

## RISKIEST ASSUMPTION (validate đầu tiên)
> A_x: [giả định mà nếu sai thì cả dự án sụp]

## KHÔNG thuộc phạm vi tư duy này
- (KHÔNG bàn tech, KHÔNG bàn feature — chỉ vấn đề)
```

---

## Template: competitor-analysis.md (GĐ2)

```markdown
# Market & Competitor Research

## Market Sizing
- TAM (Total Addressable Market): $X — nguồn: [URL, ngày]
- SAM (Serviceable Available Market): $Y
- SOM (Serviceable Obtainable Market): $Z (thực tế ta có thể lấy)

## Competitor Matrix
| Đối thủ | Loại | Value Prop | Pricing | Mạnh | Yếu | Segment |
|---------|------|-----------|---------|------|-----|---------|
| A | trực tiếp | ... | ... | ... | ... | ... |
| B | trực tiếp | ... | ... | ... | ... | ... |
| C | gián tiếp | ... | ... | ... | ... | ... |

## Gap Analysis (cơ hội)
- Khoảng trống 1: [đối thủ chưa lấp] → cơ hội: ...

## Trends
- Xu hướng đang lên: ...
- Công nghệ mới liên quan: ...

## Nguồn
- [URL] (truy cập [ngày])
```

---

## Template: audience-personas.md (GĐ3)

```markdown
# Audience Segmentation & Personas

## Segments
| Segment | Size | Pain chính | Willingness-to-pay | Dễ tiếp cận? |
|---------|------|-----------|--------------------|--------------| 
| S1 | ... | ... | ... | ... |

## BEACHHEAD (segment tập trung đầu tiên)
> S_x — vì: nhỏ đủ để thắng, đau nhất, dễ tiếp cận nhất.

## Persona 1: [Tên]
- Vai trò / nghề: ...
- Mục tiêu: ...
- Pain points: ...
- Hành vi hiện tại: ...
- Một ngày của họ: ...
- JTBD: "Khi [tình huống], tôi muốn [động lực], để [kết quả]."

## Persona 2: ...
```

---

## Template: user-interviews.md (GĐ4) — The Mom Test

```markdown
# User Interviews

## Interview Script (The Mom Test)
NGUYÊN TẮC: hỏi quá khứ & hành vi thật, KHÔNG hỏi tương lai giả định, KHÔNG pitch.

Câu hỏi mở:
1. "Lần gần nhất bạn gặp [vấn đề] là khi nào? Kể tôi nghe."
2. "Bạn đã làm gì để giải quyết? Tốn bao lâu/bao nhiêu?"
3. "Phần nào khó chịu nhất?"
4. "Bạn đã thử giải pháp nào khác chưa? Tại sao bỏ?"
5. "Nếu có cây đũa thần, bạn ước gì?"

CẤM hỏi: "Bạn có dùng sản phẩm làm X không?" (dẫn dắt → vô giá trị)

## Interview Log
### Người 1 — [segment, ngày]
- Quote nguyên văn: "..."
- Pain observed: ...
- Hành vi thật: ...

### Người 2 ...

## Patterns (lặp ≥ 3 lần)
- Pattern 1: [N/5 người] ...
- Ngôn ngữ họ dùng (→ glossary): "..."

## Kết luận
- Pain được xác nhận? CÓ/KHÔNG ([N]/[total])
```

---

## Template: validation-experiments.md (GĐ5)

```markdown
# Idea Validation Experiments

## Experiment 1: [Loại — vd Smoke Test]
- Hypothesis: "Chúng tôi tin rằng [X]."
- Metric: [đo cái gì]
- Threshold PASS (định TRƯỚC): [ngưỡng]
- Setup: [cách chạy]
- Kết quả: [số liệu thật]
- Verdict: PASS / FAIL
- Learning: [học được gì]
- Hành động: tiếp tục / pivot / kill

## Experiment 2: ...

## Tổng kết
- Riskiest assumption: validated / invalidated
- Quyết định: GO / PIVOT / KILL
```

---

## Template: demand-signals.md + waitlist.md (GĐ6)

```markdown
# Demand Validation

## Landing Page
- URL: ...
- Value prop test: [variant thắng]
- CTA: [join waitlist / pre-order]

## Demand Signals
| Metric | Giá trị | Ngưỡng PASS | Đạt? |
|--------|---------|-------------|------|
| Waitlist signups | ... | ... | ✅/❌ |
| Conversion (visit→signup) | ...% | >X% | |
| Pre-orders / deposits | ... | ... | |
| Referral / shares | ... | ... | |

## Phân tích Waitlist
- Ai đăng ký? Đúng beachhead segment? [%]
- Nguồn traffic: organic/paid/referral [breakdown]
- Engagement: email open rate, invite rate

## QUYẾT ĐỊNH CỔNG VALIDATION
- [ ] GO — demand đạt ngưỡng → sang GĐ7 DEFINE
- [ ] PIVOT — quay lại GĐ1-3 (validation_iteration +1)
- [ ] KILL — dừng dự án (ghi ADR lý do)
```

---

## Template: priority-matrix.md (GĐ8)

```markdown
# Feature Prioritization

## Framework dùng: [MoSCoW / RICE / Kano / Value-Effort]

## RICE scoring (nếu dùng RICE)
| Feature | Reach | Impact | Confidence | Effort | RICE Score | Persona/JTBD |
|---------|-------|--------|-----------|--------|-----------|--------------|
| F1 | ... | ... | ... | ... | =(R×I×C)/E | P1 / JTBD-x |

## MVP (Must-have — giải quyết JTBD cốt lõi)
- [ ] F1 — map: [requirement] + [persona JTBD]
- [ ] F2 — ...

## Backlog (Should/Could → backlog-next.md)
- F5, F6, ...

## Won't-have (loại khỏi scope hiện tại)
- F9 (lý do: không map JTBD nào)

## Truy vết
> Mọi MVP feature PHẢI có dòng map tới requirement + persona JTBD. Không map = LOẠI.
```

---

## Checklist tổng cho pha DISCOVER + VALIDATE

```
GĐ1 [ ] Problem statement + riskiest assumption
GĐ2 [ ] ≥5 đối thủ + gap analysis + nguồn
GĐ3 [ ] Beachhead + ≥2 persona + JTBD
GĐ4 [ ] ≥5 interview (Mom Test) + pain pattern  🧑
GĐ5 [ ] ≥1 experiment với threshold định trước
GĐ6 [ ] Demand đạt ngưỡng → GO/PIVOT/KILL  ← CỔNG VALIDATION
GĐ7 [ ] Requirements + scope  🧑
GĐ8 [ ] MVP chốt + truy vết JTBD  ← CỔNG PRIORITIZATION
```
