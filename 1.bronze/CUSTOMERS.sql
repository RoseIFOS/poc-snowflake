CREATE OR REPLACE TABLE BRONZE.CUSTOMERS AS 
SELECT
     $1:"customer_id"::string as customer_id
    ,$1:"customer_state"::string as customer_state
    ,$1:"customer_city"::string as customer_city
    ,$1:"customer_unique_id"::string as customer_unique_id
    ,$1:"customer_zip_code_prefix"::string as customer_zip_code_prefix
    ,current_timestamp as created_at
    ,metadata$filename as source_file
FROM @S3_OLIST/raw/customers
(FILE_FORMAT => 'PARQUET_FORMAT')
;