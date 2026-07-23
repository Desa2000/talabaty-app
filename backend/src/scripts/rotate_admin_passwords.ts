import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';

const prisma = new PrismaClient();

async function main() {
  console.log('🔒 Initiating Secure Admin Password Rotation...');

  const adminRoles = ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'] as const;
  const adminUsers = await prisma.user.findMany({
    where: {
      role: { in: [...adminRoles] },
    },
  });

  const credentialsOutput: Record<string, { phone: string; email: string | null; role: string; passwordGenerated: string }> = {};

  for (const user of adminUsers) {
    // Generate strong 32-character random password
    const newPassword = crypto.randomBytes(24).toString('hex');
    const passwordHash = await bcrypt.hash(newPassword, 12);
    const newVersion = user.tokenVersion + 1;

    // Ensure email domain uses mytalabaty.com
    let updatedEmail = user.email;
    if (user.email && !user.email.endsWith('@mytalabaty.com')) {
      const namePart = user.email.split('@')[0];
      updatedEmail = `${namePart}@mytalabaty.com`;
    }

    await prisma.user.update({
      where: { id: user.id },
      data: {
        passwordHash,
        tokenVersion: newVersion,
        forcePasswordChange: true,
        email: updatedEmail,
        passwordChangedAt: new Date(),
        failedLoginAttempts: 0,
        lockoutUntil: null,
      },
    });

    // Revoke all existing refresh tokens
    await prisma.refreshToken.updateMany({
      where: { userId: user.id },
      data: { revoked: true },
    });

    credentialsOutput[user.role] = {
      phone: user.phone,
      email: updatedEmail,
      role: user.role,
      passwordGenerated: newPassword,
    };
  }

  // Save to secure local file on server with restricted file permissions
  const targetPath = process.env.CREDENTIALS_FILE_PATH || path.join(process.cwd(), '..', 'ADMIN_CREDENTIALS.secure.json');
  fs.writeFileSync(targetPath, JSON.stringify(credentialsOutput, null, 2), { mode: 0o600 });

  console.log('✅ PASS: All admin passwords successfully rotated and stored in secure server storage!');
}

main()
  .catch((e) => {
    console.error('FAILED to rotate passwords:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
