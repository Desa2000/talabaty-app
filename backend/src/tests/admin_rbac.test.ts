import { UserRole } from '@prisma/client';

export interface RBACCheckResult {
  name: string;
  passed: boolean;
  error?: string;
}

export function isRouteAccessAllowed(
  userRole: UserRole,
  routeCategory: 'OVERVIEW' | 'ORDERS' | 'REASSIGN_COURIER' | 'MERCHANTS' | 'COURIERS' | 'CUSTOMERS' | 'PAYMENTS_VERIFY' | 'COVERAGE' | 'SUPPORT' | 'SETTINGS' | 'MANAGE_ADMINS'
): boolean {
  const adminRoles: UserRole[] = ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'];
  if (!adminRoles.includes(userRole)) {
    return false; // Customer, Merchant, Courier completely forbidden from any admin route!
  }

  switch (routeCategory) {
    case 'OVERVIEW':
    case 'ORDERS':
    case 'MERCHANTS':
    case 'COURIERS':
    case 'CUSTOMERS':
    case 'COVERAGE':
    case 'SUPPORT':
      return true; // Read-only dashboard sections accessible to all admin staff

    case 'REASSIGN_COURIER':
      return ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS'].includes(userRole);

    case 'PAYMENTS_VERIFY':
      return ['SUPER_ADMIN', 'ADMIN', 'FINANCE'].includes(userRole);

    case 'COVERAGE':
      return ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS'].includes(userRole);

    case 'SETTINGS':
    case 'MANAGE_ADMINS':
      return ['SUPER_ADMIN'].includes(userRole);

    default:
      return false;
  }
}

export function runSecurityRbacTests(): RBACCheckResult[] {
  const tests: RBACCheckResult[] = [];

  // Test 1: Customer cannot access admin overview
  const t1 = isRouteAccessAllowed('CUSTOMER', 'OVERVIEW');
  tests.push({ name: 'Customer cannot access /admin overview', passed: !t1, error: t1 ? 'CUSTOMER was allowed' : undefined });

  // Test 2: Merchant cannot access admin orders
  const t2 = isRouteAccessAllowed('MERCHANT', 'ORDERS');
  tests.push({ name: 'Merchant cannot access /admin orders', passed: !t2, error: t2 ? 'MERCHANT was allowed' : undefined });

  // Test 3: Courier cannot access admin dashboard
  const t3 = isRouteAccessAllowed('COURIER', 'OVERVIEW');
  tests.push({ name: 'Courier cannot access /admin dashboard', passed: !t3, error: t3 ? 'COURIER was allowed' : undefined });

  // Test 4: SUPPORT cannot verify Bankak payments
  const t4 = isRouteAccessAllowed('SUPPORT', 'PAYMENTS_VERIFY');
  tests.push({ name: 'SUPPORT cannot verify Bankak payments', passed: !t4, error: t4 ? 'SUPPORT was allowed to verify payments' : undefined });

  // Test 5: FINANCE cannot reassign couriers
  const t5 = isRouteAccessAllowed('FINANCE', 'REASSIGN_COURIER');
  tests.push({ name: 'FINANCE cannot reassign couriers', passed: !t5, error: t5 ? 'FINANCE was allowed to reassign courier' : undefined });

  // Test 6: OPERATIONS cannot manage admin users
  const t6 = isRouteAccessAllowed('OPERATIONS', 'MANAGE_ADMINS');
  tests.push({ name: 'OPERATIONS cannot create SUPER_ADMIN or manage admin users', passed: !t6, error: t6 ? 'OPERATIONS was allowed to manage admins' : undefined });

  // Test 7: SUPER_ADMIN can manage settings
  const t7 = isRouteAccessAllowed('SUPER_ADMIN', 'SETTINGS');
  tests.push({ name: 'SUPER_ADMIN can manage settings', passed: t7, error: !t7 ? 'SUPER_ADMIN was denied' : undefined });

  return tests;
}

if (require.main === module) {
  console.log('🛡️ Running Admin RBAC & Security Unit Tests...');
  const results = runSecurityRbacTests();
  let allPassed = true;
  results.forEach((r) => {
    if (r.passed) {
      console.log(` ✅ PASS: ${r.name}`);
    } else {
      console.log(` ❌ FAIL: ${r.name} -> ${r.error}`);
      allPassed = false;
    }
  });

  if (allPassed) {
    console.log('\n🎉 ALL 7 RBAC SECURITY TESTS PASSED CLEANLY!\n');
  } else {
    process.exit(1);
  }
}
