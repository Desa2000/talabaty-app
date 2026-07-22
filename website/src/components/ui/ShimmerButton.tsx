"use client";

import React from "react";
import { motion, HTMLMotionProps } from "framer-motion";

interface ShimmerButtonProps extends HTMLMotionProps<"button"> {
  children: React.ReactNode;
  className?: string;
}

export function ShimmerButton({
  children,
  className = "",
  ...props
}: ShimmerButtonProps) {
  return (
    <motion.button
      whileHover={{ scale: 1.03 }}
      whileTap={{ scale: 0.97 }}
      className={`relative inline-flex items-center justify-center overflow-hidden rounded-xl px-6 py-3.5 font-bold text-white shadow-lg transition-all duration-300 bg-[#FF5722] hover:bg-[#E64A19] hover:shadow-orange-500/30 ${className}`}
      {...props}
    >
      {/* Shimmer effect */}
      <span className="absolute inset-0 -translate-x-full animate-[shimmer_2.5s_infinite] bg-gradient-to-r from-transparent via-white/30 to-transparent pointer-events-none" />
      <span className="relative z-10 flex items-center gap-2">{children}</span>
    </motion.button>
  );
}
