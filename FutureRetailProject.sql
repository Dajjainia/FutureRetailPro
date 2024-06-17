-- Tổng lợi nhuận tháng 10
select SUM([Total Profit (GMROI)] *[Quantity Ordered]) 
from BC1.[dbo].[10SE Regional Sales]
-- Tổng lợi nhuận tháng 10 theo từng loại mặt hàng
select [Product Category],
	COUNT([Order ID]) as SoDonHang,
	SUM([Total Profit (GMROI)] * [Quantity Ordered]) as Tongloinhuan
from BC1..[10SE Regional Sales]
group by [Product Category]

-- Tổng lợi nhuận tháng 11
select SUM([Total Profit (GMROI)] *[Quantity Ordered]) 
from BC1.[dbo].[11SE Regional Sales]

-- Tổng lợi nhuận tháng 11 theo từng mặt hàng sản phẩm
select [Product Category], SUM([Total Profit (GMROI)]*[Quantity Ordered]) as Loi_nhuan
from BC1.[dbo].[11SE Regional Sales]
group by [Product Category]
order by Loi_nhuan desc

-- Tổng lợi nhuận tháng 12 

SELECT SUM(CONVERT(decimal(10,2), [Total Profit (GMROI)]) * CONVERT(int, [Quantity Ordered]))
FROM BC1.[dbo].[12SE Regional Sales];

-- Lợi nhuận từng mặt hàng trong tháng 12 
SELECT [Product Category],
       COUNT([Order ID]) AS So_luong_don_hang,
       SUM(CAST([Quantity Ordered] AS int)) AS Tong_so_luong,  -- Assuming whole quantities
       SUM(CONVERT(decimal(10,2), [Total Profit (GMROI)] * CAST([Quantity Ordered] AS int))) AS Loi_nhuan
FROM BC1.[dbo].[12SE Regional Sales]
GROUP BY [Product Category]
ORDER BY Loi_nhuan DESC;




select [Product Category], SUM([Total Profit (GMROI)] * [Quantity Ordered]) as Loi_nhuan
from BC1.[dbo].[12SE Regional Sales]
where [Product Category] is not null
group by [Product Category]
order by Loi_nhuan desc

-- Quy mô giao dịch trung bình theo sản phẩm trong tháng 10
select * 
from BC1..[10SE Regional Sales]

select [Product Category], SUM([Transaction Price]) as Giatrigiaodich, (SUM([Transaction Price])/COUNT([Order ID])) as Quymo
from BC1..[10SE Regional Sales]
group by [Product Category]
-- Quy mô giao dịch trung bình theo sản phẩm trong tháng 11
select [Product Category], SUM([Transaction Price]) as Giatrigiaodich, (SUM([Transaction Price])/COUNT([Order ID])) as Quymo
from BC1..[11SE Regional Sales]
group by [Product Category]
-- Quy mô giao dịch trung bình theo sản phẩm trong tháng 12 
select [Product Category], SUM([Transaction Price]) as Giatrigiaodich, (SUM([Transaction Price])/COUNT([Order ID])) as Quymo
from BC1..[12SE Regional Sales]
group by [Product Category]

-- Quy mô giao dịch trung bình theo sản phẩm trong cả Quý 4
select * 
from BC1.[dbo].[SE Regional Sales]

select [Product Category], SUM([Total Profit (GMROI)] *[Quantity Ordered])/COUNT([Order ID]) as Gia_tri_giao_dich
from BC1.[dbo].[SE Regional Sales]
where [Product Category] is not null
group by [Product Category]

-- Lợi nhuận trung bình 1 sản phẩm theo mặt hàng trong Quý 4
select [Product Category], SUM([Total Profit (GMROI)])/COUNT([Quantity Ordered]) as LN1SP
from BC1.[dbo].[SE Regional Sales]
where [Product Category] is not null
group by [Product Category]

-- Số lượng đơn hàng bị hủy theo từng lý do trong Quý 4 
select [Return Reason], 
	COUNT([Order ID]) as SoDonHuy
from BC1..[SE Regional Sales]
where [Return Reason] is not null
group by [Return Reason]
-- Số lượng đơn hàng theo từng Bang trong Quý 4
select [State],
	COUNT([Order ID]) as SoDonHang
from BC1..[SE Regional Sales]
where [State] is not null
group by [State]

--Phân tích khách hàng bằng phương pháp RFM Analysis
--Tính toán Frequency, Monetary
SELECT  
    [Customer ID],
    MAX([Order Date]) AS last_purchase_date,
    COUNT([Order ID]) AS frequency,
    SUM([Sale Price] * [Quantity Ordered]) AS monetary 
