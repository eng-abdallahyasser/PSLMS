# LMS — Endpoints Implementation Plan

Align the Flutter app with the updated `API_DOC.json` (manara API v1.0).
Areas: paged responses, purchases, content uploads, storage/revenue,
removal of deleted endpoints, public discovery, cleanup.

## Phase 0 — Foundations
- [x] 0.1 Add paged-response handling to `lib/core/network/api_client.dart` — `getPaged()` unwraps `{data: [...], meta: {...}}` envelopes and also accepts plain top-level arrays.
- [x] 0.2 Create `lib/core/models/paginated_result.dart` (`PaginatedResult<T>` + `PageMeta`).
- [x] 0.3 Verify response shapes with live GET calls:
  - `GET /public/courses`, `GET /public/instructors` → `{data, meta:{itemsPerPage,totalItems,currentPage,totalPages,sortBy}, links}` envelope ✅
  - `GET /public/categories`, `GET /public/universities` → plain top-level arrays ✅ (both handled)
  - Pending (auth required): `GET /learner/my-courses`, `GET /instructor/revenue`, `GET /instructor/storage/usage` — verify after login during Phase 1/3.

## Phase 1 — Learner Purchases (new feature: `features/learner/purchases/`)
- [x] 1.1 `domain/`: `PurchaseResult` entity, `PurchaseRepository` (purchaseCourse), `PurchaseCourseUseCase`.
- [x] 1.2 `data/`: `PurchaseRemoteDataSource` implementing:
  - `POST /api/learner/courses/{id}/purchase` → returns checkoutUrl (paid) or completed (free); tolerant parse (top-level or nested `session.checkoutUrl`).
  - 409 → `already_enrolled` success result; 401/403 → `AuthException`.
  - Repository impl + failure mapping (`NetworkFailure`, `ServerFailure`, `AuthFailure`).
- [x] 1.3 `presentation/`: `PurchaseCubit` states (`PurchaseLoading`, `PurchaseCheckoutRequired(url)`, `PurchaseEnrolled`, `PurchaseError`); `course_card.dart` opens checkoutUrl via `url_launcher` and refreshes courses on enroll.
- [x] 1.4 Registered in `injection_container.dart`; `PurchaseCubit` provided app-wide in `app.dart`; old `POST /learner/courses/{id}/enroll` code removed (datasource, repository, usecase, `EnrollmentCubit.enroll`).
- [x] 1.5 Learner my-courses already parses `{data, meta}` envelope from `GET /my-courses`; detail uses `GET /my-courses/{id}` (unchanged endpoint).
- [x] 1.6 Unit tests: `test/features/learner/purchases/purchase_flow_test.dart` — 9 tests passing (repo branches, 409, offline, cubit states).
- [x] 1.7 Runtime verification after login (pending smoke test): purchase response shape, `GET /learner/my-courses` list items shape.
  - **Static schema verification done (2026-10-06):** all parsing matches `API_DOC.json` schemas exactly —
    `InitUploadSessionDto` (fileSize is doc-typed `string`, sent as string ✅), `UploadSessionResponseDto` (all 9 props incl. `totalBytes`), `CompleteCourseContentUploadDto` (sessionId/title required), `UploadStatusResponseDto` (all 6 props, `pending` enum), tolerant `PurchaseResult.fromJson` (top-level or nested `session.checkoutUrl`, 409 → `already_enrolled`), my-courses via `getPaged` envelope.
  - **Live unauthenticated spot-check ✅:** `GET /api` 200, `/public/categories` plain array (handled by `getPaged`), `/public/courses` `{data,...}` envelope — backend up, shapes match.
  - **Live device log captured (free purchase completed → record present):** `GET /learner/my-courses` items are **purchase records** (`{...purchase, course: {...}}`, camelCase timestamps, null `thumbnailUrl`), `meta` has `sortBy`. **Bug found & fixed:** datasource parsed items as bare `CourseModel` → `type 'null' is not subtype of "string"` crash.
    - Fix: unwrap nested `course` in `my_courses_remote_datasource.dart`; `CourseModel.fromJson` now null-safe (`id`/`title`/`description`) and parses camelCase `createdAt`; `MyCourseDetailModel.fromJson` unwraps purchase-wrapped detail too.
    - Regression test: `test/features/learner/my_courses/my_courses_parsing_test.dart` (5 tests, real captured payload).
    - Re-verified: `flutter analyze` 0 errors/warnings; `flutter test` **46/46**.

