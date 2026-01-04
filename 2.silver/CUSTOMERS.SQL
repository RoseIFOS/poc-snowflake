/* ============================================================
   CONTEXTO
   ============================================================
   Camada: Silver
   Objetivo:
   - Manter o estado atual confiável do cliente
   - Aplicar padronização básica (UPPER em city)
   - Detectar mudanças de atributos relevantes via HASH
   - Garantir carga idempotente usando MERGE

   Estratégia:
   - Bronze já estruturado (não é Bronze cego)
   - Silver representa o "current state" do cliente
   - Histórico de mudança será tratado na Gold
   ============================================================ */
   

/* ============================================================
   DEFINIÇÃO DE CONTEXTO
   ============================================================ */

USE DATABASE OLIST
USE SCHEMA BRONZE

/* ============================================================
   DDL – TABELA SILVER.CUSTOMERS
   ============================================================
   CUSTOMER_SK:
   - Chave substituta técnica (surrogate key)
   - Usada para relacionamentos futuros no DW

   CUSTOMER_ID:
   - Chave natural da fonte
   - Usada como critério de MERGE

   CREATED_AT:
   - Timestamp técnico de inserção
   - Preenchido automaticamente no INSERT
   - Não é atualizado em mudanças (SCD Type 1)

   HASH_DIFF:
   - Hash dos atributos relevantes do cliente
   - Usado para detectar mudanças de estado
   ============================================================ */


CREATE TABLE IF NOT EXISTS SILVER.CUSTOMERS (
     CUSTOMER_SK BIGINT AUTOINCREMENT
    ,CUSTOMER_ID STRING
    ,CUSTOMER_STATE STRING
    ,CUSTOMER_CITY STRING
    ,CUSTOMER_UNIQUE_ID STRING
    ,CUSTOMER_ZIP_CODE_PREFIX STRING
    ,CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
    ,HASH_DIFF STRING
);


/* ============================================================
   MERGE – BRONZE → SILVER
   ============================================================
   Lógica aplicada:
   - INSERT: quando o cliente ainda não existe na Silver
   - UPDATE: quando o cliente existe, mas algum atributo mudou

   Critério de mudança:
   - Comparação de HASH_DIFF
   - Evita updates desnecessários
   - Garante idempotência do processo
   ============================================================ */

MERGE INTO SILVER.CUSTOMERS AS S
USING (

SELECT
     CUSTOMER_ID
    ,CUSTOMER_STATE
    ,UPPER(CUSTOMER_CITY) AS CUSTOMER_CITY
    ,CUSTOMER_UNIQUE_ID
    ,CUSTOMER_ZIP_CODE_PREFIX
    ,CURRENT_TIMESTAMP AS CREATED_AT
    
    /* Hash usado para detectar mudança de estado do cliente. Somente atributos do negócio, campos técnicos não entram */
    ,md5(
        NVL(CUSTOMER_STATE, '') || '|' ||
        NVL(CUSTOMER_CITY, '') || '|' ||
        NVL(CUSTOMER_ZIP_CODE_PREFIX, '')
    ) AS HASH_DIFF
FROM BRONZE.CUSTOMERS

)  AS B

ON S.CUSTOMER_ID = B.CUSTOMER_ID

/* ============================================================
   UPDATE – CLIENTE EXISTENTE COM MUDANÇA
   ============================================================
   - Só atualiza se o hash for diferente
   - Evita reprocessamento desnecessário
   - Caracteriza um SCD Type 1 (sem histórico)
   ============================================================ */

WHEN MATCHED
    AND S.HASH_DIFF <> B.HASH_DIFF THEN
    UPDATE SET
         CUSTOMER_STATE = B.CUSTOMER_STATE
        ,CUSTOMER_CITY = B.CUSTOMER_CITY
        ,CUSTOMER_ZIP_CODE_PREFIX = B.CUSTOMER_ZIP_CODE_PREFIX
        ,HASH_DIFF = B.HASH_DIFF

WHEN NOT MATCHED THEN
    INSERT (
         CUSTOMER_ID
        ,CUSTOMER_STATE
        ,CUSTOMER_CITY
        ,CUSTOMER_UNIQUE_ID
        ,CUSTOMER_ZIP_CODE_PREFIX
        ,HASH_DIFF
    )

    VALUES (
         B.CUSTOMER_ID
        ,B.CUSTOMER_STATE
        ,B.CUSTOMER_CITY
        ,B.CUSTOMER_UNIQUE_ID
        ,B.CUSTOMER_ZIP_CODE_PREFIX
        ,B.HASH_DIFF
    )
    ;

/* ============================================================
   VALIDAÇÃO RÁPIDA
   ============================================================
   - Consulta simples para inspeção dos dados carregados
   - Usada apenas para validação manual
   ============================================================ */
   
SELECT * FROM SILVER.CUSTOMERS
LIMIT 10