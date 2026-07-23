import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);

  // 1. Super Admin & Admin Users
  await prisma.user.upsert({
    where: { phone: '0900000000' },
    update: { role: 'SUPER_ADMIN' },
    create: {
      name: 'Super Admin - المدير العام',
      phone: '0900000000',
      email: 'superadmin@talabaty.com',
      passwordHash,
      role: 'SUPER_ADMIN',
      isVerified: true,
      adminProfile: { create: {} },
    },
  });

  await prisma.user.upsert({
    where: { phone: '0900000001' },
    update: { role: 'ADMIN' },
    create: {
      name: 'مدير عمليات النظام',
      phone: '0900000001',
      email: 'admin@talabaty.com',
      passwordHash,
      role: 'ADMIN',
      isVerified: true,
      adminProfile: { create: {} },
    },
  });

  await prisma.user.upsert({
    where: { phone: '0900000002' },
    update: { role: 'OPERATIONS' },
    create: {
      name: 'مسؤول العمليات',
      phone: '0900000002',
      email: 'ops@talabaty.com',
      passwordHash,
      role: 'OPERATIONS',
      isVerified: true,
      adminProfile: { create: {} },
    },
  });

  await prisma.user.upsert({
    where: { phone: '0900000003' },
    update: { role: 'FINANCE' },
    create: {
      name: 'مسؤول المالية',
      phone: '0900000003',
      email: 'finance@talabaty.com',
      passwordHash,
      role: 'FINANCE',
      isVerified: true,
      adminProfile: { create: {} },
    },
  });

  await prisma.user.upsert({
    where: { phone: '0900000004' },
    update: { role: 'SUPPORT' },
    create: {
      name: 'مسؤول الدعم الفني',
      phone: '0900000004',
      email: 'support@talabaty.com',
      passwordHash,
      role: 'SUPPORT',
      isVerified: true,
      adminProfile: { create: {} },
    },
  });

  // 2. Customer User
  const customerUser = await prisma.user.upsert({
    where: { phone: '0912345678' },
    update: {},
    create: {
      name: 'عمر صديق (عميل تجريبي)',
      phone: '0912345678',
      email: 'customer@talabaty.com',
      passwordHash,
      role: 'CUSTOMER',
      isVerified: true,
      customerProfile: { create: {} },
    },
  });

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

  // 3. Restaurant Merchant & Store
  const restMerchant = await prisma.user.upsert({
    where: { phone: '0922345678' },
    update: {},
    create: {
      name: 'أحمد التاجر (مطعم)',
      phone: '0922345678',
      email: 'merchant.restaurant@talabaty.com',
      passwordHash,
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
    include: {
      merchantProfile: {
        include: { stores: true },
      },
    },
  });

  const restStoreId = restMerchant.merchantProfile!.stores[0].id;

  const burgerCategory = await prisma.productCategory.create({
    data: {
      storeId: restStoreId,
      nameAr: 'برجر وساندوتشات',
      nameEn: 'Burgers & Sandwiches',
    },
  });

  const pizzaCategory = await prisma.productCategory.create({
    data: {
      storeId: restStoreId,
      nameAr: 'بيتزا إيطالية',
      nameEn: 'Italian Pizza',
    },
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

  // 4. Supermarket Merchant & Store
  const superMerchant = await prisma.user.upsert({
    where: { phone: '0922345679' },
    update: {},
    create: {
      name: 'عثمان التاجر (سوبرماركت)',
      phone: '0922345679',
      email: 'merchant.supermarket@talabaty.com',
      passwordHash,
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
    include: {
      merchantProfile: {
        include: { stores: true },
      },
    },
  });

  const superStoreId = superMerchant.merchantProfile!.stores[0].id;

  const dairyCat = await prisma.productCategory.create({
    data: {
      storeId: superStoreId,
      nameAr: 'ألبان وأجبان',
      nameEn: 'Dairy & Cheese',
    },
  });

  await prisma.product.createMany({
    data: [
      {
        storeId: superStoreId,
        categoryId: dairyCat.id,
        nameAr: 'حليب كابو 2.25 كجم',
        nameEn: 'Capo Powdered Milk 2.25kg',
        descriptionAr: 'حليب بودرة كامل الدسم ممتاز',
        price: 18500.0,
        isAvailable: true,
        stock: 20,
      },
      {
        storeId: superStoreId,
        categoryId: dairyCat.id,
        nameAr: 'جبنة بيضاء سودانية 1 كجم',
        nameEn: 'Sudanese White Cheese 1kg',
        descriptionAr: 'جبنة طازجة طبيعية 100%',
        price: 4200.0,
        isAvailable: true,
        stock: 35,
      },
    ],
  });

  // 5. Pharmacy Merchant & Store
  const pharmMerchant = await prisma.user.upsert({
    where: { phone: '0922345680' },
    update: {},
    create: {
      name: 'د. سارة (صيدلية)',
      phone: '0922345680',
      email: 'merchant.pharmacy@talabaty.com',
      passwordHash,
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
    include: {
      merchantProfile: {
        include: { stores: true },
      },
    },
  });

  const pharmStoreId = pharmMerchant.merchantProfile!.stores[0].id;

  const healthCat = await prisma.productCategory.create({
    data: {
      storeId: pharmStoreId,
      nameAr: 'عناية شخصية وفيتامينات',
      nameEn: 'Personal Care & Vitamins',
    },
  });

  await prisma.product.createMany({
    data: [
      {
        storeId: pharmStoreId,
        categoryId: healthCat.id,
        nameAr: 'فيتامين سي فوار 1000 ملجم',
        nameEn: 'Vitamin C Effervescent 1000mg',
        descriptionAr: 'مكمل غذائي لدعم المناعة',
        price: 2800.0,
        isAvailable: true,
        stock: 50,
      },
      {
        storeId: pharmStoreId,
        categoryId: healthCat.id,
        nameAr: 'شامبو للعناية اليومية 400 مل',
        nameEn: 'Daily Care Shampoo 400ml',
        descriptionAr: 'مرطب ومغذي للشعر',
        price: 3900.0,
        isAvailable: true,
        stock: 25,
      },
    ],
  });

  // 6. Couriers
  await prisma.user.upsert({
    where: { phone: '0932345678' },
    update: {},
    create: {
      name: 'محمد علي (مندوب موتر)',
      phone: '0932345678',
      email: 'courier1@talabaty.com',
      passwordHash,
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

  await prisma.user.upsert({
    where: { phone: '0942345678' },
    update: {},
    create: {
      name: 'طارق حسين (مندوب عجلة كهربائية)',
      phone: '0942345678',
      email: 'courier2@talabaty.com',
      passwordHash,
      role: 'COURIER',
      isVerified: true,
      courierProfile: {
        create: {
          vehicleType: 'ELECTRIC_BICYCLE',
          idNumber: '5647382910',
          licenseNumber: 'ع 5432',
          verificationStatus: 'APPROVED',
          status: 'AVAILABLE',
          isOnline: true,
          currentLatitude: 15.5600,
          currentLongitude: 32.5800,
        },
      },
    },
  });

  // 7. Seed Service Areas (Khartoum State)
  const areas = [
    { state: 'ولاية الخرطوم', locality: 'الخرطوم', nameAr: 'محلية الخرطوم', nameEn: 'Khartoum Locality', isActive: true, deliveryRadius: 20.0, minimumDeliveryFee: 500.0, pricePerKm: 200.0 },
    { state: 'ولاية الخرطوم', locality: 'بحري', nameAr: 'محلية بحري', nameEn: 'Bahri Locality', isActive: true, deliveryRadius: 18.0, minimumDeliveryFee: 500.0, pricePerKm: 200.0 },
    { state: 'ولاية الخرطوم', locality: 'أم درمان', nameAr: 'محلية أم درمان', nameEn: 'Omdurman Locality', isActive: true, deliveryRadius: 22.0, minimumDeliveryFee: 500.0, pricePerKm: 200.0 },
    { state: 'الجزيرة', locality: 'ود مدني', nameAr: 'محلية ود مدني (قريباً)', nameEn: 'Wad Madani', isActive: false, deliveryRadius: 15.0, minimumDeliveryFee: 600.0, pricePerKm: 250.0 },
    { state: 'البحر الأحمر', locality: 'بورتسودان', nameAr: 'محلية بورتسودان (قريباً)', nameEn: 'Port Sudan', isActive: false, deliveryRadius: 15.0, minimumDeliveryFee: 600.0, pricePerKm: 250.0 },
  ];

  for (const area of areas) {
    await prisma.serviceArea.create({ data: area });
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

  console.log('Admin Seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