INTO table1
FROM BC1..[SE Regional Sales]
WHERE [Customer ID] IS NOT NULL
GROUP BY [Customer ID];

select * 
from table1
-- Tính toán Recency
SELECT 
    *,
    DATEDIFF(DAY, last_purchase_date, MAX(last_purchase_date) OVER () + 1) AS recency
INTO table2
FROM table1;

select * from table2

-- Monetary percentiles
SELECT DISTINCT
    PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY monetary) OVER () AS m20,
    PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY monetary) OVER () AS m40,
    PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY monetary) OVER () AS m60,
    PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY monetary) OVER () AS m80,
    PERCENTILE_CONT(1.0) WITHIN GROUP (ORDER BY monetary) OVER () AS m100
INTO #monetary_percentile
FROM table2;

-- Frequency percentiles
SELECT DISTINCT
    PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY frequency) OVER () AS f20,
    PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY frequency) OVER () AS f40,
    PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY frequency) OVER () AS f60,
    PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY frequency) OVER () AS f80,
    PERCENTILE_CONT(1.0) WITHIN GROUP (ORDER BY frequency) OVER () AS f100
INTO #frequency_percentiles
FROM table2;

-- Recency percentiles
SELECT DISTINCT
    PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY recency) OVER () AS r20,
    PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY recency) OVER () AS r40,
    PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY recency) OVER () AS r60,
    PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY recency) OVER () AS r80,
    PERCENTILE_CONT(1.0) WITHIN GROUP (ORDER BY recency) OVER () AS r100
INTO #recency_percentiles
FROM table2;
-- Tính điểm số Recency, Frequency, Monetary cho từng khách hàng trong Quý 4
SELECT 
    a.*,
    b.m20, b.m40, b.m60, b.m80, b.m100,
    c.f20, c.f40, c.f60, c.f80, c.f100,
    d.r20, d.r40, d.r60, d.r80, d.r100
INTO table3
FROM 
    table2 a
    CROSS JOIN #monetary_percentile b
    CROSS JOIN #frequency_percentiles c
    CROSS JOIN #recency_percentiles d;

