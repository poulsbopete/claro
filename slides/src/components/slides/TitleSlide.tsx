"use client";

import { motion } from "framer-motion";
import { useLanguage } from "@/context/LanguageContext";
import type { SlideData } from "@/data/slides";

export function TitleSlide({ slide }: { slide: SlideData }) {
  const { t } = useLanguage();
  const words = t(slide.title).split(" ");

  return (
    <div className="flex flex-col items-center justify-center h-full text-center px-8 max-w-5xl mx-auto">
      {/* Elastic wordmark */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="mb-8 flex items-center gap-3"
      >
        <div className="flex gap-1.5">
          {["bg-elastic-blue", "bg-elastic-teal", "bg-elastic-pink", "bg-amber-400"].map(
            (color, i) => (
              <div key={i} className={`w-3 h-3 rounded-sm ${color}`} />
            ),
          )}
        </div>
        <span className="text-white text-sm font-semibold tracking-widest uppercase">
          Elastic
        </span>
      </motion.div>

      {/* Animated title */}
      <h1 className="text-5xl sm:text-6xl md:text-7xl font-bold mb-6 tracking-tight leading-tight">
        {words.map((word, wi) => (
          <span key={wi} className="inline-block mr-3 last:mr-0">
            {word.split("").map((letter, li) => (
              <motion.span
                key={`${wi}-${li}`}
                initial={{ y: 80, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{
                  delay: wi * 0.12 + li * 0.025,
                  type: "spring",
                  stiffness: 150,
                  damping: 25,
                }}
                className="inline-block text-white"
              >
                {letter}
              </motion.span>
            ))}
          </span>
        ))}
      </h1>

      {/* Subtitle */}
      <motion.p
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8, duration: 0.6 }}
        className="text-lg sm:text-xl text-white max-w-2xl leading-relaxed"
      >
        {t(slide.subtitle)}
      </motion.p>
    </div>
  );
}
