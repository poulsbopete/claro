export type SlideType = "title" | "problem" | "lab" | "summary";

export interface ComparisonRow {
  capability: { en: string; pt: string };
  elastic: string;
  splunk: string;
}

export interface LabPoint {
  en: string;
  pt: string;
}

export interface SlideData {
  id: string;
  type: SlideType;
  title:    { en: string; pt: string };
  subtitle: { en: string; pt: string };
  labNumber?: number;
  badge?:   { en: string; pt: string };
  metric?:  { value: string; label: { en: string; pt: string } };
  points?:  LabPoint[];
  comparison?: ComparisonRow[];
  cta?:     { en: string; pt: string };
  footer?:  { en: string; pt: string };
}

export const slides: SlideData[] = [
  // ── Slide 1: Title ────────────────────────────────────────────────────────
  {
    id: "title",
    type: "title",
    title: {
      en: "Elastic Observability",
      pt: "Elastic Observability",
    },
    subtitle: {
      en: "The Unified Platform Advantage — Four Labs, Four Architectural Wins",
      pt: "A Vantagem da Plataforma Unificada — Quatro Labs, Quatro Vitórias Arquitetônicas",
    },
  },

  // ── Slide 2: The Problem ──────────────────────────────────────────────────
  {
    id: "problem",
    type: "problem",
    title: {
      en: "The Splunk Tax",
      pt: "O Custo Oculto do Splunk",
    },
    subtitle: {
      en: "Four architectural constraints that slow teams down and inflate costs",
      pt: "Quatro restrições arquitetônicas que freiam as equipes e inflam os custos",
    },
    points: [
      {
        en: "Logs in Splunk Cloud, traces in Splunk Observability Cloud — two products, two UIs, two bills",
        pt: "Logs no Splunk Cloud, rastreamentos no Splunk OC — dois produtos, duas interfaces, duas faturas",
      },
      {
        en: "MTS-based pricing punishes high-cardinality Kubernetes metrics — forcing teams to drop data",
        pt: "O preço por MTS penaliza métricas de alta cardinalidade do Kubernetes — forçando as equipes a descartar dados",
      },
      {
        en: "DDAA archives are not searchable in-place — rehydration takes hours or days",
        pt: "Os arquivos DDAA não são consultáveis no lugar — a reidratação leva horas ou dias",
      },
      {
        en: "Splunk Enterprise Security requires a separate license, CIM normalization, and double ingest",
        pt: "Splunk Enterprise Security exige licença separada, normalização CIM e ingestão dupla",
      },
    ],
  },

  // ── Slide 3: Lab 1 — Architectural Unity ─────────────────────────────────
  {
    id: "lab1",
    type: "lab",
    labNumber: 1,
    badge: { en: "Architectural Unity", pt: "Unidade Arquitetônica" },
    title: {
      en: "One Datastore. Zero Context Switches.",
      pt: "Um Único Armazenamento. Zero Trocas de Contexto.",
    },
    subtitle: {
      en: "Pivot from an APM trace to its correlated log line in one click — no second product, no copied trace IDs",
      pt: "Salte de um rastreamento APM para seu log correlacionado em um clique — sem segundo produto, sem copiar IDs",
    },
    metric: {
      value: "1",
      label: { en: "platform for logs + traces + metrics", pt: "plataforma para logs + rastreamentos + métricas" },
    },
    comparison: [
      {
        capability: { en: "Traces + Logs in one datastore", pt: "Rastreamentos + Logs em um único armazenamento" },
        elastic: "✅ Elasticsearch",
        splunk:  "❌ Two products",
      },
      {
        capability: { en: "Pivot trace → log", pt: "Salto rastreamento → log" },
        elastic: "✅ One click",
        splunk:  "❌ Copy ID, open second UI",
      },
      {
        capability: { en: "Single query language", pt: "Linguagem de consulta única" },
        elastic: "✅ ES|QL everywhere",
        splunk:  "❌ SPL + SignalFlow",
      },
      {
        capability: { en: "Single billing contract", pt: "Contrato de faturamento único" },
        elastic: "✅",
        splunk:  "❌ Cloud + OC",
      },
    ],
    footer: {
      en: "Lab: Ingest synthetic APM traces + logs sharing trace.id, correlate them with one ES|QL query",
      pt: "Lab: Ingira rastreamentos APM + logs com trace.id compartilhado, correlacione-os com uma consulta ES|QL",
    },
  },

  // ── Slide 4: Lab 2 — Elastic Streams ─────────────────────────────────────
  {
    id: "lab2",
    type: "lab",
    labNumber: 2,
    badge: { en: "Elastic Streams", pt: "Elastic Streams" },
    title: {
      en: "Control Cardinality Without Touching Your Agents",
      pt: "Controle a Cardinalidade Sem Modificar seus Agentes",
    },
    subtitle: {
      en: "Set retention per stream, apply processing rules to drop high-cardinality fields — all inside the platform",
      pt: "Configure retenção por stream, aplique regras para eliminar campos de alta cardinalidade — tudo dentro da plataforma",
    },
    metric: {
      value: "0",
      label: { en: "agent changes to control cardinality", pt: "alterações de agente para controlar cardinalidade" },
    },
    comparison: [
      {
        capability: { en: "Retention per data stream", pt: "Retenção por fluxo de dados" },
        elastic: "✅ 7d detailed / 90d summary",
        splunk:  "❌ Global policy only",
      },
      {
        capability: { en: "Drop fields inside the platform", pt: "Eliminar campos dentro da plataforma" },
        elastic: "✅ Processing rules",
        splunk:  "❌ Collector-level only",
      },
      {
        capability: { en: "MTS / cardinality pricing", pt: "Preço por MTS / cardinalidade" },
        elastic: "✅ GB-based, no MTS charge",
        splunk:  "❌ Per-MTS billing",
      },
      {
        capability: { en: "Reversible in-platform control", pt: "Controle reversível dentro da plataforma" },
        elastic: "✅ Any time",
        splunk:  "❌ Re-deploy agents",
      },
    ],
    footer: {
      en: "Lab: Accept auto-partitioning suggestions on logs.otel, set per-service retention and processing rules",
      pt: "Lab: Aceite sugestões de particionamento automático no logs.otel, defina retenção e regras de processamento por serviço",
    },
  },

  // ── Slide 5: Lab 3 — Searchable Snapshots ────────────────────────────────
  {
    id: "lab3",
    type: "lab",
    labNumber: 3,
    badge: { en: "Searchable Snapshots", pt: "Snapshots Consultáveis" },
    title: {
      en: "Two-Year-Old Data. Sub-Second Query.",
      pt: "Dados de Dois Anos Atrás. Consulta em Milissegundos.",
    },
    subtitle: {
      en: "Query frozen-tier data stored in S3 instantly — no rehydration job, no support ticket, no waiting overnight",
      pt: "Consulte dados no tier congelado no S3 instantaneamente — sem reidratação, sem tickets, sem esperar a noite toda",
    },
    metric: {
      value: "0",
      label: { en: "seconds rehydration time", pt: "segundos de tempo de reidratação" },
    },
    comparison: [
      {
        capability: { en: "Query archived data directly", pt: "Consultar dados arquivados diretamente" },
        elastic: "✅ Instantly",
        splunk:  "❌ Requires rehydration",
      },
      {
        capability: { en: "Rehydration time", pt: "Tempo de reidratação" },
        elastic: "✅ None",
        splunk:  "❌ Hours to days",
      },
      {
        capability: { en: "Same API as hot data", pt: "Mesma API que dados quentes" },
        elastic: "✅ Full ES|QL",
        splunk:  "❌ Different path",
      },
      {
        capability: { en: "Cross-tier query (hot + archive)", pt: "Consulta entre tiers (quente + arquivo)" },
        elastic: "✅ Single query",
        splunk:  "❌ Two operations",
      },
    ],
    footer: {
      en: "Lab: Query 500 audit logs timestamped 2 years ago alongside recent data — one wildcard pattern",
      pt: "Lab: Consulte 500 logs de auditoria de 2 anos atrás junto com dados recentes — um padrão wildcard",
    },
  },

  // ── Slide 6: Lab 4 — Converged Operations ────────────────────────────────
  {
    id: "lab4",
    type: "lab",
    labNumber: 4,
    badge: { en: "Converged Operations", pt: "Operações Convergidas" },
    title: {
      en: "SIEM Coverage. Zero Extra Ingest.",
      pt: "Cobertura SIEM. Sem Ingestão Adicional.",
    },
    subtitle: {
      en: "Enable a security detection rule on the same index that powers your APM dashboards — no double ingest, no second license",
      pt: "Ative uma regra de detecção de segurança no mesmo índice do seu APM — sem ingestão dupla, sem segunda licença",
    },
    metric: {
      value: "0×",
      label: { en: "extra ingest cost for SIEM coverage", pt: "custo adicional de ingestão para SIEM" },
    },
    comparison: [
      {
        capability: { en: "Detection rules on observability data", pt: "Regras de detecção em dados de observabilidade" },
        elastic: "✅ Same index",
        splunk:  "❌ Separate product",
      },
      {
        capability: { en: "Additional ingest for SIEM", pt: "Ingestão adicional para SIEM" },
        elastic: "✅ Zero",
        splunk:  "❌ Full double-ingest",
      },
      {
        capability: { en: "Normalization required", pt: "Normalização necessária" },
        elastic: "✅ None (ECS native)",
        splunk:  "❌ CIM mapping",
      },
      {
        capability: { en: "Alert → trace correlation", pt: "Alerta → correlação de rastreamentos" },
        elastic: "✅ Same platform",
        splunk:  "❌ Cross-product navigation",
      },
    ],
    footer: {
      en: "Lab: Brute-force attack injected into lab7-attack-logs-* — the same observability index structure",
      pt: "Lab: Ataque de força bruta injetado em lab7-attack-logs-* — mesma estrutura do índice de observabilidade",
    },
  },

  // ── Slide 7: Summary ──────────────────────────────────────────────────────
  {
    id: "summary",
    type: "summary",
    title: {
      en: "The Elastic Advantage",
      pt: "A Vantagem do Elastic",
    },
    subtitle: {
      en: "One platform. Unified data. Predictable cost.",
      pt: "Uma plataforma. Dados unificados. Custo previsível.",
    },
    points: [
      {
        en: "Architectural Unity — logs, traces, and metrics in a single Elasticsearch datastore",
        pt: "Unidade Arquitetônica — logs, rastreamentos e métricas em um único armazenamento Elasticsearch",
      },
      {
        en: "Elastic Streams — control retention and cardinality inside the platform, without touching agents",
        pt: "Elastic Streams — controle retenção e cardinalidade dentro da plataforma, sem tocar nos agentes",
      },
      {
        en: "Searchable Snapshots — frozen-tier archives queryable instantly, no rehydration lag",
        pt: "Snapshots Consultáveis — arquivos no tier congelado consultáveis instantaneamente, sem atraso de reidratação",
      },
      {
        en: "Converged Operations — SIEM detection on observability data at zero extra ingest cost",
        pt: "Operações Convergidas — detecção SIEM em dados de observabilidade sem custo adicional de ingestão",
      },
    ],
  },
];
