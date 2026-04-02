---
slug: high-cardinality-metrics
id: tmnahuexgbwt
type: challenge
title: 'Competitive Edge 2: Elastic Streams — Intelligent Partitioning Without Agent
  Changes'
teaser: Elastic analyzes your live data and suggests routing rules automatically.
  Accept a suggestion and your logs instantly split into per-service streams with
  independent retention and processing rules — zero Collector restarts.
notes:
- type: text
  contents: "## Workshop Slides\n\nFollow along with the full presentation:\n\n**[→
    Open Workshop Slides](https://poulsbopete.github.io/claro/)**\n\n*(Opens in a
    new tab)*\n\n***\n\n\U0001F1E7\U0001F1F7 **[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**\n\n*(Abre
    em uma nova aba)*\n"
- type: text
  contents: "## How Splunk Forces a Cardinality Trade-off\n\nIn Splunk, every unique
    metric dimension combination is a billable **Metric Time Series (MTS)**. High-cardinality
    fields like `pod.uid` or `container.id` multiply your bill with every deployment.
    The only cost lever is at the **OpenTelemetry Collector** — drop the field globally,
    permanently, before it reaches Splunk.\n\n**Elastic Streams gives you control
    inside the platform.** Instead of dropping fields at the agent, you route data
    into per-service streams — each with its own retention policy and field-level
    processing rules — without touching a single agent config.\n\n***\n\n\U0001F1E7\U0001F1F7
    **Como o Splunk Força uma Troca de Cardinalidade**\n\nNo Splunk, cada combinação
    única de dimensões de métrica é uma **Metric Time Series (MTS)** faturável. Campos
    de alta cardinalidade como `pod.uid` ou `container.id` multiplicam sua fatura
    a cada implantação. O único controle de custo está no **Collector OpenTelemetry**
    — remover o campo globalmente, permanentemente, antes de chegar ao Splunk.\n\n**O
    Elastic Streams dá controle dentro da plataforma.** Em vez de remover campos no
    agente, você roteia dados para streams por serviço — cada um com sua própria política
    de retenção e regras de processamento no nível de campo — sem tocar em nenhuma
    configuração de agente.\n"
- type: text
  contents: "## What You'll Do\n\nElastic Streams **analyzes your live data** and
    automatically suggests how to partition it. For the Claro scenario, it detects
    that `logs.otel` contains logs from 9 different services and suggests creating
    child streams like:\n\n- `logs.otel.billing-engine` — billing and OCS charging
    events\n- `logs.otel.mobile-core` — 5G/4G core network events\n- `logs.otel.voice-platform`
    — SIP/IMS events\n- (and 6 more...)\n\nEach child stream is **completely independent**:
    set 7-day retention on `billing-engine` for fast incident triage, 90-day on `network-analytics`
    for capacity trending. Add a `drop_field` rule to one without affecting the others.\n\n|
    Capability | Elastic Streams | Splunk |\n|------------|----------------|--------|\n|
    Auto-detect routing candidates | ✅ Analyzes live data | ❌ Manual pipeline config
    |\n| Per-service retention | ✅ Each child independent | ❌ Global DDAA policy |\n|
    Drop fields per-stream | ✅ Processing rules | ❌ Global Collector change |\n| Zero
    agent changes | ✅ | ❌ Requires Collector restart |\n\n***\n\n\U0001F1E7\U0001F1F7
    **O Que Você Vai Fazer**\n\nO Elastic Streams **analisa seus dados em tempo real**
    e sugere automaticamente como particioná-los. Para o cenário Claro, ele detecta
    que `logs.otel` contém logs de 9 serviços diferentes e sugere a criação de streams
    filhos como:\n\n- `logs.otel.billing-engine` — eventos de cobrança e OCS\n- `logs.otel.mobile-core`
    — eventos do core de rede 5G/4G\n- `logs.otel.voice-platform` — eventos SIP/IMS\n-
    (e mais 6...)\n\nCada stream filho é **completamente independente**: defina 7
    dias de retenção em `billing-engine` para triagem rápida de incidentes, 90 dias
    em `network-analytics` para tendências de capacidade. Adicione uma regra `drop_field`
    a um sem afetar os outros.\n\n| Capacidade | Elastic Streams | Splunk |\n|------------|----------------|--------|\n|
    Detectar candidatos automaticamente | ✅ Analisa dados em tempo real | ❌ Config
    manual no pipeline |\n| Retenção por serviço | ✅ Cada filho independente | ❌ Política
    DDAA global |\n| Remover campos por stream | ✅ Regras de processamento | ❌ Mudança
    global no Collector |\n| Zero mudanças no agente | ✅ | ❌ Requer reinicialização
    do Collector |\n"
tabs:
- id: addwrseojmxt
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: feqdqyofcddf
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: uinbtoljou0s
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/streams
  port: 8080
  custom_request_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self'' https://kibana.estccdn.com; worker-src blob: ''self'';
      style-src ''unsafe-inline'' ''self'' https://kibana.estccdn.com; style-src-elem
      ''unsafe-inline'' ''self'' https://kibana.estccdn.com'
  custom_response_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self'' https://kibana.estccdn.com; worker-src blob: ''self'';
      style-src ''unsafe-inline'' ''self'' https://kibana.estccdn.com; style-src-elem
      ''unsafe-inline'' ''self'' https://kibana.estccdn.com'
difficulty: intermediate
timelimit: 2700
enhanced_loading: null
---

# Elastic Streams — Zero-Touch Data Control

The fault is resolved. Now see the second competitive differentiator: **Elastic Streams** gives you per-service data routing, retention, and processing rules — without touching a single agent config.

---

## Step 1 — Open the Streams Page

The **Elastic Serverless** tab opens on **Observability → Streams**. You'll see the `logs.otel` stream — this is where all 9 Claro services have been sending their OpenTelemetry logs.

Click **`logs.otel`** to open it, then click the **Partitioning** tab.

> Elastic has already analyzed the last 1,000 documents and automatically detected that this stream contains data from 9 different services. No configuration required — it read your data and generated the suggestions.

---

## Step 2 — Review the Auto-Generated Suggestions

You'll see suggested child streams like:

- `logs.otel.billing-engine` — billing and OCS charging events
- `logs.otel.mobile-core` — 5G/4G core network events  
- `logs.otel.voice-platform` — SIP/IMS events
- (one per service, with live traffic percentages)

Each suggestion shows **what percentage of log volume** that service represents and a **live data preview** of real log messages.

| Capability | Elastic Streams | Splunk |
|------------|----------------|--------|
| Auto-detect routing candidates | ✅ Analyzes live data | ❌ Manual pipeline config |
| Per-service retention | ✅ Each child stream independent | ❌ Global DDAA policy |
| Drop fields per-stream | ✅ Processing rules | ❌ Global Collector restart |
| Zero agent changes | ✅ | ❌ Requires Collector redeploy |

---

## Step 3 — Accept a Partition

Click **Accept** on `logs.otel.billing-engine`.

Elastic immediately:
1. Creates the child stream `logs.otel.billing-engine`
2. Routes new logs from billing-engine to its own dedicated stream
3. Keeps `logs.otel` receiving everything else — no data loss, no downtime

Now you can set a **7-day retention** on `billing-engine` for fast incident triage while keeping the parent stream at 30 days. Add a `drop_field` rule to remove PII from billing logs without affecting mobile-core logs at all.

> **In Splunk:** A platform engineer would write Collector routing rules in YAML, deploy to every collector node, wait for restart, verify in Splunk, then fix mistakes and redeploy. No data preview. No automatic suggestions.

✅ **That's the full demo.** Fault injected → detected by ES|QL alert → AI workflow investigated and created a case → operator resolved → verified in Chaos Controller → competitive edge demonstrated in Streams.

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Elastic Streams — Controle de Dados Sem Tocar nos Agentes

A falha foi resolvida. Agora veja o segundo diferencial competitivo: **Elastic Streams** oferece roteamento, retenção e regras de processamento por serviço — sem tocar em nenhuma configuração de agente.

---

## Passo 1 — Abrir a Página Streams

A aba **Elastic Serverless** abre em **Observability → Streams**. Você verá o stream `logs.otel` — é onde todos os 9 serviços Claro enviam seus logs OpenTelemetry.

Clique em **`logs.otel`** para abri-lo, depois clique na aba **Partitioning**.

> O Elastic já analisou os últimos 1.000 documentos e detectou automaticamente que este stream contém dados de 9 serviços diferentes. Sem configuração — ele leu seus dados e gerou as sugestões.

---

## Passo 2 — Revisar as Sugestões Geradas Automaticamente

Você verá streams filhos sugeridos como:

- `logs.otel.billing-engine` — eventos de cobrança e OCS
- `logs.otel.mobile-core` — eventos do core 5G/4G
- `logs.otel.voice-platform` — eventos SIP/IMS
- (um por serviço, com percentuais de volume de tráfego ao vivo)

| Capacidade | Elastic Streams | Splunk |
|------------|----------------|--------|
| Detectar candidatos automaticamente | ✅ Analisa dados ao vivo | ❌ Config manual no pipeline |
| Retenção por serviço | ✅ Cada stream filho independente | ❌ Política DDAA global |
| Remover campos por stream | ✅ Regras de processamento | ❌ Restart global do Collector |
| Zero mudanças no agente | ✅ | ❌ Requer redesploy do Collector |

---

## Passo 3 — Aceitar uma Partição

Clique em **Accept** em `logs.otel.billing-engine`.

O Elastic imediatamente:
1. Cria o stream filho `logs.otel.billing-engine`
2. Roteia novos logs do billing-engine para seu próprio stream dedicado
3. Mantém `logs.otel` recebendo todo o resto — sem perda de dados, sem downtime

> **No Splunk:** Um engenheiro de plataforma escreveria regras de roteamento no Collector em YAML, faria deploy em cada nó de coletor, esperaria o restart, verificaria no Splunk, consertaria erros e refaria o deploy. Sem preview de dados. Sem sugestões automáticas.

✅ **É o demo completo.** Falha injetada → detectada por alerta ES|QL → workflow de IA investigou e criou um caso → operador resolveu → verificado no Chaos Controller → diferencial competitivo demonstrado no Streams.

</details>
