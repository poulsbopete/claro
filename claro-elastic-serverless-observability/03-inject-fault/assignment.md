---
slug: inject-fault
id: x0nxmlapbpyo
type: challenge
title: Inject a Fault and Watch Elastic Detect It
teaser: Use the incident simulator to inject a realistic multi-cloud fault and watch
  Elastic's ES|QL alert rules and AI agent fire within seconds.
notes:
- type: text
  contents: "## Workshop Slides\n\nFollow along with the full presentation:\n\n**[→
    Open Workshop Slides](https://poulsbopete.github.io/claro/)**\n\n*(Opens in a
    new tab)*\n\n***\n\n\U0001F1E7\U0001F1F7 **[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**\n\n*(Abre
    em uma nova aba)*\n"
- type: text
  contents: "## Lab 3 — Inject a Fault and Watch Elastic Detect It\n\n**By the end
    of this challenge you will:**\n\n- ✅ Trigger a realistic fault using the Demo
    App Chaos controller\n- ✅ Watch the error spike appear in Elastic's log stream
    within seconds\n- ✅ See an ES|QL alert rule fire within 30–60 seconds\n- ✅ Observe
    the AI agent begin its investigation automatically\n\n**You have 20 fault channels
    to choose from** — each simulates a realistic incident across AWS, GCP, and Azure
    services. Pick any one and watch Elastic light up.\n\n***\n\n\U0001F1E7\U0001F1F7
    **Lab 3 — Injetar uma Falha e Ver o Elastic Detectá-la**\n\n**Ao final deste desafio
    você irá:**\n\n- ✅ Acionar uma falha realista usando o controlador de Chaos do
    Demo App\n- ✅ Ver o pico de erros aparecer no stream de logs do Elastic em segundos\n-
    ✅ Ver uma regra de alerta ES|QL disparar em 30–60 segundos\n- ✅ Observar o agente
    de IA iniciar sua investigação automaticamente\n\n**Você tem 20 canais de falha
    para escolher** — cada um simula um incidente realista nos serviços AWS, GCP e
    Azure. Escolha qualquer um e veja o Elastic acender.\n"
- type: text
  contents: "## How Fault Detection Works\n\nEvery fault channel is monitored by a
    dedicated **ES|QL alert rule** running on a 30-second schedule:\n\n```\nFROM logs*\n|
    WHERE @timestamp > NOW() - 2 MINUTES\n| WHERE body.text : \"MacAddressFlappingException\"\n|
    STATS error_count = COUNT(*)\n| WHERE error_count > 5\n```\n\nWhen errors exceed
    the threshold:\n1. The alert fires and appears in **Observability → Alerts**\n2.
    The alert triggers the **Significant Event Notification** workflow\n3. The workflow
    calls the **AI agent** with the error context\n4. The agent queries logs, correlates
    signals, and produces a root-cause analysis\n\n***\n\n\U0001F1E7\U0001F1F7 **Como
    a Detecção de Falhas Funciona**\n\nCada canal de falha é monitorado por uma **regra
    de alerta ES|QL** dedicada, executada a cada 30 segundos:\n\n```\nFROM logs*\n|
    WHERE @timestamp > NOW() - 2 MINUTES\n| WHERE body.text : \"MacAddressFlappingException\"\n|
    STATS error_count = COUNT()\n| WHERE error_count > 5\n```\n\nQuando os erros excedem
    o limite:\n1. O alerta dispara e aparece em **Observability → Alerts**\n2. O alerta
    aciona o workflow **Significant Event Notification**\n3. O workflow chama o **agente
    de IA** com o contexto do erro\n4. O agente consulta logs, correlaciona sinais
    e produz uma análise de causa raiz\n"
- type: text
  contents: "## Fault Cascade: Why Observability Is Hard\n\nA single fault channel
    doesn't just affect one service — it cascades:\n\n| Step | What happens |\n|------|-------------|\n|
    **1** | Primary service emits `ERROR` logs with a specific exception type |\n|
    **2** | Downstream services emit `WARN` — degraded upstream responses |\n| **3**
    | Trace spans show elevated latency at integration boundaries |\n| **4** | Host
    metrics spike on the affected cloud provider |\n\nThis cascade across logs, metrics,
    and traces is what makes incidents hard to diagnose manually — and what makes
    Elastic's correlated view so powerful.\n\n***\n\n\U0001F1E7\U0001F1F7 **Cascata
    de Falhas: Por Que Observabilidade é Difícil**\n\nUm único canal de falha não
    afeta apenas um serviço — ele cria uma cascata:\n\n| Etapa | O que acontece |\n|-------|---------------|\n|
    **1** | Serviço primário emite logs `ERROR` com um tipo específico de exceção
    |\n| **2** | Serviços downstream emitem `WARN` — respostas upstream degradadas
    |\n| **3** | Spans de rastreamento mostram latência elevada nos limites de integração
    |\n| **4** | Métricas do host sobem no provedor de nuvem afetado |\n\nEssa cascata
    entre logs, métricas e rastreamentos é o que torna incidentes difíceis de diagnosticar
    manualmente — e o que torna a visão correlacionada do Elastic tão poderosa.\n"
- type: text
  contents: "## 20 Fault Channels — Pick One\n\n| Category | Cloud | Example Faults
    |\n|----------|-------|---------------|\n| **Mobile Core** | AWS | 5G SA session
    failure, LTE X2 handover storm, DNS/NRF failure |\n| **Billing & Charging** |
    AWS | CDR mediation backlog, OCS Diameter Gy failure, real-time fraud spike |\n|
    **Messaging** | AWS | SMSC queue overflow, SMPP bind failures |\n| **Digital Services**
    | GCP | Customer portal auth cascade, self-care API rate limit |\n| **CDN & Video**
    | GCP | CDN cache purge storm, video transcoding pipeline stall |\n| **Analytics**
    | GCP | Network analytics pipeline lag, DPI classification failure |\n| **Voice
    & IoT** | Azure | SIP trunk saturation, IMS registration storm, MQTT broker overload
    |\n| **Operations** | Azure | NOC alert storm, BGP route flap |\n\nStart with
    **Channel 1 — 5G SA Core Session Failure** for the clearest end-to-end telecom
    demo.\n\n***\n\n\U0001F1E7\U0001F1F7 **20 Canais de Falha — Escolha Um**\n\n|
    Categoria | Nuvem | Exemplos de Falhas |\n|-----------|-------|-------------------|\n|
    **Mobile Core** | AWS | Falha de sessão 5G SA, tempestade de handover LTE X2,
    falha DNS/NRF |\n| **Cobrança** | AWS | Backlog de mediação CDR, falha OCS Diameter
    Gy, pico de fraude em tempo real |\n| **Mensagens** | AWS | Overflow de fila SMSC,
    falhas de bind SMPP |\n| **Serviços Digitais** | GCP | Cascata de auth do portal,
    limite de taxa da API self-care |\n| **CDN e Vídeo** | GCP | Tempestade de purge
    de cache CDN, stall do pipeline de transcodificação |\n| **Analytics** | GCP |
    Lag do pipeline de analytics de rede, falha de classificação DPI |\n| **Voz e
    IoT** | Azure | Saturação de trunk SIP, tempestade de registro IMS, sobrecarga
    do broker MQTT |\n| **Operações** | Azure | Tempestade de alertas NOC, flap de
    rota BGP |\n\nComece com o **Canal 1 — 5G SA Core Session Failure** para a demonstração
    telecom mais clara de ponta a ponta.\n"
tabs:
- id: tue0oby8caoi
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: ochrymzhghlz
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: zdzv5jniehhj
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/discover#/?_a=(columns:!(service.name,severity_text,body.text),index:logs.otel,interval:auto,query:(esql:'FROM+logs.otel%2Clogs.otel.*+%7C+WHERE+%40timestamp+>+NOW()+-+30+minutes+%7C+WHERE+severity_text+%3D%3D+%22ERROR%22+%7C+KEEP+service.name%2C+body.text%2C+severity_text%2C+%40timestamp+%7C+SORT+%40timestamp+DESC+%7C+LIMIT+50',language:esql),sort:!(!('@timestamp',desc)))&_g=(filters:!(),refreshInterval:(pause:!f,value:10000),time:(from:now-30m,to:now))
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

# Inject a Fault — Watch Elastic Detect It

Open the **Chaos Controller** tab, pick a fault channel, and watch Elastic surface the incident in real time.

---

## Step 1 — Inject a Fault

1. Click the **Chaos Controller** tab
2. Select any fault channel from the dropdown — **CH-01: 5G SA Core Session Failure** gives the clearest telecom story
3. Choose a fault mode (Calibration Drift is the default)
4. Click **INJECT FAULT** — you'll see it appear immediately in the **Active Channels** panel on the right

> The fault is now generating error logs across the affected services at a rate that will trigger the ES|QL alert rule within 30–60 seconds.

---

## Step 2 — Watch the Error Spike in Discover

Click the **Elastic Serverless** tab — it opens directly into a live ES|QL query showing ERROR logs from the last 30 minutes.

Watch the error count climb for the affected service. Re-run the query every 30 seconds:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS errors = COUNT(*) BY service.name
| SORT errors DESC
```

> **What you're seeing:** Every fault channel generates errors with a specific exception type (e.g. `5G-SESSION-FAIL`) across the primary service and its downstream dependents — all captured in a single Elasticsearch datastore, queryable instantly with ES|QL. In Splunk, these logs and APM traces live in two separate products.

---

## Step 3 — Watch the Alert Fire

Navigate to **Observability → Alerts** in the left nav.

Within 30–60 seconds of injecting the fault, an alert will appear — the ES|QL rule detected the error spike and fired. The alert shows:
- Which service is affected
- When the threshold was breached
- Severity level

> **What happens next:** This alert automatically triggers the **Claro NOC Significant Event Notification** workflow — which is what you'll explore in the next challenge.

✅ **Ready to continue when** you see an active alert in Observability → Alerts.

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Injetar uma Falha — Ver o Elastic Detectar

Abra a aba **Chaos Controller**, escolha um canal de falha e veja o Elastic identificar o incidente em tempo real.

---

## Passo 1 — Injetar uma Falha

1. Clique na aba **Chaos Controller**
2. Selecione qualquer canal de falha — **CH-01: 5G SA Core Session Failure** é o mais claro
3. Escolha um modo de falha (Calibration Drift é o padrão)
4. Clique em **INJECT FAULT** — a falha aparece imediatamente no painel **Active Channels**

> A falha está gerando logs de erro nos serviços afetados a uma taxa que acionará a regra de alerta ES|QL em 30–60 segundos.

---

## Passo 2 — Ver o Pico de Erros no Discover

Clique na aba **Elastic Serverless** — ela abre diretamente em uma consulta ES|QL ao vivo mostrando logs ERROR dos últimos 30 minutos.

Observe a contagem de erros subir para o serviço afetado. Reexecute a consulta a cada 30 segundos:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS errors = COUNT(*) BY service.name
| SORT errors DESC
```

> **O que você está vendo:** Cada canal de falha gera erros com um tipo específico de exceção em todo o serviço primário e seus dependentes — tudo capturado em um único armazenamento Elasticsearch, consultável instantaneamente com ES|QL.

---

## Passo 3 — Ver o Alerta Disparar

Navegue para **Observability → Alerts** na navegação esquerda.

Em 30–60 segundos após injetar a falha, um alerta aparecerá — a regra ES|QL detectou o pico de erros. O alerta mostra:
- Qual serviço está afetado
- Quando o limite foi ultrapassado
- Nível de severidade

> **O que acontece a seguir:** Este alerta aciona automaticamente o workflow **Claro NOC Significant Event Notification** — o que você vai explorar no próximo desafio.

✅ **Pronto para continuar quando** você ver um alerta ativo em Observability → Alerts.

</details>
