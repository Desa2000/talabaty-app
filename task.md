# Tasks - Phase 1 Backend Auth Migration

## Backend Setup
- [x] Initialize TypeScript, Prisma, and dependencies in `backend/`
- [x] Configure database connection in Prisma (`schema.prisma` and `.env.example`)
- [x] Create database migration and seed script for dev environments
- [x] Implement Express app with routing, middleware, and database access
- [x] Implement JWT login/register/refresh/logout/getMe endpoints
- [x] Support token revocation by storing/verifying refresh tokens in PostgreSQL

## Flutter Secure Networking
- [x] Add `dio` and `flutter_secure_storage` dependencies to `pubspec.yaml`
- [x] Implement `ApiClient`, `ApiEndpoints`, and custom Dio interceptors for auth headers and refreshing tokens
- [x] Configure centralized `API_BASE_URL` setup

## Flutter Authentication Migration
- [x] Rewrite `auth_provider.dart` to communicate with the REST API using `ApiClient`
- [x] Securely read/write access and refresh tokens using `flutter_secure_storage`
- [x] Handle error states: timeout, duplicate phone/email, invalid credentials, token expiry
- [x] Verify redirects for Customer, Merchant, Courier, and Admin roles
- [x] Verify persistence across app restarts

## Verification
- [x] Run `flutter analyze` and resolve critical warnings
- [x] Build and verify Node.js backend typescript typecheck
- [x] Run local database and test end-to-end user journeys
