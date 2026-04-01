"use client";

import { motion } from "framer-motion";
import { CheckCircle2, XCircle } from "lucide-react";
import { useLanguage } from "@/context/LanguageContext";
import type { SlideData } from "@/data/slides";

export function LabSlide({ slide }: { slide: SlideData }) {
  const { t } = useLanguage();

  return (
    <div className="flex flex-col h-full px-6 py-8 max-w-6xl mx-auto w-full">
      {/* Header row */}
      <div className="flex items-start justify-between gap-6 mb-8">
        <motion.div
          initial={{ opacity: 0, x: -30 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5 }}
          className="flex-1"
        >
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-elastic-blue/40 bg-elastic-blue/10 text-elastic-blue text-xs font-bold mb-3 uppercase tracking-wider">
            <span className="w-4 h-4 rounded-full bg-elastic-blue/30 flex items-center justify-center text-[10px] font-black">
              {slide.labNumber}
            </span>
            {slide.badge ? t(slide.badge) : "Lab"}
          </div>

          <h2 className="text-3xl md:text-4xl font-bold text-white leading-tight mb-3">
            {t(slide.title)}
          </h2>
          <p className="text-white text-base leading-relaxed max-w-xl">
            {t(slide.subtitle)}
          </p>
        </motion.div>

        {/* Big metric */}
        {slide.metric && (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="text-center flex-shrink-0"
          >
            <div className="text-6xl md:text-7xl font-black text-transparent bg-clip-text bg-gradient-to-b from-elastic-blue to-elastic-teal leading-none">
              {slide.metric.value}
            </div>
            <div className="text-white text-xs mt-1 max-w-[140px] leading-snug">
              {t(slide.metric.label)}
            </div>
          </motion.div>
        )}
      </div>

      {/* Comparison table */}
      {slide.comparison && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="rounded-2xl border border-white/10 bg-white/5 backdrop-blur-sm overflow-hidden flex-1"
        >
          {/* Table header */}
          <div className="grid grid-cols-[1fr_180px_180px] border-b border-white/10">
            <div className="px-5 py-3 text-white text-xs font-semibold uppercase tracking-wider">
              {t({ en: "Capability", pt: "Capacidade" })}
            </div>
            <div className="px-5 py-3 text-elastic-teal text-xs font-bold uppercase tracking-wider text-center">
              Elastic
            </div>
            <div className="px-5 py-3 text-red-400/70 text-xs font-bold uppercase tracking-wider text-center">
              Splunk
            </div>
          </div>

          {/* Table rows */}
          {slide.comparison.map((row, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.4 + i * 0.08 }}
              className="grid grid-cols-[1fr_180px_180px] border-b border-white/5 last:border-0 hover:bg-white/5 transition-colors"
            >
              <div className="px-5 py-3.5 text-white text-sm">
                {t(row.capability)}
              </div>
              <div className="px-5 py-3.5 text-elastic-teal text-sm text-center flex items-center justify-center gap-1.5">
                <CheckCircle2 className="w-3.5 h-3.5 flex-shrink-0 opacity-70" />
                <span className="text-xs">{row.elastic.replace("✅ ", "").replace("✅", "")}</span>
              </div>
              <div className="px-5 py-3.5 text-red-400/80 text-sm text-center flex items-center justify-center gap-1.5">
                <XCircle className="w-3.5 h-3.5 flex-shrink-0 opacity-70" />
                <span className="text-xs">{row.splunk.replace("❌ ", "").replace("❌", "")}</span>
              </div>
            </motion.div>
          ))}
        </motion.div>
      )}

      {/* Footer */}
      {slide.footer && (
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8 }}
          className="mt-4 text-white/70 text-xs font-mono text-center"
        >
          {t(slide.footer)}
        </motion.p>
      )}
    </div>
  );
}
