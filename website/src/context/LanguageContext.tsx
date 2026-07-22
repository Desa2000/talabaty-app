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
    coverage: "مناطق التغطية",
    faq: "الأسئلة الشائعة",
    founders: "مؤسسو طلباتي",
    contact: "تواصل معانا",
    downloadApp: "التطبيق قريبًا",
    joinMerchant: "سجّل متجرك",
    joinCourier: "اشتغل مندوب",

    // Hero
    heroTitlePrefix: "طلباتك",
    heroTitleMain: "أسرع.. أسهل.. أقرب ليك",
    heroDescription:
      "مطعم، سوبرماركت ولا صيدلية؟ اطلب حاجاتك وخلي التوصيل علينا.",
    brandPhrase: "من عندهم.. لحدي عندك.",
    fastDeliveryBadge: "توصيل سريع",
    trustedCouriersBadge: "مناديب موثوقون",

    // Services
    servicesTitle: "البتحتاجو.. تلقاه في طلباتي",
    servicesSubtitle: "منصتك الشاملة لتوفير احتياجاتك اليومية بكل سهولة",
    restaurants: "المطاعم",
    restaurantsDesc: "نفسك في شنو؟ اختار مطعمك وخلي طلبك يجيك لحدي عندك.",
    supermarkets: "السوبرماركت",
    supermarketsDesc: "حاجات البيت ناقصة؟ اطلب البتحتاجو وخلي المشوار علينا.",
    pharmacies: "الصيدليات",
    pharmaciesDesc: "احتياجات الصيدلية أقرب ليك، اطلبها وخلي التوصيل علينا.",
    exploreCategory: "استكشف المتاجر",

    // How It Works
    howTitle: "تطلب كيف؟ الموضوع بسيط",
    step1Title: "اختار المكان",
    step1Desc: "مطعم، سوبرماركت أو صيدلية.",
    step2Title: "اختار حاجاتك",
    step2Desc: "ضيف البتحتاجو للسلة.",
    step3Title: "أكد طلبك",
    step3Desc: "راجع طلبك واختار طريقة الدفع.",
    step4Title: "خليك متابع",
    step4Desc: "تابع الطلب لحدي يصل عندك.",

    // Merchant Section
    merchantTitle: "عندك متجر؟ خلّي زباين أكتر يصلوا ليك",
    merchantSubtitle: "سجّل متجرك في طلباتي، اعرض منتجاتك واستقبل طلباتك من مكان واحد.",
    mFeat1: "استقبل الطلبات أول بأول",
    mFeat2: "حدّث منتجاتك وأسعارك بسهولة",
    mFeat3: "تابع الطلب من التجهيز لحدي التسليم",
    mFeat4: "وصل لعملاء أكتر",
    mFeat5: "خلّي إدارة متجرك أبسط",
    mFeat6: "زيادة مبيعاتك وأرباحك",
    registerStoreNow: "سجّل متجرك هسي",

    // Courier Section
    courierTitle: "عندك عجلة أو موتر؟ اشتغل مع طلباتي",
    courierSubtitle: "انضم لمناديب طلباتي، استقبل التوصيلات المناسبة ليك وتابع شغلك من التطبيق.",
    cFeat1: "طلبات قريبة منك",
    cFeat2: "موقع الاستلام والتسليم واضح",
    cFeat3: "تابع توصيلاتك",
    cFeat4: "تحكم في وقت شغلك",
    cFeat5: "شوف أرباحك بسهولة",
    supportedVehiclesTitle: "المركبات المدعومة فقط:",
    bicycle: "دراجة هوائية",
    electricBike: "دراجة كهربائية",
    motorcycle: "دراجة نارية",
    joinCourierNow: "انضم كمندوب",

    // Coverage
    coverageTitle: "خريطة تغطية طلباتي في السودان",
    coverageSubtitle: "بنبدأ خطوة خطوة، وكل يوم بنقرب ليك أكتر.",

    // Founders
    foundersTitle: "مؤسسو طلباتي",
    foundersSubtitle: "فريق سوداني شغال عشان يخلي الطلب والتوصيل أسهل وأسرع.",
    coFounder: "مؤسس مشارك",

    // Download App
    downloadTitle: "طلباتي قريب في تلفونك",
    downloadSubtitle: "شغالين نجهز ليك تجربة طلب سريعة وسهلة من أول ضغطة لحدي عندك.",
    comingSoon: "قريبًا",

    // FAQ
    faqTitle: "عندك سؤال؟",

    // Contact
    contactTitle: "نحن معاك",
    contactSubtitle: "عندك سؤال، اقتراح أو مشكلة؟ اتواصل معانا.",

    // Footer
    footerDesc: "تطبيق طلباتي منصة سودانية للتوصيل من المطاعم والسوبرماركت والصيدليات.",
    brandLine: "طلباتي.. من عندهم لحدي عندك.",
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
    coverage: "Coverage Areas",
    faq: "FAQ",
    founders: "Founders",
    contact: "Contact Us",
    downloadApp: "App Coming Soon",
    joinMerchant: "Join as Merchant",
    joinCourier: "Join as Courier",

    // Hero
    heroTitlePrefix: "Your Orders",
    heroTitleMain: "Faster.. Easier.. Closer to You",
    heroDescription:
      "Restaurant, supermarket, or pharmacy? Order what you need and leave the delivery to us.",
    brandPhrase: "From them.. right to your doorstep.",
    fastDeliveryBadge: "Fast Delivery",
    trustedCouriersBadge: "Trusted Couriers",

    // Services
    servicesTitle: "Everything You Need on Talabaty",
    servicesSubtitle: "Your all-in-one platform for daily essentials effortlessly",
    restaurants: "Restaurants",
    restaurantsDesc: "Craving something delicious? Choose your restaurant and we bring your order to your door.",
    supermarkets: "Supermarkets",
    supermarketsDesc: "Running low on home supplies? Order what you need and leave the errand to us.",
    pharmacies: "Pharmacies",
    pharmaciesDesc: "Pharmacy essentials closer to you, order now and leave delivery to us.",
    exploreCategory: "Explore Stores",

    // How It Works
    howTitle: "How to Order? It's Simple",
    step1Title: "Choose a Place",
    step1Desc: "Restaurant, supermarket, or pharmacy.",
    step2Title: "Pick Your Items",
    step2Desc: "Add what you need to your cart.",
    step3Title: "Confirm Order",
    step3Desc: "Review your order and select payment method.",
    step4Title: "Track Delivery",
    step4Desc: "Track your order step-by-step until it arrives.",

    // Merchant Section
    merchantTitle: "Own a Store? Reach More Customers",
    merchantSubtitle: "Register your store with Talabaty, list your products, and manage orders from one place.",
    mFeat1: "Receive orders in real-time",
    mFeat2: "Update products and prices easily",
    mFeat3: "Track orders from prep to delivery",
    mFeat4: "Reach more local customers",
    mFeat5: "Simplify store management",
    mFeat6: "Grow your revenue and sales",
    registerStoreNow: "Register Your Store Now",

    // Courier Section
    courierTitle: "Have a Bike or Motorcycle? Join Talabaty",
    courierSubtitle: "Join Talabaty couriers, receive suitable deliveries, and manage your work from the app.",
    cFeat1: "Orders near your location",
    cFeat2: "Clear pickup and delivery locations",
    cFeat3: "Track your deliveries",
    cFeat4: "Flexible working hours",
    cFeat5: "View your earnings easily",
    supportedVehiclesTitle: "Supported Vehicles Only:",
    bicycle: "Bicycle",
    electricBike: "Electric Bicycle",
    motorcycle: "Motorcycle",
    joinCourierNow: "Join as Courier",

    // Coverage
    coverageTitle: "Talabaty Sudan Coverage Map",
    coverageSubtitle: "Expanding step by step to be closer to you in more cities.",

    // Founders
    foundersTitle: "Talabaty Founders",
    foundersSubtitle: "Sudanese team working to make ordering and delivery faster and easier.",
    coFounder: "Co-Founder",

    // Download App
    downloadTitle: "Talabaty App Coming Soon",
    downloadSubtitle: "We are preparing a fast and seamless ordering experience right to your phone.",
    comingSoon: "Coming Soon",

    // FAQ
    faqTitle: "Have Questions?",

    // Contact
    contactTitle: "We Are With You",
    contactSubtitle: "Have a question, suggestion, or issue? Get in touch with us.",

    // Footer
    footerDesc: "Talabaty is a Sudanese delivery platform for food, groceries, and pharmacy supplies.",
    brandLine: "From them.. right to your doorstep.",
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
