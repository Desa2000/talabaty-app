import fs from 'fs';

async function main() {
  const file = '/opt/talabaty-app/SUPERADMIN_ACCESS.secure.json';
  if (!fs.existsSync(file)) {
    console.error('File not found');
    process.exit(1);
  }

  const creds = JSON.parse(fs.readFileSync(file, 'utf8'));
  const res = await fetch('http://127.0.0.1:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      identifier: creds.email,
      password: creds.password,
    }),
  });

  const data: any = await res.json();
  if (res.ok && (data.token || data.accessToken)) {
    console.log('==================================================');
    console.log('✅ PRODUCTION SUPERADMIN LOGIN VERIFIED CLEANLY!');
    console.log('==================================================');
    console.log(`User: ${data.user?.email || creds.email} | Role: ${data.user?.role}`);
    console.log('Access Token: Granted & Validated');
    console.log('==================================================');
  } else {
    console.error('❌ LOGIN TEST FAILED:', data);
    process.exit(1);
  }
}

main();
