-- DeviceToken FCM integration
ALTER TABLE "DeviceToken"
    ADD COLUMN "appType" TEXT NOT NULL DEFAULT 'CUSTOMER',
    ADD COLUMN "isActive" BOOLEAN NOT NULL DEFAULT true,
    ADD COLUMN "updatedAt" TIMESTAMP(3),
    ALTER COLUMN "platform" SET DEFAULT 'ANDROID';

-- Safe backfill in case rows are inserted before deployment
UPDATE "DeviceToken"
SET "updatedAt" = COALESCE("createdAt", CURRENT_TIMESTAMP)
WHERE "updatedAt" IS NULL;

ALTER TABLE "DeviceToken"
    ALTER COLUMN "updatedAt" SET NOT NULL;


-- Store rating aggregation
ALTER TABLE "Store"
    ADD COLUMN "rating" DOUBLE PRECISION NOT NULL DEFAULT 5.0,
    ADD COLUMN "reviewCount" INTEGER NOT NULL DEFAULT 0;


-- Customer reviews
CREATE TABLE "Review" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Review_orderId_key"
ON "Review"("orderId");

ALTER TABLE "Review"
ADD CONSTRAINT "Review_orderId_fkey"
FOREIGN KEY ("orderId")
REFERENCES "Order"("id")
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE "Review"
ADD CONSTRAINT "Review_storeId_fkey"
FOREIGN KEY ("storeId")
REFERENCES "Store"("id")
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE "Review"
ADD CONSTRAINT "Review_userId_fkey"
FOREIGN KEY ("userId")
REFERENCES "User"("id")
ON DELETE CASCADE
ON UPDATE CASCADE;
