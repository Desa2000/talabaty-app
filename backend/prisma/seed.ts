import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // Only run seeding in development/testing, or check if database is empty
  const passwordHash = await bcrypt.hash('123', 10);

  // 1. Seed Admin User
  await prisma.user.upsert({
    where: { phone: '0900000000' },
    update: {},
    create: {
      name: 'مدير النظام',
      phone: '0900000000',
      email: 'admin@talabaty.com',
      passwordHash,
      role: 'ADMIN',
      isVerified: true,
      adminProfile: {
        create: {},
      },
    },
  });

  // 2. Seed Customer User
  await prisma.user.upsert({
    where: { phone: '0912345678' },
    update: {},
    create: {
      name: 'عمر صديق',
      phone: '0912345678',
      email: 'omar@talabaty.com',
      passwordHash,
      role: 'CUSTOMER',
      isVerified: true,
      customerProfile: {
        create: {},
      },
    },
  });

  // 3. Seed Merchant User (with default Store mapping)
  await prisma.user.upsert({
    where: { phone: '0900000001' },
    update: {},
    create: {
      name: 'محمد التاجر',
      phone: '0900000001',
      email: 'merchant@talabaty.com',
      passwordHash,
      role: 'MERCHANT',
      isVerified: true,
      merchantProfile: {
        create: {
          businessName: 'مطعم البيت الكبير',
          businessDescription: 'وجبات سودانية وعالمية طازجة',
          businessArea: 'الخرطوم',
          stores: {
            create: {
              id: 's1', // Match original mock store ID
              name: 'مطعم البيت الكبير',
              category: 'RESTAURANT',
              description: 'وجبات سودانية وعالمية طازجة',
              address: 'شارع المشتل، الرياض، الخرطوم',
              latitude: 15.5640,
              longitude: 32.5840,
            },
          },
        },
      },
    },
  });

  // 4. Seed Courier User
  await prisma.user.upsert({
    where: { phone: '0933333333' },
    update: {},
    create: {
      name: 'محمد أحمد',
      phone: '0933333333',
      email: 'courier@talabaty.com',
      passwordHash,
      role: 'COURIER',
      isVerified: true,
      courierProfile: {
        create: {
          vehicleType: 'MOTORCYCLE',
          idNumber: '123456789',
          licenseNumber: 'خ 1234',
        },
      },
    },
  });

  console.log('Seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
