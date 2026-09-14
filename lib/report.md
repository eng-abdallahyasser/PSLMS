# API Wiring Report

Analysis of which endpoints in `API_DOC.json` (88 total) are actually wired into the Flutter app (`lib/`).

**Legend**
- ✅ **Wired** — HTTP call exists in a datasource **and** is triggered from the UI (page → cubit → use case → repo → datasource).
- ⚠️ **Data layer only** — datasource/repo/cubit method exists, but **no page calls it** (dormant).
- ❌ **Not wired** — no code references the endpoint at all.
- 🔧 **Server-side** — backend callback/webhook, not meant to be called by the app.

## Summary

| Status | Count |
|---|---|
| ✅ Wired (full UI → API) | 49 |
| ⚠️ Data layer only (no UI trigger) | 14 |
| ❌ Not wired | 22 |
| 🔧 Server-side / by design | 3 |
| **Total** | **88** |

---

## Auth (`/auth/*`)

| Endpoint | Status | Notes |
|---|---|---|
| `POST /api/auth/register` | ✅ | RegisterPage |
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
| `POST /api/auth/complete-registration` | ⚠️ | `AuthCubit.completeRegistration` exists, only reachable after a social flow that has no UI |
| `GET /api/auth/google/callback` | 🔧 | Server renders result; app parses tokens via `FlutterWebAuth2` |
| `GET /api/auth/facebook/callback` | 🔧 | Same as above |

