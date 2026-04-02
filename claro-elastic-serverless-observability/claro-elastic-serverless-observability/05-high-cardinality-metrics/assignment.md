---
slug: high-cardinality-metrics
id: tmnahuexgbwt
type: challenge
title: 'Competitive Edge 2: Elastic Streams — Intelligent Partitioning Without Agent
  Changes'
teaser: Elastic analyzes your live data and suggests routing rules automatically.
  Accept a suggestion and your logs instantly split into per-service streams with
  independent retention and processing rules — zero Collector restarts.
notes:
- type: text
  contents: "## Workshop Slides\n\nFollow along with the full presentation:\n\n**[→
    Open Workshop Slides](https://poulsbopete.github.io/claro/)**\n\n*(Opens in a
    new tab)*\n\n***\n\n\U0001F1E7\U0001F1F7 **[→ Abrir Slides do Workshop](https://poulsbopete.github.io/claro/)**\n\n*(Abre
    em uma nova aba)*\n"
- type: text
  contents: "## How Splunk Forces a Cardinality Trade-off\n\nIn Splunk, every unique
    metric dimension combination is a billable **Metric Time Series (MTS)**. High-cardinality
    fields like `pod.uid` or `container.id` multiply your bill with every deployment.
    The only cost lever is at the **OpenTelemetry Collector** — drop the field globally,
    permanently, before it reaches Splunk.\n\n**Elastic Streams gives you control
    inside the platform.** Instead of dropping fields at the agent, you route data
    into per-service streams — each with its own retention policy and field-level
    processing rules — without touching a single agent config.\n\n***\n\n\U0001F1E7\U0001F1F7
    **Como o Splunk Força uma Troca de Cardinalidade**\n\nNo Splunk, cada combinação
    única de dimensões de métrica é uma **Metric Time Series (MTS)** faturável. Campos
    de alta cardinalidade como `pod.uid` ou `container.id` multiplicam sua fatura
    a cada implantação. O único controle de custo está no **Collector OpenTelemetry**
    — remover o campo globalmente, permanentemente, antes de chegar ao Splunk.\n\n**O
    Elastic Streams dá controle dentro da plataforma.** Em vez de remover campos no
    agente, você roteia dados para streams por serviço — cada um com sua própria política
    de retenção e regras de processamento no nível de campo — sem tocar em nenhuma
    configuração de agente.\n"
- type: text
  contents: "## What You'll Do\n\nElastic Streams **analyzes your live data** and
    automatically suggests how to partition it. For the Claro scenario, it detects
    that `logs.otel` contains logs from 9 different services and suggests creating
    child streams like:\n\n- `logs.otel.billing-engine` — billing and OCS charging
    events\n- `logs.otel.mobile-core` — 5G/4G core network events\n- `logs.otel.voice-platform`
    — SIP/IMS events\n- (and 6 more...)\n\nEach child stream is **completely independent**:
    set 7-day retention on `billing-engine` for fast incident triage, 90-day on `network-analytics`
    for capacity trending. Add a `drop_field` rule to one without affecting the others.\n\n|
    Capability | Elastic Streams | Splunk |\n|------------|----------------|--------|\n|
    Auto-detect routing candidates | ✅ Analyzes live data | ❌ Manual pipeline config
    |\n| Per-service retention | ✅ Each child independent | ❌ Global DDAA policy |\n|
    Drop fields per-stream | ✅ Processing rules | ❌ Global Collector change |\n| Zero
    agent changes | ✅ | ❌ Requires Collector restart |\n\n***\n\n\U0001F1E7\U0001F1F7
    **O Que Você Vai Fazer**\n\nO Elastic Streams **analisa seus dados em tempo real**
    e sugere automaticamente como particioná-los. Para o cenário Claro, ele detecta
    que `logs.otel` contém logs de 9 serviços diferentes e sugere a criação de streams
    filhos como:\n\n- `logs.otel.billing-engine` — eventos de cobrança e OCS\n- `logs.otel.mobile-core`
    — eventos do core de rede 5G/4G\n- `logs.otel.voice-platform` — eventos SIP/IMS\n-
    (e mais 6...)\n\nCada stream filho é **completamente independente**: defina 7
    dias de retenção em `billing-engine` para triagem rápida de incidentes, 90 dias
    em `network-analytics` para tendências de capacidade. Adicione uma regra `drop_field`
    a um sem afetar os outros.\n\n| Capacidade | Elastic Streams | Splunk |\n|------------|----------------|--------|\n|
    Detectar candidatos automaticamente | ✅ Analisa dados em tempo real | ❌ Config
    manual no pipeline |\n| Retenção por serviço | ✅ Cada filho independente | ❌ Política
    DDAA global |\n| Remover campos por stream | ✅ Regras de processamento | ❌ Mudança
    global no Collector |\n| Zero mudanças no agente | ✅ | ❌ Requer reinicialização
    do Collector |\n"
