---
slug: connect-and-deploy
id: fjsfttmxlhvb
type: challenge
title: Connect to Elastic Cloud & Deploy
teaser: Wire the demo platform to your Elastic Cloud project and launch 9 microservices
  sending live OpenTelemetry telemetry.
notes:
- type: text
  contents: "## Workshop Slides\n\nFollow along with the full presentation while the
    lab sets up:\n\n**[→ Open Workshop Slides](https://poulsbopete.github.io/claro/)**\n\nThe
    slides cover all four competitive differentiators you'll explore in these labs
    — with bilingual English/Portuguese support.\n\n*(Opens in a new tab — come back
    here when setup completes)*\n\n***\n\n\U0001F1E7\U0001F1F7 Acompanhe a apresentação
    completa enquanto o lab é configurado:\n\n**[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**\n\nOs
    slides cobrem os quatro diferenciais competitivos que você explorará nestes labs
    — com suporte bilíngue Inglês/Português.\n\n*(Abre em uma nova aba — volte aqui
    quando a configuração for concluída)*\n"
- type: text
  contents: "## Lab 1 — Connect to Elastic Cloud & Deploy\n\n**What's happening right
    now:**\nYour Elastic Cloud Serverless Observability project is being provisioned
    and the Claro NOC demo platform is being configured with your credentials.\n\n**By
    the end of this challenge you will:**\n\n- ✅ Confirm the Claro scenario is deployed
    and sending live telemetry\n- ✅ Open your Elastic Serverless project — no login
    required\n- ✅ Verify logs, metrics, and traces are flowing from 9 microservices\n-
    ✅ Review the auto-provisioned AI agent, alert rules, and workflows\n\n*Setup takes
    3–4 minutes. Grab a coffee — it'll be ready soon.*\n\n***\n\n\U0001F1E7\U0001F1F7
    **Lab 1 — Conectar ao Elastic Cloud e Implantar**\n\n**O que está acontecendo
    agora:**\nSeu projeto Elastic Cloud Serverless Observability está sendo provisionado
    e a plataforma de demonstração Claro NOC está sendo configurada com suas credenciais.\n\n**Ao
    final deste desafio você irá:**\n\n- ✅ Confirmar que o cenário Claro está implantado
    e enviando telemetria em tempo real\n- ✅ Abrir seu projeto Elastic Serverless
    — sem necessidade de login\n- ✅ Verificar que logs, métricas e rastreamentos estão
    fluindo de 9 microsserviços\n- ✅ Revisar o agente de IA, regras de alerta e workflows
    provisionados automaticamente\n\n*A configuração leva 3–4 minutos. Pegue um café
    — estará pronto em breve.*\n"
- type: text
  contents: "## Your Lab Environment\n\n**Two tabs, everything you need:**\n\n| Tab
    | What it is |\n|-----|-----------|\n| **Demo App** | Control panel — view service
    health, manage deployments, inject faults |\n| **Elastic Serverless** | Your Observability
    project — pre-logged in, data already flowing |\n\n**The Claro Network Operations
    Center scenario simulates 9 microservices across 3 clouds:**\n\n- ☁️ **AWS** —
    Mobile Core (5G/4G AMF/SMF/UPF), Billing Engine (OCS/CDR), SMS Gateway (SMSC/SMPP)\n-
    ☁️ **GCP** — Customer Portal (Mi Claro), Content Delivery (CDN/Claro TV), Network
    Analytics (DPI/Flink)\n- ☁️ **Azure** — Voice Platform (IMS/SIP), IoT Connect
    (MQTT/PKI), NOC Dashboard (BGP/Alerts)\n\nEvery service emits **real OpenTelemetry**
    logs, metrics, and traces — no synthetic data.\n\n***\n\n\U0001F1E7\U0001F1F7
    **Seu Ambiente de Lab**\n\n**Duas abas, tudo o que você precisa:**\n\n| Aba |
    O que é |\n|-----|---------|\n| **Demo App** | Painel de controle — veja saúde
    dos serviços, gerencie implantações, injete falhas |\n| **Elastic Serverless**
    | Seu projeto de Observabilidade — já autenticado, dados já fluindo |\n\n**O cenário
    do Centro de Operações de Rede (NOC) da Claro simula 9 microsserviços em 3 nuvens:**\n\n-
    ☁️ **AWS** — Mobile Core (5G/4G AMF/SMF/UPF), Billing Engine (OCS/CDR), SMS Gateway
    (SMSC/SMPP)\n- ☁️ **GCP** — Customer Portal (Mi Claro), Content Delivery (CDN/Claro
    TV), Network Analytics (DPI/Flink)\n- ☁️ **Azure** — Voice Platform (IMS/SIP),
    IoT Connect (MQTT/PKI), NOC Dashboard (BGP/Alertas)\n\nCada serviço emite logs,
    métricas e rastreamentos **reais via OpenTelemetry** — sem dados sintéticos.\n"
- type: text
  contents: "## What Was Auto-Deployed\n\nWhen the lab started, the setup script provisioned
    your full observability stack automatically:\n\n| Resource | Details |\n|----------|---------|\n|
    **Alert rules** | 20 ES\\|QL rules — one per fault channel, 30s interval |\n|
    **AI agent** | Investigation tools + system prompt |\n| **Workflows** | Alert
    → investigate → create case → remediate |\n| **Dashboards** | Executive dashboard
    + OTel signal dashboards |\n| **Data views** | `logs.otel`, `metrics-*`, `traces-*`
    |\n\nThis is the same stack you'd deploy in production — configured in code, repeatable,
    version-controlled.\n\n***\n\n\U0001F1E7\U0001F1F7 **O Que Foi Implantado Automaticamente**\n\nQuando
    o lab iniciou, o script de configuração provisionou toda a pilha de observabilidade
    automaticamente:\n\n| Recurso | Detalhes |\n|---------|----------|\n| **Regras
    de alerta** | 20 regras ES\\|QL — uma por canal de falha, intervalo de 30s |\n|
    **Agente de IA** | Ferramentas de investigação + prompt do sistema |\n| **Workflows**
    | Alerta → investigar → criar caso → remediar |\n| **Dashboards** | Dashboard
    executivo + dashboards de sinais OTel |\n| **Data views** | `logs.otel`, `metrics-*`,
    `traces-*` |\n\nEsta é a mesma pilha que você implantaria em produção — configurada
    em código, repetível e versionada.\n"
- type: text
  contents: "## Key Concepts: Elastic Serverless + OpenTelemetry\n\n**Elastic Serverless**
    scales compute and storage independently. No cluster management, no shard tuning
    — just ingest and query.\n\n**OpenTelemetry (OTel)** is the CNCF standard for
    vendor-neutral instrumentation. Elastic is a Platinum member and natively ingests
    OTLP — no Collector required.\n\n**ES|QL** is Elastic's pipe-based query language,
    purpose-built for telemetry at scale:\n\n```\nFROM logs*\n| WHERE severity_text
    == \"ERROR\"\n| STATS errors = COUNT(*) BY service.name\n| SORT errors DESC\n```\n\n**AI
    Workflows** connect alert detection to investigation to remediation — all without
    human intervention.\n\n***\n\n\U0001F1E7\U0001F1F7 **Conceitos-chave: Elastic
    Serverless + OpenTelemetry**\n\n**Elastic Serverless** escala computação e armazenamento
    de forma independente. Sem gerenciamento de cluster, sem ajuste de shards — apenas
    ingerir e consultar.\n\n**OpenTelemetry (OTel)** é o padrão CNCF para instrumentação
    agnóstica de fornecedores. A Elastic é membro Platinum e ingere OTLP nativamente
    — sem Collector necessário.\n\n**ES|QL** é a linguagem de consulta baseada em
    pipes da Elastic, criada para telemetria em escala:\n\n```\nFROM logs*\n| WHERE
    severity_text == \"ERROR\"\n| STATS errors = COUNT(*) BY service.name\n| SORT
    errors DESC\n```\n\n**AI Workflows** conectam detecção de alertas à investigação
    e remediação — tudo sem intervenção humana.\n"
- type: text
  contents: "## While You Wait — Play O11y Survivors! \U0001F3AE\n\nSetup takes a
    few minutes. Survive the anomaly storm while Elastic provisions your environment:\n\n<iframe
    src=\"https://poulsbopete.github.io/Vampire-Clone/\" width=\"100%\" height=\"800\"
    frameborder=\"0\" allowfullscreen style=\"border-radius:8px;display:block;\"></iframe>\n"
tabs:
- id: vb4w6je2d07a
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: zlhgq4cdpd3k
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: zc2taxpt1yvo
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: kgxgvk3mwafg
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

# Connect to Elastic Cloud & Deploy

Everything was **automatically provisioned** when this lab started — your Elastic Cloud project is live, 9 microservices are sending telemetry, and the AI observability stack is configured. Nothing to set up.

---

## Explore the Demo App

Use the three Demo App tabs to explore the running scenario:

| Tab | What you'll see |
|-----|----------------|
| **Demo App** | Scenario selector — overview and deployment status |
| **Live Dashboard** | Real-time service health across all 9 microservices |
| **Chaos Controller** | 20 fault channels ready to inject — you'll use this in Lab 3 |

---

## Explore Elastic Serverless

Click the **Elastic Serverless** tab — you're already logged in. Navigate to:

- **Discover → ES|QL** — query live logs from `mobile-core`, `billing-engine`, `sms-gateway`, `customer-portal`, and more
- **Applications → Service inventory** — distributed traces from 9 services
- **Observability → Infrastructure** — 3 simulated hosts (AWS, GCP, Azure)
- **Observability → SLOs** — 27 auto-created SLOs, one per service per signal type
- **Observability → Workflows** — 4 pre-configured AI response workflows

> **Tip:** Set the time range to **Last 15 minutes** to see the freshest data.

---

## What Was Auto-Deployed

| Resource | Details |
|----------|---------|
| Alert rules | 20 ES\|QL rules — one per fault channel, 30s interval |
| AI agent | Investigation tools + system prompt |
| Workflows | Alert → investigate → create case → remediate |
| Dashboards | Executive dashboard + OTel signal dashboards |
| SLOs | 21 SLOs auto-created across all services |
| Data views | `logs.otel`, `logs.otel.*`, `metrics-*` |

✅ **You're ready for the next challenge when** you can see logs, services, or SLOs in the Elastic Serverless tab.

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Conectar ao Elastic Cloud e Implantar

Tudo foi **provisionado automaticamente** quando este lab iniciou — seu projeto Elastic Cloud está ativo, 9 microsserviços estão enviando telemetria e a pilha de observabilidade com IA está configurada. Nada para configurar.

---

## Explorar o Demo App

Use as três abas do Demo App para explorar o cenário em execução:

| Aba | O que você verá |
|-----|----------------|
| **Demo App** | Seletor de cenário — visão geral e status da implantação |
| **Live Dashboard** | Saúde dos serviços em tempo real entre os 9 microsserviços |
| **Chaos Controller** | 20 canais de falha prontos para injeção — você usará isso no Lab 3 |

---

## Explorar o Elastic Serverless

Clique na aba **Elastic Serverless** — você já está autenticado. Navegue para:

- **Discover → ES|QL** — consulte logs em tempo real de `mobile-core`, `billing-engine`, `sms-gateway`, `customer-portal` e mais
- **Applications → Service inventory** — rastreamentos distribuídos de 9 serviços
- **Observability → Infrastructure** — 3 hosts simulados (AWS, GCP, Azure)
- **Observability → SLOs** — 27 SLOs criados automaticamente, um por serviço por tipo de sinal
- **Observability → Workflows** — 4 fluxos de resposta com IA pré-configurados

> **Dica:** Defina o intervalo de tempo para **Últimos 15 minutos** para ver os dados mais recentes.

---

## O Que Foi Implantado Automaticamente

| Recurso | Detalhes |
|---------|---------|
| Regras de alerta | 20 regras ES\|QL — uma por canal de falha, intervalo de 30s |
| Agente de IA | Ferramentas de investigação + prompt do sistema |
| Workflows | Alerta → investigar → criar caso → remediar |
| Dashboards | Dashboard executivo + dashboards de sinais OTel |
| SLOs | 21 SLOs criados automaticamente em todos os serviços |
| Data views | `logs.otel`, `logs.otel.*`, `metrics-*` |

✅ **Você está pronto para o próximo desafio quando** conseguir ver logs, serviços ou SLOs na aba Elastic Serverless.

</details>