## Phase 2 — Instructor Content Upload (replace direct POST)
- [x] 2.1 Upload session types & models: `data/models/upload_session_model.dart` — `UploadSession` (sessionId, provider, uploadUrl, httpMethod, chunkSize, fields, headers, publicId), `UploadStatus` (resume offset/percentage), `CloudinaryResult` (to/from provider response).
- [x] 2.2 `content_remote_datasource.dart` — `uploadContent` now orchestrates:
  - `POST /api/instructor/courses/{courseId}/content/upload-session` (fileName, fileSize-as-string, mimeType, title, description, isPreview)
  - `POST /api/uploads/session/{sessionId}/status` (added as `getUploadStatus`)
  - `DELETE /api/uploads/session/{sessionId}` (added as `abortUpload`)
  - `POST .../complete-upload` with `cloudinaryResult {publicId, secureUrl, bytes, resourceType, format}`; validates sessionId/uploadUrl; guards `413` quota via `ApiException → ServerException`.
- [x] 2.3 Direct-to-provider upload: new `data/datasources/provider_upload_client.dart` — POST multipart (fields + file) or PUT raw body (fields as query params), honors session headers, parses Cloudinary snake_case response, maps 401/403 → `AuthException`, other errors → `ServerException` with provider message.
- [x] 2.4 DTO updates: reorder sends both `contentIds` + `videoIds`; `updateContent` now accepts optional `isPreview` (UpdateCourseContentDto: title/description/isPreview).
- [x] 2.5 Old direct upload `POST /instructor/courses/{courseId}/content` removed — `uploadContent` no longer calls `uploadFile`; UI/cubit/usecase/repository APIs unchanged (they pass through).
- [x] 2.6 Tests: `test/features/instructor/courses/content/upload_flow_test.dart` — 10 tests passing (orchestration order, init/complete payloads, 413 mapping, provider-failure skips complete, status parsing, abort, reorder payload, session/status parsing).

## Phase 3 — Instructor Storage Plans & Revenue (new: `features/instructor/storage/`)
- [x] 3.1 `domain/` + `data/`:
  - `GET /api/instructor/storage/usage` (quota, usedBytes, subscriptions) — tolerant parsing (quota/used keys, subscriptions as list or count)
  - `GET /api/instructor/storage/plans` (tiers) — handles paged envelope or plain array
  - `POST /api/instructor/storage/subscribe {planId}` → Kashier `checkoutUrl` (also `url` / nested `session.checkoutUrl`)
  - `GET /api/instructor/revenue` (totals, commissions, net) — tolerant keys
- [x] 3.2 `presentation/`: `StoragePage` at `/instructor/storage` (usage card + plans list + revenue section); opens checkoutUrl; revenue widget added to instructor dashboard via `DashboardCubit` + `GetRevenueUseCase` (silently null on failure).
- [x] 3.3 **Delete all `/instructor/subscription/*` code** (9 endpoints: subscription, plans, portal, cancel, checkout, choose-plan, refresh-subscription, storage, storage/plans) — entire `features/instructor/subscriptions/` tree removed (pages, cubits, datasources, DI, route, dashboard link).
- [x] 3.4 Tests: `test/features/instructor/storage/storage_flow_test.dart` — 12 tests (parsing, envelope handling, failure mapping, cubit load/subscribe).

## Phase 4 — Remove Students/Enrollments/Invitations (dead endpoints)
- [x] 4.1 Delete `/instructor/students*` (7) + `/instructor/courses/{id}/enrollments` + `/instructor/courses/{id}/invite` + `/instructor/enrollments*` code — features, cubits, DI entries.
  - Deleted `features/instructor/students/` + `features/instructor/courses/enrollments/` entirely, plus shared `enrollment_entity.dart`/`enrollment_model.dart`.
  - Relocated still-alive `/learner/my-courses*` methods into new `features/learner/my_courses/data/` (`MyCoursesRemoteDataSource`, `MyCoursesRepository`); usecases repointed; DI updated.
- [x] 4.2 Delete `/learner/invitations/*`, `/learner/my-instructors*`, `/learner/instructors/{id}/join` code — remove navigation routes/tabs referencing them in `app.dart`.
  - Removed `requestToJoin`, `getMyInstructors`, `getInstructorCourses` (dead `my-instructors/{id}/courses`), `getInvitationInfo`, `acceptInvitation` from datasource/repo/cubit; deleted 5 usecases, `invitation_page.dart`, `my_instructors_page.dart`, invitation entity/model; dropped join button from instructor profile.
  - Removed routes `/instructor/students`, `/courses/:courseId/enrollments`, `/my-instructors`, `/invitation`; dashboard action cards (Students, My Instructors); invitation deep-link in notifications page.
  - Kept alive: `/learner/instructors` search + `/learner/instructors/{id}` profile.
- [x] 4.3 Fix compile errors from removals (BlocProviders, router guards, dashboard links) — `EnrollmentCubit`/`StudentCubit` providers removed; analyzer clean.

