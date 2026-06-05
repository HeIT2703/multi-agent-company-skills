---
name: product-discovery
description: >
  Playbook bắt buộc cho pha DISCOVER + VALIDATE (GĐ1-8): tư duy trước khi build, nghiên cứu
  thị trường & đối thủ, phân khúc khách hàng & persona, nói chuyện với người dùng trước,
  battery validate ý tưởng, đo demand & dựng waitlist, thu thập yêu cầu, ưu tiên feature
  trước khi code. Tất cả theo tư duy Lean Startup Build-Measure-Learn. Dùng khi bắt đầu
  một dự án mới, khi cần validate ý tưởng trước khi viết code, khi nghiên cứu thị trường,
  khi phân tích đối thủ, khi dựng waitlist, hoặc khi ưu tiên feature.
---

# Product Discovery & Validation Playbook (GĐ1-8)

> NGUYÊN TẮC TỐI THƯỢNG: **KHÔNG viết một dòng code nào trước khi qua cổng validation (GĐ6)
> và cổng prioritization (GĐ8).** "Build cái không ai cần" là cách lãng phí lớn nhất.

Đây là LUẬT cho 2 pha đầu. Mỗi giai đoạn có: mục tiêu, hoạt động bắt buộc, artifact đầu ra,
và cổng (điều kiện thoát).

---

## PHA 1 — DISCOVER (GĐ1-3): Hiểu vấn đề & bối cảnh

### GĐ1 — Thinking & Problem Framing (Tư duy trước khi build)

> "Think before building." Đóng khung VẤN ĐỀ, KHÔNG nhảy vào giải pháp.

**Hoạt động bắt buộc:**
1. Viết **Problem Statement** theo khuôn: *"[Đối tượng] gặp [vấn đề] khi [bối cảnh], hiện tại họ [giải pháp tạm], điều đó tệ vì [hậu quả]."*
2. Phân biệt **symptom vs root cause** (5 Whys).
3. Liệt kê **giả định (assumptions)** — cái gì ta đang TIN mà chưa chứng minh.
4. Xác định **assumption rủi ro nhất** (nếu sai thì cả dự án sụp) → đây là cái phải validate đầu tiên.
5. KHÔNG bàn tech/feature ở đây. Chỉ vấn đề.

**Đầu ra:** `validation/problem-statement.md` (gồm: problem, assumptions, riskiest assumption).
**Cổng ra:** problem statement rõ ràng + danh sách assumption + đã chỉ ra riskiest assumption.

### GĐ2 — Market & Competitor Research (Nghiên cứu thị trường & đối thủ)

**Hoạt động bắt buộc (agent `researcher`):**
1. **Market sizing:** TAM / SAM / SOM (ước lượng có dẫn chứng, KHÔNG bịa số).
2. **Competitor matrix:** liệt kê ≥ 3 đối thủ trực tiếp + ≥ 2 gián tiếp.
3. Mỗi đối thủ phân tích: value prop, pricing, điểm mạnh, điểm yếu, segment họ phục vụ.
4. **Gap analysis:** khoảng trống nào đối thủ chưa lấp → cơ hội của ta.
5. **Trend:** xu hướng thị trường (đang lên/xuống), công nghệ mới liên quan.
6. Dùng web search để lấy dữ liệu thật. Ghi nguồn (URL + ngày).

**Đầu ra:** `validation/competitor-analysis.md` (market size + competitor matrix + gap + trend + nguồn).
**Cổng ra:** ≥ 5 đối thủ phân tích; gap analysis chỉ ra cơ hội cụ thể; có dẫn chứng.

### GĐ3 — Audience Segmentation & Personas (Phân khúc & persona)

**Hoạt động bắt buộc (agent `researcher`):**
1. Chia thị trường thành **segments** theo tiêu chí (demographic, behavior, need, willingness-to-pay).
2. Với mỗi segment: size, pain point, accessibility (có dễ tiếp cận không).
3. Chọn **Beachhead segment** (segment đầu tiên tập trung — nhỏ, đau nhất, dễ tiếp cận nhất).
4. Tạo **2-3 persona** chi tiết: tên, vai trò, mục tiêu, pain, hành vi, "một ngày của họ".
5. Mỗi persona gắn với **Jobs To Be Done (JTBD)**: *"Khi [tình huống], tôi muốn [động lực], để [kết quả mong đợi]."*

**Đầu ra:** `validation/audience-personas.md` (segments + beachhead + personas + JTBD).
**Cổng ra:** beachhead segment được chọn có lý do; ≥ 2 persona với JTBD rõ ràng.

---

## PHA 2 — VALIDATE (GĐ4-6): Chứng minh trước khi build

> Đây là vòng lặp **Build-Measure-Learn**. Mục tiêu: chứng minh (hoặc bác bỏ) riskiest
> assumption bằng BẰNG CHỨNG THẬT, không phải ý kiến.

