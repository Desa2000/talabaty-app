# Talabaty Backend API Server

REST and Socket.IO real-time tracking backend server built with Node.js, TypeScript, Express, PostgreSQL, and Prisma ORM.

## Environment Configuration

Create a `.env` file in the root of the `backend/` directory following `.env.example`:

```env
PORT=3000
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/talabaty?schema=public"
JWT_ACCESS_SECRET="your-super-secret-access-token-key-2026"
JWT_REFRESH_SECRET="your-super-secret-refresh-token-key-2026"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="30d"
NODE_ENV="development"
```

## Running the Database locally (Docker Compose)

Start the PostgreSQL service:

```bash
docker-compose up -d db
```

Or start both the database and API services inside docker:

```bash
docker-compose up --build
```

## Local Installation & Run (Development)

If you are running the Node.js service locally on your host machine:

### 1. Install Dependencies
```bash
npm install
```

### 2. Generate Prisma Client
```bash
npx prisma generate
```

### 3. Run Migrations
Creates the tables inside PostgreSQL:
```bash
npx prisma migrate dev
```

### 4. Seed Development Users
Populates dev database with seed login accounts (Admin, Customer, Merchant, Courier):
```bash
npx prisma db seed
```

### 5. Start Development Server
```bash
npm run dev
```

## Production Build
To build and start compiling into Javascript:
```bash
npm run build
npm start
```
