/* ============================================================
   CRIAÇÃO DA TABELA SILVER.SELLERS
   ============================================================
   Abordagem:
   - CREATE OR REPLACE TABLE
   - Substitui completamente o conteúdo anterior
   - Garante consistência e simplicidade operacional

   Justificativa:
   - Volume reduzido
   - Mudanças pouco frequentes
   - Custo de rebuild inferior à complexidade de MERGE
   ============================================================ */

CREATE OR REPLACE TABLE SILVER.SELLERS AS

SELECT 
     SELLER_ID
    ,UPPER(SELLER_CITY) AS SELLER_CITY
    ,SELLER_STATE
    ,SELLER_ZIP_CODE_PREFIX
    ,CURRENT_TIMESTAMP AS CREATED_AT
FROM BRONZE.SELLERS