### GĐ4 — User Conversations First (Nói chuyện với người dùng trước) 🧑

> "Talk to user first." Cổng human-checkpoint: con người tham gia/duyệt kế hoạch phỏng vấn.

**Hoạt động bắt buộc (agent `product-validator`):**
1. Thiết kế **interview script** theo The Mom Test:
   - Hỏi về QUÁ KHỨ & HÀNH VI THẬT, KHÔNG hỏi về tương lai giả định.
   - ĐÚNG: "Lần cuối bạn gặp vấn đề X là khi nào? Bạn đã làm gì?"
   - SAI: "Bạn có dùng sản phẩm làm Y không?" (câu hỏi dẫn dắt → câu trả lời lịch sự vô giá trị).
2. Phỏng vấn ≥ 5 người thuộc beachhead segment (số lượng theo size dự án).
3. Ghi lại nguyên văn pain points, ngôn ngữ họ dùng (đưa vào glossary).
4. Tổng hợp **pattern** xuất hiện ≥ 3 lần.
5. KHÔNG pitch ý tưởng trong phỏng vấn discovery (làm hỏng tính khách quan).

**Đầu ra:** `validation/user-interviews.md` (script + notes + patterns + quotes).
**Cổng ra (🧑 human duyệt):** ≥ 5 interview; ≥ 1 pain pattern lặp lại được xác nhận; quotes thật.

### GĐ5 — Idea Validation Battery (Tất cả loại validate ý tưởng)

**Hoạt động bắt buộc — chọn các experiment phù hợp (agent `product-validator`):**

| Loại validation | Cách làm | Tín hiệu PASS |
|-----------------|----------|---------------|
| **Problem validation** | Phỏng vấn (GĐ4) xác nhận pain có thật + đủ đau | ≥ 60% interviewee xác nhận pain |
| **Solution validation** | Mockup/wireframe/concept test với user | User hiểu + muốn dùng |
| **Wizard of Oz** | Giả lập sản phẩm bằng tay (human làm backend) | User hoàn thành task, hài lòng |
| **Concierge** | Phục vụ thủ công vài khách đầu | Khách quay lại, giới thiệu |
| **Smoke test / Fake door** | Landing page mô tả sản phẩm + nút CTA | Click-through rate > baseline |
| **Pre-sale / LOI** | Bán trước khi build (deposit / Letter of Intent) | Có người trả tiền/cam kết |
| **A/B value prop test** | Test 2-3 cách phát biểu value prop | 1 variant thắng rõ |

**Quy tắc cứng:**
- Mỗi experiment PHẢI có: hypothesis, metric, ngưỡng PASS/FAIL ĐỊNH TRƯỚC.
- KHÔNG đổi ngưỡng sau khi thấy kết quả (confirmation bias).
- Kết quả FAIL = học được, KHÔNG phải thất bại. Pivot hoặc kill.

**Đầu ra:** `validation/validation-experiments.md` (mỗi experiment: hypothesis + metric + threshold + result + learning).
**Cổng ra:** riskiest assumption đã được validate hoặc bác bỏ bằng dữ liệu.

### GĐ6 — Demand Validation & Waitlist (Đo nhu cầu & dựng waitlist)

> Cổng quan trọng nhất pha đầu: **CHỨNG MINH CÓ NHU CẦU THẬT trước khi đầu tư build.**

**Hoạt động bắt buộc (agent `product-validator`):**
1. Dựng **landing page** (value prop + CTA "đăng ký sớm / join waitlist").
2. Thu thập **demand signal:**
   - Số đăng ký waitlist.
   - Conversion rate (visit → signup).
   - Nguồn traffic (organic/paid/referral).
   - Mức độ engagement (mở email, share, mời bạn).
3. (Tùy chọn mạnh hơn) **Pre-order / deposit** — tín hiệu mạnh nhất là tiền.
4. So sánh với **ngưỡng demand ĐỊNH TRƯỚC** (theo size dự án).
5. Phân tích waitlist: ai đăng ký? có đúng beachhead segment không?

**Ngưỡng demand gợi ý (điều chỉnh theo bối cảnh):**

| size | Tín hiệu demand tối thiểu để PASS |
|------|-----------------------------------|
| personal | ≥ 50 signup HOẶC 10 người dùng thử cam kết |
| small | ≥ 500 signup HOẶC conversion > 20% HOẶC ≥ 10 pre-order |
| super-large | ≥ 2000 signup HOẶC ≥ 5 enterprise LOI HOẶC market validation rõ |

**Đầu ra:** `validation/demand-signals.md` + `validation/waitlist.md` (metrics + analysis + GO/PIVOT/KILL).
**Cổng ra (CỔNG VALIDATION — bắt buộc):**
- ✅ Demand signal ĐẠT ngưỡng → **GO** sang DEFINE (GĐ7).
- ⚠️ Không đạt → **PIVOT** (quay lại GĐ1-3 với góc nhìn mới) hoặc **KILL** (dừng dự án).
- 🔁 Vòng lặp này tối đa `max_validation_iterations` (mặc định 3) → chạm trần buộc quyết định.

