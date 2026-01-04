--DDL - CRIACAO DA ESTRUTURA DA TABELA NA BRONZE-----------

CREATE TABLE IF NOT EXISTS SILVER.ORDER_ITEMS (
     order_id string
    ,order_item_id string
    ,product_id string
    ,seller_id string
    ,price float
    ,freight_value float
    ,shipping_limit_date date
    ,created_at datetime
    
        );


---- APAGA DADOS DA TABELA ------------------
TRUNCATE TABLE SILVER.ORDER_ITEMS;

-----INSERE DADOS NA TABELA------------------
INSERT INTO SILVER.ORDER_ITEMS

SELECT
     ORDER_ID
    ,ORDER_ITEM_ID
    ,PRODUCT_ID
    ,SELLER_ID
    ,PRICE
    ,FREIGHT_VALUE
    ,SHIPPING_LIMIT_DATE
    ,CURRENT_TIMESTAMP AS CREATED_AT
FROM BRONZE.ORDER_ITEMS
;

SELECT * FROM SILVER.ORDER_ITEMS
LIMIT 10;