## Health & Webhook

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api` | ❌ | No health-check call in app |
| `POST /api/stripe/webhook` | 🔧 | Stripe webhook handled by backend |

## Profile (`/profile/*`)

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/profile/me` | ✅ | ProfilePage |
| `PATCH /api/profile/me` | ✅ | ProfilePage (name edit) |
| `PATCH /api/profile/me/preferences` | ✅ | ProfilePage (lang/theme) |
| `POST /api/profile/me/avatar` | ✅ | ProfilePage (avatar upload, multipart) |

## Instructor — Courses & Dashboard

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/instructor/courses` | ✅ | CoursesPage + DashboardCubit |
| `POST /api/instructor/courses` | ⚠️ | `CourseCubit.createCourse` exists — no create form/UI |
| `PATCH /api/instructor/courses/{id}` | ⚠️ | `CourseCubit.updateCourse` exists — no UI |
| `DELETE /api/instructor/courses/{id}` | ⚠️ | `CourseCubit.deleteCourse` exists — no UI |
| `GET /api/instructor/courses/{id}` | ❌ | No datasource method calls `/instructor/courses/{id}` at all |
| `GET /api/instructor/courses/stats/dashboard` | ❌ | Dashboard stats are **computed client-side** from course lists instead |
| `GET /api/learner/courses` | ✅ | CoursesPage (learner role) |
| `GET /api/learner/courses/{id}` | ⚠️ | `getCourseById` → `GET /learner/courses/{id}` — no use case/UI |

## Instructor — Content

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/instructor/courses/{courseId}/content` | ✅ | ContentsPage |
| `POST /api/instructor/courses/{courseId}/content` | ✅ | ContentsPage (upload) |
| `PATCH /api/instructor/courses/{courseId}/content/reorder` | ✅ | ContentsPage (reorder) |
| `PATCH /api/instructor/courses/{courseId}/content/{contentId}` | ✅ | ContentsPage (edit) |
| `DELETE /api/instructor/courses/{courseId}/content/{contentId}` | ✅ | ContentsPage (delete) |

## Instructor — Enrollments

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/instructor/courses/{courseId}/enrollments` | ✅ | EnrollmentsPage |
| `PATCH /api/instructor/enrollments/{id}/respond` | ✅ | EnrollmentsPage (approve/reject) |
| `POST /api/instructor/courses/{courseId}/invite` | ✅ | EnrollmentsPage (invite) |
| `DELETE /api/instructor/enrollments/{id}` | ✅ | EnrollmentsPage (remove) |

## Instructor — Students

| Endpoint | Status | Notes |
|---|---|---|
| `POST /api/instructor/students/invite` | ✅ | StudentsPage |
| `GET /api/instructor/students` | ✅ | StudentsPage |
| `GET /api/instructor/students/requests` | ✅ | StudentsPage |
| `PATCH /api/instructor/students/requests/{id}/respond` | ✅ | StudentsPage |
| `DELETE /api/instructor/students/{id}` | ✅ | StudentsPage |
| `POST /api/instructor/students/{studentId}/assign` | ✅ | StudentsPage (assign modal) |
| `GET /api/instructor/students/{studentId}/assignments` | ✅ | StudentsPage |

## Instructor — Subscriptions

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/instructor/subscription` | ✅ | SubscriptionPage |
| `GET /api/instructor/subscription/plans` | ✅ | SubscriptionPage |
| `POST /api/instructor/subscription/choose-plan` | ✅ | SubscriptionPage (free→apply, paid→Stripe) |
| `POST /api/instructor/subscription/portal` | ✅ | SubscriptionPage (manage) |
| `POST /api/instructor/subscription/refresh-subscription` | ✅ | SubscriptionPage (pull-to-refresh) |
| `POST /api/instructor/subscription/cancel` | ✅ | SubscriptionPage (cancel) |
| `POST /api/instructor/subscription/checkout` | ⚠️ | `createCheckout` in datasource/cubit — page uses **choose-plan** instead |
| `POST /api/instructor/subscription/storage` | ✅ | SubscriptionPage (buy storage) — ⚠️ **missing `planId` body**, API docs require it |
| `GET /api/instructor/subscription/storage` | ✅ | SubscriptionPage (storage add-ons) |
| `GET /api/instructor/subscription/storage/plans` | ❌ | No `GetStoragePlans` use case / datasource method at all |

## Learner — Courses / Enrollments

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/learner/my-courses` | ✅ | MyCoursesPage |
| `GET /api/learner/my-courses/{courseId}` | ⚠️ | `MyCoursesCubit.getMyCourseDetail` exists — MyCourseDetailPage calls **contents** instead |
| `POST /api/learner/courses/{courseId}/enroll` | ⚠️ | `EnrollmentCubit.enroll` exists — no "Enroll" button anywhere |
| `GET /api/learner/my-courses/{courseId}/content` | ✅ | MyCourseDetailPage |
| `GET /api/learner/my-courses/{courseId}/content/{contentId}` | ⚠️ | `LearnerContentCubit.getContentDetail` exists — no detail page/UI |

## Learner — Instructors & Invitations

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/learner/instructors` | ✅ | SearchInstructorsPage |
| `GET /api/learner/instructors/{id}` | ✅ | InstructorProfilePage |
| `POST /api/learner/instructors/{instructorId}/join` | ✅ | InstructorProfilePage ("Request to Join") |
| `GET /api/learner/my-instructors` | ✅ | MyInstructorsPage |
| `GET /api/learner/my-instructors/{instructorId}/courses` | ⚠️ | `InstructorCubit.getInstructorCourses` exists — no UI |
| `GET /api/learner/invitations/accept` | ⚠️ | `InstructorCubit.acceptInvitation` exists — no deep link/UI |
| `GET /api/learner/invitations/info` | ⚠️ | `InstructorCubit.getInvitationInfo` exists — no UI |

## Notifications

| Endpoint | Status | Notes |
|---|---|---|
| `GET /api/notifications` | ✅ | NotificationsPage |
| `PATCH /api/notifications/{id}/read` | ✅ | NotificationsPage |
| `POST /api/notifications/read-all` | ✅ | NotificationsPage |

## Admin (`/admin/*`) — NOT WIRED (18 endpoints)

No admin feature exists in the app (only the `UserRole.admin` enum). All are ❌:

- `POST/GET /admin/users`, `GET/PATCH/DELETE /admin/users/{id}`
- `GET /admin/subscriptions`, `GET /admin/subscriptions/plans`, `PATCH /admin/subscriptions/{id}/status`
- `GET/POST /admin/subscriptions/storage-plans`, `PATCH /admin/subscriptions/storage-plans/{id}`
- `GET /admin/courses`, `GET/PATCH/DELETE /admin/courses/{id}`
- `GET /admin/enrollments`, `PATCH /admin/enrollments/{id}`
- `POST /admin/push-notifications/test`

---

## Mismatches & Risks

1. **`POST /instructor/subscription/storage`** is called with **no request body**, but `API_DOC.json` requires `planId`. Users could buy a plan the subscription page can't select (no storage-plans fetched).
2. **`GET /instructor/courses/stats/dashboard`** is defined in the API but the app computes dashboard numbers client-side from `GET /instructor/courses` / `GET /learner/courses` — anyone with the course list could fake stats; client logic diverges from backend-counted metrics.
3. **Google / Facebook OAuth is dead code in the UI.** `SocialLoginButton`, `signInWithGoogle/Facebook`, and `complete-registration` are wired through the data layer but no login/register screen renders a social button, so those endpoints are unreachable by users.
4. **Invitation flow** (`GET /learner/invitations/info`, `GET /learner/invitations/accept`) is implemented but has no screen or deep-link handler, so invited learners cannot accept instructor invitations from the app.
5. **Half-finished learner flows:** `enroll`, `my-course-detail`, `content-detail`, and instructor course create/update/delete are implemented in cubits/usecases but never triggered — dead code paths with no user entry point.
6. **`GET /auth/google` / `GET /auth/facebook` callback endpoints** are handled server-side; the app consumes the redirect through `FlutterWebAuth2` and token parsing. These should not be called directly from the app.

## Endpoint Counts by Domain

| Domain | ✅ | ⚠️ | ❌ | 🔧 |
|---|---|---|---|---|
| Auth | 10 | 3 | 0 | 2 |
| Health / Webhook | 0 | 0 | 1 | 1 |
| Profile | 4 | 0 | 0 | 0 |
| Instructor Courses/Dashboard | 2 | 4 | 2 | 0 |
| Instructor Content | 5 | 0 | 0 | 0 |
| Instructor Enrollments | 4 | 0 | 0 | 0 |
| Instructor Students | 7 | 0 | 0 | 0 |
| Instructor Subscriptions | 8 | 1 | 1 | 0 |
| Learner Courses/Enrollments | 1 | 2 | 0 | 0 |
| Learner Content | 1 | 1 | 0 | 0 |
| Learner Instructors/Invitations | 4 | 3 | 0 | 0 |
| Notifications | 3 | 0 | 0 | 0 |
| Admin (all) | 0 | 0 | 18 | 0 |
| **Total** | **49** | **14** | **22** | **3** |