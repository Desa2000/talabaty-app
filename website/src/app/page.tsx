import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Services from "@/components/Services";
import HowItWorks from "@/components/HowItWorks";
import MerchantSection from "@/components/MerchantSection";
import CourierSection from "@/components/CourierSection";
import BenefitsSection from "@/components/BenefitsSection";
import DownloadSection from "@/components/DownloadSection";
import FaqSection from "@/components/FaqSection";
import Footer from "@/components/Footer";

export default function HomePage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-grow">
        <Hero />
        <Services />
        <HowItWorks />
        <MerchantSection />
        <CourierSection />
        <BenefitsSection />
        <DownloadSection />
        <FaqSection />
      </main>
      <Footer />
    </div>
  );
}
