"use client";

import { motion } from "framer-motion";
import { Link2, Layers3, Archive, Shield, PlayCircle } from "lucide-react";
import { useLanguage } from "@/context/LanguageContext";
import type { SlideData } from "@/data/slides";

const INSTRUQT_URL = "https://play.instruqt.com/elastic/invite/f4qxesovpsmi";

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
        <p className="text-white text-lg">{t(slide.subtitle)}</p>
      </motion.div>

      {/* Win cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 w-full mb-6">
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
              <p className="text-white text-sm leading-relaxed">{t(point)}</p>
            </motion.div>
          );
        })}
      </div>

      {/* Instruqt CTA */}
      <motion.a
        href={INSTRUQT_URL}
        target="_blank"
        rel="noopener noreferrer"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.7, duration: 0.5 }}
        className="flex items-center gap-3 px-6 py-3 rounded-2xl border border-elastic-blue/40 bg-elastic-blue/10 hover:bg-elastic-blue/20 transition-all duration-200 group"
      >
        <PlayCircle className="w-5 h-5 text-elastic-blue flex-shrink-0" />
        <div className="text-left">
          <div className="text-white text-sm font-bold group-hover:text-elastic-blue transition-colors">
            {t({ en: "Start the Lab", pt: "Iniciar o Lab" })}
          </div>
          <div className="text-white/50 text-xs font-mono">
            {INSTRUQT_URL}
          </div>
        </div>
      </motion.a>
    </div>
  );
}
