"use client";

import { motion } from "framer-motion";
import { useLanguage } from "@/context/LanguageContext";

const stats = [
  {
    value: "20,000+",
    label: { en: "Customers", es: "Clientes" },
    accent: "#00BFB3", // teal
  },
  {
    value: "50%",
    label: { en: "of Fortune 500", es: "del Fortune 500" },
    accent: "#1BA9F5", // blue
  },
  {
    value: "19B+",
    label: { en: "Events searched / day", es: "Eventos buscados / día" },
    accent: "#F04E98", // pink
  },
  {
    value: "4B+",
    label: { en: "Total downloads", es: "Descargas totales" },
    accent: "#FEC514", // yellow
  },
  {
    value: "<10ms",
    label: { en: "Avg. query latency", es: "Latencia media de consulta" },
    accent: "#00BFB3",
  },
  {
    value: "3PB+",
    label: { en: "Data ingested / day", es: "Datos ingeridos / día" },
    accent: "#1BA9F5",
  },
];

export function ElasticStats() {
  const { t } = useLanguage();

  return (
    <div className="w-full px-6 pb-1">
      {/* Label */}
      <div className="flex items-center gap-2 mb-2">
        <div className="h-px flex-1 bg-white/10" />
        <span className="text-white/40 text-[9px] font-bold tracking-widest uppercase">
          Elastic by the Numbers
        </span>
        <div className="h-px flex-1 bg-white/10" />
      </div>

      {/* Stats row */}
      <div className="flex items-stretch justify-between gap-0">
        {stats.map((stat, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 6 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 + i * 0.07, duration: 0.4 }}
            className="flex-1 flex flex-col items-center px-2 py-1 relative"
          >
            {/* Separator */}
            {i > 0 && (
              <div className="absolute left-0 top-1 bottom-1 w-px bg-white/10" />
            )}

            {/* Value */}
            <span
              className="text-base font-black leading-none tracking-tight"
              style={{ color: stat.accent }}
            >
              {stat.value}
            </span>

            {/* Label */}
            <span className="text-white text-[9px] mt-0.5 text-center leading-tight font-medium">
              {t(stat.label)}
            </span>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
