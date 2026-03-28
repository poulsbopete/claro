"use client";

import { useLanguage, type Language } from "@/context/LanguageContext";
import { cn } from "@/lib/utils";

export function LanguageToggle() {
  const { language, setLanguage } = useLanguage();

  const btn = (lang: Language, label: string) => (
    <button
      key={lang}
      onClick={() => setLanguage(lang)}
      className={cn(
        "px-3 py-1.5 text-xs font-semibold rounded-md transition-all duration-200",
        language === lang
          ? "bg-white text-elastic-navy shadow"
          : "text-white/60 hover:text-white/90",
      )}
    >
      {label}
    </button>
  );

  return (
    <div className="flex items-center gap-1 rounded-lg border border-white/10 bg-white/5 backdrop-blur-sm p-1">
      {btn("en", "EN")}
      {btn("es", "ES")}
    </div>
  );
}