## Phase 5 — Public Discovery (new: `features/shared/discovery/`)
- [x] 5.1 `domain/` + `data/`: `GetPublicCoursesUseCase`, `GetPublicInstructorsUseCase`, `GetCategoriesUseCase` (public, no auth) — `GET /api/public/courses`, `/public/courses/{id}`, `/public/instructors`, `/public/instructors/{id}`, `/public/categories`.
  - `features/shared/discovery/` created: `DiscoveryRemoteDataSource` (uses `getPaged` — handles envelope or plain array), `DiscoveryRepository` (`Either<Failure, T>` + offline/error mapping), `CategoryEntity`/`CategoryModel` (name/nameAr/slug).
  - Reuses existing `CourseModel` and `InstructorProfileModel` for parsing.
- [x] 5.2 Presentation: use for unauthenticated browsing (guest mode) if supported; otherwise register as repositories for future onboarding.
  - Guest mode is **not supported** (router redirects all unauthenticated traffic to `/login`), so datasource/repository/3 usecases are registered in DI ready for a future onboarding/guest-browse UI.
- [x] 5.3 Reuse `UniversitiesRemoteDataSource` (already created) — optionally move under this feature.
  - Left in `features/shared/universities/` (works, used by register flow); noted as intentionally not moved to avoid churn.
- Tests: `test/features/shared/discovery/discovery_test.dart` — 10 tests (courses/instructor/category parsing, single fetch, 404 mapping, repo guards, usecase delegation).

## Phase 6 — Admin & Profile verification (unchanged endpoints, low priority)
- [x] 6.1 Verify admin endpoints still compile (users/courses/categories/universities/storage-plans); add new admin groups only if admin screens are in scope.
  - **No admin screens exist in the app** (only `UserRole.admin` enum value) → admin group (11 paths) is API-side only; nothing to compile; no admin groups added (out of scope).
  - Full endpoint audit (app code vs `API_DOC.json`, `$var` → `{param}` normalized): **every endpoint called by app code exists in the API doc** (only flagged item was the router path `/instructors/:id`, a false positive).
  - Profile verified: `/profile/me`, `/profile/me/avatar`, `/profile/me/preferences` all used by `features/shared/profile/` and compiling.
  - Social auth `/auth/google`, `/auth/facebook` used via `SocialAuthService` (baseUrl-prefixed strings); `*/callback` endpoints are server-side redirects.
  - Unused-but-available API endpoints noted: `/instructor/courses/stats/dashboard`, `/instructor/courses/{id}/sales` (dashboard computes stats locally; no sales screen), `/public/universities/{id}`, `/webhooks/kashier` (server-side), `/admin/*` (screens out of scope).

## Phase 7 — Cleanup & Verification
- [x] 7.1 Remove unused models/entities from deleted features (`Enrollment`, `Invitation`, `Student`, `Subscription`, etc.).
  - Confirmed: no references to `Enrollment`/`Invitation`/`Subscription`/`StorageAddon`/`Student*` anywhere in `lib/` or `test/`; all files from deleted features already removed (`git status` D list).
  - Deleted stray duplicate cubit `lib/features/learner/content/presentation/cubit/learner_content_cubit.dart` (outdated copy of `my_courses/content/...` cubit, never imported).
  - Removed 19 empty directories left behind by deletions (incl. `instructor/subscription*`, `my_courses/enrollments*`, `my_courses/content/data`).
  - `auth_widgets.dart` (`SocialLoginButton`) is unused but pre-existing and unrelated to deleted features — kept (documented as dormant social-UI risk in report).
- [x] 7.2 `flutter analyze` — zero errors; fix warnings.
  - Result: **0 errors, 0 warnings** (26 pre-existing infos: `sort_constructors_first`, `prefer_const_constructors`, deprecated `onReorder`).
- [x] 7.3 Run full test suite (`flutter test`); add tests from phases 1–3.
  - Result: **41/41 tests pass** — includes new suites: purchases (9), upload flow (10), storage (12), discovery (10), widget (1) plus pre-existing.
- [ ] 7.4 Manual smoke test: register → verify OTP → login → instructor: create course, upload content via new flow, revenue; learner: browse, purchase (free + paid), view my-courses; session-expiry redirect.
  - Checklist documented in `lib/report.md` ("Manual Smoke Checklist"). **Requires device/emulator run against Railway backend — to be executed by user.**
- [x] 7.5 Update `lib/report.md` endpoint table to match the new API.
  - Rewritten for the new API: **65 paths** — ✅ 33 wired, ⚠️ 14 data-layer-only, ❌ 15 not wired, 🔧 3 server-side; includes new sections (Storage, Purchases, Discovery/Uploads), removed dead sections (Enrollments/Students/Subscriptions), updated risks list.

---

Execution order: **0 → 2 → 1 → 3 → 4 → 5 → 7** (upload is the biggest functional gap).
