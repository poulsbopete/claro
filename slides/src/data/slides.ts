export type SlideType = "title" | "problem" | "lab" | "summary";

export interface ComparisonRow {
  capability: { en: string; es: string };
  elastic: string;
  splunk: string;
}

export interface LabPoint {
  en: string;
  es: string;
}

export interface SlideData {
  id: string;
  type: SlideType;
  title:    { en: string; es: string };
  subtitle: { en: string; es: string };
  labNumber?: number;
  badge?:   { en: string; es: string };
  metric?:  { value: string; label: { en: string; es: string } };
  points?:  LabPoint[];
  comparison?: ComparisonRow[];
  cta?:     { en: string; es: string };
  footer?:  { en: string; es: string };
}

export const slides: SlideData[] = [
  // ── Slide 1: Title ────────────────────────────────────────────────────────
  {
    id: "title",
    type: "title",
    title: {
      en: "Elastic Observability",
      es: "Elastic Observability",
    },
    subtitle: {
      en: "The Unified Platform Advantage — Four Labs, Four Architectural Wins",
      es: "La Ventaja de la Plataforma Unificada — Cuatro Labs, Cuatro Victorias Arquitectónicas",
    },
    cta: {
      en: "Start the Labs →",
      es: "Comenzar los Labs →",
    },
  },

  // ── Slide 2: The Problem ──────────────────────────────────────────────────
  {
    id: "problem",
    type: "problem",
    title: {
      en: "The Splunk Tax",
      es: "El Costo Oculto de Splunk",
    },
    subtitle: {
      en: "Four architectural constraints that slow teams down and inflate costs",
      es: "Cuatro restricciones arquitectónicas que frenan a los equipos e inflan los costos",
    },
    points: [
      {
        en: "Logs in Splunk Cloud, traces in Splunk Observability Cloud — two products, two UIs, two bills",
        es: "Logs en Splunk Cloud, trazas en Splunk OC — dos productos, dos interfaces, dos facturas",
      },
      {
        en: "MTS-based pricing punishes high-cardinality Kubernetes metrics — forcing teams to drop data",
        es: "El precio por MTS penaliza las métricas de alta cardinalidad — forzando a eliminar datos",
      },
      {
        en: "DDAA archives are not searchable in-place — rehydration takes hours or days",
        es: "Los archivos DDAA no son consultables en su lugar — la rehidratación tarda horas o días",
      },
      {
        en: "Splunk Enterprise Security requires a separate license, CIM normalization, and double ingest",
        es: "Splunk ES requiere licencia separada, normalización CIM e ingestión doble",
      },
    ],
  },

  // ── Slide 3: Lab 1 — Architectural Unity ─────────────────────────────────
  {
    id: "lab1",
    type: "lab",
    labNumber: 1,
    badge: { en: "Architectural Unity", es: "Unidad Arquitectónica" },
    title: {
      en: "One Datastore. Zero Context Switches.",
      es: "Un Solo Almacén de Datos. Cero Cambios de Contexto.",
    },
    subtitle: {
      en: "Pivot from an APM trace to its correlated log line in one click — no second product, no copied trace IDs",
      es: "Salta de una traza APM a su log correlacionado en un clic — sin segundo producto, sin copiar IDs",
    },
    metric: {
      value: "1",
      label: { en: "platform for logs + traces + metrics", es: "plataforma para logs + trazas + métricas" },
    },
    comparison: [
      {
        capability: { en: "Traces + Logs in one datastore", es: "Trazas + Logs en un solo almacén" },
        elastic: "✅ Elasticsearch",
        splunk:  "❌ Two products",
      },
      {
        capability: { en: "Pivot trace → log", es: "Salto traza → log" },
        elastic: "✅ One click",
        splunk:  "❌ Copy ID, open second UI",
      },
      {
        capability: { en: "Single query language", es: "Lenguaje de consulta único" },
        elastic: "✅ ES|QL everywhere",
        splunk:  "❌ SPL + SignalFlow",
      },
      {
        capability: { en: "Single billing contract", es: "Contrato de facturación único" },
        elastic: "✅",
        splunk:  "❌ Cloud + OC",
      },
    ],
    footer: {
      en: "Lab: Ingest synthetic APM traces + logs sharing trace.id, correlate them with one ES|QL query",
      es: "Lab: Ingesta trazas APM + logs con trace.id compartido, correlalos con una consulta ES|QL",
    },
  },

  // ── Slide 4: Lab 2 — Elastic Streams ─────────────────────────────────────
  {
    id: "lab2",
    type: "lab",
    labNumber: 2,
    badge: { en: "Elastic Streams", es: "Elastic Streams" },
    title: {
      en: "Control Cardinality Without Touching Your Agents",
      es: "Controla la Cardinalidad Sin Modificar tus Agentes",
    },
    subtitle: {
      en: "Set retention per stream, apply processing rules to drop high-cardinality fields — all inside the platform",
      es: "Configura retención por stream, aplica reglas para eliminar campos de alta cardinalidad — todo dentro de la plataforma",
    },
    metric: {
      value: "0",
      label: { en: "agent changes to control cardinality", es: "cambios de agente para controlar cardinalidad" },
    },
    comparison: [
      {
        capability: { en: "Retention per data stream", es: "Retención por flujo de datos" },
        elastic: "✅ 7d detailed / 90d summary",
        splunk:  "❌ Global policy only",
      },
      {
        capability: { en: "Drop fields inside the platform", es: "Eliminar campos dentro de la plataforma" },
        elastic: "✅ Processing rules",
        splunk:  "❌ Collector-level only",
      },
      {
        capability: { en: "MTS / cardinality pricing", es: "Precio por MTS / cardinalidad" },
        elastic: "✅ GB-based, no MTS charge",
        splunk:  "❌ Per-MTS billing",
      },
      {
        capability: { en: "Reversible in-platform control", es: "Control reversible dentro de la plataforma" },
        elastic: "✅ Any time",
        splunk:  "❌ Re-deploy agents",
      },
    ],
    footer: {
      en: "Lab: Create lab5-k8s-detailed (7d) and lab5-k8s-summary (90d) streams via Kibana Streams API",
      es: "Lab: Crea streams lab5-k8s-detailed (7d) y lab5-k8s-summary (90d) mediante la API de Kibana Streams",
    },
  },

  // ── Slide 5: Lab 3 — Searchable Snapshots ────────────────────────────────
  {
    id: "lab3",
    type: "lab",
    labNumber: 3,
    badge: { en: "Searchable Snapshots", es: "Snapshots Consultables" },
    title: {
      en: "Two-Year-Old Data. Sub-Second Query.",
      es: "Datos de Hace Dos Años. Consulta en Milisegundos.",
    },
    subtitle: {
      en: "Query frozen-tier data stored in S3 instantly — no rehydration job, no support ticket, no waiting overnight",
      es: "Consulta datos en tier congelado en S3 al instante — sin rehidratación, sin tickets, sin esperar toda la noche",
    },
    metric: {
      value: "0",
      label: { en: "seconds rehydration time", es: "segundos de tiempo de rehidratación" },
    },
    comparison: [
      {
        capability: { en: "Query archived data directly", es: "Consultar datos archivados directamente" },
        elastic: "✅ Instantly",
        splunk:  "❌ Requires rehydration",
      },
      {
        capability: { en: "Rehydration time", es: "Tiempo de rehidratación" },
        elastic: "✅ None",
        splunk:  "❌ Hours to days",
      },
      {
        capability: { en: "Same API as hot data", es: "Misma API que datos calientes" },
        elastic: "✅ Full ES|QL",
        splunk:  "❌ Different path",
      },
      {
        capability: { en: "Cross-tier query (hot + archive)", es: "Consulta entre tiers (caliente + archivo)" },
        elastic: "✅ Single query",
        splunk:  "❌ Two operations",
      },
    ],
    footer: {
      en: "Lab: Query 500 audit logs timestamped 2 years ago alongside recent data — one wildcard pattern",
      es: "Lab: Consulta 500 logs de auditoría de hace 2 años junto con datos recientes — un patrón wildcard",
    },
  },

  // ── Slide 6: Lab 4 — Converged Operations ────────────────────────────────
  {
    id: "lab4",
    type: "lab",
    labNumber: 4,
    badge: { en: "Converged Operations", es: "Operaciones Convergentes" },
    title: {
      en: "SIEM Coverage. Zero Extra Ingest.",
      es: "Cobertura SIEM. Sin Ingestión Adicional.",
    },
    subtitle: {
      en: "Enable a security detection rule on the same index that powers your APM dashboards — no double ingest, no second license",
      es: "Activa una regla de detección de seguridad en el mismo índice de tu APM — sin doble ingestión, sin segunda licencia",
    },
    metric: {
      value: "0×",
      label: { en: "extra ingest cost for SIEM coverage", es: "costo adicional de ingestión para SIEM" },
    },
    comparison: [
      {
        capability: { en: "Detection rules on observability data", es: "Reglas de detección en datos de observabilidad" },
        elastic: "✅ Same index",
        splunk:  "❌ Separate product",
      },
      {
        capability: { en: "Additional ingest for SIEM", es: "Ingestión adicional para SIEM" },
        elastic: "✅ Zero",
        splunk:  "❌ Full double-ingest",
      },
      {
        capability: { en: "Normalization required", es: "Normalización requerida" },
        elastic: "✅ None (ECS native)",
        splunk:  "❌ CIM mapping",
      },
      {
        capability: { en: "Alert → trace correlation", es: "Alerta → correlación de trazas" },
        elastic: "✅ Same platform",
        splunk:  "❌ Cross-product navigation",
      },
    ],
    footer: {
      en: "Lab: Brute-force attack injected into lab4-app-logs-* — the same observability index from Lab 1",
      es: "Lab: Ataque de fuerza bruta inyectado en lab4-app-logs-* — el mismo índice de observabilidad del Lab 1",
    },
  },

  // ── Slide 7: Summary ──────────────────────────────────────────────────────
  {
    id: "summary",
    type: "summary",
    title: {
      en: "The Elastic Advantage",
      es: "La Ventaja de Elastic",
    },
    subtitle: {
      en: "One platform. Unified data. Predictable cost.",
      es: "Una plataforma. Datos unificados. Costo predecible.",
    },
    points: [
      {
        en: "Architectural Unity — logs, traces, and metrics in a single Elasticsearch datastore",
        es: "Unidad Arquitectónica — logs, trazas y métricas en un solo almacén de datos Elasticsearch",
      },
      {
        en: "Elastic Streams — control retention and cardinality inside the platform, without touching agents",
        es: "Elastic Streams — controla retención y cardinalidad dentro de la plataforma, sin tocar agentes",
      },
      {
        en: "Searchable Snapshots — frozen-tier archives queryable instantly, no rehydration lag",
        es: "Snapshots Consultables — archivos en tier congelado consultables al instante, sin demora de rehidratación",
      },
      {
        en: "Converged Operations — SIEM detection on observability data at zero extra ingest cost",
        es: "Operaciones Convergentes — detección SIEM en datos de observabilidad sin costo adicional de ingestión",
      },
    ],
    cta: {
      en: "Try the Instruqt Workshop →",
      es: "Prueba el Workshop en Instruqt →",
    },
  },
];
