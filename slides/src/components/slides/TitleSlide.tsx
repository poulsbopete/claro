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
        <span className="text-white/40 text-sm font-semibold tracking-widest uppercase">
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
                className="inline-block text-transparent bg-clip-text bg-gradient-to-r from-white to-white/70"
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
        className="text-lg sm:text-xl text-white/60 max-w-2xl mb-12 leading-relaxed"
      >
        {t(slide.subtitle)}
      </motion.p>

      {/* CTA */}
      {slide.cta && (
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 1.1, duration: 0.5 }}
          className="inline-flex items-center gap-2 px-8 py-4 rounded-2xl
            border border-elastic-blue/40 bg-elastic-blue/10 backdrop-blur
            text-elastic-blue font-semibold text-lg hover:bg-elastic-blue/20
            hover:-translate-y-0.5 transition-all duration-300 cursor-default"
        >
          {t(slide.cta)}
        </motion.div>
      )}

      {/* Workshop URL */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.4, duration: 0.6 }}
        className="mt-8 text-xs text-white/25 font-mono"
      >
        play.instruqt.com/elastic/tracks/claro-elastic-serverless-observability
      </motion.p>
    </div>
  );
}
