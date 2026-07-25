-- Talabaty courier dispatch offers migration
-- Additive only. Does not delete existing application data.

DO $$
BEGIN
    CREATE TYPE "CourierOfferStatus" AS ENUM (
        'QUEUED',
        'OFFERED',
        'ACCEPTED',
        'EXPIRED',
        'REJECTED',
        'CANCELLED'
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END
$$;

CREATE TABLE IF NOT EXISTS "CourierDispatchOffer" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "courierId" TEXT NOT NULL,
    "rank" INTEGER NOT NULL,
    "status" "CourierOfferStatus" NOT NULL DEFAULT 'QUEUED',
    "distanceMeters" INTEGER,
    "durationSeconds" INTEGER,
    "offeredAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CourierDispatchOffer_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "CourierDispatchOffer_orderId_courierId_key"
ON "CourierDispatchOffer"("orderId", "courierId");

CREATE INDEX IF NOT EXISTS "CourierDispatchOffer_orderId_status_rank_idx"
ON "CourierDispatchOffer"("orderId", "status", "rank");

CREATE INDEX IF NOT EXISTS "CourierDispatchOffer_courierId_status_expiresAt_idx"
ON "CourierDispatchOffer"("courierId", "status", "expiresAt");

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'CourierDispatchOffer_orderId_fkey'
    ) THEN
        ALTER TABLE "CourierDispatchOffer"
        ADD CONSTRAINT "CourierDispatchOffer_orderId_fkey"
        FOREIGN KEY ("orderId")
        REFERENCES "Order"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'CourierDispatchOffer_courierId_fkey'
    ) THEN
        ALTER TABLE "CourierDispatchOffer"
        ADD CONSTRAINT "CourierDispatchOffer_courierId_fkey"
        FOREIGN KEY ("courierId")
        REFERENCES "CourierProfile"("userId")
        ON DELETE CASCADE
        ON UPDATE CASCADE;
    END IF;
END
$$;
