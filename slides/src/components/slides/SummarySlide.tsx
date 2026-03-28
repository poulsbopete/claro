"use client";

import { motion } from "framer-motion";
import { Link2, Layers3, Archive, Shield } from "lucide-react";
import { useLanguage } from "@/context/LanguageContext";
import type { SlideData } from "@/data/slides";

const icons = [Link2, Layers3, Archive, Shield];
const gradients = [
  "from-blue-500/20  to-blue-600/5  border-blue-500/20",
  "from-teal-500/20  to-teal-600/5  border-teal-500/20",
  "from-purple-500/20 to-purple-600/5 border-purple-500/20",
  "from-pink-500/20  to-pink-600/5  border-pink-500/20",
];
const iconColors = [
  "text-blue-400",
  "text-teal-400",
  "text-purple-400",
  "text-pink-400",
];

export function SummarySlide({ slide }: { slide: SlideData }) {
  const { t } = useLanguage();

  return (
    <div className="flex flex-col items-center h-full px-8 py-10 max-w-5xl mx-auto w-full">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="text-center mb-10"
      >
        <div className="flex justify-center gap-1.5 mb-4">
          {["bg-elastic-blue", "bg-elastic-teal", "bg-elastic-pink", "bg-amber-400"].map(
            (color, i) => (
              <div key={i} className={`w-2.5 h-2.5 rounded-sm ${color}`} />
            ),
          )}
        </div>
        <h2 className="text-4xl md:text-5xl font-bold text-white mb-3">
          {t(slide.title)}
        </h2>
        <p className="text-white/50 text-lg">{t(slide.subtitle)}</p>
      </motion.div>

      {/* Win cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 w-full mb-10">
        {(slide.points ?? []).map((point, i) => {
          const Icon = icons[i];
          return (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.15 + i * 0.1, duration: 0.5 }}
              className={`flex gap-4 p-5 rounded-2xl border bg-gradient-to-br backdrop-blur-sm ${gradients[i]}`}
            >
              <div className={`flex-shrink-0 mt-0.5 ${iconColors[i]}`}>
                <Icon className="w-5 h-5" />
              </div>
              <p className="text-white/75 text-sm leading-relaxed">{t(point)}</p>
            </motion.div>
          );
        })}
      </div>

      {/* CTA */}
      {slide.cta && (
        <motion.a
          href="https://play.instruqt.com/elastic/tracks/claro-elastic-serverless-observability"
          target="_blank"
          rel="noopener noreferrer"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.7, duration: 0.5 }}
          className="inline-flex items-center gap-2 px-8 py-4 rounded-2xl
            bg-gradient-to-r from-elastic-blue to-elastic-teal
            text-white font-bold text-lg shadow-lg shadow-elastic-blue/25
            hover:-translate-y-0.5 hover:shadow-xl hover:shadow-elastic-blue/30
            transition-all duration-300"
        >
          {t(slide.cta)}
        </motion.a>
      )}
    </div>
  );
}
