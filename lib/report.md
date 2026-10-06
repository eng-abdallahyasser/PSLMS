# API Wiring Report

Analysis of which endpoints in `API_DOC.json` (**65 paths**) are wired into the Flutter app (`lib/`), after the API-sync implementation (see `docs/IMPLEMENTATION_PLAN.md`).

**Legend**
- ✅ **Wired** — HTTP call exists in a datasource **and** is triggered from the UI (page → cubit → use case → repo → datasource).
- ⚠️ **Data layer only** — datasource/repo/cubit method exists, but **no page calls it** (dormant).
- ❌ **Not wired** — no code references the endpoint at all.
- 🔧 **Server-side** — backend callback/webhook, not meant to be called by the app.

## Summary

| Status | Count |
|---|---|
| ✅ Wired (full UI → API) | 33 |
| ⚠️ Data layer only (no UI trigger) | 14 |
| ❌ Not wired | 15 |
| 🔧 Server-side / by design | 3 |
| **Total paths** | **65** |

---

## Auth (`/auth/*`)

| Endpoint | Status | Notes |
|---|---|---|
| `POST /api/auth/register` | ✅ | RegisterPage (universities dropdown via `/public/universities`) |
| `POST /api/auth/login` | ✅ | LoginPage |
| `POST /api/auth/verify-email` | ✅ | VerifyEmailPage |
| `POST /api/auth/send-otp` | ✅ | VerifyEmailPage (resend) |
| `POST /api/auth/send-mobile-otp` | ✅ | MobileOtpPage |
| `POST /api/auth/verify-mobile-otp` | ✅ | MobileOtpPage |
| `POST /api/auth/forgot-password` | ✅ | ForgotPasswordPage |
| `POST /api/auth/reset-password` | ✅ | ResetPasswordPage |
| `POST /api/auth/refresh` | ✅ | Auto token-refresh interceptor (`ApiClient`) |
| `POST /api/auth/logout` | ✅ | ProfilePage (logout) |
| `GET /api/auth/google` | ⚠️ | `SocialAuthService` builds URL, `AuthCubit.signInWithGoogle` exists — **no social button in Login/Register UI** |
| `GET /api/auth/facebook` | ⚠️ | Same as Google — dormant |
| `POST /api/auth/complete-registration` | ⚠️ | Full chain (use case → `AuthCubit` event) exists, only reachable after a social flow that has no UI |
| `GET /api/auth/google/callback` | 🔧 | Server renders result; app parses tokens via `FlutterWebAuth2` |
| `GET /api/auth/facebook/callback` | 🔧 | Same as above |

