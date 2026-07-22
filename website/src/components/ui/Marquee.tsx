"use client";

import React from "react";
import { motion } from "framer-motion";

export function Marquee({
  items,
  speed = 25,
  direction = "left",
  className = "",
}: {
  items: React.ReactNode[];
  speed?: number;
  direction?: "left" | "right";
  className?: string;
}) {
  return (
    <div className={`overflow-hidden whitespace-nowrap flex relative ${className}`}>
      <motion.div
        className="flex gap-8 items-center flex-nowrap"
        animate={{
          x: direction === "left" ? ["0%", "-50%"] : ["-50%", "0%"],
        }}
        transition={{
          ease: "linear",
          duration: speed,
          repeat: Infinity,
        }}
      >
        {items.concat(items).map((item, index) => (
          <div key={index} className="inline-block flex-shrink-0">
            {item}
          </div>
        ))}
      </motion.div>
    </div>
  );
}