WITH t4 AS (
    SELECT 
        *, 
        CAST(ROUND((f_score + m_score) / 2.0, 0) AS INT) AS fm_score
    FROM (
        SELECT 
            *,
            CASE 
                WHEN monetary <= m20 THEN 1
                WHEN monetary <= m40 AND monetary > m20 THEN 2 
                WHEN monetary <= m60 AND monetary > m40 THEN 3 
                WHEN monetary <= m80 AND monetary > m60 THEN 4 
                WHEN monetary <= m100 AND monetary > m80 THEN 5
            END AS m_score,
            CASE 
                WHEN frequency <= f20 THEN 1
                WHEN frequency <= f40 AND frequency > f20 THEN 2 
                WHEN frequency <= f60 AND frequency > f40 THEN 3 
                WHEN frequency <= f80 AND frequency > f60 THEN 4 
                WHEN frequency <= f100 AND frequency > f80 THEN 5
            END AS f_score,
            -- Recency scoring is reversed
            CASE 
                WHEN recency <= r20 THEN 5
                WHEN recency <= r40 AND recency > r20 THEN 4 
                WHEN recency <= r60 AND recency > r40 THEN 3 
                WHEN recency <= r80 AND recency > r60 THEN 2 
                WHEN recency <= r100 AND recency > r80 THEN 1
            END AS r_score
        FROM table3
    ) AS subquery
),
t5 AS (
    SELECT 
        t4.[Customer ID], 
        t4.recency,
        t4.frequency,
        t4.monetary,
        t4.r_score,
        t4.f_score,
        t4.m_score,
        t4.fm_score,
        CASE 
            WHEN (t4.r_score = 5 AND t4.fm_score = 5) 
                OR (t4.r_score = 5 AND t4.fm_score = 4) 
                OR (t4.r_score = 4 AND t4.fm_score = 5) 
            THEN 'Champions'
            WHEN (t4.r_score = 5 AND t4.fm_score = 3) 
                OR (t4.r_score = 4 AND t4.fm_score = 4)
                OR (t4.r_score = 3 AND t4.fm_score = 5)
                OR (t4.r_score = 3 AND t4.fm_score = 4)
            THEN 'Loyal Customers'
            WHEN (t4.r_score = 5 AND t4.fm_score = 2) 
                OR (t4.r_score = 4 AND t4.fm_score = 2)
                OR (t4.r_score = 3 AND t4.fm_score = 3)
                OR (t4.r_score = 4 AND t4.fm_score = 3)
            THEN 'Potential Loyalists'
            WHEN t4.r_score = 5 AND t4.fm_score = 1 THEN 'Recent Customers'
            WHEN (t4.r_score = 4 AND t4.fm_score = 1) 
                OR (t4.r_score = 3 AND t4.fm_score = 1)
            THEN 'Promising'
            WHEN (t4.r_score = 3 AND t4.fm_score = 2) 
                OR (t4.r_score = 2 AND t4.fm_score = 3)
                OR (t4.r_score = 2 AND t4.fm_score = 2)
            THEN 'Customers Needing Attention'
            WHEN t4.r_score = 2 AND t4.fm_score = 1 THEN 'About to Sleep'
            WHEN (t4.r_score = 2 AND t4.fm_score = 5) 
                OR (t4.r_score = 2 AND t4.fm_score = 4)
                OR (t4.r_score = 1 AND t4.fm_score = 3)
            THEN 'At Risk'
            WHEN (t4.r_score = 1 AND t4.fm_score = 5)
                OR (t4.r_score = 1 AND t4.fm_score = 4)        
            THEN 'Cant Lose Them'
            WHEN t4.r_score = 1 AND t4.fm_score = 2 THEN 'Hibernating'
            WHEN t4.r_score = 1 AND t4.fm_score = 1 THEN 'Lost'
        END AS rfm_segment 
    FROM t4
)
SELECT * FROM t5;

        frequency,
        monetary,
        CAST(ROUND((frequency + monetary) / 2.0, 0) AS INT) AS fm_score,
        CASE 
            WHEN monetary <= 20 THEN 1
            WHEN monetary <= 40 THEN 2
            WHEN monetary <= 60 THEN 3
            WHEN monetary <= 80 THEN 4
            WHEN monetary <= 100 THEN 5
        END AS m_score,
        CASE 
            WHEN frequency <= 20 THEN 1
            WHEN frequency <= 40 THEN 2
            WHEN frequency <= 60 THEN 3
            WHEN frequency <= 80 THEN 4
            WHEN frequency <= 100 THEN 5
        END AS f_score,
        CASE 
            WHEN recency <= 20 THEN 5
            WHEN recency <= 40 THEN 4
            WHEN recency <= 60 THEN 3
            WHEN recency <= 80 THEN 2
            WHEN recency <= 100 THEN 1
        END AS r_score
    FROM table3
),
t5 AS (
    SELECT 
        t4.[Customer ID], 
        t4.recency,
        t4.frequency,
        t4.monetary,
        t4.r_score,
        t4.f_score,
        t4.m_score,
        t4.fm_score,
        CASE 
            WHEN (t4.r_score = 5 AND t4.fm_score = 5) 
                OR (t4.r_score = 5 AND t4.fm_score = 4) 
                OR (t4.r_score = 4 AND t4.fm_score = 5) 
            THEN 'Champions'
            WHEN (t4.r_score = 5 AND t4.fm_score = 3) 
                OR (t4.r_score = 4 AND t4.fm_score = 4)
                OR (t4.r_score = 3 AND t4.fm_score = 5)
                OR (t4.r_score = 3 AND t4.fm_score = 4)
            THEN 'Loyal Customers'
            WHEN (t4.r_score = 5 AND t4.fm_score = 2) 
                OR (t4.r_score = 4 AND t4.fm_score = 2)
                OR (t4.r_score = 3 AND t4.fm_score = 3)
                OR (t4.r_score = 4 AND t4.fm_score = 3)
            THEN 'Potential Loyalists'
            WHEN t4.r_score = 5 AND t4.fm_score = 1 THEN 'Recent Customers'
            WHEN (t4.r_score = 4 AND t4.fm_score = 1) 
                OR (t4.r_score = 3 AND t4.fm_score = 1)
            THEN 'Promising'
            WHEN (t4.r_score = 3 AND t4.fm_score = 2) 
                OR (t4.r_score = 2 AND t4.fm_score = 3)
                OR (t4.r_score = 2 AND t4.fm_score = 2)
            THEN 'Customers Needing Attention'
            WHEN t4.r_score = 2 AND t4.fm_score = 1 THEN 'About to Sleep'
            WHEN (t4.r_score = 2 AND t4.fm_score = 5) 
                OR (t4.r_score = 2 AND t4.fm_score = 4)
                OR (t4.r_score = 1 AND t4.fm_score = 3)
            THEN 'At Risk'
            WHEN (t4.r_score = 1 AND t4.fm_score = 5)
                OR (t4.r_score = 1 AND t4.fm_score = 4)        
            THEN 'Cant Lose Them'
            WHEN t4.r_score = 1 AND t4.fm_score = 2 THEN 'Hibernating'
            WHEN t4.r_score = 1 AND t4.fm_score = 1 THEN 'Lost'
        END AS rfm_segment 
    FROM t4
)
SELECT * FROM t5;
