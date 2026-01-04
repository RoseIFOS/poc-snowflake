--DDL - CRIACAO DA ESTRUTURA DA TABELA NA BRONZE-----------

CREATE TABLE IF NOT EXISTS BRONZE.ORDER_ITEMS (
     order_id string
    ,order_item_id string
    ,product_id string
    ,seller_id string
    ,price float
    ,freight_value float
    ,shipping_limit_date date
    ,created_at datetime
    ,source_file string
    );


---- APAGA DADOS DA TABELA ------------------
TRUNCATE TABLE BRONZE.ORDER_ITEMS;

-----INSERE DADOS NA TABELA------------------
COPY INTO BRONZE.ORDER_ITEMS
FROM (

SELECT
     $1:"order_id"::string as order_id
    ,$1:"order_item_id"::string as order_item_id
    ,$1:"product_id"::string as product_id
    ,$1:"seller_id"::string as seller_id
    ,$1:"price"::float as price
    ,$1:"freight_value"::float as freight_value
    ,$1:"shipping_limit_date"::date as shipping_limit_date
    ,current_timestamp as created_at
    ,metadata$filename as source_file
FROM @S3_OLIST/raw/orderitems
(FILE_FORMAT => 'PARQUET_FORMAT')
    )
;

select * from bronze.order_items
limit 10;