/* ============================================================
   CONTEXTO
   ============================================================
   Camada: Silver
   Entidade: Orders
   Origem: Bronze.Orders

   Objetivo:
   - Manter o estado atual do pedido
   - Padronizar atributos textuais
   - Detectar mudança de status e datas via hash
   - Garantir idempotência na carga

   Estratégia:
   - SCD Type 1 (sobrescrita)
   - Histórico será tratado na Gold
   ============================================================ */

   /* ============================================================
   DDL – TABELA SILVER.ORDERS
   ============================================================
   ORDER_ID:
   - Chave natural do pedido na fonte

   HASH_DIFF:
   - Hash dos atributos de negócio
   - Usado para detectar mudança de estado
   ============================================================ */
--DROP TABLE SILVER.ORDERS;

CREATE TABLE IF NOT EXISTS SILVER.ORDERS (
     ORDER_ID STRING
    ,CUSTOMER_ID STRING
    ,ORDER_STATUS STRING
    ,ORDER_PURCHASE DATE
    ,ORDER_ESTIMATED_DELIVERY_DATE DATE
    ,ORDER_DELIVERED_CARRIER_DATE DATE
    ,ORDER_DELIVERED_CUSTOMER_DATE DATE
    ,CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
    ,HASH_DIFF STRING
);


/* ============================================================
   MERGE – BRONZE → SILVER
   ============================================================
   Lógica aplicada:
   - INSERT: novo pedido
   - UPDATE: pedido existente com mudança de estado

   Critério de mudança:
   - Comparação de HASH_DIFF
   - Evita updates desnecessários
   - Garante idempotência do processo
   ============================================================ */

MERGE INTO SILVER.ORDERS AS S
USING (

SELECT
     ORDER_ID
    ,CUSTOMER_ID
    ,UPPER(ORDER_STATUS) AS ORDER_STATUS
    ,ORDER_PURCHASE_TIMESTAMP AS ORDER_PURCHASE
    ,ORDER_ESTIMATED_DELIVERY_DATE
    ,ORDER_DELIVERED_CARRIER_DATE
    ,ORDER_DELIVERED_CUSTOMER_DATE
    ,CURRENT_TIMESTAMP AS CREATED_AT
    
    /* Hash usado para detectar mudança de estado. Somente atributos do negócio, campos técnicos não entram */
    ,md5(
        NVL(ORDER_STATUS, '') || '|' ||
        NVL(TO_VARCHAR(ORDER_ESTIMATED_DELIVERY_DATE), '') || '|' ||
        NVL(TO_VARCHAR(ORDER_DELIVERED_CARRIER_DATE), '') || '|' ||
        NVL(TO_VARCHAR(ORDER_DELIVERED_CUSTOMER_DATE), '')
    ) AS HASH_DIFF
FROM BRONZE.ORDERS

)  AS B

ON S.ORDER_ID = B.ORDER_ID



WHEN MATCHED
    AND S.HASH_DIFF <> B.HASH_DIFF THEN
    UPDATE SET
         ORDER_STATUS = B.ORDER_STATUS
        ,ORDER_ESTIMATED_DELIVERY_DATE = B.ORDER_ESTIMATED_DELIVERY_DATE
        ,ORDER_DELIVERED_CARRIER_DATE = B.ORDER_DELIVERED_CARRIER_DATE
        ,ORDER_DELIVERED_CUSTOMER_DATE = B.ORDER_DELIVERED_CUSTOMER_DATE
        ,HASH_DIFF = B.HASH_DIFF

WHEN NOT MATCHED THEN
    INSERT (
         ORDER_ID
        ,CUSTOMER_ID
        ,ORDER_STATUS
        ,ORDER_PURCHASE
        ,ORDER_ESTIMATED_DELIVERY_DATE
        ,ORDER_DELIVERED_CARRIER_DATE
        ,ORDER_DELIVERED_CUSTOMER_DATE
        ,HASH_DIFF
        )

    VALUES (
         B.ORDER_ID
        ,B.CUSTOMER_ID
        ,B.ORDER_STATUS
        ,B.ORDER_PURCHASE
        ,B.ORDER_ESTIMATED_DELIVERY_DATE
        ,B.ORDER_DELIVERED_CARRIER_DATE
        ,B.ORDER_DELIVERED_CUSTOMER_DATE
        ,B.HASH_DIFF
    )
    ;

/* ============================================================
   VALIDAÇÃO RÁPIDA
   ============================================================
   - Consulta simples para inspeção dos dados carregados
   - Usada apenas para validação manual
   ============================================================ */
   
SELECT * FROM SILVER.ORDERS
LIMIT 10