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
  const layer1Ref = useRef<THREE.Mesh>(null);
  const layer2Ref = useRef<THREE.Mesh>(null);
  const layer3Ref = useRef<THREE.Mesh>(null);

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

  useFrame((state, delta) => {
    if (!groupRef.current) return;

    // High precision time delta for smooth lerping
    const dt = Math.min(delta, 0.1);

    // 1. Mouse Parallax target rotations (Max 0.05 radians)
    const targetRotY = mouse.current.x * 0.05;
    const targetRotX = -mouse.current.y * 0.05;

    // Smooth spring interpolation (lerp)
    groupRef.current.rotation.y = THREE.MathUtils.lerp(groupRef.current.rotation.y, targetRotY, dt * 5);
    groupRef.current.rotation.x = THREE.MathUtils.lerp(groupRef.current.rotation.x, targetRotX, dt * 5);

    // 2. Multi-depth Parallax Layering for extra Lusion-style depth
    if (layer1Ref.current) {
        layer1Ref.current.position.x = THREE.MathUtils.lerp(layer1Ref.current.position.x, mouse.current.x * -0.2, dt * 3);
        layer1Ref.current.position.y = THREE.MathUtils.lerp(layer1Ref.current.position.y, mouse.current.y * 0.2, dt * 3);
    }
    if (layer2Ref.current) {
        layer2Ref.current.position.x = THREE.MathUtils.lerp(layer2Ref.current.position.x, mouse.current.x * 0.1, dt * 4);
        layer2Ref.current.position.y = THREE.MathUtils.lerp(layer2Ref.current.position.y, mouse.current.y * -0.1, dt * 4);
    }
    if (layer3Ref.current) {
        layer3Ref.current.position.x = THREE.MathUtils.lerp(layer3Ref.current.position.x, mouse.current.x * 0.3, dt * 5);
        layer3Ref.current.position.y = THREE.MathUtils.lerp(layer3Ref.current.position.y, mouse.current.y * -0.3, dt * 5);
    }

    // 3. Scroll-linked camera depth movement
    // 0% -> 100% scroll shifts camera Z and Group position smoothly
    const scrollZOffset = scrollProgress * 2.5;
    const scrollYOffset = scrollProgress * 1.5;

    state.camera.position.z = THREE.MathUtils.lerp(state.camera.position.z, 5 + scrollZOffset, dt * 4);
    state.camera.position.y = THREE.MathUtils.lerp(state.camera.position.y, -scrollYOffset, dt * 4);
  });

  return (
    <group ref={groupRef}>
      
      {/* Layer 1 (Background Scene): z = -4 */}
      <mesh ref={layer1Ref} position={[0, 0, -4]}>
        <planeGeometry args={[12, 12]} />
        <meshBasicMaterial map={bgTexture} transparent opacity={0.35} depthWrite={false} />
      </mesh>

      {/* Ambient Floating Particles */}
      <Sparkles 
        count={80} 
        scale={10} 
        size={2} 
        speed={0.4} 
        opacity={0.15} 
        color="#FF8A65" 
        position={[0, 0, -3]} 
      />

      {/* Layer 2 (Atmospheric Radial Glow): z = -2.5 */}
      <mesh ref={layer2Ref} position={[0, 0, -2.5]}>
        <planeGeometry args={[8, 8]} />
        <meshBasicMaterial transparent opacity={0.25} color="#FF5722" depthWrite={false} />
      </mesh>

      {/* Extra Atmospheric Particles foreground */}
      <Sparkles 
        count={40} 
        scale={6} 
        size={3} 
        speed={0.6} 
        opacity={0.2} 
        color="#FFCCBC" 
        position={[0, 0, -1]} 
      />

      {/* Layer 3 (Customer Phone Visual): z = 0 */}
      <mesh ref={layer3Ref} position={[0, -0.1, 0]}>
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
