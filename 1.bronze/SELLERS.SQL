CREATE OR REPLACE TABLE BRONZE.SELLERS AS 
SELECT
     $1:"seller_id"::string as seller_id
    ,$1:"seller_city"::string as seller_city
    ,$1:"seller_state"::string as seller_state
    ,$1:"seller_zip_code_prefix"::string as seller_zip_code_prefix
    ,current_timestamp as created_at
    ,metadata$filename as source_file
FROM @S3_OLIST/raw/sellers
(FILE_FORMAT => 'PARQUET_FORMAT')
;