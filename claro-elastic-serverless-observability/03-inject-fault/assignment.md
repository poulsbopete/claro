---
slug: inject-fault
id: x0nxmlapbpyo
type: challenge
title: Inject a Fault and Watch Elastic Detect It
teaser: Use the incident simulator to inject a realistic multi-cloud fault and watch
  Elastic's ES|QL alert rules and AI agent fire within seconds.
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
    ## Lab 3 — Inject a Fault and Watch Elastic Detect It

    **By the end of this challenge you will:**

    - ✅ Trigger a realistic fault using the Demo App Chaos controller
    - ✅ Watch the error spike appear in Elastic's log stream within seconds
    - ✅ See an ES|QL alert rule fire within 30–60 seconds
    - ✅ Observe the AI agent begin its investigation automatically

    **You have 20 fault channels to choose from** — each simulates a realistic incident across AWS, GCP, and Azure services. Pick any one and watch Elastic light up.

    ***

    🇧🇷 **Lab 3 — Injetar uma Falha e Ver o Elastic Detectá-la**

    **Ao final deste desafio você irá:**

    - ✅ Acionar uma falha realista usando o controlador de Chaos do Demo App
    - ✅ Ver o pico de erros aparecer no stream de logs do Elastic em segundos
    - ✅ Ver uma regra de alerta ES|QL disparar em 30–60 segundos
    - ✅ Observar o agente de IA iniciar sua investigação automaticamente

    **Você tem 20 canais de falha para escolher** — cada um simula um incidente realista nos serviços AWS, GCP e Azure. Escolha qualquer um e veja o Elastic acender.
- type: text
  contents: |
    ## How Fault Detection Works

    Every fault channel is monitored by a dedicated **ES|QL alert rule** running on a 30-second schedule:

    ```
    FROM logs*
    | WHERE @timestamp > NOW() - 2 MINUTES
    | WHERE body.text : "MacAddressFlappingException"
    | STATS error_count = COUNT(*)
    | WHERE error_count > 5
    ```

    When errors exceed the threshold:
    1. The alert fires and appears in **Observability → Alerts**
    2. The alert triggers the **Significant Event Notification** workflow
    3. The workflow calls the **AI agent** with the error context
    4. The agent queries logs, correlates signals, and produces a root-cause analysis

    ***

    🇧🇷 **Como a Detecção de Falhas Funciona**

    Cada canal de falha é monitorado por uma **regra de alerta ES|QL** dedicada, executada a cada 30 segundos:

    ```
    FROM logs*
    | WHERE @timestamp > NOW() - 2 MINUTES
    | WHERE body.text : "MacAddressFlappingException"
    | STATS error_count = COUNT()
    | WHERE error_count > 5
    ```

    Quando os erros excedem o limite:
    1. O alerta dispara e aparece em **Observability → Alerts**
    2. O alerta aciona o workflow **Significant Event Notification**
    3. O workflow chama o **agente de IA** com o contexto do erro
    4. O agente consulta logs, correlaciona sinais e produz uma análise de causa raiz
- type: text
  contents: |
    ## Fault Cascade: Why Observability Is Hard

    A single fault channel doesn't just affect one service — it cascades:

    | Step | What happens |
    |------|-------------|
    | **1** | Primary service emits `ERROR` logs with a specific exception type |
    | **2** | Downstream services emit `WARN` — degraded upstream responses |
    | **3** | Trace spans show elevated latency at integration boundaries |
    | **4** | Host metrics spike on the affected cloud provider |

    This cascade across logs, metrics, and traces is what makes incidents hard to diagnose manually — and what makes Elastic's correlated view so powerful.

    ***

    🇧🇷 **Cascata de Falhas: Por Que Observabilidade é Difícil**

    Um único canal de falha não afeta apenas um serviço — ele cria uma cascata:

    | Etapa | O que acontece |
    |-------|---------------|
    | **1** | Serviço primário emite logs `ERROR` com um tipo específico de exceção |
    | **2** | Serviços downstream emitem `WARN` — respostas upstream degradadas |
    | **3** | Spans de rastreamento mostram latência elevada nos limites de integração |
    | **4** | Métricas do host sobem no provedor de nuvem afetado |

    Essa cascata entre logs, métricas e rastreamentos é o que torna incidentes difíceis de diagnosticar manualmente — e o que torna a visão correlacionada do Elastic tão poderosa.
