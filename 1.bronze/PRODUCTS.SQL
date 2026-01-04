CREATE OR REPLACE TABLE BRONZE.PRODUCTS AS 
SELECT
     $1:"product_id"::string as product_id
    ,$1:"product_category_name"::string as product_category_name
    ,$1:"product_weight_g"::integer as product_weight_g
    ,$1:"product_width_cm"::integer as product_width_cm
    ,$1:"product_length_cm"::integer as product_length_cm
    ,$1:"product_height_cm"::integer as product_height_cm
    ,current_timestamp as created_at
    ,metadata$filename as source_file
FROM @S3_OLIST/raw/products
(FILE_FORMAT => 'PARQUET_FORMAT')
;