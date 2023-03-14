use otus;

drop procedure if exists otus.insert_ord_status;
delimiter //
CREATE procedure otus.insert_ord_status()
BEGIN
    INSERT INTO otus.order_statuses (id, status)
    VALUES (5, 'Тестовый статус');

    INSERT INTO otus.orders (id, user_id, order_status_id, payment_type_id)
    VALUES (6, 3, 5, 1);
END
    //
delimiter ;

call insert_ord_status();

begin;
SELECT count(*) FROM otus.orders;
call insert_ord_status();
SELECT count(*) FROM otus.orders;
commit;

drop TABLE if exists test_load;
create table if not exists otus.jewelry
(
    Handle                                  varchar(100),
    Title                                   varchar(100),
    Body_HTML                               varchar(1000),
    Vendor                                  varchar(100),
    Type                                    varchar(100),
    Tags                                    varchar(100),
    Published                               varchar(100),
    Option1_Name                            varchar(100),
    Option1_Value                           varchar(100),
    Option2_Name                            varchar(100),
    Option2_Value                           varchar(100),
    Option3_Name                            varchar(100),
    Option3_Value                           varchar(100),
    Variant_SKU                             varchar(100),
    Variant_Grams                           varchar(100),
    Variant_Inventory_Tracker               varchar(100),
    Variant_Inventory_Qty                   varchar(100),
    Variant_Inventory_Policy                varchar(100),
    Variant_Fulfillment_Service             varchar(100),
    Variant_Price                           varchar(100),
    Variant_Compare_At_Price                varchar(100),
    Variant_Requires_Shipping               varchar(100),
    Variant_Taxable                         varchar(100),
    Variant_Barcode                         varchar(100),
    Image_Src                               varchar(1000),
    Image_Alt_Text                          varchar(1000),
    Gift_Card                               varchar(100),
    SEO_Title                               varchar(100),
    SEO_Description                         varchar(100),
    Google_Shopping_Google_Product_Category varchar(100),
    Google_Shopping_Gender                  varchar(100),
    Google_Shopping_Age_Group               varchar(100),
    Google_Shopping_MPN                     varchar(100),
    Google_Shopping_AdWords_Grouping        varchar(100),
    Google_Shopping_AdWords_Labels          varchar(100),
    Google_Shopping_Condition               varchar(100),
    Google_Shopping_Custom_Product          varchar(100),
    Google_Shopping_Custom_Label_0          varchar(100),
    Google_Shopping_Custom_Label_1          varchar(100),
    Google_Shopping_Custom_Label_2          varchar(100),
    Google_Shopping_Custom_Label_3          varchar(100),
    Google_Shopping_Custom_Label_4          varchar(100),
    Variant_Image                           varchar(100),
    Variant_Weight_Unit                     varchar(100)
);

LOAD DATA INFILE '/csv/jewelry.csv'
    INTO TABLE otus.jewelry
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;

SELECT * from otus.jewelry;

-- mysqlimport otus -p -u root --ignore-lines=1 --lines-terminated-by="\n" --fields-terminated-by="," --fields-enclosed-by="\"" "/csv/jewelry.csv"

SELECT * FROM otus.jewelry;