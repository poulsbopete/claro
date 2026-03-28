"use client";

import { motion } from "framer-motion";
import { AlertTriangle, DollarSign, Clock, Layers } from "lucide-react";
import { useLanguage } from "@/context/LanguageContext";
import type { SlideData } from "@/data/slides";

const icons = [Layers, DollarSign, Clock, AlertTriangle];
const colors = [
  "text-blue-400   border-blue-400/30  bg-blue-400/10",
  "text-amber-400  border-amber-400/30  bg-amber-400/10",
  "text-orange-400 border-orange-400/30 bg-orange-400/10",
  "text-red-400    border-red-400/30   bg-red-400/10",
];

export function ProblemSlide({ slide }: { slide: SlideData }) {
  const { t } = useLanguage();

  return (
    <div className="flex flex-col h-full px-8 py-10 max-w-6xl mx-auto w-full">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="text-center mb-10"
      >
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-red-400/30 bg-red-400/10 text-red-400 text-sm font-semibold mb-4">
          <AlertTriangle className="w-4 h-4" />
          Splunk
        </div>
        <h2 className="text-4xl md:text-5xl font-bold text-white mb-3">
          {t(slide.title)}
        </h2>
        <p className="text-white/50 text-lg max-w-2xl mx-auto">
          {t(slide.subtitle)}
        </p>
      </motion.div>

      {/* Pain point cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 flex-1">
        {(slide.points ?? []).map((point, i) => {
          const Icon = icons[i];
          return (
            <motion.div
              key={i}
              initial={{ opacity: 0, x: i % 2 === 0 ? -30 : 30, y: 20 }}
              animate={{ opacity: 1, x: 0, y: 0 }}
              transition={{ delay: 0.2 + i * 0.12, duration: 0.5 }}
              className={`flex gap-4 p-5 rounded-2xl border backdrop-blur-sm ${colors[i]}`}
            >
              <div className="flex-shrink-0 mt-0.5">
                <Icon className="w-5 h-5" />
              </div>
              <p className="text-white/80 text-sm sm:text-base leading-relaxed">
                {t(point)}
              </p>
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}
