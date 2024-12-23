-- membuat tabel baru dengan nama kf_tabel_analisa
CREATE TABLE 
    rakamin-kf-analytics-445318.kimia_farma.kf_tabel_analisa AS
-- digunakan perintah cte dengan membuat subquery 'main'
WITH
    main AS (
        -- 'main' menampilkan kolom transaction_id, date, branch_id, branch_name, kota, provinsi, rating_cabang, customer_name, product_id, product_name, actual_price, discount_percentage, persentase_gross_laba, nett_sales
        SELECT 
            transaction_id, date, t.branch_id, branch_name, kota, provinsi, c.rating rating_cabang, customer_name, t.product_id, product_name, p.price actual_price, discount_percentage,
            -- ketentuan persentase laba
            CASE 
                WHEN p.price <= 50000 THEN 0.1
                WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
                WHEN p.price > 100000 AND p.price <= 300000 THEN 0.2
                WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
                ELSE 0.3
            END 
            AS persentase_gross_laba, p.price*(1-discount_percentage) AS nett_sales
        FROM 
            rakamin-kf-analytics-445318.kimia_farma.kf_final_transaction t
        -- dilakukan join tabel transaksi dengan tabel kantor cabang untuk menambahkan kolom nama cabang, kota, provinsi, dan rating cabang yang tidak terdapat pada tabel transaksi
        LEFT JOIN
            rakamin-kf-analytics-445318.kimia_farma.kf_kantor_cabang c
        ON
            t.branch_id = c.branch_id
        -- dan dengan tabel produk untuk menambahkan kolom nama produk yang tidak terdapat pada tabel transaksi
        LEFT JOIN
            rakamin-kf-analytics-445318.kimia_farma.kf_product p
        ON
            t.product_id = p.product_id
    )
-- menampilkan keseluruhan kolom 'main' + nett_profit dan rating_transaksi
SELECT
    DISTINCT main.*, (actual_price*persentase_gross_laba)-(actual_price-nett_sales) nett_profit, t.rating rating_transaksi
FROM
    main, rakamin-kf-analytics-445318.kimia_farma.kf_final_transaction t
WHERE
    main.transaction_id = t.transaction_id
-- mengurutkan dari transaksi terbaru
ORDER BY
    date DESC;
