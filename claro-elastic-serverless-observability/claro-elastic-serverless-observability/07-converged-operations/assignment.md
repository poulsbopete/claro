---
slug: converged-operations
id: urvrw8ilmvn9
type: challenge
title: 'Competitive Edge 4: Converged Operations — SIEM Value Without Double Ingest'
teaser: Enable a security detection rule on logs you already ingested. No separate
  Splunk ES license. No second ingest pipeline. Zero extra cost.
notes:
- type: text
  contents: |
    ## Workshop Slides

    Follow along with the full presentation:

    **[→ Open Workshop Slides](https://poulsbopete.github.io/claro/)**

    *(Opens in a new tab)*
- type: text
  contents: |
    ## The Splunk Enterprise Security Tax

    To get SIEM detection on application logs in Splunk, you need:

    - **Splunk Cloud** — for observability (logs, metrics)
    - **Splunk Enterprise Security** — a separate, expensive product with its own license
    - **CIM normalization** — your logs must be mapped to Splunk's Common Information Model
    - **Double ingest** — data typically flows into both Splunk Cloud *and* Splunk ES separately

    The result: SIEM coverage on app logs costs approximately **2× the ingest cost** plus an additional ES license plus CIM mapping work.

    **In Elastic, observability data is security data.** The same Elasticsearch index that powers your APM dashboards can be targeted by Elastic Security detection rules — no additional ingest, no second license, no CIM.
- type: text
  contents: |
    ## The Elastic Converged Operations Advantage

    | Capability | Elastic | Splunk |
    |------------|---------|--------|
    | Detection rules on observability data | ✅ Same index | ❌ Separate product |
    | Extra ingest for SIEM coverage | ✅ Zero | ❌ Full double-ingest |
    | CIM / normalization required | ✅ None (ECS native) | ❌ CIM mapping required |
    | Alert → trace correlation | ✅ Same platform | ❌ Cross-product navigation |
    | Single license for obs + security | ✅ | ❌ Cloud + ES licenses |

    > **Splunk's model creates a financial disincentive to security coverage.** Every log that could be a security signal costs twice as much to protect.
tabs:
- id: xufxvrksrpet
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: lkg2icza9qwo
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: rfolxbyvzemr
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: pcswyicg95ws
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/security/alerts
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

# Competitive Edge 4: Converged Operations

## The Scenario

The setup script injected a **brute-force attack pattern** into `lab7-attack-logs-*` — structured exactly like your Claro observability logs:

- **50 normal service requests** (baseline traffic from `payments-api`, `billing-engine`, etc.)
- **15 authentication failures** from IP `198.51.100.42` within 5 minutes
- **1 successful login** at the end — the brute force succeeded
- **Target user:** `admin` on `/api/auth/login`

A Kibana Security detection rule was pre-created targeting this index.

---

## Step 1: Confirm the Attack Is in Your Observability Index

Open the **Elastic Serverless** tab → **Discover → ES|QL**:

```esql
FROM lab7-attack-logs-*
| WHERE `source.ip` == "198.51.100.42"
| KEEP @timestamp, `log.level`, message, `event.action`, `event.outcome`,
       `http.response.status_code`
| SORT @timestamp ASC
```

> **This is the critical insight:** You are querying `lab7-attack-logs-*` — the **same observability index as your APM logs.** No separate SIEM ingest. No data duplication. No additional cost.

---

## Step 2: Run the Brute-Force Detection Logic

This is the logic underlying your detection rule:

```esql
FROM lab7-attack-logs-*
| WHERE @timestamp > NOW() - 15 minutes
  AND `http.response.status_code` == 401
| STATS failure_count = COUNT(),
        endpoints_hit = COUNT_DISTINCT(`url.path`)
  BY `source.ip`, `user.name`
| WHERE failure_count >= 5
| SORT failure_count DESC
```

---

## Step 3: View the Detection Rule in Kibana Security

1. In the **Elastic Serverless** tab navigate to **Security → Rules → Detection Rules**
2. Find **"[Lab 7] Brute Force: Auth Failures on Observability Logs"**
3. Confirm:
   - Status: **Enabled**
   - Index pattern: `lab7-attack-logs-*` ← your observability index, not a SIEM-specific index
   - MITRE ATT&CK mapping: `T1110 - Brute Force`

> If the rule was not auto-created, create it manually: **Create Rule → Threshold** → index `lab7-attack-logs-*`, query `http.response.status_code: 401`, threshold ≥ 5 grouped by `source.ip`.

---

## Step 4: View the Generated Alert

1. Navigate to **Security → Alerts**
2. Click any alert to expand it
3. Note the source index in the alert details: `lab7-attack-logs-*`
4. Click **Investigate in Timeline** — you see the raw log events directly

> In Splunk ES, this alert would reference data from a CIM-normalized SIEM datastore, separate from your observability data. In Elastic, the alert points directly to the **original observability log document.**

---

## Step 5: Pivot to the Live Claro Streams

Now see the same capability on your **live** Claro observability data. Run this in ES|QL:

```esql
FROM logs.otel, logs.otel.*
| WHERE severity_text == "ERROR"
  AND @timestamp > NOW() - 10 minutes
| STATS error_count = COUNT(),
        services    = COUNT_DISTINCT(service.name)
  BY `service.name`
| SORT error_count DESC
| LIMIT 10
```

> **The same query that powers your SRE dashboards can drive a security detection rule.** No second data copy required.

---

## ✅ Complete When:

- [ ] The ES|QL query confirms the brute-force events exist in `lab7-attack-logs-*` (the observability index)
- [ ] The detection rule in Kibana Security shows `lab7-attack-logs-*` as its target index
- [ ] A security alert is visible in Security → Alerts
- [ ] You confirmed no separate SIEM index or double-ingest was required

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Diferencial Competitivo 4: Operações Convergidas

## O Cenário

O script de configuração injetou um **padrão de ataque de força bruta** em `lab7-attack-logs-*` — estruturado exatamente como seus logs de observabilidade da Claro:

- **50 requisições normais de serviço** (tráfego de linha de base de `payments-api`, `billing-engine`, etc.)
- **15 falhas de autenticação** do IP `198.51.100.42` em 5 minutos
- **1 login bem-sucedido** no final — a força bruta teve sucesso
- **Usuário alvo:** `admin` em `/api/auth/login`

Uma regra de detecção de segurança do Kibana foi pré-criada apontando para este índice.

---

## Passo 1: Confirmar que o Ataque Está no Seu Índice de Observabilidade

Abra a aba **Elastic Serverless** → **Discover → ES|QL**:

```esql
FROM lab7-attack-logs-*
| WHERE `source.ip` == "198.51.100.42"
| KEEP @timestamp, `log.level`, message, `event.action`, `event.outcome`,
       `http.response.status_code`
| SORT @timestamp ASC
```

> **Este é o insight crítico:** Você está consultando `lab7-attack-logs-*` — o **mesmo índice de observabilidade dos seus logs APM.** Sem ingestão SIEM separada. Sem duplicação de dados. Sem custo adicional.

---

## Passo 2: Executar a Lógica de Detecção de Força Bruta

Esta é a lógica subjacente à sua regra de detecção:

```esql
FROM lab7-attack-logs-*
| WHERE @timestamp > NOW() - 15 minutes
  AND `http.response.status_code` == 401
| STATS falhas = COUNT(),
        endpoints = COUNT_DISTINCT(`url.path`)
  BY `source.ip`, `user.name`
| WHERE falhas >= 5
| SORT falhas DESC
```

---

## Passo 3: Ver a Regra de Detecção no Kibana Security

1. Na aba **Elastic Serverless** navegue para **Security → Rules → Detection Rules**
2. Encontre **"[Lab 7] Brute Force: Auth Failures on Observability Logs"**
3. Confirme:
   - Status: **Habilitado**
   - Padrão de índice: `lab7-attack-logs-*` ← seu índice de observabilidade, não um índice específico de SIEM
   - Mapeamento MITRE ATT&CK: `T1110 - Brute Force`

> Se a regra não foi criada automaticamente, crie manualmente: **Create Rule → Threshold** → índice `lab7-attack-logs-*`, consulta `http.response.status_code: 401`, limite ≥ 5 agrupado por `source.ip`.

---

## Passo 4: Ver o Alerta Gerado

1. Navegue para **Security → Alerts**
2. Clique em qualquer alerta para expandi-lo
3. Observe o índice de origem nos detalhes do alerta: `lab7-attack-logs-*`
4. Clique em **Investigate in Timeline** — você vê os eventos de log brutos diretamente

> No Splunk ES, este alerta referenciaria dados de um armazenamento SIEM normalizado pelo CIM, separado dos seus dados de observabilidade. No Elastic, o alerta aponta diretamente para o **documento de log de observabilidade original.**

---

## Passo 5: Pivotar para os Streams Claro em Tempo Real

Agora veja a mesma capacidade nos seus dados de observabilidade **em tempo real** da Claro:

```esql
FROM logs.otel, logs.otel.*
| WHERE severity_text == "ERROR"
  AND @timestamp > NOW() - 10 minutes
| STATS erros = COUNT(),
        servicos = COUNT_DISTINCT(service.name)
  BY `service.name`
| SORT erros DESC
| LIMIT 10
```

> **A mesma consulta que alimenta seus dashboards de SRE pode acionar uma regra de detecção de segurança.** Sem segunda cópia de dados necessária.

---

## ✅ Concluído Quando:

- [ ] A consulta ES|QL confirma que os eventos de força bruta existem em `lab7-attack-logs-*` (o índice de observabilidade)
- [ ] A regra de detecção no Kibana Security mostra `lab7-attack-logs-*` como índice alvo
- [ ] Um alerta de segurança está visível em Security → Alerts
- [ ] Você confirmou que nenhum índice SIEM separado ou ingestão dupla foi necessário

</details>
