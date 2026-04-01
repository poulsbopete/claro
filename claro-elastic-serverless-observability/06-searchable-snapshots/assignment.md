---
slug: searchable-snapshots
id: krwlj5l6baxp
type: challenge
title: 'Competitive Edge 3: Searchable Snapshots — Audit-Ready Archives, Zero Wait
  Time'
teaser: Query two-year-old audit logs stored in object storage instantly. No rehydration
  jobs. No waiting overnight. No support tickets.
notes:
- type: text
  contents: "## Workshop Slides\n\nFollow along with the full presentation:\n\n**[→
    Open Workshop Slides](https://poulsbopete.github.io/claro/)**\n\n*(Opens in a
    new tab)*\n\n***\n\n\U0001F1E7\U0001F1F7 **[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**\n\n*(Abre
    em uma nova aba)*\n"
- type: text
  contents: "## The Splunk DDAA Problem vs Elastic Serverless\n\nSplunk's **Dynamic
    Data Active Archive (DDAA)** offloads aged data to Amazon S3 to reduce costs.
    The problem: **archived data is not searchable in place.** To query it, you must:\n\n1.
    File a **rehydration request** in the Splunk UI\n2. Wait for the job to copy data
    from S3 back into warm storage\n3. Rehydration can take **hours to days** depending
    on data volume\n4. During an active compliance audit or security incident, your
    auditors wait\n\n**Elastic Serverless is architecturally different.** Data stored
    in object storage as a Searchable Snapshot remains **directly queryable via the
    standard Elasticsearch API** — no copy-back, no rehydration queue, no support
    ticket required.\n\n***\n\n\U0001F1E7\U0001F1F7 **O Problema de Reidratação do
    Splunk DDAA**\n\nO **Dynamic Data Active Archive (DDAA)** do Splunk move dados
    antigos para o Amazon S3 para reduzir custos. O problema: **dados arquivados não
    são consultáveis no lugar.** Para consultá-los, você deve:\n\n1. Abrir uma **solicitação
    de reidratação** na interface do Splunk\n2. Aguardar o job copiar os dados do
    S3 de volta para o armazenamento quente\n3. A reidratação pode levar **horas a
    dias** dependendo do volume de dados\n4. Durante uma auditoria de compliance ativa
    ou incidente de segurança, seus auditores esperam\n\n**O Tier Congelado do Elastic
    é arquiteturalmente diferente.** Dados armazenados no armazenamento de objetos
    como Snapshot Consultável permanecem **diretamente consultáveis via API Elasticsearch
    padrão** — sem cópia de volta, sem fila de reidratação, sem ticket de suporte
    necessário.\n"
- type: text
  contents: "## Elastic Serverless vs Splunk DDAA\n\n```\nElastic Frozen Tier (Searchable
    Snapshots)\n├── Data stored as snapshots in S3 / GCS / Azure Blob\n├── Shard metadata
    cached locally (minimal footprint)\n├── On query: relevant data fetched on-demand,
    cached\n└── Result: full ES|QL API, zero rehydration lag\n\nSplunk DDAA\n├── Data
    stored as Splunk-format files in S3\n├── NOT searchable in-place\n├── Requires
    full copy from S3 → warm storage first\n└── Result: hours/days of blocked auditors\n```\n\n|
    Capability | Elastic Frozen Tier | Splunk DDAA |\n|------------|--------------------|----|\n|
    Query archived data directly | ✅ Instantly | ❌ Requires rehydration |\n| Rehydration
    time | None | Hours to days |\n| Same API as hot data | ✅ | ❌ |\n| Cross-tier
    queries (hot + archive) | ✅ Single query | ❌ Two operations |\n\n***\n\n\U0001F1E7\U0001F1F7
    **A Arquitetura do Tier Congelado do Elastic**\n\n```\nTier Congelado do Elastic
    (Snapshots Consultáveis)\n├── Dados armazenados como snapshots no S3 / GCS / Azure
    Blob\n├── Metadados de shard em cache local (footprint mínimo)\n├── Na consulta:
    dados relevantes buscados sob demanda, em cache\n└── Resultado: API ES|QL completa,
    zero latência de reidratação\n\nSplunk DDAA\n├── Dados armazenados como arquivos
    no formato Splunk no S3\n├── NÃO consultáveis no lugar\n├── Requer cópia completa
    do S3 → armazenamento quente primeiro\n└── Resultado: horas/dias de auditores
    bloqueados\n```\n\n| Capacidade | Tier Congelado Elastic | Splunk DDAA |\n|------------|----------------------|-------------|\n|
    Consultar dados arquivados diretamente | ✅ Instantaneamente | ❌ Requer reidratação
    |\n| Tempo de reidratação | ✅ Nenhum | ❌ Horas a dias |\n| Mesma API que dados
    quentes | ✅ ES\\|QL completo | ❌ Caminho diferente |\n| Consulta entre tiers (quente
    + arquivo) | ✅ Uma consulta | ❌ Duas operações |\n"
tabs:
- id: j4pjehbtzbyz
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: muyjbvxgznzx
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: qmlv0fcaxr0t
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: t5rwh0cnugeo
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/discover
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

# Competitive Edge 3: Always-On Archives

## The Scenario

Your compliance team has received a request from a SOC 2 auditor:

> *"We need all `data_export` and `privilege_escalation_attempt` events for any user in the `payments-api` service from **two years ago**. We need results within the hour."*

In Splunk: open a rehydration ticket. Wait hours or days.

In Elastic Serverless: run a query. Get results in seconds.

> **Why Elastic Serverless is different:** Serverless automatically manages all storage optimization behind the scenes — you never think about hot, warm, or frozen tiers. Every document, regardless of age, is always queryable with the same API. The contrast with Splunk DDAA is stark: Splunk requires you to manually trigger a copy-back job before archived data becomes searchable again.

The setup script indexed 500 audit log events timestamped **2 years ago** and 100 recent events — both queryable with the exact same ES|QL query.

---

## Step 1: Confirm the Full Time Span is Queryable

Open the **Elastic Serverless** tab → **Discover → ES|QL**. Set the time range to **Last 3 years**, then run:

```esql
FROM lab6-audit-logs-*
| STATS doc_count = COUNT(),
        earliest  = MIN(@timestamp),
        latest    = MAX(@timestamp)
