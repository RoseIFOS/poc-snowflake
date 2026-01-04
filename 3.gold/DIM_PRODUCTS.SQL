/* ============================================================
   GOLD – DIM_PRODUCTS
   ============================================================
   Camada: Gold
   Tipo: Dimensão
   Grão: 1 linha por PRODUCT_ID
   Origem: SILVER.PRODUCTS

   Objetivo:
   - Disponibilizar a dimensão de produtos para consumo analítico
   - Servir como tabela de referência para fatos (ex.: ft_orders)
   - Centralizar atributos físicos e categóricos do produto

   Estratégia de carga:
   - Rebuild completo (CREATE OR REPLACE TABLE)
   - Não mantém histórico (SCD Type 1)
   - Assume dados já padronizados e validados na Silver

   Justificativa técnica:
   - Dimensão estática ou de baixa mutabilidade
   - Volume controlado
   - Rebuild simplifica governança e reduz complexidade operacional
   - Evita uso desnecessário de MERGE ou lógica incremental

   Observações:
   - PRODUCT_ID é a chave natural do produto
   - Atributos dimensionais são mantidos no nível mais granular
   - CREATED_AT representa o timestamp de materialização na Gold
   ============================================================ */


CREATE OR REPLACE TABLE GOLD.DIM_PRODUCTS AS
SELECT
     PRODUCT_ID
    ,PRODUCT_CATEGORY_NAME
    ,PRODUCT_WEIGHT_G
    ,PRODUCT_WIDTH_CM
    ,PRODUCT_LENGTH_CM
    ,PRODUCT_HEIGHT_CM
    ,CURRENT_TIMESTAMP AS CREATED_AT
FROM SILVER.PRODUCTS;
