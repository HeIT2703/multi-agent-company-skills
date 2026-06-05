# 05 — LUẬT FRONTEND & UI (Bắt buộc)

> ĐÂY LÀ LUẬT. Vi phạm = finding GĐ14 Part A/C.

---

## NGUYÊN TẮC BẤT BIẾN

1. **UI = hàm của state.** UI(state) → view. KHÔNG modify DOM trực tiếp ngoài framework.
2. **Component nhỏ, đơn mục đích.** > 150 dòng = tách.
3. **Tách Business Logic khỏi UI.** Component KHÔNG chứa fetch/compute phức tạp.
4. **Accessibility (a11y) không phải optional.** WCAG 2.1 AA bắt buộc.
5. **Performance budget là law.** LCP < 2.5s, FID < 100ms, CLS < 0.1.

---

## LUẬT COMPONENT

```
1. Mỗi component = 1 file. Tên = PascalCase. File = kebab-case.
2. Props: typed (TypeScript/PropTypes). KHÔNG any/unknown cho props.
3. ≤ 5 props lý tưởng. > 8 props = tách component hoặc dùng compound pattern.
4. KHÔNG business logic trong component. Gọi hook/service/store.
5. KHÔNG fetch data trong component trực tiếp. Dùng hook/composable/loader.
6. Children/slot cho composition. KHÔNG prop drilling > 3 level.
7. Key prop BẮT BUỘC cho list rendering. KHÔNG dùng index làm key (trừ static list).
```

### Cấu trúc feature-based BẮT BUỘC (>5 features)

```
src/features/<feature>/
├── components/         { presentational components }
├── hooks/              { business logic hooks/composables }
├── services/           { API calls }
├── stores/             { state slice nếu cần }
├── types.ts            { interfaces/types }
├── utils.ts            { pure helper }
├── <Feature>.tsx       { page/entry component }
└── <Feature>.test.tsx  { test }
```

---

## LUẬT STATE MANAGEMENT

### Bảng chọn (BẮT BUỘC theo kích thước)

| Kích thước state | Giải pháp | CẤM |
|------------------|-----------|-----|
| Local (1 component) | useState / ref | Global store |
| Shared (2-3 components gần) | Lift state up / Context | Redux cho 2 component |
| Feature-level | Zustand / Pinia / slice | Monolithic global store |
| App-wide (auth, theme, i18n) | Global store (Redux/Zustand/Pinia) | useState scattered |
| Server state (API data) | React Query / SWR / TanStack Query | Manual fetch + useState |

### LUẬT server state

```
1. BẮT BUỘC dùng server-state library (TanStack Query, SWR, Apollo).
2. KHÔNG manual useState + useEffect cho fetch. (stale closure, race condition, no cache).
3. Caching + revalidation strategy BẮT BUỘC (staleTime, cacheTime).
4. Loading/error/success state PHẢI handle đủ 3. KHÔNG chỉ happy path.
5. Optimistic update cho UX tốt (revert nếu fail).
```

---

## LUẬT STYLING

```
1. CHỌN 1 approach, tuân theo toàn dự án. KHÔNG trộn.
   Cho phép: CSS Modules | Tailwind | Styled-components | CSS-in-JS | SCSS Modules
2. Design tokens (color, spacing, font-size) PHẢI từ design-system. KHÔNG hardcode.
3. Responsive: mobile-first. BẮT BUỘC test 3 breakpoint (mobile/tablet/desktop).
4. KHÔNG !important (trừ override thư viện bên ngoài có ADR).
5. Dark mode: nếu có trong requirements, thiết kế từ đầu (CSS variables/theme).
```

---

## LUẬT FORM

```
1. BẮT BUỘC validation library (Zod/Yup + React Hook Form / VeeValidate / Formik).
2. Validate client-side (UX nhanh) + server-side (security). KHÔNG chỉ 1 phía.
3. Error message rõ ràng, actionable, gần field lỗi.
4. Submit button: disable khi submitting. Hiện loading state.
5. KHÔNG mất data khi user navigate accident (unsaved changes warning).
```