## Health & Webhook

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api` | ❌ | No health-check call in app |
| `POST /api/webhooks/kashier` | 🔧 | Kashier payment webhook handled by backend |

## Profile (`/profile/*`)

| Endpoint | Status | Notes |
|---|---|---|
| `GET/PATCH /api/profile/me` | ✅ | ProfilePage (name edit) |
| `PATCH /api/profile/me/preferences` | ✅ | ProfilePage (lang/theme) |
| `POST /api/profile/me/avatar` | ✅ | ProfilePage (avatar upload, multipart) |

## Instructor — Courses, Content & Revenue

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/instructor/courses` | ✅ | CoursesPage + DashboardCubit |
| `POST /api/instructor/courses` | ⚠️ | `CourseCubit.createCourse` exists — **no create form/UI** |
| `PATCH /api/instructor/courses/{id}` | ⚠️ | `CourseCubit.updateCourse` exists — no UI |
| `DELETE /api/instructor/courses/{id}` | ⚠️ | `CourseCubit.deleteCourse` exists — no UI |
| `GET /api/instructor/courses/{id}` | ❌ | No datasource method; `getCourseById` calls `/learner/courses/{id}` instead |
| `GET /api/instructor/courses/stats/dashboard` | ❌ | Dashboard stats are **computed client-side** from course lists |
| `GET /api/instructor/courses/{id}/sales` | ❌ | No sales screen in app |
| `GET /api/instructor/revenue` | ✅ | DashboardCubit (revenue card) + StoragePage revenue section |
| `GET /api/instructor/courses/{courseId}/content` | ✅ | ContentsPage |
| `POST .../content/upload-session` | ✅ | Upload flow step 1 (`ContentRemoteDataSource.uploadContent`) |
| `POST .../content/complete-upload` | ✅ | Upload flow step 3 (after provider upload) |
| `PATCH .../content/reorder` | ✅ | ContentsPage (drag reorder, body `contentIds` + `videoIds`) |
| `GET/PATCH/DELETE .../content/{contentId}` | ✅ | ContentsPage (list / edit `isPreview` / delete) |
| `GET .../content/{contentId}` (single) | ✅ | Covered by edit flow / list data |

## Instructor — Storage & Billing

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/instructor/storage/usage` | ✅ | StoragePage (usage progress card) |
| `GET /api/instructor/storage/plans` | ✅ | StoragePage (plans list) |
| `POST /api/instructor/storage/subscribe` | ✅ | StoragePage (subscribe with `planId` → Kashier checkout) |

## Learner — Courses & Purchases

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/learner/courses` | ✅ | CoursesPage (learner role) |
| `GET /api/learner/courses/{id}` | ⚠️ | `getCourseById` in datasource/repo — no cubit/UI caller |
| `POST /api/learner/courses/{id}/purchase` | ✅ | CourseCard → `PurchaseCubit` (payment flow) |
| `GET /api/learner/my-courses` | ✅ | MyCoursesPage |
| `GET /api/learner/my-courses/{id}` | ⚠️ | `MyCoursesCubit.getMyCourseDetail` exists — no page calls it |
| `GET /api/learner/my-courses/{courseId}/content` | ✅ | MyCourseDetailPage |
| `GET /api/learner/my-courses/{courseId}/content/{contentId}` | ⚠️ | `LearnerContentCubit.getContentDetail` — no detail page/UI |

## Learner — Instructors

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/learner/instructors` | ✅ | SearchInstructorsPage |
| `GET /api/learner/instructors/{id}` | ✅ | InstructorProfilePage |

Note: `/learner/my-instructors*`, `/learner/invitations*`, `/learner/instructors/{id}/join` and the old enrollment endpoints were **removed from the API and from the app** (Plan Phase 4).

## Notifications

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/notifications` | ✅ | NotificationsPage |
| `PATCH /api/notifications/{id}/read` | ✅ | NotificationsPage |
| `POST /api/notifications/read-all` | ✅ | NotificationsPage |

## Uploads (shared)

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/uploads/session/{sessionId}/status` | ⚠️ | `getUploadStatus` in datasource — no UI polling |
| `DELETE /api/uploads/session/{sessionId}` | ⚠️ | `abortUpload` in datasource — no caller |

## Public / Discovery (`/public/*`)

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/public/universities` | ✅ | RegisterPage (university dropdown) |
| `GET /api/public/universities/{id}` | ❌ | No caller |
| `GET /api/public/categories` | ⚠️ | `DiscoveryRepository.getCategories` + use case registered in DI — **no UI** (guest mode unsupported) |
| `GET /api/public/courses` | ⚠️ | Same — discovery feature is data-layer only |
| `GET /api/public/courses/{id}` | ⚠️ | Same |
| `GET /api/public/instructors` | ⚠️ | Same |
| `GET /api/public/instructors/{id}` | ⚠️ | Same |

## Admin (`/admin/*`) — NOT WIRED (11 paths)

No admin feature exists in the app (only the `UserRole.admin` enum). All are ❌:

- `GET/POST /admin/users`, `GET/PATCH/DELETE /admin/users/{id}`
- `GET/POST /admin/storage-plans`, `PATCH /admin/storage-plans/{id}`
- `GET/PATCH/DELETE /admin/courses`, `GET/PATCH/DELETE /admin/courses/{id}`
- `GET/POST /admin/universities`, `PATCH /admin/universities/{id}`
- `GET/POST /admin/categories`, `PATCH /admin/categories/{id}`
- `POST /admin/push-notifications/test`

---

## Mismatches & Risks (post-sync)

1. **`GET /instructor/courses/stats/dashboard` unused** — dashboard numbers are computed client-side from `GET /instructor/courses`; backend-counted metrics would be authoritative.
2. **`GET /instructor/courses/{id}` unused** — `getCourseById` targets `/learner/courses/{id}`; instructor-side single-course fetch never called.
3. **Google / Facebook OAuth dormant in UI** — `SocialLoginButton`, `signInWithGoogle/Facebook`, and `complete-registration` are fully wired through the data layer but no login/register screen renders a social button.
4. **Half-finished learner flows:** `learner/courses/{id}`, `my-courses/{id}`, content detail, and instructor course create/update/delete are implemented in cubits/usecases but never triggered — dead code paths with no user entry point.
5. **Upload status/abort dormant** — `getUploadStatus`/`abortUpload` exist but no UI polls or cancels sessions (client assumes direct success after `complete-upload`).
6. **`/public/*` discovery is data-layer only** — registered in DI but unreachable without guest mode.
7. **Server-side by design:** auth callbacks (consumed via `FlutterWebAuth2` redirect) and `POST /webhooks/kashier` must not be called directly from the app.

## Endpoint Counts by Domain

| Domain | ✅ | ⚠️ | ❌ | 🔧 |
|---|---|---|---|---|
| Auth | 10 | 3 | 0 | 2 |
| Health / Webhook | 0 | 0 | 1 | 1 |
| Profile | 3 | 0 | 0 | 0 |
| Instructor Courses/Content | 7 | 3 | 3 | 0 |
| Instructor Storage/Revenue | 3 | 0 | 0 | 0 |
| Learner Courses/Purchases | 4 | 3 | 0 | 0 |
| Learner Instructors | 2 | 0 | 0 | 0 |
| Notifications | 3 | 0 | 0 | 0 |
| Uploads (shared) | 0 | 2 | 0 | 0 |
| Public / Discovery | 1 | 5 | 1 | 0 |
| Admin (all) | 0 | 0 | 11 | 0 |
| **Total** | **33** | **14** | **15** | **3** |

---

## Manual Smoke Checklist (Plan 7.4)

Run on a device/emulator against `https://lms-production-1a72.up.railway.app/api`:

**Auth / Profile**
1. Register (with university dropdown) → verify email OTP → login.
2. Forgot/reset password flow.
3. Profile: edit name, switch theme/language (preferences PATCH), upload avatar, logout.

**Learner**
4. Browse courses → course card → **purchase** (Kashier payment) → `My Courses`.
5. Open my-course detail → content list → mark progress.
6. Search instructors → instructor profile.

**Instructor**
7. Dashboard: stats load; revenue card; **Storage & Billing** → view usage/plans → subscribe to a plan → checkout.
8. Contents page: upload video (Cloudinary provider session → complete), edit `isPreview`, drag-reorder, delete.
9. Profile/logout.

**Negative**
10. Trigger a 401 → auto token refresh → retry; trigger 403/404 → friendly error UI.
