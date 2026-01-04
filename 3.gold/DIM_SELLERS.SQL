/* ============================================================
   GOLD – DIM_SELLERS
   ============================================================
   Camada: Gold
   Tipo: Dimensão
   Grão: 1 linha por SELLER_ID
   Origem: SILVER.SELLERS

   Objetivo:
   - Disponibilizar a dimensão de vendedores para consumo analítico
   - Servir como tabela de referência para fatos (ex.: ft_orders)
   - Centralizar informações geográficas e cadastrais do vendedor

   Estratégia de carga:
   - Rebuild completo (CREATE OR REPLACE TABLE)
   - Não mantém histórico (SCD Type 1)
   - Assume dados já padronizados e validados na Silver

   Justificativa técnica:
   - Dimensão simples, sem necessidade de versionamento
   - Volume controlado
   - Rebuild garante consistência total da dimensão
   - Reduz complexidade operacional ao evitar MERGE e lógica incremental

   Observações:
   - SELLER_ID é a chave natural do vendedor
   - Atributos geográficos são expostos no nível mais granular
   - CREATED_AT indica o momento de materialização na camada Gold
   ============================================================ */


CREATE OR REPLACE TABLE GOLD.DIM_SELLERS AS
SELECT
     SELLER_ID
    ,SELLER_CITY
    ,SELLER_STATE
    ,SELLER_ZIP_CODE_PREFIX
    ,CURRENT_TIMESTAMP AS CREATED_AT
FROM SILVER.SELLERS;