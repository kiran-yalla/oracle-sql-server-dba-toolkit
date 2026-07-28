-- sqlserver/dba_dash_health_queries.sql
-- Sample T-SQL health/performance queries in the style used alongside
-- DBA Dash for proactive SQL Server monitoring and issue identification.

-- 1. Top 10 queries by average CPU time (identify expensive queries)
SELECT TOP 10
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    qs.execution_count,
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
    SUBSTRING(st.text, (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset END
            - qs.statement_start_offset) / 2) + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY avg_cpu_time DESC;

-- 2. Index fragmentation report (rebuild/reorganize candidates)
SELECT
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i
  ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 20
  AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- 3. Blocking sessions snapshot
SELECT
    blocking.session_id AS blocking_session,
    blocked.session_id AS blocked_session,
    blocked.wait_type,
    blocked.wait_time,
    blocked.wait_resource
FROM sys.dm_exec_requests blocked
JOIN sys.dm_exec_sessions blocking
  ON blocked.blocking_session_id = blocking.session_id
WHERE blocked.blocking_session_id != 0;

-- 4. Database and log file space usage
SELECT
    DB_NAME(database_id) AS database_name,
    type_desc,
    name AS file_name,
    size / 128.0 AS size_mb,
    size / 128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT) / 128.0 AS free_space_mb
FROM sys.master_files
WHERE database_id = DB_ID();

