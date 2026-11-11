-- Add optional owner links without deleting or rewriting any existing rows.
ALTER TABLE "TransferRequest" ADD COLUMN "userId" TEXT;
ALTER TABLE "Bill" ADD COLUMN "userId" TEXT;

CREATE INDEX "TransferRequest_userId_idx" ON "TransferRequest"("userId");
CREATE INDEX "Bill_userId_idx" ON "Bill"("userId");

ALTER TABLE "TransferRequest"
  ADD CONSTRAINT "TransferRequest_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "Bill"
  ADD CONSTRAINT "Bill_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
