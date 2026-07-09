# Navigation Graph Analysis Report

## Current GoRouter Routes (21 defined)

| Path | Screen | Role Access | Has Page File |
|---|---|---|---|
| `/splash` | SplashPage | Public | ✅ |
| `/login` | LoginPage | Public | ✅ |
| `/register` | RegisterPage | Public | ✅ |
| `/verify-email` | VerifyEmailPage | Public | ✅ |
| `/forgot-password` | ForgotPasswordPage | Public | ✅ |
| `/reset-password` | ResetPasswordPage | Public | ✅ |
| `/mobile-otp` | MobileOtpPage | Public | ✅ |
| `/dashboard` | DashboardPage | Learner | ✅ |
| `/courses` | CoursesPage | Both | ✅ |
| `/courses/:courseId/contents` | ContentsPage | Instructor | ✅ |
| `/courses/:courseId/enrollments` | EnrollmentsPage | Instructor | ✅ |
| `/instructor/dashboard` | DashboardPage | Instructor | ✅ (same as learner dash) |
| `/instructor/students` | StudentsPage | Instructor | ✅ |
| `/instructor/subscription` | SubscriptionPage | Instructor | ✅ |
| `/profile` | ProfilePage | Both | ✅ |
| `/my-courses` | MyCoursesPage | Learner | ✅ |
| `/my-courses/:courseId` | MyCourseDetailPage | Learner | ✅ |
| `/search-instructors` | SearchInstructorsPage | Learner | ✅ |
| `/instructors/:id` | InstructorProfilePage | Learner | ✅ |
| `/my-instructors` | MyInstructorsPage | Learner | ✅ |
| `/notifications` | NotificationsPage | Both | ✅ |

## Role-Based Redirect Logic

| Auth State | Behavior |
|---|---|
| `AuthInitial` / `AuthLoading` | Only auth pages allowed; else → `/splash` |
| `AuthOtpSent` | Force → `/verify-email` |
| `AuthEmailVerified` | Force → `/login` |
| `AuthEmailNotVerified` | Force → `/verify-email` |
| `AuthAuthenticated` (Instructor) | On auth pages → `/instructor/dashboard`; else allow |
| `AuthAuthenticated` (Learner) | On auth pages → `/dashboard`; on `/instructor/*` or `/courses/:courseId/*` → `/dashboard` |
| `AuthUnauthenticated` | Only public routes; else → `/login` |

**Note:** Learners are blocked from `/courses/*` sub-routes (contents, enrollments) and `/instructor/*` — but these are instructor-only anyway. New learner routes (`/my-courses/*`, `/instructors/*`, `/search-instructors`, `/my-instructors`, `/notifications`, `/courses`) all pass through for learners.

## Navigation Table (Destination ↔ Sources)

| Destination Screen | Can Navigate To It From | Can Navigate From It To |
|---|---|---|
| **Splash** | — (initial route) | Auto-redirects based on auth state |
| **Login** | Register ("Sign In"), VerifyEmail (on verify), ForgotPassword (on send), ResetPassword (on reset), Profile (on logout), Auto-redirect (unauthenticated) | Register ("Sign Up"), **Forgot Password** (✅), **Login with Phone** (✅) |
| **Register** | Login ("Sign Up") | Login ("Sign In"), VerifyEmail (on signup) |
| **VerifyEmail** | Register (on signup), Auto-redirect (OtpSent / EmailNotVerified) | Login (on verify) |
| **ForgotPassword** | **Login** (✅) | Login (on send, back) |
| **ResetPassword** | — (no link navigates here — needs email token flow) | Login (on reset, back) |
| **MobileOtp** | **Login** (✅ "Login with Phone" added) | Dashboard (on verify), Login (back) |
| **Dashboard** | Bottom Nav (index 0), Auto-redirect (authenticated) | My Courses, My Instructors, Find Instructors, Notifications, Browse All, Profile (learner); Courses, Students, Subscription, Profile (instructor) |
| **My Courses** | Dashboard (✅ quick action) | Course Detail (on tap card) |
| **My Course Detail** | My Courses (on tap card) | — (AppBar back) |
| **Search Instructors** | Dashboard (✅ quick action) | Instructor Profile (on tap result) |
| **Instructor Profile** | Search Instructors (on tap result) | Join request (button) |
| **My Instructors** | Dashboard (✅ quick action) | — (AppBar back) |
| **Notifications** | Dashboard (✅ quick action) | Mark all read, Mark single read |
| **Courses** | Bottom Nav (index 1), Dashboard (action card) | Profile (via nav), Course detail pages (via CourseCard widget) |
| **Courses/:id/Contents** | CourseCard (via widget) | — (AppBar back) |
| **Courses/:id/Enrollments** | CourseCard (via widget) | — (AppBar back) |
| **Instructor/Dashboard** | Auto-redirect (instructor, on auth page) | Same as Dashboard |
| **Instructor/Students** | Dashboard (✅) | — (AppBar back) |
| **Instructor/Subscription** | Dashboard (✅) | — (AppBar back) |
| **Profile** | Bottom Nav (index 2), Dashboard (action card) | Login (on logout) |

