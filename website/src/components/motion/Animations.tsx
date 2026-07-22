"use client";

import React, { ReactNode, useState, useEffect } from "react";
import { motion, Variants, useMotionValue, useSpring, useTransform } from "framer-motion";

// ──────────────────────────────────────────────
// Centralized Motion Tokens
// ──────────────────────────────────────────────
export const MOTION_TOKENS = {
  FAST: 0.18,
  NORMAL: 0.45,
  SLOW: 0.7,
  EASE_PREMIUM: [0.25, 0.46, 0.45, 0.94] as [number, number, number, number],
  SPRING: { damping: 25, stiffness: 180 },
};

// ──────────────────────────────────────────────
// Reusable FadeUp Component
// ──────────────────────────────────────────────
const fadeUp: Variants = {
  hidden: { opacity: 0, y: 24 },
  visible: (delay: number = 0) => ({
    opacity: 1,
    y: 0,
    transition: {
      duration: MOTION_TOKENS.NORMAL,
      delay,
      ease: MOTION_TOKENS.EASE_PREMIUM,
    },
  }),
};

export function FadeUp({
  children,
  delay = 0,
  className = "",
}: {
  children: ReactNode;
  delay?: number;
  className?: string;
}) {
  return (
    <motion.div
      variants={fadeUp}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-40px" }}
      custom={delay}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// ──────────────────────────────────────────────
// Reusable Stagger Container & Child
// ──────────────────────────────────────────────
const staggerContainer: Variants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.05,
    },
  },
};

const staggerChild: Variants = {
  hidden: { opacity: 0, y: 18 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: MOTION_TOKENS.NORMAL, ease: MOTION_TOKENS.EASE_PREMIUM },
  },
};

export function StaggerContainer({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <motion.div
      variants={staggerContainer}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-40px" }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

export function StaggerChild({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <motion.div variants={staggerChild} className={className}>
      {children}
    </motion.div>
  );
}

// ──────────────────────────────────────────────
// Apple-Inspired Image Reveal (Scale + Fade + Y)
// ──────────────────────────────────────────────
export function ImageReveal({
  children,
  delay = 0,
  className = "",
}: {
  children: ReactNode;
  delay?: number;
  className?: string;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.92, y: 40 }}
      whileInView={{ opacity: 1, scale: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{
        duration: MOTION_TOKENS.SLOW,
        delay,
        ease: MOTION_TOKENS.EASE_PREMIUM,
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// ──────────────────────────────────────────────
// SlideIn from direction
// ──────────────────────────────────────────────
export function SlideIn({
  children,
  direction = "up",
  delay = 0,
  className = "",
}: {
  children: ReactNode;
  direction?: "left" | "right" | "up" | "down";
  delay?: number;
  className?: string;
}) {
  const offsets = {
    left: { x: -40, y: 0 },
    right: { x: 40, y: 0 },
    up: { x: 0, y: 30 },
    down: { x: 0, y: -30 },
  };

  return (
    <motion.div
      initial={{ opacity: 0, ...offsets[direction] }}
      whileInView={{ opacity: 1, x: 0, y: 0 }}
      viewport={{ once: true, margin: "-40px" }}
      transition={{
        duration: MOTION_TOKENS.NORMAL,
        delay,
        ease: MOTION_TOKENS.EASE_PREMIUM,
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// ──────────────────────────────────────────────
// Linear Style Minimal Section Label (Tiny Dot + Text)
// ──────────────────────────────────────────────
export function SectionLabel({ text }: { text: string }) {
  return (
    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-orange-50/80 text-[#FF5722] text-xs font-bold border border-orange-100 mb-3">
      <span className="w-1.5 h-1.5 rounded-full bg-[#FF5722]" />
      <span>{text}</span>
    </div>
  );
}

// ──────────────────────────────────────────────
// Lusion-Inspired Subtle Desktop Tilt Visual (Max 2-3 deg)
// Disabled on Touch/Mobile and Reduced Motion
// ──────────────────────────────────────────────
export function TiltVisual({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  const [isDesktop, setIsDesktop] = useState(false);
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const rotateX = useSpring(useTransform(y, [-150, 150], [2.5, -2.5]), MOTION_TOKENS.SPRING);
  const rotateY = useSpring(useTransform(x, [-150, 150], [-2.5, 2.5]), MOTION_TOKENS.SPRING);

  useEffect(() => {
    const mediaQuery = window.matchMedia("(min-width: 1024px) and (pointer: fine)");
    setIsDesktop(mediaQuery.matches);
    const handler = (e: MediaQueryListEvent) => setIsDesktop(e.matches);
    mediaQuery.addEventListener("change", handler);
    return () => mediaQuery.removeEventListener("change", handler);
  }, []);

  if (!isDesktop) {
    return <div className={className}>{children}</div>;
  }

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    x.set(e.clientX - centerX);
    y.set(e.clientY - centerY);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.div
      style={{ rotateX, rotateY, transformStyle: "preserve-3d" }}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className={className}
    >
      {children}
    </motion.div>
  );
}