- type: text
  contents: |
    ## 20 Fault Channels — Pick One

    | Category | Cloud | Example Faults |
    |----------|-------|---------------|
    | **Mobile Core** | AWS | 5G SA session failure, LTE X2 handover storm, DNS/NRF failure |
    | **Billing & Charging** | AWS | CDR mediation backlog, OCS Diameter Gy failure, real-time fraud spike |
    | **Messaging** | AWS | SMSC queue overflow, SMPP bind failures |
    | **Digital Services** | GCP | Customer portal auth cascade, self-care API rate limit |
    | **CDN & Video** | GCP | CDN cache purge storm, video transcoding pipeline stall |
    | **Analytics** | GCP | Network analytics pipeline lag, DPI classification failure |
    | **Voice & IoT** | Azure | SIP trunk saturation, IMS registration storm, MQTT broker overload |
    | **Operations** | Azure | NOC alert storm, BGP route flap |

    Start with **Channel 1 — 5G SA Core Session Failure** for the clearest end-to-end telecom demo.

    ***

    🇧🇷 **20 Canais de Falha — Escolha Um**

    | Categoria | Nuvem | Exemplos de Falhas |
    |-----------|-------|-------------------|
    | **Mobile Core** | AWS | Falha de sessão 5G SA, tempestade de handover LTE X2, falha DNS/NRF |
    | **Cobrança** | AWS | Backlog de mediação CDR, falha OCS Diameter Gy, pico de fraude em tempo real |
    | **Mensagens** | AWS | Overflow de fila SMSC, falhas de bind SMPP |
    | **Serviços Digitais** | GCP | Cascata de auth do portal, limite de taxa da API self-care |
    | **CDN e Vídeo** | GCP | Tempestade de purge de cache CDN, stall do pipeline de transcodificação |
    | **Analytics** | GCP | Lag do pipeline de analytics de rede, falha de classificação DPI |
    | **Voz e IoT** | Azure | Saturação de trunk SIP, tempestade de registro IMS, sobrecarga do broker MQTT |
    | **Operações** | Azure | Tempestade de alertas NOC, flap de rota BGP |

    Comece com o **Canal 1 — 5G SA Core Session Failure** para a demonstração telecom mais clara de ponta a ponta.
tabs:
- id: tue0oby8caoi
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: 4bawzkethfme
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
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

# Inject a Fault and Watch Elastic Detect It

Trigger a fault from the **Demo App**, then watch Elastic automatically investigate and create a case — no human intervention required.

---

## Step 1 — Inject a Fault

1. Open the **Chaos Controller** tab
2. Select any fault channel and click **Inject Fault**

> **Recommended:** Start with **Channel 1 — 5G SA Core Session Failure** for the clearest end-to-end telecom demo.

While the fault propagates, run this query in **Elastic Serverless → Discover → ES|QL** to watch the error spike in real time:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS errors = COUNT(*) BY service.name
| SORT errors DESC
```

> **Tip:** Re-run this every 30 seconds after injecting the fault — you'll see the affected service's error count climb while all other services stay flat.

---

## Step 2 — Watch the Workflow Run

In the **Elastic Serverless** tab, go to **Observability → Workflows**.

Within 1–2 minutes of injecting the fault, the **Claro NOC Significant Event Notification** workflow will show a recent execution. Click it to see each step:

- **count_errors** — ES|QL query counting recent errors from the affected service
- **run_rca** — AI agent root-cause analysis
- **create_case** — Kibana case created with RCA findings

Click **View Full Conversation** to open the AI agent's complete chat thread — you can see exactly what it queried, what it found, and why it drew its conclusions. You can even type follow-up questions or ask the agent to take a remediation action.

---

## Step 3 — Review the Case

Go to **Observability → Cases** (or click **Cases** in the left nav).

A new case will appear automatically with:
- The fault name and affected service in the title
- The AI agent's root-cause analysis in the description
- Severity set to **High**

✅ **Ready to continue when** you can see a workflow execution and an auto-created case in Elastic Serverless.

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Injetar uma Falha e Ver o Elastic Detectá-la

Acione uma falha no **Demo App** e observe o Elastic investigar e criar um caso automaticamente — sem intervenção humana.

---

## Passo 1 — Injetar uma Falha

1. Abra a aba **Chaos Controller**
2. Selecione qualquer canal de falha e clique em **Inject Fault**

> **Recomendado:** Comece com o **Canal 1 — 5G SA Core Session Failure** para a demonstração telecom mais clara de ponta a ponta.

Enquanto a falha se propaga, execute esta consulta em **Elastic Serverless → Discover → ES|QL** para acompanhar o pico de erros em tempo real:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS errors = COUNT(*) BY service.name
| SORT errors DESC
```

> **Dica:** Reexecute a cada 30 segundos após injetar a falha — você verá a contagem de erros do serviço afetado subir enquanto todos os outros permanecem estáveis.

---

## Passo 2 — Acompanhar a Execução do Workflow

Na aba **Elastic Serverless**, vá para **Observability → Workflows**.

Em 1–2 minutos após injetar a falha, o workflow **Claro NOC Significant Event Notification** mostrará uma execução recente. Clique nela para ver cada etapa:

- **count_errors** — consulta ES|QL contando erros recentes do serviço afetado
- **run_rca** — análise de causa raiz pelo agente de IA
- **create_case** — caso Kibana criado com as descobertas da RCA

Clique em **View Full Conversation** para abrir o histórico completo do agente de IA — você pode ver exatamente o que ele consultou, o que encontrou e por que chegou às suas conclusões. Você também pode digitar perguntas adicionais ou pedir ao agente que execute uma ação de remediação.

---

## Passo 3 — Revisar o Caso

Vá para **Observability → Cases** (ou clique em **Cases** na navegação lateral).

Um novo caso aparecerá automaticamente com:
- O nome da falha e o serviço afetado no título
- A análise de causa raiz do agente de IA na descrição
- Severidade definida como **Alta**

✅ **Pronto para continuar quando** você conseguir ver uma execução de workflow e um caso criado automaticamente no Elastic Serverless.

</details>