tabs:
- id: addwrseojmxt
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: feqdqyofcddf
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: uinbtoljou0s
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/streams
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

# Competitive Edge 2: Elastic Streams — Intelligent Partitioning

Elastic has already been watching the live Claro log stream. Open the **Elastic Serverless** tab — you're on the Streams page.

---

## Step 1: Open logs.otel and Review Partitioning Suggestions

1. Click **`logs.otel`** in the Streams list
2. Click the **Partitioning** tab at the top

Kibana has analyzed the last 1,000 documents from `logs.otel` and automatically identified that this stream contains data from multiple Claro services. You'll see suggested child streams like:

- `logs.otel.billing-engine`
- `logs.otel.mobile-core`
- `logs.otel.voice-platform`
- `logs.otel.noc-dashboard`
- `logs.otel.content-delivery`
- ... (one per service)

Each suggestion shows the **percentage of log volume** that service represents, along with a live **Data Preview** of the actual log messages that would be routed there.

> **Why this matters:** Kibana did the analysis automatically. In Splunk, a platform engineer would need to manually write Collector routing rules — reading the data schema, choosing split dimensions, testing in staging, then deploying. Here, Elastic shows you the answer.

---

## Step 2: Accept Two Partitions

Click **Accept** on **at least two** of the suggested partitions — for example:

1. `logs.otel.billing-engine` — billing and OCS charging events (highest financial impact)
2. `logs.otel.mobile-core` — 5G/4G core network events

After accepting, Kibana immediately:
- Creates the child streams `logs.otel.billing-engine` and `logs.otel.mobile-core`
- Sets up routing rules so new logs from those services go to their dedicated stream
- `logs.otel` continues receiving logs from all other services

> **The Splunk equivalent:** Modify `otelcol-contrib.yaml` with routing processor rules, deploy to all collector nodes, wait for restart, verify in Splunk. No data preview. No automatic suggestions. And if you get it wrong, data goes to the wrong destination until you fix and redeploy.

---

## Step 3: Set Different Retention on Each Child Stream

Click **`logs.otel.billing-engine`** from the Streams list.

1. Click the **Retention** tab
2. Change retention to **7 days** → Save
   - Billing logs need detail for rapid incident triage, but OCS CDR data has compliance rules

Now click **`logs.otel.mobile-core`**:

1. Click the **Retention** tab
2. Change retention to **30 days** → Save
   - 5G core events are needed longer for capacity planning and handover analysis

> In Splunk, retention is set at the **index level** via DDAA — a global policy. You cannot set different retention for different services within the same index. If `billing-engine` and `mobile-core` share an index (to save MTS costs), they share a retention policy. Period.

---

## Step 4: Add a Processing Rule to Drop a High-Cardinality Field

Click **`logs.otel.mobile-core`** → **Processing** tab:

