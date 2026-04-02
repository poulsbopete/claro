---
slug: architectural-unity
id: u3xhamtxcv1b
type: challenge
title: 'AI Response: Watch Elastic Investigate and Resolve the Fault'
teaser: Watch the Significant Event Notification workflow run the AI agent for root-cause
  analysis, review the auto-created case, then resolve the fault and verify it clears.
notes:
- type: text
  contents: "## Workshop Slides\n\nFollow along with the full presentation:\n\n**[→
    Open Workshop Slides](https://poulsbopete.github.io/claro/)**\n\n*(Opens in a
    new tab)*\n\n***\n\n\U0001F1E7\U0001F1F7 **[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**\n\n*(Abre
    em uma nova aba)*\n"
- type: text
  contents: "## Why Splunk Forces Context Switches\n\nIn Splunk, **logs live in Splunk
    Cloud** and **APM traces live in Splunk Observability Cloud** — two separate backends,
    two billing contracts, two query languages (SPL and SignalFlow).\n\nTo correlate
    a trace to a log, a Splunk operator must:\n1. Copy a trace ID from Splunk Observability
    Cloud\n2. Open a second browser tab, navigate to Splunk Cloud\n3. Run a second
    SPL search using that trace ID\n4. Hope the log was indexed in the same time window\n\n**Elastic
    stores logs, metrics, and traces in a single Elasticsearch datastore.** The shared
    `trace.id` field links every signal together, and Kibana surfaces them all without
    leaving your context.\n\n***\n\n\U0001F1E7\U0001F1F7 **Por Que o Splunk Força
    Trocas de Contexto**\n\nNo Splunk, **logs ficam no Splunk Cloud** e **rastreamentos
    APM ficam no Splunk Observability Cloud** — dois backends separados, dois contratos
    de cobrança, duas linguagens de consulta (SPL e SignalFlow).\n\nPara correlacionar
    um rastreamento a um log, um operador Splunk precisa:\n1. Copiar um trace ID do
    Splunk Observability Cloud\n2. Abrir uma segunda aba do navegador e navegar para
    o Splunk Cloud\n3. Executar uma segunda pesquisa SPL usando esse trace ID\n4.
    Torcer para que o log tenha sido indexado na mesma janela de tempo\n\n**O Elastic
    armazena logs, métricas e rastreamentos em um único armazenamento Elasticsearch.**
    O campo `trace.id` compartilhado vincula todos os sinais, e o Kibana os apresenta
    sem sair do contexto.\n"
- type: text
  contents: "## The Elastic Architecture Advantage\n\n| Capability | Elastic | Splunk
    |\n|------------|---------|--------|\n| Traces + Logs in one datastore | ✅ Elasticsearch
    | ❌ Two products |\n| Shared correlation field | ✅ `trace.id` everywhere | ❌ Manual
    copy-paste |\n| Single query language | ✅ ES\\|QL | ❌ SPL (logs) + SignalFlow
    (APM) |\n| One billing contract | ✅ | ❌ Splunk Cloud + Splunk OC |\n\n> When your
    on-call engineer gets paged at 2 AM, **context switches cost resolution time**.
    Elastic's architectural unity eliminates that tax entirely.\n\n***\n\n\U0001F1E7\U0001F1F7
    **A Vantagem Arquitetônica do Elastic**\n\n| Capacidade | Elastic | Splunk |\n|------------|---------|--------|\n|
    Rastreamentos + Logs em um armazenamento | ✅ Elasticsearch | ❌ Dois produtos |\n|
    Campo de correlação compartilhado | ✅ `trace.id` em todo lugar | ❌ Copiar e colar
    manual |\n| Linguagem de consulta única | ✅ ES\\|QL | ❌ SPL (logs) + SignalFlow
    (APM) |\n| Um contrato de cobrança | ✅ | ❌ Splunk Cloud + Splunk OC |\n\n> Quando
    seu engenheiro de plantão é acionado às 2h da manhã, **trocas de contexto custam
    tempo de resolução**. A unidade arquitetônica do Elastic elimina completamente
    esse custo.\n"
tabs:
- id: mrvpkb0obqmz
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: 6gcwxgihaixs
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: 35cseanknkdw
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/workflows
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
timelimit: 2700
enhanced_loading: null
---

# AI Response: Investigate and Resolve

The alert you saw in the previous challenge automatically triggered an AI-powered workflow. Let's watch it run and close the incident.

---

## Step 1 — Watch the Workflow Execute

Click the **Elastic Serverless** tab — it opens directly on **Observability → Workflows**.

Find the **Claro Network Operations Center Significant Event Notification** workflow and click the most recent execution. You'll see the steps running in real time:

| Step | What it does | Typical time |
|------|-------------|-------------|
| `enrich_context` | ES|QL query — finds log lines matching the error type | < 1 sec |
| `count_errors` | ES|QL query — counts total errors in last 15 minutes | < 1 sec |
| `run_rca` | AI agent — searches logs, traces, correlates signals, writes RCA | ~1–2 min |
| `create_case` | Creates a Kibana case with the RCA as the description | < 1 sec |
| `audit_log` | Writes a record to the significant-events index | < 1 sec |

> **The Elastic difference:** This entire chain — alert → workflow → AI agent → case — runs on a single platform. In Splunk, alerting (Splunk Cloud), AI (Splunk AI Assistant), and case management (ITSM connector) are all separate products with separate configurations.

---

## Step 2 — Read the AI's Root Cause Analysis

Once `run_rca` completes, go to **Observability → Cases** in the left nav.

A new case will be there automatically, titled **"Claro Network Operations Center RCA: [alert name]"**. Open it to see:
- Which service failed and why
- Which downstream services were affected
- What the AI recommends as a remediation step

Click **View Conversation** to open the AI agent's full chat thread — you can ask follow-up questions directly in Kibana.

---

## Step 3 — Resolve the Fault

Go back to the **Chaos Controller** tab.

In the **Active Channels** panel, find the fault you injected and click **RESOLVE**. The channel immediately returns to **STANDBY**.

> **Note:** Auto-remediation via the workflow is not enabled in this environment. Click **RESOLVE** manually in the Chaos Controller to close the incident — this represents the NOC operator acting on the AI's recommendation.

---

## Step 4 — Verify Resolution

The channel card in the Active Channels panel disappears and the channel status returns to **STANDBY**.

In **Elastic Serverless → Observability → Alerts**, the alert will auto-recover once the ES|QL rule no longer detects errors above threshold — typically within 1–2 minutes of resolving the fault.

✅ **Ready to continue when** the Chaos Controller shows the channel back at STANDBY.

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Resposta da IA: Investigar e Resolver

O alerta que você viu no desafio anterior acionou automaticamente um workflow com IA. Vamos acompanhá-lo e fechar o incidente.

---

## Passo 1 — Ver o Workflow Executar

Clique na aba **Elastic Serverless** — ela abre diretamente em **Observability → Workflows**.

Encontre o workflow **Claro Network Operations Center Significant Event Notification** e clique na execução mais recente. Você verá as etapas rodando em tempo real:

| Etapa | O que faz | Tempo típico |
|-------|-----------|-------------|
| `enrich_context` | Consulta ES|QL — encontra logs correspondentes ao tipo de erro | < 1 seg |
| `count_errors` | Consulta ES|QL — conta erros totais nos últimos 15 minutos | < 1 seg |
| `run_rca` | Agente IA — pesquisa logs, rastreamentos, correlaciona sinais, escreve RCA | ~1–2 min |
| `create_case` | Cria um caso no Kibana com o RCA como descrição | < 1 seg |
| `audit_log` | Grava um registro no índice de eventos significativos | < 1 seg |

> **A diferença do Elastic:** Toda essa cadeia — alerta → workflow → agente IA → caso — roda em uma única plataforma.

---

## Passo 2 — Ler a Análise de Causa Raiz da IA

Após o `run_rca` concluir, vá para **Observability → Cases**.

Um novo caso estará lá automaticamente. Abra-o para ver:
- Qual serviço falhou e por quê
- Quais serviços downstream foram afetados
- O que a IA recomenda como ação de remediação

Clique em **View Conversation** para abrir o histórico completo do agente IA.

---

## Passo 3 — Resolver a Falha

Volte para a aba **Chaos Controller**.

No painel **Active Channels**, encontre a falha injetada e clique em **RESOLVE**. O canal volta imediatamente para **STANDBY**.

> **Nota:** A remediação automática via workflow não está habilitada neste ambiente. Clique em **RESOLVE** manualmente no Chaos Controller para fechar o incidente.

---

## Passo 4 — Verificar a Resolução

O card do canal desaparece do painel Active Channels e o status volta para **STANDBY**.

Em **Elastic Serverless → Observability → Alerts**, o alerta se recupera automaticamente assim que a regra ES|QL não detecta mais erros acima do limite — geralmente em 1–2 minutos após resolver a falha.

✅ **Pronto para continuar quando** o Chaos Controller mostrar o canal de volta em STANDBY.

</details>
