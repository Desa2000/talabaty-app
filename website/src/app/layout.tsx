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
    default: "طلباتي | Talabaty - تطبيق التوصيل الأول في السودان",
    template: "%s | طلباتي",
  },
  description:
    "طلباتي منصة توصيل للمطاعم والسوبرماركت والصيدليات في السودان. اطلب وجباتك ومقاضيك ودواك وسننوصلها لك بسرعة وأمان.",
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
    title: "طلباتي | Talabaty - أسرع.. أسهل.. أقرب",
    description:
      "منصة توصيل للمطاعم والسوبرماركت والصيدليات في السودان. توصيل سريع وموثوق بكوادر سودانية.",
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
    description: "منصة توصيل للمطاعم والسوبرماركت والصيدليات في السودان.",
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

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className={cairo.variable}>
      <head>
        <link rel="icon" href="/logo.png" />
      </head>
      <body className="antialiased bg-white text-[#1A1D27] min-h-screen flex flex-col font-sans">
        <LanguageProvider>{children}</LanguageProvider>
      </body>
    </html>
  );
}
