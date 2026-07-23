import { PrismaClient } from '@prisma/client';
import crypto from 'crypto';

const prisma = new PrismaClient();

async function main() {
  console.log('🔑 Generating One-Time Activation Token for SUPER_ADMIN...');

  let user = await prisma.user.findFirst({
    where: {
      OR: [
        { email: 'superadmin@talabaty.com' },
        { email: 'superadmin@mytalabaty.com' },
        { role: 'SUPER_ADMIN' },
      ],
    },
  });

  if (!user) {
    console.error('❌ Error: SUPER_ADMIN user not found.');
    process.exit(1);
  }

  // Generate 64-char random hex token
  const rawToken = crypto.randomBytes(32).toString('hex');
  const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');
  const expiresAt = new Date(Date.now() + 25 * 60 * 1000); // 25 minutes validity

  // Revoke all existing sessions and set setup pending
  await prisma.user.update({
    where: { id: user.id },
    data: {
      email: 'superadmin@talabaty.com',
      role: 'SUPER_ADMIN',
      isActive: true,
      firstTimeSetupCompleted: false,
      activationTokenHash: tokenHash,
      activationTokenExpiresAt: expiresAt,
      tokenVersion: user.tokenVersion + 1,
    },
  });

  // Revoke all DB refresh tokens
  await prisma.refreshToken.updateMany({
    where: { userId: user.id },
    data: { revoked: true },
  });

  const setupUrl = `https://mytalabaty.com/admin/setup?token=${rawToken}`;

  console.log('\n==================================================');
  console.log('✨ ONE-TIME SUPER_ADMIN ACTIVATION LINK GENERATED');
  console.log('==================================================');
  console.log(`URL: ${setupUrl}`);
  console.log('Expires: In 25 Minutes');
  console.log('Single Use: YES (Invalidated immediately after use)');
  console.log('==================================================\n');
}

main()
  .catch((e) => {
    console.error('❌ Error generating token:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
