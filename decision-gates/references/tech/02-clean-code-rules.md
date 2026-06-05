# 02 — LUẬT CLEAN CODE & TỔ CHỨC MÃ NGUỒN (Bắt buộc)

> ĐÂY LÀ LUẬT. Agent viết code PHẢI tuân theo. Vi phạm ở GĐ14 audit = finding.

---

## NGUYÊN TẮC BẤT BIẾN

1. **Code phải đọc được như văn xuôi.** Nếu cần comment để giải thích "code này làm gì" = code tệ.
2. **Mỗi function/method LÀM MỘT VIỆC.** Tên function = mô tả chính xác việc đó.
3. **Mỗi file/module MỘT TRÁCH NHIỆM.** Không trộn business logic + infra + UI.
4. **Không để code chết.** Commented code, unused import, dead function = XÓA ngay.
5. **Test đi kèm code.** Viết feature = viết test. Không test = không tồn tại.

---

## LUẬT NAMING (bắt buộc mọi ngôn ngữ)

| Đối tượng | Quy tắc | Ví dụ đúng | Ví dụ sai |
|-----------|---------|------------|-----------|
| Biến/tham số | camelCase, mô tả rõ ý nghĩa | `userEmail`, `orderCount` | `x`, `data`, `temp`, `val` |
| Hằng | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` | `maxRetry` |
| Function/method | camelCase, BẮT ĐẦU bằng động từ | `getUserById()`, `calculateTotal()` | `user()`, `total()`, `process()` |
| Class/Type | PascalCase, danh từ | `OrderService`, `PaymentGateway` | `DoOrder`, `Pay` |
| Boolean | BẮT ĐẦU bằng is/has/can/should | `isActive`, `hasPermission` | `active`, `permission` |
| Collection | PLURAL | `orders`, `userIds` | `orderList`, `userIdArray` |
| Interface | PascalCase (KHÔNG prefix I) | `PaymentGateway` | `IPaymentGateway` |
| File name | kebab-case (hoặc convention của framework) | `order-service.ts` | `OrderService.ts` (trừ class-per-file lang) |

**CẤM tuyệt đối:**
- Tên 1–2 ký tự (trừ `i,j` trong loop ngắn, `e` trong catch).
- Tên generic: `data`, `info`, `item`, `result`, `temp`, `stuff`, `handler`, `manager`, `processor` (trừ khi THẬT SỰ generic).
- Viết tắt không phổ biến: `usr`, `qty`, `amt` → dùng `user`, `quantity`, `amount`.

---

## LUẬT FUNCTION/METHOD

```
MỖI FUNCTION PHẢI:
1. Làm MỘT việc (Single Responsibility).
2. Có tên mô tả CHÍNH XÁC việc đó (không cần đọc body).
3. ≤ 20 dòng (soft limit). > 40 dòng = BẮT BUỘC tách.
4. ≤ 3 tham số. > 3 = dùng object/DTO.
5. Không side-effect ẩn (ghi DB, gửi email mà tên không nói).
6. Return sớm khi có thể (guard clause). Không nest > 3 level.
7. Không mix abstraction levels (HTTP parsing + business logic + DB query trong 1 function = CẤM).
```

**Khuôn mẫu guard clause:**
```typescript
// ĐÚNG:
function processOrder(order: Order): Result {
  if (!order) return Result.fail('Order is null');
  if (order.status !== 'pending') return Result.fail('Not pending');
  if (!order.items.length) return Result.fail('Empty order');

  // happy path
  const total = calculateTotal(order.items);
  return Result.ok(total);
}

// SAI (pyramid of doom):
function processOrder(order: Order): Result {
  if (order) {
    if (order.status === 'pending') {
      if (order.items.length > 0) {
        // ...
      }
    }
  }
}
```

---

## LUẬT FILE/MODULE ORGANIZATION

### Feature-based (BẮT BUỘC cho app > 5 features)

```
src/features/<feature-name>/
├── <feature>.controller.ts    # HTTP/UI handler (thin — chỉ parse request + gọi service)
├── <feature>.service.ts       # Business logic (KHÔNG biết HTTP, KHÔNG biết DB)
├── <feature>.repository.ts    # Data access (KHÔNG biết business rules)
├── <feature>.model.ts         # Domain entity/DTO
├── <feature>.validator.ts     # Input validation schema
├── <feature>.types.ts         # TypeScript types/interfaces
└── <feature>.test.ts          # Unit tests
```

**LUẬT cứng:**
- Controller KHÔNG chứa business logic. Chỉ: parse input → validate → gọi service → format output.
- Service KHÔNG import từ infra trực tiếp. Gọi qua interface (DI).
- Repository KHÔNG chứa business rules. Chỉ CRUD.
- KHÔNG import "internal" của feature khác. Qua public interface.

### Layer dependency rule (Dependency Inversion)

```
UI / Controller → Service (Business) → Repository Interface
                                              ↑
                                        Repository Impl (Infra)

BẮT BUỘC: mũi tên dependency CHỈ đi VÀO (tức infra DEPEND on business, KHÔNG ngược lại).
Business layer KHÔNG import:
  ❌ express, fastify, koa (HTTP framework)
  ❌ prisma, typeorm, mongoose (ORM trực tiếp)
  ❌ redis, kafka (infra client trực tiếp)
