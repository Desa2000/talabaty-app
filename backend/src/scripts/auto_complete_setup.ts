import crypto from 'crypto';
import fs from 'fs';
import path from 'path';

async function main() {
  const token = process.argv[2] || '0d6dcc9991393c7ab27ef5976db8367ff12189bd5f120e421901c731e1b06449';
  const newPassword = 'TalabatyAdmin2026!#Secured' + crypto.randomBytes(6).toString('hex');

  console.log('🔒 Automating SuperAdmin First-Time Setup...');

  const response = await fetch('http://127.0.0.1:3000/api/admin/setup-password', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ token, newPassword }),
  });

  const data = await response.json();

  if (response.ok) {
    console.log('✅ PASS: SuperAdmin First-Time Setup completed successfully!');
    const targetFile = path.join(process.cwd(), '..', 'SUPERADMIN_ACCESS.secure.json');
    fs.writeFileSync(
      targetFile,
      JSON.stringify(
        {
          email: 'superadmin@talabaty.com',
          password: newPassword,
          setupCompletedAt: new Date().toISOString(),
        },
        null,
        2
      ),
      { mode: 0o600 }
    );
    console.log(`🔒 Credentials saved securely to ${targetFile} (chmod 600)`);
  } else {
    console.error('❌ FAIL: Setup failed:', data);
    process.exit(1);
  }
}

main().catch((e) => {
  console.error('❌ Error in setup script:', e);
  process.exit(1);
});
