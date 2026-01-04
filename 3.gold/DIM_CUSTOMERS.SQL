/* ============================================================
   GOLD – DIM_CUSTOMERS
   ============================================================
   Camada: Gold
   Tipo: Dimensão
   Grão: 1 linha por CUSTOMER_ID
   Origem: SILVER.CUSTOMERS

   Objetivo:
   - Expor a dimensão de clientes pronta para consumo analítico
   - Servir como tabela de referência para fatos (ex.: ft_orders)
   - Aplicar padronização final e nomenclatura semântica (DIM)

   Estratégia de carga:
   - Rebuild completo (CREATE OR REPLACE TABLE)
   - Não mantém histórico (SCD Type 1)
   - Assume que a Silver já está limpa e validada

   Justificativa técnica:
   - Dimensão simples, sem necessidade de controle temporal
   - Volume controlado

   Observações:
   - CUSTOMER_SK é mantida como surrogate key técnica
   - HASH_DIFF é preservado para rastreabilidade e possível auditoria
   - CREATED_AT indica o momento de materialização na camada Gold
   ============================================================ */

CREATE OR REPLACE TABLE GOLD.DIM_CUSTOMERS AS
SELECT
     CUSTOMER_SK
    ,CUSTOMER_ID
    ,CUSTOMER_STATE
    ,CUSTOMER_CITY
    ,CUSTOMER_UNIQUE_ID
    ,CUSTOMER_ZIP_CODE_PREFIX
    ,CURRENT_TIMESTAMP AS CREATED_AT
    ,HASH_DIFF
FROM SILVER.CUSTOMERS
