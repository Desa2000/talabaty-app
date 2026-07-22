"use client";

import React, { useRef, useEffect, useState } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { PerspectiveCamera, useTexture, Sparkles } from "@react-three/drei";
import * as THREE from "three";

// ──────────────────────────────────────────────
// Inner R3F Scene Component with Mesh Planes & Camera Parallax
// ──────────────────────────────────────────────
function HeroScene({ scrollProgress }: { scrollProgress: number }) {
  const groupRef = useRef<THREE.Group>(null);
  const mouse = useRef({ x: 0, y: 0 });

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      const centerX = window.innerWidth / 2;
      const centerY = window.innerHeight / 2;
      mouse.current.x = (e.clientX - centerX) / centerX;
      mouse.current.y = (e.clientY - centerY) / centerY;
    };

    window.addEventListener("mousemove", handleMouseMove);
    return () => window.removeEventListener("mousemove", handleMouseMove);
  }, []);

  useFrame((state, delta) => {
    if (!groupRef.current) return;
    const dt = Math.min(delta, 0.1);
    groupRef.current.rotation.y = THREE.MathUtils.lerp(groupRef.current.rotation.y, mouse.current.x * 0.03, dt * 5);
    groupRef.current.rotation.x = THREE.MathUtils.lerp(groupRef.current.rotation.x, -mouse.current.y * 0.03, dt * 5);
  });

  return (
    <group ref={groupRef}>
      {/* Ambient Floating Particles */}
      <Sparkles 
        count={60} 
        scale={10} 
        size={2} 
        speed={0.4} 
        opacity={0.2} 
        color="#FF8A65" 
        position={[0, 0, -2]} 
      />
    </group>
  );
}

// ──────────────────────────────────────────────
// Exported HeroCanvas Wrapper Component
// ──────────────────────────────────────────────
export default function HeroCanvas() {
  const [scrollProgress, setScrollProgress] = useState(0);
  const [isEligibleDesktop, setIsEligibleDesktop] = useState(false);
  const [hasWebGLSupport, setHasWebGLSupport] = useState(true);

  useEffect(() => {
    // 1. Feature Detection: Desktop >= 1024px, Fine Pointer, Reduced Motion check
    const checkEligibility = () => {
      const isDesktop = window.matchMedia("(min-width: 1024px) and (pointer: fine)").matches;
      const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
      
      // Test WebGL context availability
      try {
        const canvas = document.createElement("canvas");
        const gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
        setHasWebGLSupport(!!gl);
      } catch {
        setHasWebGLSupport(false);
      }

      setIsEligibleDesktop(isDesktop && !prefersReduced);
    };

    checkEligibility();
    window.addEventListener("resize", checkEligibility);

    // 2. Scroll Listener
    const handleScroll = () => {
      const heroEl = document.getElementById("hero-section");
      if (!heroEl) return;
      const rect = heroEl.getBoundingClientRect();
      const total = rect.height;
      const progress = Math.max(0, Math.min(1, -rect.top / total));
      setScrollProgress(progress);
    };

    window.addEventListener("scroll", handleScroll);
    return () => {
      window.removeEventListener("resize", checkEligibility);
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  // Fallback: If on mobile / touch or unsupported WebGL, don't render canvas
  if (!isEligibleDesktop || !hasWebGLSupport) {
    return null;
  }

  return (
    <div className="absolute inset-0 z-0 pointer-events-none overflow-hidden">
      <Canvas
        dpr={[1, 1.5]}
        gl={{ antialias: true, alpha: true, powerPreference: "high-performance" }}
        className="w-full h-full"
      >
        <PerspectiveCamera makeDefault position={[0, 0, 5]} fov={50} />
        <ambientLight intensity={1.2} />
        <HeroScene scrollProgress={scrollProgress} />
      </Canvas>
    </div>
  );
}
