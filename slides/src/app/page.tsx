import { BackgroundPaths } from "@/components/ui/background-paths";
import { SlideShow } from "@/components/SlideShow";

export default function Home() {
  return (
    <main className="relative w-screen h-screen overflow-hidden bg-elastic-dark">
      <BackgroundPaths />
      <div className="relative z-10 w-full h-full">
        <SlideShow />
      </div>
    </main>
  );
}