---

## LUẬT ROUTING & NAVIGATION

```
1. Route = URL. Mỗi page/view có URL duy nhất (deep-linkable).
2. Protected route: redirect to login nếu chưa auth. KHÔNG render rồi mới check.
3. 404 page BẮT BUỘC.
4. Loading state cho route transition (skeleton/spinner).
5. Breadcrumb / back navigation cho app có depth > 2.
```

---

## LUẬT PERFORMANCE

### Budget bắt buộc (Web Core Vitals)

| Metric | Target | Công cụ đo |
|--------|--------|-----------|
| LCP (Largest Contentful Paint) | < 2.5s | Lighthouse |
| FID/INP (Interaction to Next Paint) | < 200ms | Web Vitals |
| CLS (Cumulative Layout Shift) | < 0.1 | Lighthouse |
| Bundle size (JS initial) | < 200KB gzipped | Bundler analyzer |
| TTI (Time to Interactive) | < 3.5s | Lighthouse |

### LUẬT cứng

```
1. Code splitting BẮT BUỘC: route-based lazy loading.
2. Image: WebP/AVIF format + responsive srcset + lazy loading (loading="lazy").
3. Font: subset + display=swap + preload critical.
4. KHÔNG import toàn bộ library nặng (lodash, moment). Dùng tree-shakable hoặc native.
5. Memoize expensive computation (useMemo, computed). KHÔNG memoize mọi thứ.
6. Virtual scroll cho list > 100 items.
7. Debounce search/filter input (300ms).
```

---

## LUẬT ACCESSIBILITY (a11y)

```
BẮT BUỘC (WCAG 2.1 AA):
1. Semantic HTML: <button> cho click, <a> cho navigate, <nav>/<main>/<header>.
2. Mọi <img> có alt text (decorative = alt="").
3. Form field có <label> linked (htmlFor/id).
4. Color contrast ratio ≥ 4.5:1 (text), ≥ 3:1 (large text/UI).
5. Keyboard navigable: Tab order logic, focus visible, no trap.
6. Screen reader: aria-label cho icon button, aria-live cho dynamic content.
7. Skip to main content link.
8. Error messages linked to field (aria-describedby).
```

---

## LUẬT TESTING (Frontend-specific)

| Loại | Tool | Test cái gì |
|------|------|------------|
| Component unit | Vitest + Testing Library | Render, interaction, a11y |
| Hook/logic | Vitest | Business logic isolated |
| Integration | Testing Library + MSW | Feature flow với mock API |
| E2E | Playwright / Cypress | Critical path real browser |
| Visual | Chromatic / Percy | UI regression |

```
LUẬT:
1. Test BEHAVIOR không DOM structure (getByRole, getByText — KHÔNG querySelector).
2. Mock API ở network level (MSW). KHÔNG mock fetch/axios.
3. Mỗi component có ít nhất 1 test: render + key interaction.
```

---

## LUẬT INTERNATIONALIZATION (i18n)

```
1. KHÔNG hardcode text trong component. Mọi string hiển thị đi qua i18n.
2. Key format: <feature>.<context>.<label>  Ví dụ: orders.status.pending
3. Plural/gender rules: dùng ICU format.
4. RTL support: nếu target Arabic/Hebrew, dùng logical properties (margin-inline-start).
5. Date/number format: dùng Intl API, KHÔNG format thủ công.
```

---

## LUẬT SEO (Web — SSR/SSG)

```
1. <title> unique mỗi page. ≤ 60 ký tự.
2. <meta description> unique. ≤ 155 ký tự.
3. <h1> duy nhất mỗi page. Hierarchy h1>h2>h3.
4. Canonical URL cho duplicate content.
5. Structured data (JSON-LD) cho product/article/FAQ.
6. Sitemap.xml + robots.txt.
7. Open Graph + Twitter Card meta cho social sharing.
8. Ảnh: alt text + width/height attribute (CLS).
```
