import 'package:uuid/uuid.dart';
import '../../core/constants/enums.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class MockData {
  static const uuid = Uuid();

  // MOCK ADDRESSES
  static final AddressModel addressKhartoum = AddressModel(id: 'a1', title: 'المنزل', city: 'الخرطوم', area: 'الرياض', street: 'شارع المشتل', landmark: 'بالقرب من ماكس', latitude: 15.5640, longitude: 32.5840, phone: '0912345678');
  static final AddressModel addressBahri = AddressModel(id: 'a2', title: 'العمل', city: 'بحري', area: 'شمبات', street: 'شارع المعونة', landmark: 'جوار المؤسسة', latitude: 15.6389, longitude: 32.5265, phone: '0123456789');
  static final AddressModel addressOmdurman = AddressModel(id: 'a3', title: 'أخرى', city: 'أم درمان', area: 'المهندسين', street: 'الشارع الرئيسي', landmark: 'جوار صينية المهندسين', latitude: 15.6476, longitude: 32.4807, phone: '0111111111');

  // MOCK CUSTOMERS
  static List<UserModel> get mockCustomers => [
    UserModel(id: 'cu1', name: 'عمر صديق', phone: '0912345678', email: 'omar@talabaty.com', password: '123', role: UserRole.customer, createdAt: DateTime.now()),
  ];
  static List<CustomerProfile> get mockCustomerProfiles => [
    CustomerProfile(userId: 'cu1', addresses: [addressKhartoum, addressBahri, addressOmdurman], defaultAddressId: 'a1'),
  ];

  // MOCK STORES
  static List<StoreModel> get mockStores => [
    // Restaurants
    StoreModel(id: 's1', ownerId: 'm1', name: 'مطعم البيت الكبير', type: StoreType.restaurant, logo: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=400', rating: 4.8, area: 'الخرطوم', street: 'الرياض', landmark: '', phone: '0911111111', latitude: 15.5640, longitude: 32.5840, openingTime: '10:00 AM', closingTime: '11:00 PM', preparationTime: '20-30 د', minimumOrder: 2000, deliveryFee: 1500),
    StoreModel(id: 's2', ownerId: 'm2', name: 'كبابجي البرنس', type: StoreType.restaurant, logo: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=400', rating: 4.6, area: 'بحري', street: 'شمبات', landmark: '', phone: '0911111112', latitude: 15.6389, longitude: 32.5265, openingTime: '10:00 AM', closingTime: '11:00 PM', preparationTime: '20-30 د', minimumOrder: 2000, deliveryFee: 1500),
    StoreModel(id: 's3', ownerId: 'm3', name: 'مطبخ أكل سوداني', type: StoreType.restaurant, logo: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=400', rating: 4.5, area: 'أم درمان', street: 'الموردة', landmark: '', phone: '0911111113', latitude: 15.6476, longitude: 32.4807, openingTime: '10:00 AM', closingTime: '11:00 PM', preparationTime: '20-30 د', minimumOrder: 2000, deliveryFee: 1500),
    StoreModel(id: 's4', ownerId: 'm4', name: 'بيتزا الخرطوم', type: StoreType.restaurant, logo: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=400', rating: 4.2, area: 'الخرطوم', street: 'المنشية', landmark: '', phone: '0911111114', latitude: 15.5500, longitude: 32.5500, openingTime: '10:00 AM', closingTime: '11:00 PM', preparationTime: '20-30 د', minimumOrder: 2000, deliveryFee: 1500),
    StoreModel(id: 's5', ownerId: 'm5', name: 'شاورما النيل', type: StoreType.restaurant, logo: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?q=80&w=400', rating: 4.5, area: 'الخرطوم', street: 'النيل', landmark: '', phone: '0911111115', latitude: 15.5700, longitude: 32.5300, openingTime: '10:00 AM', closingTime: '11:00 PM', preparationTime: '20-30 د', minimumOrder: 2000, deliveryFee: 1500),
    
    // Supermarkets
    StoreModel(id: 's6', ownerId: 'm6', name: 'سوبر ماركت النيل', type: StoreType.supermarket, logo: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=400', rating: 4.3, area: 'بحري', street: 'الصافية', landmark: '', phone: '0911111116', latitude: 15.6500, longitude: 32.5200, openingTime: '08:00 AM', closingTime: '11:00 PM', preparationTime: '15-20 د', minimumOrder: 5000, deliveryFee: 1000),
    StoreModel(id: 's7', ownerId: 'm7', name: 'أسواق العالية', type: StoreType.supermarket, logo: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=400', rating: 4.7, area: 'الخرطوم', street: 'اركويت', landmark: '', phone: '0911111117', latitude: 15.5400, longitude: 32.5600, openingTime: '08:00 AM', closingTime: '11:00 PM', preparationTime: '15-20 د', minimumOrder: 5000, deliveryFee: 1000),
    StoreModel(id: 's8', ownerId: 'm8', name: 'ماركت بحري', type: StoreType.supermarket, logo: 'https://images.unsplash.com/photo-1534723452862-4c874018d66d?q=80&w=400', rating: 4.4, area: 'بحري', street: 'الشعبية', landmark: '', phone: '0911111118', latitude: 15.6400, longitude: 32.5300, openingTime: '08:00 AM', closingTime: '11:00 PM', preparationTime: '15-20 د', minimumOrder: 5000, deliveryFee: 1000),
    StoreModel(id: 's9', ownerId: 'm9', name: 'سوبر ماركت الرياض', type: StoreType.supermarket, logo: 'https://images.unsplash.com/photo-1506617564039-2f3b650b7010?q=80&w=400', rating: 4.6, area: 'الخرطوم', street: 'الرياض', landmark: '', phone: '0911111119', latitude: 15.5650, longitude: 32.5800, openingTime: '08:00 AM', closingTime: '11:00 PM', preparationTime: '15-20 د', minimumOrder: 5000, deliveryFee: 1000),
    StoreModel(id: 's10', ownerId: 'm10', name: 'مركز التسوق السوداني', type: StoreType.supermarket, logo: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=400', rating: 4.8, area: 'الخرطوم', street: 'الصحافة', landmark: '', phone: '0911111120', latitude: 15.5300, longitude: 32.5400, openingTime: '08:00 AM', closingTime: '11:00 PM', preparationTime: '15-20 د', minimumOrder: 5000, deliveryFee: 1000),
    
    // Pharmacies
    StoreModel(id: 's11', ownerId: 'm11', name: 'صيدلية السلام', type: StoreType.pharmacy, logo: 'https://images.unsplash.com/photo-1576602976047-174e57a47881?q=80&w=400', rating: 4.9, area: 'الخرطوم', street: 'شارع الستين', landmark: '', phone: '0911111121', latitude: 15.5500, longitude: 32.5700, openingTime: '24 Hours', closingTime: '24 Hours', preparationTime: '10-15 د', minimumOrder: 1000, deliveryFee: 1000),
    StoreModel(id: 's12', ownerId: 'm12', name: 'صيدلية النيل', type: StoreType.pharmacy, logo: 'https://images.unsplash.com/photo-1585435557343-3b092031a831?q=80&w=400', rating: 4.8, area: 'الخرطوم', street: 'امتداد ناصر', landmark: '', phone: '0911111122', latitude: 15.5600, longitude: 32.5500, openingTime: '24 Hours', closingTime: '24 Hours', preparationTime: '10-15 د', minimumOrder: 1000, deliveryFee: 1000),
    StoreModel(id: 's13', ownerId: 'm13', name: 'صيدلية الحياة', type: StoreType.pharmacy, logo: 'https://images.unsplash.com/photo-1625244724120-1fd1d34d00f6?q=80&w=400', rating: 4.5, area: 'أم درمان', street: 'بانت', landmark: '', phone: '0911111123', latitude: 15.6300, longitude: 32.4700, openingTime: '24 Hours', closingTime: '24 Hours', preparationTime: '10-15 د', minimumOrder: 1000, deliveryFee: 1000),
    StoreModel(id: 's14', ownerId: 'm14', name: 'صيدلية الخرطوم', type: StoreType.pharmacy, logo: 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?q=80&w=400', rating: 4.7, area: 'الخرطوم', street: 'السوق العربي', landmark: '', phone: '0911111124', latitude: 15.5900, longitude: 32.5200, openingTime: '24 Hours', closingTime: '24 Hours', preparationTime: '10-15 د', minimumOrder: 1000, deliveryFee: 1000),
    StoreModel(id: 's15', ownerId: 'm15', name: 'صيدلية الشفاء', type: StoreType.pharmacy, logo: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=400', rating: 4.6, area: 'بحري', street: 'المزاد', landmark: '', phone: '0911111125', latitude: 15.6600, longitude: 32.5300, openingTime: '24 Hours', closingTime: '24 Hours', preparationTime: '10-15 د', minimumOrder: 1000, deliveryFee: 1000),
    
    // Gifts
    StoreModel(id: 's16', ownerId: 'm16', name: 'ورود وهدايا', type: StoreType.gift, logo: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=400', rating: 4.9, area: 'الخرطوم', street: 'شارع عبيد ختم', landmark: '', phone: '0911111126', latitude: 15.5600, longitude: 32.5500, openingTime: '10:00 AM', closingTime: '10:00 PM', preparationTime: '30-45 د', minimumOrder: 3000, deliveryFee: 1500),
  ];

  static final List<ProductModel> mockProducts = _generateMockProducts();

  static List<ProductModel> _generateMockProducts() {
    List<ProductModel> products = [];
    
    final sizeOptionGroup = ProductOptionGroup(
      id: 'og1',
      name: 'الحجم',
      isRequired: true,
      maxSelection: 1,
      options: [
        ProductOption(id: 'o1', name: 'صغير', extraPrice: 0),
        ProductOption(id: 'o2', name: 'وسط', extraPrice: 1000),
        ProductOption(id: 'o3', name: 'كبير', extraPrice: 2000),
      ],
    );

    final commonAddOns = [
      ProductAddOn(id: 'a1', name: 'جبنة إضافية', price: 500),
      ProductAddOn(id: 'a2', name: 'صوص', price: 250),
      ProductAddOn(id: 'a3', name: 'بطاطس', price: 800),
      ProductAddOn(id: 'a4', name: 'مشروب غازي', price: 600),
    ];

    final now = DateTime.now();

    // Restaurants
    products.addAll([
      ProductModel(id: 'p1', storeId: 's1', name: 'مندي دجاج', description: 'مندي دجاج مع أرز بسمتي', price: 5000, image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=200', category: 'وجبات رئيسية', stockQuantity: 60, optionGroups: [sizeOptionGroup], addOns: commonAddOns, createdAt: now, updatedAt: now),
      ProductModel(id: 'p2', storeId: 's2', name: 'كباب مشوي', description: 'أسياخ كباب ضأن مشوية على الفحم', price: 6000, image: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=200', category: 'مشويات', stockQuantity: 40, addOns: commonAddOns, createdAt: now, updatedAt: now),
      ProductModel(id: 'p3', storeId: 's5', name: 'شاورما دجاج', description: 'شاورما دجاج بخبز الصاج', price: 2500, image: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?q=80&w=200', category: 'سندوتشات', stockQuantity: 80, addOns: commonAddOns, createdAt: now, updatedAt: now),
      ProductModel(id: 'p4', storeId: 's4', name: 'بيتزا دجاج', description: 'بيتزا دجاج مع المشروم والزيتون', price: 4500, image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=200', category: 'بيتزا', stockQuantity: 40, optionGroups: [sizeOptionGroup], addOns: commonAddOns, createdAt: now, updatedAt: now),
      ProductModel(id: 'p5', storeId: 's1', name: 'برجر لحم', description: 'برجر لحم بقري طازج', price: 3500, image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=200', category: 'سندوتشات', stockQuantity: 50, addOns: commonAddOns, createdAt: now, updatedAt: now),
      ProductModel(id: 'p6', storeId: 's4', name: 'بطاطس', description: 'بطاطس مقلية مقرمشة', price: 1000, image: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?q=80&w=200', category: 'إضافات', stockQuantity: 100, createdAt: now, updatedAt: now),
      ProductModel(id: 'p7', storeId: 's1', name: 'عصير كركديه', description: 'عصير كركديه بارد ومنعش', price: 1000, image: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?q=80&w=200', category: 'المشروبات', stockQuantity: 100, createdAt: now, updatedAt: now),
    ]);

    // Supermarkets
    products.addAll([
      ProductModel(id: 'p8', storeId: 's6', name: 'أرز', description: 'أرز بسمتي 5 كيلو', price: 8000, image: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=200', category: 'تموين', stockQuantity: 80, createdAt: now, updatedAt: now),
      ProductModel(id: 'p9', storeId: 's7', name: 'زيت', description: 'زيت طعام 1 لتر', price: 3500, image: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=200', category: 'تموين', stockQuantity: 150, createdAt: now, updatedAt: now),
      ProductModel(id: 'p10', storeId: 's6', name: 'سكر', description: 'سكر كنانة 10 كيلو', price: 12000, image: 'https://images.unsplash.com/photo-1581441363689-1f3c3c41463c?q=80&w=200', category: 'تموين', stockQuantity: 50, createdAt: now, updatedAt: now),
      ProductModel(id: 'p11', storeId: 's8', name: 'شاي', description: 'شاي الغزالتين', price: 2000, image: 'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?q=80&w=200', category: 'مشروبات', stockQuantity: 200, createdAt: now, updatedAt: now),
      ProductModel(id: 'p12', storeId: 's9', name: 'مياه معدنية', description: 'كرتونة مياه صحية 12 حبة', price: 2400, image: 'https://images.unsplash.com/photo-1523362628745-0c100150b504?q=80&w=200', category: 'مشروبات', stockQuantity: 200, createdAt: now, updatedAt: now),
      ProductModel(id: 'p13', storeId: 's10', name: 'لبن', description: 'لبن بودرة 1 كيلو', price: 6000, image: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?q=80&w=200', category: 'ألبان', stockQuantity: 100, createdAt: now, updatedAt: now),
      ProductModel(id: 'p14', storeId: 's7', name: 'بسكويت', description: 'بسكويت مالح وحلو', price: 1500, image: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?q=80&w=200', category: 'حلويات', stockQuantity: 300, createdAt: now, updatedAt: now),
      ProductModel(id: 'p15', storeId: 's8', name: 'منظفات', description: 'صابون غسيل وملابس', price: 1800, image: 'https://images.unsplash.com/photo-1584820927498-cafe8c1c769e?q=80&w=200', category: 'عناية بالمنزل', stockQuantity: 120, createdAt: now, updatedAt: now),
    ]);

    // Pharmacies
    products.addAll([
      ProductModel(id: 'p16', storeId: 's11', name: 'كمامات', description: 'علبة كمامات طبية 50 حبة', price: 2500, image: 'https://images.unsplash.com/photo-1586942551488-825fb491d9d9?q=80&w=200', category: 'مستلزمات طبية', stockQuantity: 100, createdAt: now, updatedAt: now),
      ProductModel(id: 'p17', storeId: 's12', name: 'معقم', description: 'معقم يدين 500 مل', price: 1500, image: 'https://images.unsplash.com/photo-1584744982491-665216d95f8b?q=80&w=200', category: 'عناية شخصية', stockQuantity: 80, createdAt: now, updatedAt: now),
      ProductModel(id: 'p18', storeId: 's13', name: 'فيتامينات', description: 'فيتامين سي مع زنك', price: 4000, image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=200', category: 'مكملات غذائية', stockQuantity: 50, createdAt: now, updatedAt: now),
      ProductModel(id: 'p19', storeId: 's11', name: 'مسكن', description: 'مسكن للآلام والصداع', price: 1000, image: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=200', category: 'أدوية عامة', stockQuantity: 200, createdAt: now, updatedAt: now),
      ProductModel(id: 'p20', storeId: 's14', name: 'ميزان حرارة', description: 'ميزان حرارة إلكتروني', price: 3500, image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=200', category: 'مستلزمات طبية', stockQuantity: 30, createdAt: now, updatedAt: now),
      ProductModel(id: 'p21', storeId: 's15', name: 'شراب كحة', description: 'مهدئ وطارد للبلغم', price: 2000, image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=200', category: 'أدوية عامة', stockQuantity: 60, createdAt: now, updatedAt: now),
      ProductModel(id: 'p22', storeId: 's12', name: 'شاش طبي', description: 'شاش طبي معقم للجروح', price: 500, image: 'https://images.unsplash.com/photo-1586942551488-825fb491d9d9?q=80&w=200', category: 'مستلزمات طبية', stockQuantity: 150, createdAt: now, updatedAt: now),
    ]);

    // Gifts
    products.addAll([
      ProductModel(id: 'p23', storeId: 's16', name: 'باقة ورد جوري', description: 'باقة من الورد الجوري الأحمر الجميل', price: 15000, image: 'https://images.unsplash.com/photo-1563241598-6ce81cb4e65d?q=80&w=200', category: 'باقات', stockQuantity: 20, createdAt: now, updatedAt: now),
      ProductModel(id: 'p24', storeId: 's16', name: 'صندوق شوكولاتة', description: 'صندوق شوكولاتة فاخرة مشكلة', price: 25000, image: 'https://images.unsplash.com/photo-1540324155974-7523202daa3f?q=80&w=200', category: 'شوكولاتة', stockQuantity: 15, createdAt: now, updatedAt: now),
      ProductModel(id: 'p25', storeId: 's16', name: 'دبدوب أحمر', description: 'لعبة دبدوب ناعمة بحجم متوسط', price: 12000, image: 'https://images.unsplash.com/photo-1560867807-6bb9fdf0983a?q=80&w=200', category: 'ألعاب', stockQuantity: 10, createdAt: now, updatedAt: now),
    ]);

    return products;
  }

  // MOCK COURIERS
  static List<UserModel> get mockCourierUsers => [
    UserModel(id: 'co1', name: 'محمد أحمد', phone: '0933333333', password: '123', role: UserRole.courier, profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150', createdAt: DateTime.now()),
    UserModel(id: 'co2', name: 'أحمد عثمان', phone: '0123456789', password: '123', role: UserRole.courier, profileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150', createdAt: DateTime.now()),
    UserModel(id: 'co3', name: 'علي حسن', phone: '0944444444', password: '123', role: UserRole.courier, profileImage: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=150', createdAt: DateTime.now()),
    UserModel(id: 'co4', name: 'سامي إبراهيم', phone: '0999999999', password: '123', role: UserRole.courier, profileImage: 'https://images.unsplash.com/photo-1566492031525-87838d60eb0e?q=80&w=150', createdAt: DateTime.now()),
    UserModel(id: 'co5', name: 'خالد عمر', phone: '0922222222', password: '123', role: UserRole.courier, profileImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=150', createdAt: DateTime.now()),
  ];

  static List<CourierProfile> get mockCourierProfiles => [
    CourierProfile(userId: 'co1', nationalId: '123456789', dateOfBirth: '1990-01-01', emergencyPhone: '0911111111', vehicleType: VehicleType.motorcycle, vehiclePlate: 'خ 1234', vehicleColor: 'أحمر', vehicleModel: 'هوندا', hasDeliveryBox: true, workingAreas: ['الخرطوم'], maxDeliveryDistance: 10, currentLat: 15.5640, currentLng: 32.5840, status: CourierStatus.available, rating: 4.8, totalDeliveries: 120, todayEarnings: 15000),
    CourierProfile(userId: 'co2', nationalId: '987654321', dateOfBirth: '1992-05-15', emergencyPhone: '0122222222', vehicleType: VehicleType.car, vehiclePlate: 'خ 5678', vehicleColor: 'أبيض', vehicleModel: 'تويوتا', hasDeliveryBox: false, workingAreas: ['بحري'], maxDeliveryDistance: 15, currentLat: 15.6389, currentLng: 32.5265, status: CourierStatus.busy, rating: 4.5, totalDeliveries: 85, todayEarnings: 5000),
    CourierProfile(userId: 'co3', nationalId: '111222333', dateOfBirth: '1995-08-20', emergencyPhone: '0113333333', vehicleType: VehicleType.electricBike, hasDeliveryBox: true, workingAreas: ['أم درمان'], maxDeliveryDistance: 5, currentLat: 15.6476, currentLng: 32.4807, status: CourierStatus.available, rating: 4.9, totalDeliveries: 300, todayEarnings: 20000),
    CourierProfile(userId: 'co4', nationalId: '444555666', dateOfBirth: '1988-12-10', emergencyPhone: '0994444444', vehicleType: VehicleType.motorcycle, vehiclePlate: 'خ 9999', vehicleColor: 'أسود', vehicleModel: 'سوزوكي', hasDeliveryBox: true, workingAreas: ['الخرطوم', 'بحري'], maxDeliveryDistance: 10, currentLat: 15.5500, currentLng: 32.5500, status: CourierStatus.available, rating: 4.6, totalDeliveries: 50, todayEarnings: 0),
    CourierProfile(userId: 'co5', nationalId: '777888999', dateOfBirth: '1998-03-25', emergencyPhone: '0925555555', vehicleType: VehicleType.bicycle, hasDeliveryBox: true, workingAreas: ['الخرطوم'], maxDeliveryDistance: 3, currentLat: 15.5700, currentLng: 32.5300, status: CourierStatus.offline, rating: 4.2, totalDeliveries: 20, todayEarnings: 0),
  ];

  // MOCK MERCHANTS
  static List<UserModel> get mockMerchantUsers => [
    UserModel(id: 'm1', name: 'محمد التاجر', phone: '0900000001', password: '123', role: UserRole.merchant, createdAt: DateTime.now()),
  ];
  static List<MerchantProfile> get mockMerchantProfiles => [
    MerchantProfile(userId: 'm1', ownerName: 'محمد التاجر', storeId: 's1'),
  ];
}
