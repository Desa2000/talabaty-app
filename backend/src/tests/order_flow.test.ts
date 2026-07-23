import { OrderStatus, UserRole } from '@prisma/client';

export interface TestResult {
  name: string;
  passed: boolean;
  error?: string;
}

export function validateStatusTransition(
  currentStatus: OrderStatus,
  newStatus: OrderStatus,
  actorRole: UserRole,
  isAssignedCourier: boolean,
  isStoreOwner: boolean,
  isOrderCustomer: boolean
): { allowed: boolean; reason?: string } {
  // Rule 1: Customer can only cancel if status is PENDING_MERCHANT
  if (newStatus === 'CUSTOMER_CANCELLED') {
    if (!isOrderCustomer) return { allowed: false, reason: 'فقط العميل صاحب الطلب يمكنه إغاء الطلب' };
    if (currentStatus !== 'PENDING_MERCHANT') return { allowed: false, reason: 'لا يمكن إلغاء الطلب بعد قبول المتجر له' };
    return { allowed: true };
  }

  // Rule 2: Customer cannot manually mark order as COMPLETED unless status is DELIVERED or ARRIVED
  if (newStatus === 'COMPLETED' && isOrderCustomer) {
    if (currentStatus !== 'DELIVERED' && currentStatus !== 'ARRIVED') {
      return { allowed: false, reason: 'لا يمكن للعميل تأكيد التسليم قبل وصول المندوب بروايات حقيقية' };
    }
  }

  // Rule 3: Merchant can only accept/reject PENDING_MERCHANT
  if (newStatus === 'MERCHANT_ACCEPTED' || newStatus === 'MERCHANT_REJECTED') {
    if (actorRole !== 'MERCHANT' && actorRole !== 'ADMIN') return { allowed: false, reason: 'فقط التاجر يمكنه قبول أو رفض الطلب' };
    if (!isStoreOwner) return { allowed: false, reason: 'هذا الطلب لا يخص متجرك' };
    if (currentStatus !== 'PENDING_MERCHANT') return { allowed: false, reason: 'الطلب ليس في حالة انتظار قبول التاجر' };
    return { allowed: true };
  }

  // Rule 4: Merchant preparing & ready
  if (newStatus === 'PREPARING') {
    if (!isStoreOwner) return { allowed: false, reason: 'غير مصرح للتاجر' };
    if (currentStatus !== 'MERCHANT_ACCEPTED') return { allowed: false, reason: 'يجب قبول الطلب أولاً' };
    return { allowed: true };
  }

  if (newStatus === 'SEARCHING_COURIER' || newStatus === 'READY_FOR_PICKUP') {
    if (!isStoreOwner) return { allowed: false, reason: 'غير مصرح للتاجر' };
    if (currentStatus !== 'PREPARING' && currentStatus !== 'MERCHANT_ACCEPTED') return { allowed: false, reason: 'الطلب ليس جاهزاً للاستلام' };
    return { allowed: true };
  }

  // Rule 5: Courier acceptance
  if (newStatus === 'COURIER_ACCEPTED') {
    if (actorRole !== 'COURIER' && actorRole !== 'ADMIN') return { allowed: false, reason: 'فقط المندوب يمكنه قبول التوصيل' };
    if (currentStatus !== 'SEARCHING_COURIER' && currentStatus !== 'READY_FOR_PICKUP') return { allowed: false, reason: 'الطلب غير متاح لقبول المندوب' };
    return { allowed: true };
  }

  // Rule 6: Courier delivery steps
  if (['PICKED_UP', 'ON_THE_WAY', 'ARRIVED', 'DELIVERED', 'COMPLETED'].includes(newStatus)) {
    if (actorRole === 'COURIER' && !isAssignedCourier) {
      return { allowed: false, reason: 'المندوب غير مسند لهذا الطلب' };
    }
  }

  return { allowed: true };
}

export function runOrderFlowAuthorizationTests(): TestResult[] {
  const results: TestResult[] = [];

  // Test 1: Merchant accepting another merchant's order must fail
  const t1 = validateStatusTransition('PENDING_MERCHANT', 'MERCHANT_ACCEPTED', 'MERCHANT', false, false, false);
  results.push({
    name: "Merchant accepting another merchant's order must fail",
    passed: !t1.allowed,
    error: t1.allowed ? 'T1 failed: Should not allow unowned store acceptance' : undefined,
  });

  // Test 2: Courier accepting unavailable order must fail
  const t2 = validateStatusTransition('PREPARING', 'COURIER_ACCEPTED', 'COURIER', false, false, false);
  results.push({
    name: 'Courier accepting unavailable order must fail',
    passed: !t2.allowed,
    error: t2.allowed ? 'T2 failed: Should not allow courier accept when not searching courier' : undefined,
  });

  // Test 3: Customer cancelling after merchant acceptance must fail
  const t3 = validateStatusTransition('PREPARING', 'CUSTOMER_CANCELLED', 'CUSTOMER', false, false, true);
  results.push({
    name: 'Customer cancelling after merchant acceptance must fail',
    passed: !t3.allowed,
    error: t3.allowed ? 'T3 failed: Should not allow customer cancellation after preparing' : undefined,
  });

  // Test 4: Customer marking completed when PENDING must fail
  const t4 = validateStatusTransition('PENDING_MERCHANT', 'COMPLETED', 'CUSTOMER', false, false, true);
  results.push({
    name: 'Customer completing order manually must fail',
    passed: !t4.allowed,
    error: t4.allowed ? 'T4 failed: Should not allow customer completion on PENDING' : undefined,
  });

  // Test 5: Valid merchant acceptance must pass
  const t5 = validateStatusTransition('PENDING_MERCHANT', 'MERCHANT_ACCEPTED', 'MERCHANT', false, true, false);
  results.push({
    name: 'Valid merchant acceptance must pass',
    passed: t5.allowed,
    error: !t5.allowed ? t5.reason : undefined,
  });

  // Test 6: Valid courier acceptance when searching courier must pass
  const t6 = validateStatusTransition('SEARCHING_COURIER', 'COURIER_ACCEPTED', 'COURIER', false, false, false);
  results.push({
    name: 'Valid courier acceptance when searching courier must pass',
    passed: t6.allowed,
    error: !t6.allowed ? t6.reason : undefined,
  });

  return results;
}

if (require.main === module) {
  console.log('🧪 Running Backend Authorization & State Machine Tests...');
  const tests = runOrderFlowAuthorizationTests();
  let allPassed = true;
  tests.forEach((t) => {
    if (t.passed) {
      console.log(` ✅ PASS: ${t.name}`);
    } else {
      console.log(` ❌ FAIL: ${t.name} -> ${t.error}`);
      allPassed = false;
    }
  });

  if (allPassed) {
    console.log('\n🎉 ALL 6 AUTHORIZATION TESTS PASSED CLEANLY!\n');
  } else {
    process.exit(1);
  }
}
