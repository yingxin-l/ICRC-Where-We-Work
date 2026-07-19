-- search country relate information
-- keypoints : LEFT, RIGHT join

SELECT
    t1.continent_name,
    t2.country_name,
    t3.icrc_name,
    t4.user_name,
    t5.article_title,
    t6.`desc`
FROM
    CONTINENT t1 RIGHT JOIN COUNTRY t2 ON t1.continent_id = t2.continent_id
    LEFT JOIN ICRC t3 ON t2.country_id = t3.country_id
    LEFT JOIN `USER` t4 ON t2.country_id = t4.country_id
    LEFT JOIN ARTICLE t5 ON t5.author_id = t4.user_id
    LEFT JOIN COUNTRY_INFO t6 ON t2.country_id = t6.country_id;


-- who write over one ARTICLEs
-- Key points: subquery , join

SELECT
    t3.user_name,
    t3.user_country,
    t4.country_name
FROM
    (
        SELECT t1.user_name, t1.user_country
        FROM `USER` t1
        WHERE t1.user_id IN (
            SELECT author_id FROM `ARTICLE` GROUP BY author_id HAVING COUNT(1) > 1
        )
    ) t3
    LEFT JOIN COUNTRY t4 ON t3.user_country = t4.country_id;


-- The person who writes the most articles with name
-- rank join agg

SELECT
    t2.user_name, COUNT(1) AS 'article num'
FROM
    ARTICLE t1
    LEFT JOIN `USER` t2 ON t1.author_id = t2.user_id
GROUP BY t1.author_id
ORDER BY COUNT(1) DESC
LIMIT 100;


-- top 10 images user in articles
-- agg join subquery

SELECT
    t2.*,
    t3.user_name
FROM
    (
        SELECT
            author_id,
            SUM(JSON_LENGTH(page_img_list)) AS image_total_per_person
        FROM ARTICLE t1
        GROUP BY author_id
        ORDER BY SUM(JSON_LENGTH(page_img_list)) DESC
    ) t2
    LEFT JOIN `USER` t3 ON t2.author_id = t3.user_id
LIMIT 10;


-- Per CONTINENT population avg contribution top3
-- string operate, json operate, join, subquery, agg, VIEW

-- Contributions in United States dollars per country

CREATE VIEW COUNTRY_CONTRIBUTE_USD_VIEW AS
SELECT
    t1.country_id,
    t1.country_name,
    t1.continent_id,
    t2.statistics,
    JSON_EXTRACT(t2.statistics, '$.population') AS 'population',
    JSON_EXTRACT(t2.statistics, '$.annual_aid_amount') AS 'annual_aid_amount',
    (SUBSTRING_INDEX(JSON_UNQUOTE(t2.statistics->'$.annual_aid_amount'), ' ', 1) + 0)
    * CASE
        WHEN JSON_UNQUOTE(t2.statistics->'$.annual_aid_amount') LIKE '%M%' THEN 1000000
        WHEN JSON_UNQUOTE(t2.statistics->'$.annual_aid_amount') LIKE '%B%' THEN 1000000000
      END
    / e.usd_exchange_rate AS aid_usd
FROM
    COUNTRY t1
    LEFT JOIN COUNTRY_INFO t2 ON t1.country_id = t2.country_id
    LEFT JOIN EXCHANGE_RATES e
    ON SUBSTRING(
        SUBSTRING_INDEX(JSON_EXTRACT(t2.statistics, '$.annual_aid_amount'), ' ', -1),
        1,
        LENGTH(SUBSTRING_INDEX(JSON_EXTRACT(t2.statistics, '$.annual_aid_amount'), ' ', -1)) - 1
    ) = e.currency_code;

SELECT
    t3.continent_id,
    t4.continent_name,
    SUM(aid_usd) AS aid_total,
    SUM(population) AS population_total,
    SUM(aid_usd) / SUM(population) AS avg_aid_per_person
FROM
    COUNTRY_CONTRIBUTE_USD_VIEW t3
    LEFT JOIN CONTINENT t4 ON t3.continent_id = t4.continent_id
GROUP BY continent_id
ORDER BY avg_aid_per_person DESC
LIMIT 3;