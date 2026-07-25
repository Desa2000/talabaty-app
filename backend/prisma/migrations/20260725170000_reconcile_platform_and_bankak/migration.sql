-- ============================================================
-- Talabaty safe additive reconciliation migration
-- ============================================================
-- This migration:
-- 1. Reconciles AuditLog into migration history.
-- 2. Reconciles PlatformSetting into migration history.
-- 3. Adds missing Bankak verification fields to Order.
--
-- No production records are deleted or modified.
-- ============================================================


-- AuditLog already exists in current production.
-- IF NOT EXISTS keeps this safe for production while ensuring
-- a fresh database built only from migrations receives the table.

CREATE TABLE IF NOT EXISTS "AuditLog" (
    "id" TEXT NOT NULL,
    "adminId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "beforeData" TEXT,
    "afterData" TEXT,
    "ipAddress" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);


-- PlatformSetting already exists in current production.

CREATE TABLE IF NOT EXISTS "PlatformSetting" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlatformSetting_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "PlatformSetting_key_key"
ON "PlatformSetting"("key");


-- Bankak verification fields.
-- These columns are currently missing from production.

ALTER TABLE "Order"
ADD COLUMN IF NOT EXISTS "bankakLast4" TEXT,
ADD COLUMN IF NOT EXISTS "paymentSubmittedAt" TIMESTAMP(3),
ADD COLUMN IF NOT EXISTS "paymentVerifiedAt" TIMESTAMP(3),
ADD COLUMN IF NOT EXISTS "paymentVerifiedBy" TEXT,
ADD COLUMN IF NOT EXISTS "paymentRejectionReason" TEXT;