1. Click **Add processor**
2. Under **Remove**, select **Remove** (the single-field remover — not "Remove by prefix" or "Drop document")
3. In the **Field** box, type: `kubernetes.pod.uid`
4. Click the **"Add kubernetes.pod.uid as a custom field"** link that appears below the field box (the ↲ icon) — this registers the field in the stream schema
5. Click **Create**

> **Tip:** The "Add as a custom field" prompt appears whenever you reference a field that isn't already in the stream's schema. You must click it before the processor can be saved.

This drops `kubernetes.pod.uid` **only from the mobile-core stream** — the billing-engine stream still retains it for pod-level incident correlation.

> **This is the core Splunk cost problem:** In Splunk Observability Cloud, `kubernetes.pod.uid` creates a new MTS for every pod. With hundreds of 5G pods cycling on every deployment, bills explode. The only fix is dropping it at the Collector — globally, for all destinations. In Elastic, you drop it from one stream while keeping it in another.

---

## Step 5: Verify in the Streams List

Go back to the Streams list. You should now see your child streams alongside `logs.otel`:

| Stream | Purpose | Retention |
|--------|---------|-----------|
| `logs.otel` | All other services | Indefinite |
| `logs.otel.billing-engine` | OCS/CDR billing events | 7 days |
| `logs.otel.mobile-core` | 5G/4G core events | 30 days |

Switch to the **Elastic Serverless** tab → **Discover → ES|QL** and confirm data is routing to the child streams:

```esql
FROM logs.otel, logs.otel.*
METADATA _index
| WHERE @timestamp > NOW() - 5 MINUTES
| STATS log_count = COUNT(*) BY _index, service.name
| SORT log_count DESC
```

You'll see `billing-engine` and `mobile-core` logs appearing under their own `_index` values (`logs.otel.billing-engine-*`, `logs.otel.mobile-core-*`) — routed automatically, zero agent changes.

---

## ✅ Complete When:

- [ ] You reviewed the auto-generated partitioning suggestions in `logs.otel → Partitioning`
- [ ] You accepted at least two partition suggestions and new child streams appeared
- [ ] You set different retention policies on each child stream
- [ ] You added a `drop_field` processing rule to one stream (without affecting others)

---

<details>
<summary>🇧🇷 <strong>Português — clique para expandir</strong></summary>

# Diferencial Competitivo 2: Elastic Streams — Particionamento Inteligente

O Elastic já está monitorando o stream de logs da Claro em tempo real. Abra a aba **Elastic Serverless** — você está na página de Streams.

---

## Passo 1: Abrir logs.otel e Revisar as Sugestões de Particionamento

1. Clique em **`logs.otel`** na lista de Streams
2. Clique na aba **Partitioning** no topo

O Kibana analisou os últimos 1.000 documentos de `logs.otel` e identificou automaticamente que este stream contém dados de múltiplos serviços da Claro. Você verá streams filhos sugeridos como:

- `logs.otel.billing-engine`
- `logs.otel.mobile-core`
- `logs.otel.voice-platform`
- `logs.otel.noc-dashboard`
- `logs.otel.content-delivery`
- ... (um por serviço)

Cada sugestão mostra o **percentual do volume de logs** que aquele serviço representa, junto com uma **pré-visualização de dados** ao vivo das mensagens de log que seriam roteadas para lá.

> **Por que isso importa:** O Kibana fez a análise automaticamente. No Splunk, um engenheiro de plataforma precisaria escrever manualmente regras de roteamento no Collector — lendo o esquema de dados, escolhendo dimensões de divisão, testando em staging e depois implantando. Aqui, o Elastic mostra a resposta automaticamente.

---

## Passo 2: Aceitar Dois Particionamentos

Clique em **Aceitar** em **pelo menos dois** dos particionamentos sugeridos — por exemplo:

1. `logs.otel.billing-engine` — eventos de cobrança e OCS (maior impacto financeiro)
2. `logs.otel.mobile-core` — eventos do core de rede 5G/4G

