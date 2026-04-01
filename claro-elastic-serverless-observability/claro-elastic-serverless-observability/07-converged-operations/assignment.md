---
slug: converged-operations
id: urvrw8ilmvn9
type: challenge
title: 'Competitive Edge 4: Converged Operations — SIEM Value Without Double Ingest'
teaser: Enable a security detection rule on logs you already ingested. No separate
  Splunk ES license. No second ingest pipeline. Zero extra cost.
notes:
- type: text
  contents: "## Workshop Slides\n\nFollow along with the full presentation:\n\n**[→
    Open Workshop Slides](https://poulsbopete.github.io/claro/)**\n\n*(Opens in a
    new tab)*\n\n***\n\n\U0001F1E7\U0001F1F7 **[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**\n\n*(Abre
    em uma nova aba)*\n"
- type: text
  contents: "## The Splunk Enterprise Security Tax\n\nTo get SIEM detection on application
    logs in Splunk, you need:\n\n- **Splunk Cloud** — for observability (logs, metrics)\n-
    **Splunk Enterprise Security** — a separate, expensive product with its own license\n-
    **CIM normalization** — your logs must be mapped to Splunk's Common Information
    Model\n- **Double ingest** — data typically flows into both Splunk Cloud *and*
    Splunk ES separately\n\nThe result: SIEM coverage on app logs costs approximately
    **2× the ingest cost** plus an additional ES license plus CIM mapping work.\n\n**In
    Elastic, observability data is security data.** The same Elasticsearch index that
    powers your APM dashboards can be targeted by Elastic Security detection rules
    — no additional ingest, no second license, no CIM.\n\n***\n\n\U0001F1E7\U0001F1F7
    **O Custo Adicional do Splunk Enterprise Security**\n\nPara obter detecção SIEM
    em logs de aplicação no Splunk, você precisa:\n\n- **Splunk Cloud** — para observabilidade
    (logs, métricas)\n- **Splunk Enterprise Security** — um produto separado e caro
    com sua própria licença\n- **Normalização CIM** — seus logs devem ser mapeados
    para o Common Information Model do Splunk\n- **Ingestão dupla** — os dados geralmente
    fluem tanto para o Splunk Cloud *quanto* para o Splunk ES separadamente\n\nO resultado:
    a cobertura SIEM em logs de aplicação custa aproximadamente **2× o custo de ingestão**
    mais uma licença ES adicional mais trabalho de mapeamento CIM.\n\n**No Elastic,
    dados de observabilidade são dados de segurança.** O mesmo índice Elasticsearch
    que alimenta seus dashboards APM pode ser alvo de regras de detecção do Elastic
    Security — sem ingestão adicional, sem segunda licença, sem CIM.\n"
- type: text
  contents: "## The Elastic Converged Operations Advantage\n\n| Capability | Elastic
    | Splunk |\n|------------|---------|--------|\n| Detection rules on observability
    data | ✅ Same index | ❌ Separate product |\n| Extra ingest for SIEM coverage |
    ✅ Zero | ❌ Full double-ingest |\n| CIM / normalization required | ✅ None (ECS
    native) | ❌ CIM mapping required |\n| Alert → trace correlation | ✅ Same platform
    | ❌ Cross-product navigation |\n| Single license for obs + security | ✅ | ❌ Cloud
    + ES licenses |\n\n> **Splunk's model creates a financial disincentive to security
    coverage.** Every log that could be a security signal costs twice as much to protect.\n\n***\n\n\U0001F1E7\U0001F1F7
    **A Vantagem das Operações Convergidas do Elastic**\n\n| Capacidade | Elastic
    | Splunk |\n|------------|---------|--------|\n| Regras de detecção em dados de
    observabilidade | ✅ Mesmo índice | ❌ Produto separado |\n| Ingestão extra para
    SIEM | ✅ Zero | ❌ Ingestão dupla completa |\n| Normalização necessária | ✅ Nenhuma
    (ECS nativo) | ❌ Mapeamento CIM |\n| Alerta → correlação de rastreamento | ✅ Mesma
    plataforma | ❌ Navegação entre produtos |\n| Licença única para obs + segurança
    | ✅ | ❌ Licenças Cloud + ES |\n\n> **O modelo do Splunk cria um desincentivo financeiro
    para cobertura de segurança.** Cada log que poderia ser um sinal de segurança
    custa o dobro para proteger.\n"
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
  path: /app/observability/alerts
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

## Step 3: Create an Alert Rule on Your Observability Index

The key point of this lab: **no separate SIEM index needed**. Your observability logs are the security data.

1. In the **Elastic Serverless** tab → **Alerts → Manage Rules**
2. Click **Create rule** → select **ES|QL**
3. Configure:
   - **Name:** `Brute Force: Auth Failures on Observability Logs`
   - **ES|QL query:**
     ```esql
     FROM lab7-attack-logs-*
     | WHERE `event.action` == "authentication_failure"
       AND `http.response.status_code` == 401
     | STATS failure_count = COUNT() BY `source.ip`, `user.name`
     | WHERE failure_count >= 5
     ```
   - **Check every:** 1 minute
   - **Severity:** High
4. Click **Save**

> The index `lab7-attack-logs-*` is your **observability log index** — the same one queried in Steps 1 and 2. In Splunk, this would require Splunk ES, CIM normalization, and a separate ingest pipeline. In Elastic, you point an alert rule at the data you already have.

---

## Step 4: View Alerts in Observability

1. Navigate to **Observability → Alerts** (or the **Alerts** icon in the left nav)
2. Within 1–2 minutes your new rule will fire against the injected attack events
3. Click any alert to expand it — note the source index: `lab7-attack-logs-*`

> **This is the core message:** The alert was triggered by data in your observability index. No double ingest. No second product. No CIM mapping. Zero extra cost.

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
- [ ] You created an ES|QL alert rule targeting `lab7-attack-logs-*` (your observability index)
- [ ] An alert fired and is visible in **Observability → Alerts**
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

## Passo 3: Criar uma Regra de Alerta no Seu Índice de Observabilidade

O ponto principal deste lab: **nenhum índice SIEM separado necessário**. Seus logs de observabilidade são os dados de segurança.

1. Na aba **Elastic Serverless** → **Alerts → Manage Rules**
2. Clique em **Create rule** → selecione **ES|QL**
3. Configure:
   - **Nome:** `Força Bruta: Falhas de Autenticação em Logs de Observabilidade`
   - **Consulta ES|QL:**
     ```esql
     FROM lab7-attack-logs-*
     | WHERE `event.action` == "authentication_failure"
       AND `http.response.status_code` == 401
     | STATS falhas = COUNT() BY `source.ip`, `user.name`
     | WHERE falhas >= 5
     ```
   - **Check every:** 1 minuto
   - **Severity:** High
4. Clique em **Save**

> O índice `lab7-attack-logs-*` é seu **índice de log de observabilidade** — o mesmo consultado nos Passos 1 e 2. No Splunk, isso exigiria Splunk ES, normalização CIM e um pipeline de ingestão separado. No Elastic, você aponta uma regra de alerta para os dados que já possui.

---

## Passo 4: Ver Alertas em Observability

1. Navegue para **Observability → Alerts** (ou o ícone **Alerts** na navegação lateral)
2. Em 1–2 minutos sua nova regra disparará contra os eventos de ataque injetados
3. Clique em qualquer alerta para expandi-lo — observe o índice de origem: `lab7-attack-logs-*`

> **Esta é a mensagem principal:** O alerta foi acionado por dados no seu índice de observabilidade. Sem ingestão dupla. Sem segundo produto. Sem mapeamento CIM. Custo adicional zero.

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
- [ ] Você criou uma regra de alerta ES|QL apontando para `lab7-attack-logs-*` (seu índice de observabilidade)
- [ ] Um alerta disparou e está visível em **Observability → Alerts**
- [ ] Você confirmou que nenhum índice SIEM separado ou ingestão dupla foi necessário

</details>
