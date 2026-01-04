/* ============================================================
   GOLD – FT_ORDERS
   ============================================================
   Camada: Gold
   Tipo: Tabela Fato
   Grão: 1 linha por item do pedido
   Origem: SILVER.ORDER_DETAILS

   Objetivo:
   - Disponibilizar a tabela fato principal para consumo analítico
   - Consolidar métricas financeiras, logísticas e operacionais
   - Servir como base para análises de performance, SLA e negócio

   Estratégia de carga:
   - Dynamic Table (atualização incremental automática)
   - TARGET_LAG define SLA de atualização dos dados
   - Snowflake gerencia dependências e refresh incremental

   Justificativa técnica:
   - Evita MERGE e lógica manual de incremental
   - Reduz complexidade operacional
   - Adequado para tabela Gold derivada (join + regras)
   - Mantém dados sempre atualizados com controle de custo

   Regras de negócio aplicadas:
   - Classificação de entrega (ON_TIME)
   - Cálculo de dias em operação
   - Cálculo de dias em trânsito
   - Padronização de tipos e datas

   Observações:
   - CREATED_AT indica o timestamp de materialização na Gold
   - A tabela é orientada a consumo (BI, analytics)
   ============================================================ */

CREATE OR REPLACE DYNAMIC TABLE GOLD.FT_ORDERS
TARGET_LAG = '10 MINUTE'
WAREHOUSE = COMPUTE_WH
AS

SELECT
     ORDER_ID

    ,TO_DATE(ORDER_PURCHASE) AS ORDER_PURCHASE

    ,SELLER_ID
    ,PRODUCT_ID

    ,CAST(PRICE AS FLOAT) AS PRICE
    ,CAST(FREIGHT_VALUE AS FLOAT) AS FREIGHT_VALUE

    ,CUSTOMER_ID
    ,ORDER_STATUS

    ,TO_DATE(SHIPPING_LIMIT_DATE) AS SHIPPING_LIMIT_DATE
    ,TO_DATE(ORDER_ESTIMATED_DELIVERY_DATE) AS ORDER_ESTIMATED_DELIVERY_DATE
    ,TO_DATE(ORDER_DELIVERED_CARRIER_DATE) AS ORDER_DELIVERED_CARRIER_DATE
    ,TO_DATE(ORDER_DELIVERED_CUSTOMER_DATE) AS ORDER_DELIVERED_CUSTOMER_DATE

    /* ========================================================
       SLA DE ENTREGA
       ======================================================== */
    ,CASE
        WHEN ORDER_DELIVERED_CUSTOMER_DATE <= ORDER_ESTIMATED_DELIVERY_DATE THEN 'ON_TIME'
        WHEN ORDER_DELIVERED_CUSTOMER_DATE > ORDER_ESTIMATED_DELIVERY_DATE THEN 'LATE'
        ELSE 'IN_TRANSIT'
     END AS ON_TIME

    /* ========================================================
       MÉTRICAS OPERACIONAIS
       ======================================================== */
    ,DATEDIFF(
        'DAY',
        ORDER_PURCHASE,
        ORDER_DELIVERED_CARRIER_DATE
     ) AS DAYS_IN_OPERATIONS

    ,DATEDIFF(
        'DAY',
        ORDER_DELIVERED_CARRIER_DATE,
        ORDER_DELIVERED_CUSTOMER_DATE
     ) AS DAYS_IN_TRANSIT

    ,CURRENT_TIMESTAMP() AS CREATED_AT

FROM SILVER.ORDER_DETAILS;