import type { Metadata } from "next";
import "./globals.css";
import { LanguageProvider } from "@/context/LanguageContext";

export const metadata: Metadata = {
  title: "Elastic Observability — The Unified Platform Advantage",
  description:
    "Four competitive labs demonstrating Elastic's architectural advantages over Splunk: Architectural Unity, Elastic Streams, Searchable Snapshots, and Converged Operations.",
  openGraph: {
    title: "Elastic Observability — The Unified Platform Advantage",
    description: "Four labs. Four architectural wins. Zero compromise.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body>
        <LanguageProvider>{children}</LanguageProvider>
      </body>
    </html>
  );
}
