"use client";

import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import StatsSection from "@/components/StatsSection";
import Services from "@/components/Services";
import HowItWorks from "@/components/HowItWorks";
import MerchantSection from "@/components/MerchantSection";
import CourierSection from "@/components/CourierSection";
import BenefitsSection from "@/components/BenefitsSection";
import Testimonials from "@/components/Testimonials";
import FoundersSection from "@/components/FoundersSection";
import DownloadSection from "@/components/DownloadSection";
import FaqSection from "@/components/FaqSection";
import Footer from "@/components/Footer";
import ScrollProgress from "@/components/motion/ScrollProgress";

export default function HomePage() {
  return (
    <div className="flex flex-col min-h-screen bg-white">
      <ScrollProgress />
      <Navbar />
      <main className="flex-grow">
        <Hero />
        <StatsSection />
        <Services />
        <HowItWorks />
        <MerchantSection />
        <CourierSection />
        <BenefitsSection />
        <Testimonials />
        <FoundersSection />
        <DownloadSection />
        <FaqSection />
      </main>
      <Footer />
    </div>
  );
}
