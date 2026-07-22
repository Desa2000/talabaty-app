import type { Metadata } from "next";
import { Cairo } from "next/font/google";
import "./globals.css";
import { LanguageProvider } from "@/context/LanguageContext";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  variable: "--font-cairo",
  weight: ["400", "500", "600", "700", "800", "900"],
});

export const metadata: Metadata = {
  metadataBase: new URL("https://mytalabaty.com"),
  title: {
    default: "طلباتي | Talabaty",
    template: "%s | طلباتي",
  },
  description:
    "طلباتي منصة سودانية للتوصيل من المطاعم والسوبرماركت والصيدليات.",
  keywords: [
    "طلباتي",
    "Talabaty",
    "توصيل الخرطوم",
    "توصيل السودان",
    "مطاعم الخرطوم",
    "سوبرماركت السودان",
    "صيدليات الخرطوم",
    "تطبيق توصيل سوداني",
  ],
  authors: [{ name: "Talabaty Team" }],
  creator: "Talabaty Sudan",
  openGraph: {
    title: "طلباتي | Talabaty - أسرع.. أسهل.. أقرب ليك",
    description:
      "طلباتي منصة سودانية للتوصيل من المطاعم والسوبرماركت والصيدليات.",
    url: "https://mytalabaty.com",
    siteName: "طلباتي - Talabaty",
    images: [
      {
        url: "/logo.png",
        width: 512,
        height: 512,
        alt: "Talabaty Logo",
      },
    ],
    locale: "ar_SD",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "طلباتي | Talabaty",
    description: "طلباتي منصة سودانية للتوصيل من المطاعم والسوبرماركت والصيدليات.",
    images: ["/logo.png"],
  },
  alternates: {
    canonical: "https://mytalabaty.com",
  },
  robots: {
    index: true,
    follow: true,
  },
};

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "Organization",
  name: "طلباتي - Talabaty",
  url: "https://mytalabaty.com",
  logo: "https://mytalabaty.com/logo.png",
  contactPoint: {
    "@type": "ContactPoint",
    telephone: "+249911421515",
    contactType: "customer service",
    areaServed: "SD",
    availableLanguage: ["Arabic", "English"],
  },
  address: {
    "@type": "PostalAddress",
    addressLocality: "Khartoum - Al Riyadh",
    addressCountry: "SD",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className={cairo.variable}>
      <head>
        <link rel="icon" href="/logo.png" />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className="antialiased bg-white text-[#1A1D27] min-h-screen flex flex-col font-sans">
        <LanguageProvider>{children}</LanguageProvider>
      </body>
    </html>
  );
}
