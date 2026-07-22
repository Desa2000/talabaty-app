"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { ArrowLeft, Home } from "lucide-react";

export default function NotFound() {
  return (
    <div className="min-h-screen bg-[#FAF7F2] flex flex-col items-center justify-center p-4 text-center">
      <div className="max-w-md mx-auto space-y-6">
        <Image
          src="/logo.png"
          alt="Talabaty Logo"
          width={160}
          height={50}
          className="h-12 w-auto object-contain mx-auto mb-8"
        />

        <div className="w-20 h-20 bg-orange-100 rounded-3xl text-[#FF5722] flex items-center justify-center mx-auto text-3xl font-black shadow-inner border border-orange-200">
          404
        </div>

        <h1 className="text-3xl font-black text-[#1A1D27] tracking-tight">
          واضح إنك مشيت بعيد شوية
        </h1>

        <p className="text-base text-gray-600 font-medium">
          الصفحة البتبحث عنها ما موجودة، خلينا نرجعك لطلباتي.
        </p>

        <div className="pt-4">
          <Link
            href="/"
            className="inline-flex items-center justify-center gap-2 px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 transition-all"
          >
            <Home className="w-5 h-5" />
            <span>ارجع للرئيسية</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
