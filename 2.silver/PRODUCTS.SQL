/* ============================================================
   CRIAÇÃO DA TABELA SILVER.PRODUCTS
   ============================================================
   Abordagem:
   - CREATE OR REPLACE TABLE
   - Substitui completamente o conteúdo anterior
   - Garante consistência total da tabela

   Justificativa:
   - Dimensão pequena
   - Baixa frequência de mudança
   - Simplicidade > complexidade de MERGE
   ============================================================ */
--DROP TABLE SILVER.PRODUCTS;

USE DATABASE OLIST;

CREATE OR REPLACE TABLE SILVER.PRODUCTS AS

SELECT 
     PRODUCT_ID
    ,UPPER(PRODUCT_CATEGORY_NAME) AS PRODUCT_CATEGORY_NAME
    ,PRODUCT_WEIGHT_G
    ,PRODUCT_WIDTH_CM
    ,PRODUCT_LENGTH_CM
    ,PRODUCT_HEIGHT_CM
    ,CURRENT_TIMESTAMP AS CREATED_AT
FROM BRONZE.PRODUCTS;