import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';

const prisma = new PrismaClient();

async function main() {
  console.log('🔒 Direct SuperAdmin Production Account Setup...');

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
    console.error('❌ Error: SUPER_ADMIN account not found.');
    process.exit(1);
  }

  // Generate strong random password
  const newPassword = 'TalabatyAdmin2026!#Secured' + crypto.randomBytes(6).toString('hex');
  const passwordHash = await bcrypt.hash(newPassword, 12);
  const newVersion = user.tokenVersion + 1;

  await prisma.user.update({
    where: { id: user.id },
    data: {
      email: 'superadmin@talabaty.com',
      passwordHash,
      role: 'SUPER_ADMIN',
      isActive: true,
      firstTimeSetupCompleted: true,
      activationTokenHash: null,
      activationTokenExpiresAt: null,
      tokenVersion: newVersion,
      forcePasswordChange: false,
      failedLoginAttempts: 0,
      lockoutUntil: null,
      passwordChangedAt: new Date(),
    },
  });

  // Revoke all existing refresh tokens
  await prisma.refreshToken.updateMany({
    where: { userId: user.id },
    data: { revoked: true },
  });

  // Verify bcrypt match
  const testMatch = await bcrypt.compare(newPassword, passwordHash);
  if (!testMatch) {
    console.error('❌ Error: Password verification failed!');
    process.exit(1);
  }

  // Save credentials securely to server storage
  const credentialsFile = '/opt/talabaty-app/SUPERADMIN_ACCESS.secure.json';
  fs.writeFileSync(
    credentialsFile,
    JSON.stringify(
      {
        email: 'superadmin@talabaty.com',
        password: newPassword,
        setupCompletedAt: new Date().toISOString(),
        loginUrl: 'https://mytalabaty.com/admin/login',
      },
      null,
      2
    ),
    { mode: 0o600 }
  );

  console.log('\n==================================================');
  console.log('✅ SUPER_ADMIN PRODUCTION SETUP COMPLETED CLEANLY!');
  console.log('==================================================');
  console.log('SUPER_ADMIN: superadmin@talabaty.com');
  console.log('Account: ACTIVE');
  console.log('First-Time Setup Completed: YES');
  console.log('Old Sessions Revoked: YES');
  console.log('Password Hash: bcrypt (12 rounds)');
  console.log(`Credentials File: ${credentialsFile} (chmod 600)`);
  console.log('==================================================\n');
}

main()
  .catch((e) => {
    console.error('❌ Setup error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
