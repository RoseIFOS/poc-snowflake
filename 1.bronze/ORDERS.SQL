--DDL - CRIACAO DA ESTRUTURA DA TABELA NA BRONZE-----------

CREATE TABLE IF NOT EXISTS BRONZE.ORDERS (
     order_id string 
    ,customer_id string
    ,order_status string
    ,order_purchase_timestamp date
    ,order_estimated_delivery_date date
    ,order_delivered_carrier_date date
    ,order_delivered_customer_date date
    ,created_at datetime
    ,source_file string);


---- APAGA DADOS DA TABELA ------------------
TRUNCATE TABLE BRONZE.ORDERS;

-----INSERE DADOS NA TABELA------------------
COPY INTO BRONZE.ORDERS
FROM (
SELECT
     $1:"order_id"::string as order_id
    ,$1:"customer_id"::string as customer_id
    ,$1:"order_status"::string as order_status
    ,$1:"order_purchase_timestamp"::date as order_purchase_timestamp
    ,$1:"order_estimated_delivery_date"::date as order_estimated_delivery_date
    ,$1:"order_delivered_carrier_date"::date as order_delivered_carrier_date
    ,$1:"order_delivered_customer_date"::date as order_delivered_customer_date
    ,current_timestamp as created_at
    ,metadata$filename as source_file
FROM @S3_OLIST/raw/orders
(FILE_FORMAT => 'PARQUET_FORMAT')
    )
;

select * from bronze.orders
limit 10;