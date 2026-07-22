"use client";

import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Services from "@/components/Services";
import HowItWorks from "@/components/HowItWorks";
import CoverageMapSection from "@/components/CoverageMapSection";
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
        <Services />
        <HowItWorks />
        <CoverageMapSection />
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
