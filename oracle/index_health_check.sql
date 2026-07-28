-- oracle/index_health_check.sql
-- Identifies unused, fragmented, and high-cost indexes in an Oracle
-- database to support performance and index-tuning reviews.

-- 1. Indexes with high clustering factor relative to table rows
--    (a strong candidate for review/rebuild)
SELECT
    i.owner,
    i.index_name,
    i.table_name,
    i.clustering_factor,
    t.num_rows,
    ROUND(i.clustering_factor / NULLIF(t.num_rows, 0), 2) AS clustering_ratio
FROM all_indexes i
JOIN all_tables t
  ON i.table_name = t.table_name AND i.owner = t.owner
WHERE i.owner NOT IN ('SYS', 'SYSTEM')
  AND t.num_rows > 10000
ORDER BY clustering_ratio DESC
FETCH FIRST 25 ROWS ONLY;

-- 2. Unused indexes (requires index monitoring to be enabled)
SELECT
    index_name,
    table_name,
    monitoring,
    used,
    start_monitoring,
    end_monitoring
FROM v$object_usage
WHERE used = 'NO';

-- 3. Indexes flagged as UNUSABLE (need rebuild)
SELECT owner, index_name, table_name, status
FROM all_indexes
WHERE status != 'VALID'
  AND owner NOT IN ('SYS', 'SYSTEM');

-- 4. Suggested rebuild statement template for unusable indexes
-- ALTER INDEX <owner>.<index_name> REBUILD ONLINE;

