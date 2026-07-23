import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';

const prisma = new PrismaClient();

async function getOrGenerateDefaultHash(): Promise<string> {
  const envPassword = process.env.SEED_INITIAL_ADMIN_PASSWORD;
  if (envPassword && envPassword.trim() !== '') {
    return bcrypt.hash(envPassword, 12);
  }
  // Generate random 32-character password hash so no static password exists in code
  const randomSecret = crypto.randomBytes(24).toString('hex');
  return bcrypt.hash(randomSecret, 12);
}

async function main() {
  const initialPasswordHash = await getOrGenerateDefaultHash();

  // 1. Admin Staff Accounts (Only creates if non-existent, never overwrites existing passwordHash)
  const adminAccounts = [
    { phone: '0900000000', email: 'superadmin@mytalabaty.com', name: 'Super Admin - المدير العام', role: 'SUPER_ADMIN' as const },
    { phone: '0900000001', email: 'admin@mytalabaty.com', name: 'مدير عمليات النظام', role: 'ADMIN' as const },
    { phone: '0900000002', email: 'ops@mytalabaty.com', name: 'مسؤول العمليات', role: 'OPERATIONS' as const },
    { phone: '0900000003', email: 'finance@mytalabaty.com', name: 'مسؤول المالية', role: 'FINANCE' as const },
    { phone: '0900000004', email: 'support@mytalabaty.com', name: 'مسؤول الدعم الفني', role: 'SUPPORT' as const },
  ];

  for (const adm of adminAccounts) {
    const existing = await prisma.user.findUnique({ where: { phone: adm.phone } });
    if (!existing) {
      await prisma.user.create({
        data: {
          name: adm.name,
          phone: adm.phone,
          email: adm.email,
          passwordHash: initialPasswordHash,
          role: adm.role,
          isVerified: true,
          forcePasswordChange: true,
          adminProfile: { create: {} },
        },
      });
    } else {
      // Ensure role and email domain are updated without touching existing passwordHash
      await prisma.user.update({
        where: { id: existing.id },
        data: {
          email: adm.email,
          role: adm.role,
        },
      });
    }
  }

  // 2. Customer User
  const customerUser = await prisma.user.upsert({
    where: { phone: '0912345678' },
    update: { email: 'customer@mytalabaty.com' },
    create: {
      name: 'عمر صديق (عميل تجريبي)',
      phone: '0912345678',
      email: 'customer@mytalabaty.com',
      passwordHash: initialPasswordHash,
      role: 'CUSTOMER',
      isVerified: true,
      customerProfile: { create: {} },
    },
  });

  const existingAddress = await prisma.address.findFirst({ where: { userId: customerUser.id } });
  if (!existingAddress) {
    await prisma.address.create({
      data: {
        userId: customerUser.id,
        title: 'البيت',
        city: 'الخرطوم',
        area: 'الرياض',
        street: 'شارع المشتل',
        landmark: 'قرب صيدلية الشفاء',
        latitude: 15.5640,
        longitude: 32.5840,
        phone: '0912345678',
      },
    });
  }

  // 3. Restaurant Merchant & Store
  const restMerchant = await prisma.user.upsert({
    where: { phone: '0922345678' },
    update: { email: 'merchant.restaurant@mytalabaty.com' },
    create: {
      name: 'أحمد التاجر (مطعم)',
      phone: '0922345678',
      email: 'merchant.restaurant@mytalabaty.com',
      passwordHash: initialPasswordHash,
      role: 'MERCHANT',
      isVerified: true,
      merchantProfile: {
        create: {
          businessName: 'مطعم البركة',
          businessDescription: 'أشهى المأكولات السودانية والوجبات السريعة',
          businessArea: 'الخرطوم - الرياض',
          status: 'APPROVED',
          stores: {
            create: {
              id: 'store-rest-1',
              name: 'مطعم البركة',
              category: 'RESTAURANT',
              description: 'أشهى المأكولات السودانية والوجبات السريعة',
              address: 'شارع المشتل، الرياض، الخرطوم',
              latitude: 15.5640,
              longitude: 32.5840,
              isOpen: true,
              isActive: true,
              deliveryFee: 500.0,
              estimatedPrepTime: 25,
            },
          },
        },
      },
    },
    include: { merchantProfile: { include: { stores: true } } },
  });

  const restStoreId = restMerchant.merchantProfile?.stores?.[0]?.id;
  if (restStoreId) {
    const existingCat = await prisma.productCategory.findFirst({ where: { storeId: restStoreId } });
    if (!existingCat) {
      const burgerCategory = await prisma.productCategory.create({
        data: { storeId: restStoreId, nameAr: 'برجر وساندوتشات', nameEn: 'Burgers & Sandwiches' },
      });
      const pizzaCategory = await prisma.productCategory.create({
        data: { storeId: restStoreId, nameAr: 'بيتزا إيطالية', nameEn: 'Italian Pizza' },
      });

      await prisma.product.createMany({
        data: [
          {
            storeId: restStoreId,
            categoryId: burgerCategory.id,
            nameAr: 'برجر دجاج كلاسيك',
            nameEn: 'Classic Chicken Burger',
            descriptionAr: 'صدر دجاج مقرمش مع جبنة شيدر وخس وصلصة خاصة',
            price: 3500.0,
            isAvailable: true,
            stock: 50,
          },
          {
            storeId: restStoreId,
            categoryId: burgerCategory.id,
            nameAr: 'برجر لحم دوبل',
            nameEn: 'Double Beef Burger',
            descriptionAr: 'قطعتين لحم بقر طازج مع مخلل وبصل ومشروم',
            price: 4500.0,
            isAvailable: true,
            stock: 40,
          },
          {
            storeId: restStoreId,
            categoryId: pizzaCategory.id,
            nameAr: 'بيتزا مارجريتا ديلوكس',
            nameEn: 'Margherita Pizza Deluxe',
            descriptionAr: 'صلصة طماطم طازجة، جبنة موزاريلا وحبق طازج',
            price: 5200.0,
            isAvailable: true,
            stock: 30,
          },
        ],
      });
    }
  }

  // 4. Supermarket Merchant & Store
  await prisma.user.upsert({
    where: { phone: '0922345679' },
    update: { email: 'merchant.supermarket@mytalabaty.com' },
    create: {
      name: 'عثمان التاجر (سوبرماركت)',
      phone: '0922345679',
      email: 'merchant.supermarket@mytalabaty.com',
      passwordHash: initialPasswordHash,
      role: 'MERCHANT',
      isVerified: true,
      merchantProfile: {
        create: {
          businessName: 'سوبرماركت الخير',
          businessDescription: 'جميع المستلزمات المنزلية والمواد الغذائية الطازجة',
          businessArea: 'الخرطوم - المعمورة',
          status: 'APPROVED',
          stores: {
            create: {
              id: 'store-super-1',
              name: 'سوبرماركت الخير',
              category: 'SUPERMARKET',
              description: 'جميع المستلزمات المنزلية والمواد الغذائية الطازجة',
              address: 'شارع ستين، المعمورة، الخرطوم',
              latitude: 15.5520,
              longitude: 32.5710,
              isOpen: true,
              isActive: true,
              deliveryFee: 600.0,
              estimatedPrepTime: 15,
            },
          },
        },
      },
    },
  });

  // 5. Pharmacy Merchant & Store
  await prisma.user.upsert({
    where: { phone: '0922345680' },
    update: { email: 'merchant.pharmacy@mytalabaty.com' },
    create: {
      name: 'د. سارة (صيدلية)',
      phone: '0922345680',
      email: 'merchant.pharmacy@mytalabaty.com',
      passwordHash: initialPasswordHash,
      role: 'MERCHANT',
      isVerified: true,
      merchantProfile: {
        create: {
          businessName: 'صيدلية الشفاء',
          businessDescription: 'مستلزمات العناية الشخصية والأدوية والمستحضرات الطبية',
          businessArea: 'الخرطوم - العمارات',
          status: 'APPROVED',
          stores: {
            create: {
              id: 'store-pharm-1',
              name: 'صيدلية الشفاء',
              category: 'PHARMACY',
              description: 'مستلزمات العناية الشخصية والأدوية والمستحضرات الطبية',
              address: 'شارع 15، العمارات، الخرطوم',
              latitude: 15.5780,
              longitude: 32.5320,
              isOpen: true,
              isActive: true,
              deliveryFee: 400.0,
              estimatedPrepTime: 10,
            },
          },
        },
      },
    },
  });

  // 6. Couriers
  await prisma.user.upsert({
    where: { phone: '0932345678' },
    update: { email: 'courier1@mytalabaty.com' },
    create: {
      name: 'محمد علي (مندوب موتر)',
      phone: '0932345678',
      email: 'courier1@mytalabaty.com',
      passwordHash: initialPasswordHash,
      role: 'COURIER',
      isVerified: true,
      courierProfile: {
        create: {
          vehicleType: 'MOTORCYCLE',
          idNumber: '1029384756',
          licenseNumber: 'خ 9876',
          verificationStatus: 'APPROVED',
          status: 'AVAILABLE',
          isOnline: true,
          currentLatitude: 15.5650,
          currentLongitude: 32.5830,
        },
      },
    },
  });

  // 7. Seed Service Areas (Khartoum State)
  const areas = [
    { state: 'ولاية الخرطوم', locality: 'الخرطوم', nameAr: 'محلية الخرطوم', nameEn: 'Khartoum Locality', isActive: true, deliveryRadius: 20.0, minimumDeliveryFee: 500.0, pricePerKm: 200.0 },
    { state: 'ولاية الخرطوم', locality: 'بحري', nameAr: 'محلية بحري', nameEn: 'Bahri Locality', isActive: true, deliveryRadius: 18.0, minimumDeliveryFee: 500.0, pricePerKm: 200.0 },
    { state: 'ولاية الخرطوم', locality: 'أم درمان', nameAr: 'محلية أم درمان', nameEn: 'Omdurman Locality', isActive: true, deliveryRadius: 22.0, minimumDeliveryFee: 500.0, pricePerKm: 200.0 },
  ];

  for (const area of areas) {
    const existingArea = await prisma.serviceArea.findFirst({ where: { locality: area.locality } });
    if (!existingArea) {
      await prisma.serviceArea.create({ data: area });
    }
  }

  // 8. Platform Settings
  const settings = [
    { key: 'accept_new_orders', value: 'true' },
    { key: 'merchant_registration_enabled', value: 'true' },
    { key: 'courier_registration_enabled', value: 'true' },
    { key: 'maximum_order_radius_km', value: '25' },
    { key: 'default_prep_time_minutes', value: '20' },
    { key: 'support_phone', value: '0900000000' },
    { key: 'support_email', value: 'support@mytalabaty.com' },
  ];

  for (const s of settings) {
    await prisma.platformSetting.upsert({
      where: { key: s.key },
      update: { value: s.value },
      create: s,
    });
  }

  console.log('Secure Seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
