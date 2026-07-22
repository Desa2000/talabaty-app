"use client";

import React, { useRef, useEffect, useState } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { PerspectiveCamera, useTexture } from "@react-three/drei";
import * as THREE from "three";

// ──────────────────────────────────────────────
// Inner R3F Scene Component with Mesh Planes & Camera Parallax
// ──────────────────────────────────────────────
function HeroScene({ scrollProgress }: { scrollProgress: number }) {
  const groupRef = useRef<THREE.Group>(null);

  // Load optimized textures
  const bgTexture = useTexture("/experience/hero/sudan-city-background.webp");
  const phoneTexture = useTexture("/experience/hero/customer-phone.webp");

  // Mouse coordinates for subtle parallax
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

  useFrame((state) => {
    if (!groupRef.current) return;

    // 1. Mouse Parallax target rotations (Max 0.03 radians)
    const targetRotY = mouse.current.x * 0.03;
    const targetRotX = -mouse.current.y * 0.03;

    // Smooth spring interpolation (lerp)
    groupRef.current.rotation.y = THREE.MathUtils.lerp(groupRef.current.rotation.y, targetRotY, 0.05);
    groupRef.current.rotation.x = THREE.MathUtils.lerp(groupRef.current.rotation.x, targetRotX, 0.05);

    // 2. Scroll-linked camera depth movement
    // 0% -> 100% scroll shifts camera Z and Group position smoothly
    const scrollZOffset = scrollProgress * 1.5;
    const scrollYOffset = scrollProgress * 1.2;

    state.camera.position.z = THREE.MathUtils.lerp(state.camera.position.z, 5 + scrollZOffset, 0.08);
    state.camera.position.y = THREE.MathUtils.lerp(state.camera.position.y, -scrollYOffset, 0.08);
  });

  return (
    <group ref={groupRef}>
      
      {/* Layer 1 (Background Scene): z = -4 */}
      <mesh position={[0, 0, -4]}>
        <planeGeometry args={[9, 9]} />
        <meshBasicMaterial map={bgTexture} transparent opacity={0.35} />
      </mesh>

      {/* Layer 2 (Atmospheric Radial Glow): z = -2.5 */}
      <mesh position={[0, 0, -2.5]}>
        <planeGeometry args={[7, 7]} />
        <meshBasicMaterial transparent opacity={0.25} color="#FF5722" />
      </mesh>

      {/* Layer 3 (Customer Phone Visual): z = 0 */}
      <mesh position={[0, -0.1, 0]}>
        <planeGeometry args={[2.2, 3.8]} />
        <meshBasicMaterial map={phoneTexture} transparent />
      </mesh>

    </group>
  );
}

// ──────────────────────────────────────────────
// Preload Textures for instant WebGL render
// ──────────────────────────────────────────────
useTexture.preload("/experience/hero/sudan-city-background.webp");
useTexture.preload("/experience/hero/customer-phone.webp");

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