---

## PHA 3 — DEFINE (GĐ7-9): Định nghĩa cái sẽ build

### GĐ7 — Requirements & Scope (Thu thập yêu cầu) 🧑

> Chỉ tới đây — SAU KHI có demand — mới định nghĩa chi tiết cái cần build.

**Hoạt động bắt buộc (agent `product`):** xem skill `decision-gates` GĐ requirements interview.
**Đầu ra:** `project/requirements.md`, `scope.md`, cập nhật `glossary.md`.
**Cổng ra (🧑):** requirements rõ + scope (in/out) + functional & non-functional.

### GĐ8 — Feature Prioritization (Ưu tiên feature TRƯỚC KHI code)

> "Prioritize features before coding." KHÔNG build mọi thứ cùng lúc. Tìm MVP thật.

**Hoạt động bắt buộc (agent `product`):**

1. Liệt kê TẤT CẢ feature ý tưởng.
2. Áp **MỘT** framework ưu tiên (chọn theo bối cảnh):

| Framework | Cách dùng | Tốt cho |
|-----------|-----------|---------|
| **MoSCoW** | Must / Should / Could / Won't-have | Quick, stakeholder alignment |
| **RICE** | (Reach × Impact × Confidence) / Effort | Data-driven, so sánh định lượng |
| **Kano** | Basic / Performance / Delighter | UX, hiểu cái gì gây "wow" |
| **Value vs Effort** | 2×2 matrix | Visual, nhanh, team nhỏ |

3. Xác định **MVP** = tập feature nhỏ nhất giải quyết JTBD cốt lõi của beachhead.
4. Mọi feature KHÔNG thuộc MVP → đẩy vào `backlog-next.md`.
5. Mỗi MVP feature gắn với 1 requirement + 1 persona JTBD (truy vết được).

**Quy tắc cứng:**
- MVP PHẢI giải quyết được riskiest assumption + JTBD cốt lõi.
- KHÔNG nhồi "nice-to-have" vào MVP. Nếu nghi ngờ → Won't-have.
- Feature không map tới persona/JTBD nào = LOẠI.

**Đầu ra:** `project/requirements.md` (đánh dấu MVP) + `options/priority-matrix.md`.
**Cổng ra (CỔNG PRIORITIZATION — bắt buộc):** MVP được chốt; mọi MVP feature truy vết tới JTBD; phần còn lại ở backlog.

### GĐ9 — Feasibility & Solution Options

Sinh phương án kỹ thuật (platform/arch/tech) — xem skill `decision-gates` + `tech-knowledge-base.md`.

---

## Feedback-Loop-Based Building (xuyên suốt)

> "Feedback-loop-based building." Build-Measure-Learn KHÔNG chỉ ở pha đầu — nó là DNA.

| Vòng lặp | Ở đâu | Cơ chế |
|----------|-------|--------|
| **Validation loop** | GĐ4-6 | Experiment → đo demand → GO/PIVOT/KILL (max 3 vòng) |
| **Discover⇄Decide loop** | GĐ1-10 | Nghiên cứu → quyết định → unknowns mới → lặp |
| **Dev feedback loop** | GĐ17 | Build increment → demo/review → adjust → tiếp |
| **Audit loop** | GĐ20-21 | Audit → fix → re-audit (circuit-breaker) |
| **Product loop** | GĐ24 → GĐ1 | Ship → đo metric thật → feedback → vòng sau |

**Quy tắc cứng cho dev feedback loop (GĐ17):**
- Build theo increment nhỏ (1 MVP feature/lần), KHÔNG big-bang.
- Mỗi increment: demo được + review + đối chiếu với JTBD.
- Thu feedback sớm (internal demo, beta user) → điều chỉnh `backlog`.

---

## Co giãn theo size

| size | Pha DISCOVER+VALIDATE chạy thế nào |
|------|-------------------------------------|
| **personal** | Gọn: GĐ1 + GĐ2 (3 đối thủ) + GĐ4 (3 interview) + GĐ6 (landing page đơn giản). Bỏ GĐ5 nặng. |
| **small** | Đầy đủ nhưng nhẹ: mọi GĐ, validation battery chọn 2-3 loại, demand ngưỡng vừa. |
| **super-large** | FULL: market sizing kỹ, ≥ 5 đối thủ, ≥ 10 interview, multi-experiment, enterprise LOI. |

---

## Tài nguyên

- Khung & template chi tiết: `references/validation-playbook.md`
- Tech options (GĐ9): skill `decision-gates` → `tech-knowledge-base.md`
- Artifact lưu ở: `.context/validation/`

> Nguồn tư duy: Lean Startup (Build-Measure-Learn), The Mom Test (interview),
> Jobs To Be Done, RICE/MoSCoW/Kano prioritization. Rephrased for licensing compliance.
