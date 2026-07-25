-- Add application fee snapshot to each order.
-- Existing orders remain valid with a zero application fee.

ALTER TABLE "Order"
ADD COLUMN IF NOT EXISTS "applicationFee" DOUBLE PRECISION NOT NULL DEFAULT 0;