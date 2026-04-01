---
slug: architectural-unity
id: u3xhamtxcv1b
type: challenge
title: 'Competitive Edge 1: Architectural Unity — One Platform, Zero Context Switches'
teaser: Pivot from an APM trace span to its correlated log line in one click — no
  second product, no copied trace IDs, no context switching.
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
- id: uoxzjbzmibqg
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
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
  path: /app/apm/services
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

# Competitive Edge 1: Architectural Unity

Nine Claro microservices are continuously generating **real** OpenTelemetry traces and logs — all flowing into the same Elasticsearch datastore. In this challenge you'll pivot from a live APM trace directly to its correlated log line without switching tools, tabs, or query languages.

---

## Step 1: Find High-Error Services with ES|QL

Open the **Elastic Serverless** tab → **Discover** → switch to **ES|QL** mode, and run:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS errors = COUNT(*) BY service.name
| SORT errors DESC
| LIMIT 10
```

> You'll see all 9 Claro services ranked by error count. Services with active chaos faults will show dramatically higher numbers — but every service is emitting errors at a background rate, giving you real data to explore.

---

## Step 2: Grab a Trace ID from a Failing Log

Find an ERROR log that has a `trace.id` — this is the link that connects logs to traces:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 5 MINUTES
| WHERE severity_text == "ERROR" AND trace.id IS NOT NULL
| KEEP service.name, body.text, trace.id, @timestamp
| SORT @timestamp DESC
| LIMIT 5
```

Copy the `trace.id` value from any row (a 32-character hex string like `4bf92f3577b34da6a3ce929d0e0e4736`).

---

## Step 3: Pivot to All Correlated Logs — The Elastic Way

Paste your `trace.id` into this query to see **every log line from that same request**, across all services involved:

```esql
FROM logs.otel, logs.otel.*
| WHERE trace.id == "<paste-your-trace-id-here>"
| KEEP @timestamp, service.name, severity_text, body.text
| SORT @timestamp ASC
```

> **In Splunk:** You are now on your second product (Splunk Cloud), running a second search in SPL, in a different browser tab, hoping the log retention window matches.
>
> **In Elastic:** Same ES|QL, same datastore, same session. **One platform. Zero context switching.**

---

## Step 4: See Native APM ↔ Log Correlation in Kibana

No query needed — Kibana does this automatically:

1. In the **Elastic Serverless** tab go to **Applications → Service inventory**
2. Click any service — for example **mobile-core** or **billing-engine**
3. Click any **transaction** to open the trace waterfall
4. Click the **Logs** tab at the top of the trace detail panel

Kibana automatically shows every log line correlated to that trace via the shared `trace.id` field — no configuration, no copy-paste, no second product.

---

## ✅ Complete When:

- [ ] Your ES|QL error query shows Claro services ranked by error rate
- [ ] You retrieved a `trace.id` from a failing log entry
- [ ] You queried all logs for that trace with a single ES|QL statement
- [ ] You clicked the **Logs** tab inside an APM trace detail — one click, no product switch

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Diferencial Competitivo 1: Unidade Arquitetônica

Nove microsserviços da Claro estão gerando continuamente rastreamentos e logs **reais** via OpenTelemetry — todos fluindo para o mesmo armazenamento Elasticsearch. Neste desafio você irá do rastreamento APM em tempo real diretamente para sua linha de log correlacionada sem trocar de ferramenta, aba ou linguagem de consulta.

---

## Passo 1: Encontrar Serviços com Mais Erros via ES|QL

Abra a aba **Elastic Serverless** → **Discover** → mude para o modo **ES|QL** e execute:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS errors = COUNT(*) BY service.name
| SORT errors DESC
| LIMIT 10
```

> Você verá todos os 9 serviços da Claro classificados por contagem de erros. Serviços com falhas ativas de chaos mostrarão números muito maiores.

---

## Passo 2: Obter um Trace ID de um Log com Falha

Encontre um log de ERRO que tenha um `trace.id` — este é o elo que conecta logs a rastreamentos:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 5 MINUTES
| WHERE severity_text == "ERROR" AND trace.id IS NOT NULL
| KEEP service.name, body.text, trace.id, @timestamp
| SORT @timestamp DESC
| LIMIT 5
```

Copie o valor de `trace.id` de qualquer linha (uma string hexadecimal de 32 caracteres).

---

## Passo 3: Pivotar para Todos os Logs Correlacionados — O Jeito Elastic

Cole seu `trace.id` nesta consulta para ver **todas as linhas de log dessa mesma requisição**, em todos os serviços envolvidos:

```esql
FROM logs.otel, logs.otel.*
| WHERE trace.id == "<cole-seu-trace-id-aqui>"
| KEEP @timestamp, service.name, severity_text, body.text
| SORT @timestamp ASC
```

> **No Splunk:** Você está agora em um segundo produto (Splunk Cloud), executando uma segunda pesquisa em SPL, em outra aba do navegador, torcendo para que a janela de retenção de logs corresponda.
>
> **No Elastic:** Mesmo ES|QL, mesmo armazenamento, mesma sessão. **Uma plataforma. Zero troca de contexto.**

---

## Passo 4: Ver a Correlação Nativa APM ↔ Log no Kibana

Nenhuma consulta necessária — o Kibana faz isso automaticamente:

1. Na aba **Elastic Serverless** vá para **Applications → Service inventory**
2. Clique em qualquer serviço — por exemplo **mobile-core** ou **billing-engine**
3. Clique em qualquer **transação** para abrir o waterfall de rastreamento
4. Clique na aba **Logs** no topo do painel de detalhes do rastreamento

O Kibana mostra automaticamente todas as linhas de log correlacionadas ao rastreamento via o campo `trace.id` compartilhado — sem configuração, sem copiar e colar, sem segundo produto.

---

## ✅ Concluído Quando:

- [ ] Sua consulta ES|QL de erros mostra os serviços da Claro classificados por taxa de erros
- [ ] Você obteve um `trace.id` de uma entrada de log com falha
- [ ] Você consultou todos os logs desse rastreamento com uma única instrução ES|QL
- [ ] Você clicou na aba **Logs** dentro de um detalhe de rastreamento APM — um clique, sem troca de produto

</details>