## Previously Missing Screens — All Added ✅

These 6 screens had API endpoints but no routes. They now have routes, pages, and navigation links from the learner dashboard:

| Screen | Route | API Endpoint(s) |
|---|---|---|
| Learner: My Courses | `/my-courses` | `GET /learner/my-courses` |
| Learner: Course Detail | `/my-courses/:courseId` | `GET /learner/my-courses/{courseId}` |
| Learner: Search Instructors | `/search-instructors` | `GET /learner/instructors?q=` |
| Learner: Instructor Profile | `/instructors/:id` | `GET /learner/instructors/{id}` |
| Learner: My Instructors | `/my-instructors` | `GET /learner/my-instructors` |
| Notifications | `/notifications` | `GET /notifications`, `PATCH .../read`, `POST .../read-all` |

## Navigation Gaps & Broken Links

| Issue | Status | Detail |
|---|---|---|
| Forgot Password button on Login | ✅ **Fixed** | Now navigates to `/forgot-password` |
| No link to `/instructor/students` | ✅ **Fixed** | Added to instructor Dashboard quick actions |
| No link to `/instructor/subscription` | ✅ **Fixed** | Added to instructor Dashboard quick actions |
| No link to `/forgot-password` | ✅ **Fixed** | Wired from Login page |
| No link to `/mobile-otp` | ✅ **Fixed** | "Login with Phone" added to Login page |
| No learner My Courses screen | ✅ **Fixed** | `/my-courses` route + page + dashboard card |
| No learner Course Detail screen | ✅ **Fixed** | `/my-courses/:courseId` route + page |
| No Search Instructors screen | ✅ **Fixed** | `/search-instructors` route + page + dashboard card |
| No Instructor Profile screen | ✅ **Fixed** | `/instructors/:id` route + page |
| No My Instructors screen | ✅ **Fixed** | `/my-instructors` route + page + dashboard card |
| No Notifications screen | ✅ **Fixed** | `/notifications` route + page + dashboard card |
| Bottom Nav only on 2 pages | ⚠️ **Open** | Dashboard & Courses only; sub-pages lack nav |
| Course detail pages require `courseId` | ⚠️ **Open** | Contents & Enrollments — only reachable via CourseCard widget |
| Instructor sub-pages have no nav bar | ⚠️ **Open** | Students, Subscription, Contents, Enrollments — no bottom nav once inside |

## Summary

**21 screens across 21 routes defined.** All 9 critical navigation gaps have been fixed. 3 ⚠️ minor issues remain.

### ✅ Fixed (9 of 9)
1. **Forgot Password button** on Login → navigates to `/forgot-password`
2. **Login with Phone** → link added to Login page, navigates to `/mobile-otp`
3. **Instructor navigation** → Dashboard shows Students + Subscription action cards
4. **My Courses** → `/my-courses` route, page, and dashboard card for learners
5. **Course Detail** → `/my-courses/:courseId` route and page for learners
6. **Search Instructors** → `/search-instructors` route, page, and dashboard card
7. **Instructor Profile** → `/instructors/:id` route and page with "Request to Join"
8. **My Instructors** → `/my-instructors` route, page, and dashboard card
9. **Notifications** → `/notifications` route, page, and dashboard card (mark read/all read)

### ⚠️ Remaining
1. **Bottom Nav missing** — most sub-pages lack navigation back to main areas
2. **Course detail pages** — Contents & Enrollments only reachable via CourseCard widget