| LIMIT 1
```

> You'll see `earliest` dated ~2 years ago and `latest` from today — **in a single query, zero extra steps**. In Splunk DDAA, that 2-year-old data would require a rehydration job before it appeared here at all.

---

## Step 2: Answer the Auditor's Query

Run the exact query the compliance team needs — documents from two years ago respond just like today's data:

```esql
FROM lab6-audit-logs-*
| WHERE `event.action` IN ("data_export", "privilege_escalation_attempt")
  AND `destination.service` == "payments-api"
| KEEP @timestamp, `user.name`, `user.id`, `event.action`,
       `event.outcome`, `source.ip`, `compliance.framework`
| SORT @timestamp DESC
```

---

## Step 3: Two-Year Compliance Report in One Query

A full 2-year compliance report — archival and recent data — in a single query:

```esql
FROM lab6-audit-logs-*
| WHERE `event.action` == "privilege_escalation_attempt"
| STATS attempt_count = COUNT(),
        services_hit  = COUNT_DISTINCT(`destination.service`)
  BY `user.name`
| SORT attempt_count DESC
| LIMIT 20
```

> In Splunk: (1) rehydrate archival data, (2) wait hours, (3) run SPL against warm storage, (4) separately query Splunk ES for security context. In Elastic Serverless: one query, instant results, one platform.

---

## Step 4: Verify in Kibana Discover

1. In **Elastic Serverless** → **Discover**, click **Open** → select the `Lab 6 - Audit Logs` data view
2. Set time range to **Last 3 years**
3. Observe that documents from 2 years ago and today appear in the **same timeline** — no gaps, no missing data, no rehydration indicator
4. Add filter: `event.action : privilege_escalation_attempt`

All data — regardless of age — is immediately visible and filterable.

---

## ✅ Complete When:

- [ ] The time-span query shows `earliest` dated ~2 years ago and `latest` from today in one result
- [ ] The auditor query returns results for `data_export` / `privilege_escalation_attempt` on `payments-api`
- [ ] You confirmed results came back in seconds — no rehydration required

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Diferencial Competitivo 3: Arquivos Sempre Disponíveis

## O Cenário

Sua equipe de compliance recebeu uma solicitação de um auditor SOC 2:

> *"Precisamos de todos os eventos `data_export` e `privilege_escalation_attempt` de qualquer usuário no serviço `payments-api` de **dois anos atrás**. Precisamos dos resultados em uma hora."*

No Splunk: abra um ticket de reidratação. Aguarde horas ou dias.

No Elastic Serverless: execute uma consulta. Resultados em segundos.

> **Por que o Elastic Serverless é diferente:** O Serverless gerencia automaticamente toda a otimização de armazenamento nos bastidores — você nunca precisa pensar em camadas quentes, mornas ou congeladas. Cada documento, independentemente da idade, está sempre consultável com a mesma API. O contraste com o Splunk DDAA é claro: o Splunk exige que você acione manualmente um job de cópia antes que os dados arquivados fiquem pesquisáveis novamente.

O script de configuração indexou 500 eventos com data de **2 anos atrás** e 100 eventos recentes — ambos consultáveis com a mesma consulta ES|QL.

---

## Passo 1: Confirmar que Todo o Intervalo de Tempo é Consultável

Abra a aba **Elastic Serverless** → **Discover → ES|QL**. Defina o intervalo de tempo para **Últimos 3 anos** e execute:

```esql
FROM lab6-audit-logs-*
| STATS doc_count = COUNT(),
        mais_antigo  = MIN(@timestamp),
        mais_recente = MAX(@timestamp)