Após aceitar, o Kibana imediatamente:
- Cria os streams filhos `logs.otel.billing-engine` e `logs.otel.mobile-core`
- Configura regras de roteamento para que novos logs desses serviços vão para seu stream dedicado
- `logs.otel` continua recebendo logs de todos os outros serviços

> **O equivalente no Splunk:** Modificar `otelcol-contrib.yaml` com regras de roteamento, implantar em todos os nós coletores, aguardar reinicialização, verificar no Splunk. Sem pré-visualização. Sem sugestões automáticas. E se errar, os dados vão para o destino errado até corrigir e reimplantar.

---

## Passo 3: Definir Retenção Diferente em Cada Stream Filho

Clique em **`logs.otel.billing-engine`** na lista de Streams.

1. Clique na aba **Retention**
2. Mude a retenção para **7 dias** → Salvar
   - Logs de cobrança precisam de detalhes para triagem rápida de incidentes

Agora clique em **`logs.otel.mobile-core`**:

1. Clique na aba **Retention**
2. Mude a retenção para **30 dias** → Salvar
   - Eventos do core 5G são necessários por mais tempo para planejamento de capacidade e análise de handover

> No Splunk, a retenção é definida no **nível do índice** via DDAA — uma política global. Você não pode definir retenções diferentes para serviços diferentes dentro do mesmo índice.

---

## Passo 4: Adicionar uma Regra de Processamento para Remover um Campo de Alta Cardinalidade

Clique em **`logs.otel.mobile-core`** → aba **Processing**:

1. Clique em **Add processor**
2. Em **Remove**, selecione **Remove** (removedor de campo único — não "Remove by prefix" nem "Drop document")
3. No campo **Field**, digite: `kubernetes.pod.uid`
4. Clique no link **"Add kubernetes.pod.uid as a custom field"** que aparece abaixo do campo (o ícone ↲) — isso registra o campo no esquema do stream
5. Clique em **Create**

> **Dica:** O prompt "Add as a custom field" aparece sempre que você referencia um campo que ainda não está no esquema do stream. Você deve clicar nele antes de salvar o processador.

Isso remove `kubernetes.pod.uid` **apenas do stream mobile-core** — o stream billing-engine ainda o mantém para correlação de incidentes no nível do pod.

> **Este é o problema central de custo do Splunk:** No Splunk Observability Cloud, `kubernetes.pod.uid` cria um novo MTS para cada pod. Com centenas de pods 5G rotacionando a cada implantação, as faturas explodem. A única solução é remover o campo no Collector — globalmente, para todos os destinos. No Elastic, você remove de um stream sem afetar os outros.

---

## Passo 5: Verificar na Lista de Streams

Volte para a lista de Streams. Você deve ver seus streams filhos ao lado de `logs.otel`:

| Stream | Propósito | Retenção |
|--------|----------|---------|
| `logs.otel` | Todos os outros serviços | Indefinida |
| `logs.otel.billing-engine` | Eventos OCS/CDR de cobrança | 7 dias |
| `logs.otel.mobile-core` | Eventos do core 5G/4G | 30 dias |

Confirme que os dados estão sendo roteados para os streams filhos via ES|QL:

```esql
FROM logs.otel, logs.otel.*
METADATA _index
| WHERE @timestamp > NOW() - 5 MINUTES
| STATS log_count = COUNT(*) BY _index, service.name
| SORT log_count DESC
```

---

## ✅ Concluído Quando:

- [ ] Você revisou as sugestões de particionamento geradas automaticamente em `logs.otel → Partitioning`
- [ ] Você aceitou pelo menos duas sugestões e novos streams filhos apareceram
- [ ] Você definiu políticas de retenção diferentes em cada stream filho
- [ ] Você adicionou uma regra de processamento `drop_field` a um stream (sem afetar os outros)

</details>
