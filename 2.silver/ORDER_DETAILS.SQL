/* ============================================================
   SILVER – ORDER_DETAILS
   ============================================================
   Camada: Silver
   Tipo: Tabela intermediária (conformed / enriched)
   Grão: 1 linha por ITEM do pedido (ORDER_ID + PRODUCT_ID + SELLER_ID)
   Origem:
     - SILVER.ORDERS      (cabeçalho do pedido)
     - SILVER.ORDER_ITEMS (itens do pedido)

   Objetivo:
   - Consolidar informações de cabeçalho e itens do pedido
   - Reduzir complexidade de joins nas camadas superiores
   - Servir como base única e consistente para construção da camada Gold
   - Padronizar o grão analítico antes da modelagem de fatos

   Estratégia de carga:
   - Rebuild completo (CREATE OR REPLACE TABLE)
   - Não mantém histórico (SCD Type 1)
   - Assume que as tabelas de origem já passaram por validações na Silver

   Justificativa técnica:
   - Tabela participa ativamente do pipeline (não é apenas visão)

   Uso downstream:
   - Fonte principal para construção da GOLD.FT_ORDERS
   - Pode ser utilizada diretamente por análises exploratórias
   - Facilita criação de métricas (GMV, freight, lead time, SLA)

   Observações importantes:
   - Atributos técnicos (ex.: CREATED_AT) não participam de regras de negócio
   - HASH_DIFF é herdado do cabeçalho para rastreabilidade de mudanças
   - Esta tabela representa o ponto de convergência entre entidades transacionais

   ============================================================ */

CREATE OR REPLACE TABLE SILVER.ORDER_DETAILS AS 

SELECT
    /* ========================================================
       QUANDO, O QUE, QUANTO, PARA QUEM
       ======================================================== */
     ODI.ORDER_ID
    ,OD.ORDER_PURCHASE
    ,ODI.SELLER_ID
    ,ODI.PRODUCT_ID
    ,ODI.PRICE
    ,ODI.FREIGHT_VALUE
    ,OD.CUSTOMER_ID

    /* ========================================================
       INFORMAÇÕES DO PEDIDO
       ======================================================== */
    ,OD.ORDER_STATUS
    ,ODI.SHIPPING_LIMIT_DATE
    ,OD.ORDER_ESTIMATED_DELIVERY_DATE

    /* ========================================================
       INFORMAÇÕES DE ENTREGA
       ======================================================== */
    ,OD.ORDER_DELIVERED_CARRIER_DATE
    ,OD.ORDER_DELIVERED_CUSTOMER_DATE
    ,OD.HASH_DIFF

    ,CURRENT_TIMESTAMP() AS CREATED_AT

FROM SILVER.ORDER_ITEMS ODI
LEFT JOIN SILVER.ORDERS OD
    ON ODI.ORDER_ID = OD.ORDER_ID;