Business layer CHỈ biết:
  ✅ Interface (port) mà infra sẽ implement (adapter)
```

---

## LUẬT ERROR HANDLING

```
1. KHÔNG bao giờ swallow error (catch rồi bỏ trống).
2. KHÔNG throw generic Error. Dùng typed error (custom class/union).
3. Error message PHẢI actionable (người đọc biết phải làm gì).
4. Phân biệt rõ: Operational Error (expected, handle) vs Programming Error (bug, crash).
5. BẮT BUỘC có error boundary ở top-level (global handler).
6. Log error với context (userId, requestId, input). KHÔNG log sensitive data (password, token).
```

**Khuôn mẫu typed error:**
```typescript
// ĐÚNG: custom error types
class OrderNotFoundError extends AppError {
  constructor(orderId: string) {
    super(`Order ${orderId} not found`, 'ORDER_NOT_FOUND', 404);
  }
}

class InsufficientBalanceError extends AppError {
  constructor(userId: string, required: number, available: number) {
    super(`User ${userId} needs ${required} but has ${available}`, 'INSUFFICIENT_BALANCE', 400);
  }
}
```

---

## LUẬT DEPENDENCY INJECTION

```
1. BẮT BUỘC: mọi external dependency (DB, cache, API, queue) inject qua constructor / parameter.
2. KHÔNG import singleton/global instance trong business logic.
3. Mục đích: test được bằng mock/stub MÀ KHÔNG cần real DB/network.
```

**Khuôn mẫu:**
```typescript
// ĐÚNG:
class OrderService {
  constructor(
    private readonly orderRepo: OrderRepository,  // interface
    private readonly paymentGateway: PaymentGateway,  // interface
    private readonly eventBus: EventBus  // interface
  ) {}
}

// SAI:
class OrderService {
  private db = new PrismaClient();  // ← hard dependency, untestable
}
```

---

## LUẬT TESTING

| Loại | Bao nhiêu | Test cái gì | KHÔNG test |
|------|-----------|-------------|------------|
| **Unit** | Nhiều nhất (70–80%) | Business logic, validation, transformation | Framework code, getter/setter |
| **Integration** | Vừa (15–20%) | API endpoint + DB thật, service + repo | UI, external API |
| **E2E** | Ít nhất (5–10%) | Critical user flow end-to-end | Edge case (để unit test) |

```
LUẬT:
1. Test name = "should <hành vi> when <điều kiện>".
2. Mỗi test case test MỘT hành vi. Không assert 10 thứ trong 1 test.
3. Arrange → Act → Assert (AAA pattern). Rõ ràng 3 phần.
4. KHÔNG test implementation detail (private method, internal state). Test behavior.
5. Test PHẢI chạy isolated (không depend lẫn nhau, không depend thứ tự).
6. KHÔNG mock cái mình không sở hữu (đừng mock axios, mock HTTP layer ở integration thay vì).
```

---

## LUẬT GIT & COMMIT

```
1. Mỗi commit = MỘT thay đổi logic duy nhất. Không trộn feature + fix + refactor.
2. Commit message format: <type>(<scope>): <description>
   type: feat | fix | refactor | docs | test | chore | perf
   Ví dụ: feat(orders): add payment retry logic
3. Branch naming: <type>/<short-description>
   Ví dụ: feat/order-payment-retry, fix/auth-token-expiry
4. KHÔNG commit: .env, secrets, node_modules, build artifacts, .DS_Store
5. PR/MR: ≤ 400 dòng thay đổi (big = chia nhỏ). > 400 = cần ADR giải thích.
```

---

## LUẬT API DESIGN (REST)

```
1. Resource-based URL: /users, /users/:id, /users/:id/orders
2. HTTP method = hành động: GET(đọc), POST(tạo), PUT(thay toàn bộ), PATCH(thay một phần), DELETE(xóa)
3. Status code chính xác: 200(ok), 201(created), 204(no content), 400(bad request), 401(unauthenticated), 403(forbidden), 404(not found), 409(conflict), 422(validation), 500(server error)
4. Response format thống nhất:
   { "data": ..., "meta": { "page": 1, "total": 100 } }
   { "error": { "code": "ORDER_NOT_FOUND", "message": "...", "details": [...] } }
5. Versioning: URL prefix /api/v1/ HOẶC header (chọn 1, không trộn).
6. Pagination BẮT BUỘC cho list endpoint: ?page=1&limit=20 hoặc cursor-based.
7. Filter/sort: ?status=active&sort=-createdAt
8. KHÔNG expose internal ID format (auto-increment) nếu security concern. Dùng UUID/ULID.
```

---

## LUẬT LOGGING & OBSERVABILITY

```
1. Log level đúng: ERROR(cần fix ngay), WARN(bất thường nhưng chưa chết), INFO(event quan trọng), DEBUG(chỉ dev).
2. Structured logging (JSON format): { "level": "error", "message": "...", "requestId": "...", "userId": "...", "error": {...} }
3. KHÔNG log: password, token, PII (email/phone nếu không cần), credit card.
4. BẮT BUỘC có: requestId/correlationId xuyên suốt (trace distributed call).
5. Mọi external call (DB, API, queue) PHẢI có: timing metric + error count.
```
