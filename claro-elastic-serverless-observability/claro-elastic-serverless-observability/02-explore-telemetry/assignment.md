---
slug: explore-telemetry
id: sxt25jeemymj
type: challenge
title: Explore Live OpenTelemetry Data
teaser: Navigate Elastic Serverless to see logs, distributed traces, and host metrics
  flowing from 9 simulated microservices across three cloud providers.
notes:
- type: text
  contents: |
    ## Workshop Slides

    Follow along with the full presentation:

    **[→ Open Workshop Slides](https://poulsbopete.github.io/claro/)**

    *(Opens in a new tab)*

    ***

    🇧🇷 **[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**

    *(Abre em uma nova aba)*
- type: text
  contents: |
    ## Lab 2 — Explore Live OpenTelemetry Data

    **By the end of this challenge you will:**

    - ✅ Query live logs with ES|QL in Discover
    - ✅ View distributed traces and service maps in APM
    - ✅ Inspect host metrics across 3 simulated cloud providers
    - ✅ Explore the Executive Dashboard for the Claro scenario
    - ✅ Run time-series ES|QL queries against live metric streams

    **Your data is real.** Every log, trace, and metric is generated fresh and shipped via OTLP directly to Elastic — no recordings, no synthetic replay.

    ***

    🇧🇷 **Lab 2 — Explorar Dados OpenTelemetry em Tempo Real**

    **Ao final deste desafio você irá:**

    - ✅ Consultar logs em tempo real com ES|QL no Discover
    - ✅ Ver rastreamentos distribuídos e mapas de serviços no APM
    - ✅ Inspecionar métricas de host em 3 provedores de nuvem simulados
    - ✅ Explorar o Dashboard Executivo do cenário Claro
    - ✅ Executar consultas ES|QL de série temporal em streams de métricas em tempo real

    **Seus dados são reais.** Cada log, rastreamento e métrica é gerado e enviado via OTLP diretamente ao Elastic — sem gravações, sem replay sintético.
- type: text
  contents: |
    ## Three Signals, One Store

    Elastic correlates logs, metrics, and traces in a single data store — no switching tools, no context loss.

    | Signal | Where to look | Index pattern |
    |--------|--------------|---------------|
    | **Logs** | Discover → ES\|QL | `logs*` |
    | **Traces** | Applications → Service inventory | `traces-*` |
    | **Metrics** | Observability → Infrastructure | `metrics-*` |

    Signals connect automatically — a trace span links to its log lines via `trace.id`, and error spikes correlate with host CPU in the same timeline.

    ***

    🇧🇷 **Três Sinais, Um Armazenamento**

    O Elastic correlaciona logs, métricas e rastreamentos em um único armazenamento de dados — sem trocar de ferramenta, sem perder contexto.

    | Sinal | Onde encontrar | Padrão de índice |
    |-------|---------------|------------------|
    | **Logs** | Discover → ES\|QL | `logs*` |
    | **Rastreamentos** | Applications → Service inventory | `traces-*` |
    | **Métricas** | Observability → Infrastructure | `metrics-*` |

    Os sinais se conectam automaticamente — um span de rastreamento se vincula às suas linhas de log via `trace.id`, e picos de erro se correlacionam com a CPU do host na mesma linha do tempo.
- type: text
  contents: |
    ## What's Generating Telemetry

    **9 scenario microservices** (application logs + traces):
    Mobile Core · Billing Engine · SMS Gateway · Customer Portal · Content Delivery · Network Analytics · Voice Platform · IoT Connect · NOC Dashboard

    **Background generators** (infrastructure telemetry):
    - 3 cloud hosts (AWS, GCP, Azure) — CPU, memory, disk, network
    - Kubernetes node + pod metrics
    - Nginx access logs and MySQL slow query logs
    - VPC flow logs and distributed trace chains

    > **Tip:** Set the time range to **Last 15 minutes** to see the freshest data.

    ***

    🇧🇷 **O Que Está Gerando Telemetria**

    **9 microsserviços do cenário** (logs de aplicação + rastreamentos):
    Mobile Core · Billing Engine · SMS Gateway · Customer Portal · Content Delivery · Network Analytics · Voice Platform · IoT Connect · NOC Dashboard

    **Geradores de fundo** (telemetria de infraestrutura):
    - 3 hosts em nuvem (AWS, GCP, Azure) — CPU, memória, disco, rede
    - Métricas de nós e pods do Kubernetes
    - Logs de acesso Nginx e logs de consulta lenta do MySQL
    - Logs de fluxo VPC e cadeias de rastreamento distribuído

    > **Dica:** Defina o intervalo de tempo para **Últimos 15 minutos** para ver os dados mais recentes.
- type: text
  contents: |
    ## ES|QL: Query Telemetry Like a Pipeline

    ES|QL is Elastic's pipe-based query language. Run these in **Discover → ES|QL** during the challenge:

    **Error spike by service:**
    ```
    FROM logs*
    | WHERE @timestamp > NOW() - 15 MINUTES
    | WHERE severity_text == "ERROR"
    | STATS errors = COUNT(*) BY service.name
    | SORT errors DESC
    ```

    **5G PDU session latency over time:**
    ```
    TS metrics*
    | WHERE @timestamp > NOW() - 30 MINUTES
    | EVAL minute = DATE_TRUNC(1 minute, @timestamp)
    | STATS avg_pdu_latency = AVG(mobile_core.pdu_session_latency_ms) BY minute
    | SORT minute DESC
    ```

    ***

    🇧🇷 **ES|QL: Consulte Telemetria como um Pipeline**

    Execute estas consultas em **Discover → ES|QL** durante o desafio:

    **Pico de erros por serviço:**
    ```
    FROM logs*
    | WHERE @timestamp > NOW() - 15 MINUTES
    | WHERE severity_text == "ERROR"
    | STATS errors = COUNT(*) BY service.name
    | SORT errors DESC
    ```

    **Latência de sessão PDU 5G ao longo do tempo:**
    ```
    TS metrics*
    | WHERE @timestamp > NOW() - 30 MINUTES
    | EVAL minuto = DATE_TRUNC(1 minute, @timestamp)
    | STATS latencia_pdu = AVG(mobile_core.pdu_session_latency_ms) BY minuto
    | SORT minuto DESC
    ```
tabs:
- id: zwxgngz79zta
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: vfexjvy3bluo
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: awkrxylku1hz
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/dashboards#/list?_g=(filters:!(),refreshInterval:(pause:!f,value:30000),time:(from:now-30m,to:now))
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
difficulty: basic
timelimit: 0
enhanced_loading: null
---

# Explore Live OpenTelemetry Telemetry

Now that your scenario is running, let's explore the data flowing into Elastic. Open the **Elastic Serverless** tab.

---

## What's Generating Telemetry

The platform runs several background generators simultaneously:

| Generator | What It Produces |
|-----------|-----------------|
| **9 scenario services** | Application logs, traces, errors |
| **Host metrics** | CPU, memory, disk, network for 3 cloud hosts |
| **Kubernetes metrics** | Node, pod, container metrics |
| **Nginx metrics + logs** | Access logs, error logs, request spans |
| **MySQL logs** | Slow query + error logs |
| **VPC flow logs** | Network flow telemetry |
| **Distributed traces** | Multi-service request chains |

---

## Explore #1 — Logs via ES|QL

1. In the **Elastic Serverless** tab → **Discover**
2. Switch to **ES|QL** mode (top-left toggle)
3. Run this query:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 5 MINUTES
| KEEP service.name, body.text, severity_text, @timestamp
| SORT @timestamp DESC
| LIMIT 50
```

You should see a stream of logs from multiple services. Once you confirm data is flowing, try filtering to errors only:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS error_count = COUNT(*) BY service.name
| SORT error_count DESC
```

**Things to notice:**
- `service.name`: `mobile-core`, `billing-engine`, `sms-gateway`, `customer-portal`, `content-delivery`, `network-analytics`, `voice-platform`, `iot-connect`, `noc-dashboard`
- `severity_text`: `INFO`, `WARN`, `ERROR`
- `body.text` contains the raw log message and error type

---

## Explore #2 — APM / Services

1. In the **Elastic Serverless** tab → **Applications → Service inventory**
2. You should see **7 services** — the 5 application services plus `nginx-proxy` and `mysql-primary`
   > The remaining 2 network/infrastructure services (`wifi-controller`, `network-controller`, `firewall-gateway`, `dns-dhcp-service`) emit logs only — no traces — so they won't appear here
3. Click any service to see latency, throughput, and error rate
4. Open a transaction to see the **distributed trace waterfall**

---

## Explore #3 — Infrastructure / Hosts

1. In the **Elastic Serverless** tab → **Observability → Infrastructure**
2. You should see 3 hosts — one per cloud provider:
   - `claro-aws-core-01` (AWS us-east-1 — Mobile Core & Billing)
   - `claro-gcp-digital-01` (GCP us-central1 — Digital Services)
   - `claro-azure-ops-01` (Azure eastus — Voice, IoT & NOC)
3. Click a host to see CPU, memory, disk, and network metrics

> **Note:** If hosts don't appear immediately, wait 1–2 minutes for the host metrics generator to send its first batch.

---

## Explore #4 — ES|QL Time Series Queries

In the **Elastic Serverless** tab → **Discover** → **ES|QL** mode, try these queries against the live metrics stream.

### 5G core health at a glance
```esql
TS metrics*
| WHERE @timestamp > NOW() - 15 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    sessions_5g    = AVG(mobile_core.active_sessions_5g),
    sessions_lte   = AVG(mobile_core.active_sessions_lte),
    pdu_latency_ms = AVG(mobile_core.pdu_session_latency_ms),
    ho_success_pct = AVG(mobile_core.handover_success_rate)
  BY minute
| SORT minute DESC
```

### Spot an OCS billing latency spike before subscribers notice
```esql
TS metrics*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS avg_ocs_latency = AVG(billing_engine.ocs_ccr_latency_ms) BY minute
| EVAL status = CASE(
    avg_ocs_latency > 2000, "🔴 CRITICAL — Prepaid subscribers blocked",
    avg_ocs_latency > 500,  "🟡 DEGRADED — OCS responding slowly",
    "🟢 HEALTHY"
  )
| SORT minute DESC
```

### CDN cache hit rate vs origin load (Claro TV)
```esql
TS metrics*
| WHERE @timestamp > NOW() - 20 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    cache_hit_pct = AVG(content_delivery.cache_hit_rate),
    origin_rps    = AVG(content_delivery.origin_rps),
    rebuffer_pct  = AVG(content_delivery.video_rebuffer_rate)
  BY minute
| EVAL cdn_health = CASE(
    cache_hit_pct < 30, "🔴 PURGE STORM — origin overloaded",
    cache_hit_pct < 70, "🟡 DEGRADED",
    "🟢 HEALTHY"
  )
| SORT minute DESC
```

### Multi-cloud voice trunk, IoT broker, and NOC alert rate
```esql
TS metrics*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL bucket5m = DATE_TRUNC(5 minutes, @timestamp)
| STATS
    sip_trunk_util   = AVG(voice_platform.sip_trunk_utilization_pct),
    mqtt_connections = AVG(iot_connect.mqtt_connections),
    noc_alert_rate   = AVG(noc_dashboard.alert_rate_per_min)
  BY bucket5m
| EVAL voice_risk = CASE(
    sip_trunk_util > 90, "🔴 SIP SATURATED",
    sip_trunk_util > 70, "🟡 HIGH LOAD",
    "🟢 OK"
  )
| SORT bucket5m DESC
```

### Log volume by service and severity over time
```esql
FROM logs*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    errors = COUNT(*) WHERE severity_text == "ERROR",
    warnings = COUNT(*) WHERE severity_text == "WARN",
    total  = COUNT(*)
  BY minute, service.name
| SORT minute DESC, total DESC
```

> **Tip:** After triggering a chaos fault in the next challenge, re-run this query to watch the error count spike for the affected service in real time — while healthy services stay flat.

---

## Explore #5 — Dashboards

The deployer created an **Executive Dashboard** pre-configured for your scenario. Find it in:

**Elastic Serverless** tab → **Dashboards** → search "Claro" (or "Executive")

✅ **Ready to continue when** you've seen logs, traces, or metrics in Elastic Serverless and confirmed services are healthy.

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Explorar Telemetria OpenTelemetry em Tempo Real

Com o cenário em execução, vamos explorar os dados que fluem para o Elastic. Abra a aba **Elastic Serverless**.

---

## O Que Está Gerando Telemetria

| Gerador | O Que Produz |
|---------|-------------|
| **9 serviços do cenário** | Logs de aplicação, rastreamentos, erros |
| **Métricas de host** | CPU, memória, disco, rede para 3 hosts em nuvem |
| **Métricas do Kubernetes** | Nó, pod, métricas de contêiner |
| **Métricas + logs do Nginx** | Logs de acesso, logs de erro, spans de requisição |
| **Logs do MySQL** | Logs de consulta lenta e erros |
| **Logs de fluxo VPC** | Telemetria de fluxo de rede |
| **Rastreamentos distribuídos** | Cadeias de requisições multi-serviço |

---

## Exploração #1 — Logs via ES|QL

1. Na aba **Elastic Serverless** → **Discover**
2. Mude para o modo **ES|QL** (botão no canto superior esquerdo)
3. Execute esta consulta:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 5 MINUTES
| KEEP service.name, body.text, severity_text, @timestamp
| SORT @timestamp DESC
| LIMIT 50
```

Confirme que os dados estão fluindo e filtre apenas erros:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS error_count = COUNT(*) BY service.name
| SORT error_count DESC
```

---

## Exploração #2 — APM / Serviços

1. Na aba **Elastic Serverless** → **Applications → Service inventory**
2. Clique em qualquer serviço para ver latência, throughput e taxa de erros
3. Abra uma transação para ver o **waterfall de rastreamento distribuído**

---

## Exploração #3 — Infraestrutura / Hosts

1. Na aba **Elastic Serverless** → **Observability → Infrastructure**
2. Você verá 3 hosts — um por provedor de nuvem:
   - `claro-aws-core-01` (AWS us-east-1 — Mobile Core e Billing)
   - `claro-gcp-digital-01` (GCP us-central1 — Serviços Digitais)
   - `claro-azure-ops-01` (Azure eastus — Voz, IoT e NOC)
3. Clique em um host para ver métricas de CPU, memória, disco e rede

---

## Exploração #4 — Consultas de Série Temporal com ES|QL

### Saúde do core 5G em uma visão geral
```esql
TS metrics*
| WHERE @timestamp > NOW() - 15 MINUTES
| EVAL minuto = DATE_TRUNC(1 minute, @timestamp)
| STATS
    sessoes_5g     = AVG(mobile_core.active_sessions_5g),
    latencia_pdu   = AVG(mobile_core.pdu_session_latency_ms)
  BY minuto
| SORT minuto DESC
```

### Detectar pico de latência OCS antes que assinantes percebam
```esql
TS metrics*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL minuto = DATE_TRUNC(1 minute, @timestamp)
| STATS latencia_ocs = AVG(billing_engine.ocs_ccr_latency_ms) BY minuto
| EVAL status = CASE(
    latencia_ocs > 2000, "🔴 CRÍTICO — Assinantes pré-pagos bloqueados",
    latencia_ocs > 500,  "🟡 DEGRADADO — OCS respondendo lentamente",
    "🟢 SAUDÁVEL"
  )
| SORT minuto DESC
```

---

## Exploração #5 — Dashboards

O implantador criou um **Dashboard Executivo** pré-configurado para o seu cenário:

**Aba Elastic Serverless** → **Dashboards** → pesquise "Claro" (ou "Executive")

✅ **Pronto para continuar quando** você tiver visto logs, rastreamentos ou métricas no Elastic Serverless e confirmado que os serviços estão saudáveis.

</details>