| LIMIT 1
```

> Você verá `mais_antigo` datado de ~2 anos atrás e `mais_recente` de hoje — **em uma única consulta, zero etapas extras**. No Splunk DDAA, esses dados de 2 anos atrás exigiriam um job de reidratação antes de aparecerem aqui.

---

## Passo 2: Responder à Consulta do Auditor

Execute a consulta exata que a equipe de compliance precisa — documentos de dois anos atrás respondem igual aos dados de hoje:

```esql
FROM lab6-audit-logs-*
| WHERE `event.action` IN ("data_export", "privilege_escalation_attempt")
  AND `destination.service` == "payments-api"
| KEEP @timestamp, `user.name`, `user.id`, `event.action`,
       `event.outcome`, `source.ip`, `compliance.framework`
| SORT @timestamp DESC
```

---

## Passo 3: Relatório de Compliance de 2 Anos em Uma Consulta

Um relatório completo de 2 anos — dados de arquivo e recentes — em uma única consulta:

```esql
FROM lab6-audit-logs-*
| WHERE `event.action` == "privilege_escalation_attempt"
| STATS tentativas = COUNT(),
        servicos   = COUNT_DISTINCT(`destination.service`)
  BY `user.name`
| SORT tentativas DESC
| LIMIT 20
```

> No Splunk: (1) reidratar dados, (2) aguardar horas, (3) executar SPL no armazenamento quente, (4) consultar o Splunk ES separadamente para contexto de segurança. No Elastic Serverless: uma consulta, resultados instantâneos, uma plataforma.

---

## Passo 4: Verificar no Kibana Discover

1. Em **Elastic Serverless** → **Discover**, clique em **Open** → selecione a data view `Lab 6 - Audit Logs`
2. Defina o intervalo de tempo para **Últimos 3 anos**
3. Observe que documentos de 2 anos atrás e de hoje aparecem na **mesma linha do tempo** — sem lacunas, sem dados ausentes, sem indicador de reidratação
4. Adicione filtro: `event.action : privilege_escalation_attempt`

Todos os dados — independentemente da idade — são imediatamente visíveis e filtráveis.

---

## ✅ Concluído Quando:

- [ ] A consulta de intervalo de tempo mostra `mais_antigo` de ~2 anos atrás e `mais_recente` de hoje em um resultado
- [ ] A consulta do auditor retorna resultados de `data_export` / `privilege_escalation_attempt` no `payments-api`
- [ ] Você confirmou que os resultados chegaram em segundos — sem reidratação necessária

</details>
