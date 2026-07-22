"use client";

import React, { createContext, useContext, useState, useEffect } from "react";

type Language = "ar" | "en";

interface LanguageContextType {
  lang: Language;
  dir: "rtl" | "ltr";
  toggleLanguage: () => void;
  t: (key: string) => string;
}

const translations: Record<Language, Record<string, string>> = {
  ar: {
    // Nav
    home: "الرئيسية",
    howItWorks: "كيف يعمل",
    services: "الخدمات",
    merchants: "للتجار",
    couriers: "للمناديب",
    faq: "الأسئلة الشائعة",
    contact: "تواصل معنا",
    downloadApp: "حمّل التطبيق",
    joinMerchant: "انضم كتاجر",
    joinCourier: "اشتغل مندوب",

    // Hero
    heroTitlePrefix: "طلباتك",
    heroTitleMain: "أسرع.. أسهل.. أقرب",
    heroDescription:
      "اطلب من مطاعمك، سوبرماركتك وصيدليتك المفضلة، ونحن نوصلها ليك بسرعة وأمان في السودان.",
    fastDeliveryBadge: "توصيل سريع ⚡",
    trustedCouriersBadge: "مناديب موثوقون 🛵",

    // Services
    servicesTitle: "كل احتياجاتك في طلباتي",
    servicesSubtitle: "منصتك الشاملة لتوفير احتياجات اليوم بلمسة زر واحدة",
    restaurants: "المطاعم",
    restaurantsDesc: "أشهى الوجبات والمأكولات السودانية والعالمية طازجة من مطابخك المفضلة.",
    supermarkets: "السوبرماركت",
    supermarketsDesc: "كل مقاضي المنزل والمواد الغذائية والتموينية بأسعار ممتازة وتوصيل سريع.",
    pharmacies: "الصيدليات",
    pharmaciesDesc: "أدويتك ومستلزماتك الطبية والعناية الشخصية تصلك لأباب بيتك بأمان.",
    exploreCategory: "استكشف المتاجر",

    // How It Works
    howTitle: "كيف يعمل طلباتي؟",
    step1Title: "اختار المتجر",
    step1Desc: "اختر مطعم، سوبرماركت أو صيدلية قريبة منك.",
    step2Title: "أضف المنتجات",
    step2Desc: "أضف ما تحتاجه إلى سلة الطلب بكل سهولة.",
    step3Title: "أكد الطلب",
    step3Desc: "اختر طريقة الدفع (كاش أو بنكك) وأكد طلبك.",
    step4Title: "تابع طلبك",
    step4Desc: "تابع طلبك لحظة بلحظة حتى يصلك لأباب بيتك.",

    // Merchant Section
    merchantTitle: "كبّر مبيعاتك مع طلباتي",
    merchantSubtitle: "سجّل متجرك وابدأ الوصول لعملاء أكثر في مدينتك.",
    mFeat1: "عرض منتجاتك بسهولة",
    mFeat2: "إدارة الطلبات والتوصيلات",
    mFeat3: "تحديث حالة الطلب لحظة بلحظة",
    mFeat4: "إدارة الأسعار والتوفر",
    mFeat5: "لوحة تحكم متكاملة ومتقدمة",
    mFeat6: "زيادة فرص وصولك للعملاء",
    registerStoreNow: "سجّل متجرك الآن",

    // Courier Section
    courierTitle: "اشتغل مندوب مع طلباتي",
    courierSubtitle: "انضم لأسرة المناديب واكسب دخل ممتاز من كل توصيل.",
    cFeat1: "استقبال الطلبات القريبة منك",
    cFeat2: "معرفة موقع الاستلام والتسليم بدقة",
    cFeat3: "متابعة الأرباح اليومية بسهولة",
    cFeat4: "التحكم الكامل في حالة التوفر",
    cFeat5: "تتبع وتوجيه حي ومباشر",
    supportedVehiclesTitle: "المركبات المدعومة فقط:",
    bicycle: "دراجة هوائية",
    electricBike: "دراجة كهربائية",
    motorcycle: "دراجة نارية",
    joinCourierNow: "انضم كمندوب الآن",

    // Download App
    downloadTitle: "حمّل تطبيق طلباتي الآن",
    downloadSubtitle: "تجربة طلب سهلة وسريعة في متناول يدك بأعلى جودة.",
    comingSoon: "قريبًا",
    qrScanTitle: "امسح الكود للتحميل",

    // Benefits
    benefitsTitle: "لماذا تختار طلباتي؟",
    b1Title: "مطاعم متنوعة",
    b1Desc: "تصفح مئات الوجبات والأصناف الطازجة من أفضل المطابخ المحلية والعالمية.",
    b2Title: "سوبرماركت شامل",
    b2Desc: "كل احتياجات المنزل والمواد الغذائية تصلك طازجة دون عناء الخروج.",
    b3Title: "صيدليات مجاورة",
    b3Desc: "دواك ومستلزماتك الطبية والعناية الشخصية متوفرة دائماً لسلامتك.",
    b4Title: "توصيل سريع وآمن",
    b4Desc: "شبكة مناديب محترفين وموثوقين في خدمتك على مدار الساعة.",

    // Footer
    footerDesc: "تطبيق طلباتي هو المنصة السودانية الأولى لتوصيل الطلبات والمأكولات والمستلزمات الطبية بسرعة وأمان.",
    forCustomers: "للعملاء",
    forMerchants: "للتجار",
    forCouriers: "للمناديب",
    orderingMethod: "طريقة الطلب",
    trackOrder: "تتبع الطلب",
    techSupport: "الدعم الفني",
    merchantTerms: "شروط التجار",
    courierTerms: "شروط الانضمام",
    allRightsReserved: "جميع الحقوق محفوظة.",
    privacyPolicy: "سياسة الخصوصية",
    termsAndConditions: "الشروط والأحكام",
  },
  en: {
    // Nav
    home: "Home",
    howItWorks: "How It Works",
    services: "Services",
    merchants: "For Merchants",
    couriers: "For Couriers",
    faq: "FAQ",
    contact: "Contact Us",
    downloadApp: "Download App",
    joinMerchant: "Join as Merchant",
    joinCourier: "Join as Courier",

    // Hero
    heroTitlePrefix: "Your Orders",
    heroTitleMain: "Faster.. Easier.. Closer",
    heroDescription:
      "Order from your favorite restaurants, supermarkets, and pharmacies, and we will deliver to you quickly and safely in Sudan.",
    fastDeliveryBadge: "Fast Delivery ⚡",
    trustedCouriersBadge: "Trusted Couriers 🛵",

    // Services
    servicesTitle: "Everything You Need on Talabaty",
    servicesSubtitle: "Your all-in-one platform for daily essentials at the tap of a button",
    restaurants: "Restaurants",
    restaurantsDesc: "Delicious Sudanese and international meals fresh from your favorite kitchens.",
    supermarkets: "Supermarkets",
    supermarketsDesc: "All home groceries and essential items with great prices and fast delivery.",
    pharmacies: "Pharmacies",
    pharmaciesDesc: "Your medicines, medical supplies, and personal care delivered safely to your door.",
    exploreCategory: "Explore Stores",

    // How It Works
    howTitle: "How Talabaty Works?",
    step1Title: "Choose a Store",
    step1Desc: "Pick a restaurant, supermarket, or pharmacy near you.",
    step2Title: "Add Products",
    step2Desc: "Add what you need to your cart effortlessly.",
    step3Title: "Confirm Order",
    step3Desc: "Select your payment method (Cash or Bankak) and confirm.",
    step4Title: "Track Your Order",
    step4Desc: "Track your delivery step-by-step until it arrives.",

    // Merchant Section
    merchantTitle: "Grow Your Sales with Talabaty",
    merchantSubtitle: "Register your store and start reaching more customers in your city.",
    mFeat1: "Display your products easily",
    mFeat2: "Manage orders and deliveries",
    mFeat3: "Real-time order status updates",
    mFeat4: "Manage pricing and availability",
    mFeat5: "Integrated advanced control panel",
    mFeat6: "Increase customer reach",
    registerStoreNow: "Register Your Store Now",

    // Courier Section
    courierTitle: "Work as a Courier with Talabaty",
    courierSubtitle: "Join our courier fleet and earn great income from every delivery.",
    cFeat1: "Receive orders near your location",
    cFeat2: "Clear pickup and delivery locations",
    cFeat3: "Track daily earnings easily",
    cFeat4: "Full control over your availability status",
    cFeat5: "Live tracking and navigation",
    supportedVehiclesTitle: "Supported Vehicles Only:",
    bicycle: "Bicycle",
    electricBike: "Electric Bicycle",
    motorcycle: "Motorcycle",
    joinCourierNow: "Join as Courier Now",

    // Download App
    downloadTitle: "Download Talabaty App Now",
    downloadSubtitle: "Fast and easy ordering experience right at your fingertips.",
    comingSoon: "Coming Soon",
    qrScanTitle: "Scan to Download",

    // Benefits
    benefitsTitle: "Why Choose Talabaty?",
    b1Title: "Diverse Restaurants",
    b1Desc: "Browse hundreds of fresh meals and dishes from top local and international kitchens.",
    b2Title: "Comprehensive Supermarkets",
    b2Desc: "All home essentials and groceries delivered fresh without leaving your house.",
    b3Title: "Nearby Pharmacies",
    b3Desc: "Your medicines and personal care items always available for your safety.",
    b4Title: "Fast & Safe Delivery",
    b4Desc: "A network of professional and trusted couriers at your service around the clock.",

    // Footer
    footerDesc: "Talabaty is Sudan's premier delivery platform for food, groceries, and medical supplies.",
    forCustomers: "For Customers",
    forMerchants: "For Merchants",
    forCouriers: "For Couriers",
    orderingMethod: "How to Order",
    trackOrder: "Order Tracking",
    techSupport: "Technical Support",
    merchantTerms: "Merchant Terms",
    courierTerms: "Courier Terms",
    allRightsReserved: "All rights reserved.",
    privacyPolicy: "Privacy Policy",
    termsAndConditions: "Terms & Conditions",
  },
};

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLang] = useState<Language>("ar");

  useEffect(() => {
    document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
    document.documentElement.lang = lang;
  }, [lang]);

  const toggleLanguage = () => {
    setLang((prev) => (prev === "ar" ? "en" : "ar"));
  };

  const t = (key: string): string => {
    return translations[lang][key] || key;
  };

  const dir = lang === "ar" ? "rtl" : "ltr";

  return (
    <LanguageContext.Provider value={{ lang, dir, toggleLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return context;
}
