---
slug: connect-and-deploy
id: fjsfttmxlhvb
type: challenge
title: Connect to Elastic Cloud & Deploy
teaser: Wire the demo platform to your Elastic Cloud project and launch 9 microservices
  sending live OpenTelemetry telemetry.
notes:
- type: text
  contents: |
    ## Lab 1 — Connect to Elastic Cloud & Deploy

    **What's happening right now:**
    Your Elastic Cloud Serverless Observability project is being provisioned and the Claro NOC demo platform is being configured with your credentials.

    **By the end of this challenge you will:**

    - ✅ Confirm the Claro scenario is deployed and sending live telemetry
    - ✅ Open your Elastic Serverless project — no login required
    - ✅ Verify logs, metrics, and traces are flowing from 9 microservices
    - ✅ Review the auto-provisioned AI agent, alert rules, and workflows

    *Setup takes 3–4 minutes. Grab a coffee — it'll be ready soon.*
- type: text
  contents: |
    ## Your Lab Environment

    **Two tabs, everything you need:**

    | Tab | What it is |
    |-----|-----------|
    | **Demo App** | Control panel — view service health, manage deployments, inject faults |
    | **Elastic Serverless** | Your Observability project — pre-logged in, data already flowing |

    **The Claro Network Operations Center scenario simulates 9 microservices across 3 clouds:**

    - ☁️ **AWS** — Mobile Core (5G/4G AMF/SMF/UPF), Billing Engine (OCS/CDR), SMS Gateway (SMSC/SMPP)
    - ☁️ **GCP** — Customer Portal (Mi Claro), Content Delivery (CDN/Claro TV), Network Analytics (DPI/Flink)
    - ☁️ **Azure** — Voice Platform (IMS/SIP), IoT Connect (MQTT/PKI), NOC Dashboard (BGP/Alerts)

    Every service emits **real OpenTelemetry** logs, metrics, and traces — no synthetic data.
- type: text
  contents: |
    ## What Was Auto-Deployed

    When the lab started, the setup script provisioned your full observability stack automatically:

    | Resource | Details |
    |----------|---------|
    | **Alert rules** | 20 ES\|QL rules — one per fault channel, 30s interval |
    | **AI agent** | Investigation tools + system prompt |
    | **Workflows** | Alert → investigate → create case → remediate |
    | **Dashboards** | Executive dashboard + OTel signal dashboards |
    | **Data views** | `logs.otel`, `metrics-*`, `traces-*` |

    This is the same stack you'd deploy in production — configured in code, repeatable, version-controlled.
- type: text
  contents: |
    ## Key Concepts: Elastic Serverless + OpenTelemetry

    **Elastic Serverless** scales compute and storage independently. No cluster management, no shard tuning — just ingest and query.

    **OpenTelemetry (OTel)** is the CNCF standard for vendor-neutral instrumentation. Elastic is a Platinum member and natively ingests OTLP — no Collector required.

    **ES|QL** is Elastic's pipe-based query language, purpose-built for telemetry at scale:

    ```
    FROM logs*
    | WHERE severity_text == "ERROR"
    | STATS errors = COUNT(*) BY service.name
    | SORT errors DESC
    ```

    **AI Workflows** connect alert detection to investigation to remediation — all without human intervention.
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
