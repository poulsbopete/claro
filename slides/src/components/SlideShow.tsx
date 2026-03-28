"use client";

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { slides } from "@/data/slides";
import { LanguageToggle } from "@/components/LanguageToggle";
import { ElasticStats }  from "@/components/ElasticStats";
import { TitleSlide }   from "@/components/slides/TitleSlide";
import { ProblemSlide } from "@/components/slides/ProblemSlide";
import { LabSlide }     from "@/components/slides/LabSlide";
import { SummarySlide } from "@/components/slides/SummarySlide";
import { cn } from "@/lib/utils";

function renderSlide(slide: (typeof slides)[number]) {
  switch (slide.type) {
    case "title":   return <TitleSlide slide={slide} />;
    case "problem": return <ProblemSlide slide={slide} />;
    case "lab":     return <LabSlide slide={slide} />;
    case "summary": return <SummarySlide slide={slide} />;
  }
}

const variants = {
  enter: (dir: number) => ({ x: dir > 0 ? "6%"  : "-6%", opacity: 0 }),
  center:              () => ({ x: 0, opacity: 1 }),
  exit:  (dir: number) => ({ x: dir > 0 ? "-6%" : "6%",  opacity: 0 }),
};

export function SlideShow() {
  const [[index, direction], setPage] = useState([0, 0]);

  const go = useCallback(
    (delta: number) => {
      setPage(([i]) => {
        const next = Math.max(0, Math.min(slides.length - 1, i + delta));
        return [next, delta];
      });
    },
    [],
  );

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight" || e.key === "ArrowDown" || e.key === " ")
        go(1);
      if (e.key === "ArrowLeft" || e.key === "ArrowUp")
        go(-1);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [go]);

  const slide = slides[index];
  const progress = ((index + 1) / slides.length) * 100;

  return (
    <div className="relative w-full h-full flex flex-col select-none">
      {/* Top bar */}
      <div className="absolute top-0 left-0 right-0 z-30 flex items-center justify-between px-6 py-4">
        <div className="flex items-center gap-2">
          <div className="flex gap-1">
            {["bg-elastic-blue","bg-elastic-teal","bg-elastic-pink","bg-amber-400"].map(
              (c,i) => <div key={i} className={`w-2 h-2 rounded-sm ${c}`} />,
            )}
          </div>
          <span className="text-white/20 text-xs font-mono">
            {String(index + 1).padStart(2, "0")} / {String(slides.length).padStart(2, "0")}
          </span>
        </div>
        <LanguageToggle />
      </div>

      {/* Slide area */}
      <div className="relative flex-1 overflow-hidden">
        <AnimatePresence initial={false} custom={direction} mode="popLayout">
          <motion.div
            key={slide.id}
            custom={direction}
            variants={variants}
            initial="enter"
            animate="center"
            exit="exit"
            transition={{ duration: 0.35, ease: [0.32, 0.72, 0, 1] }}
            className="absolute inset-0 flex items-center justify-center pt-16 pb-36"
          >
            {renderSlide(slide)}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom bar */}
      <div className="absolute bottom-0 left-0 right-0 z-30 pb-3">
        {/* Elastic by the Numbers infographic */}
        <ElasticStats />

        {/* Progress bar */}
        <div className="w-full h-px bg-white/10 my-2 overflow-hidden">
          <motion.div
            className="h-full bg-gradient-to-r from-elastic-blue to-elastic-teal"
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.35 }}
          />
        </div>

        <div className="flex items-center justify-between px-6">
          {/* Dot nav */}
          <div className="flex gap-2">
            {slides.map((s, i) => (
              <button
                key={s.id}
                onClick={() => setPage([i, i > index ? 1 : -1])}
                className={cn(
                  "rounded-full transition-all duration-300",
                  i === index
                    ? "w-6 h-2 bg-elastic-blue"
                    : "w-2 h-2 bg-white/20 hover:bg-white/40",
                )}
                aria-label={`Go to slide ${i + 1}`}
              />
            ))}
          </div>

          {/* Prev / Next buttons */}
          <div className="flex gap-2">
            <button
              onClick={() => go(-1)}
              disabled={index === 0}
              className="w-9 h-9 rounded-full border border-white/10 bg-white/5
                hover:bg-white/10 flex items-center justify-center text-white/50
                hover:text-white disabled:opacity-25 disabled:cursor-not-allowed
                transition-all duration-200"
              aria-label="Previous slide"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              onClick={() => go(1)}
              disabled={index === slides.length - 1}
              className="w-9 h-9 rounded-full border border-white/10 bg-white/5
                hover:bg-white/10 flex items-center justify-center text-white/50
                hover:text-white disabled:opacity-25 disabled:cursor-not-allowed
                transition-all duration-200"
              aria-label="Next slide"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Keyboard hint (first slide only) */}
      {index === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ delay: 2 }}
          className="absolute bottom-20 left-1/2 -translate-x-1/2 text-white/30 text-xs flex items-center gap-2"
        >
          <kbd className="px-1.5 py-0.5 rounded border border-white/10 bg-white/5 font-mono text-[10px]">←→</kbd>
          <span>or</span>
          <kbd className="px-1.5 py-0.5 rounded border border-white/10 bg-white/5 font-mono text-[10px]">Space</kbd>
          <span>to navigate</span>
        </motion.div>
      )}
    </div>
  );
}
