SELECT
  databse_name = DB_NAME()
, file_name
, page_identifier = CONCAT(file_id,':',pt.from_page_id)
, check_file_total_size = file_total_size
, check_file_total_used_space = file_total_used_space
, check_file_total_unused_pages = file_total_unused_pages
, agg_file_total_reserved_pages = file_total_reserved_pages
, agg_file_total_consecutive_unused_pages = SUM(pt.consecutive_unused_pages) OVER (PARTITION BY file_id)
, pt.*
, pages_in_range = pt.to_page_id - pt.from_page_id + 1
FROM
(
SELECT
  databse_name = DB_NAME()
, file_id
, file_name
, file_total_size
, file_total_used_space
, file_total_unused_pages = file_total_size - file_total_reserved_pages + 1
, file_total_reserved_pages
, prev_used_page
, from_used_page_id = allocated_page_page_id
, to_page_id = ISNULL(NULLIF(next_used_page,file_total_size-1) - 1, next_used_page)
, consecutive_unused_pages = ISNULL(NULLIF(next_used_page,file_total_size-1) - 1, next_used_page) - allocated_page_page_id
, next_used_page_id = LEAD(allocated_page_page_id,1,file_total_size-1) OVER(PARTITION BY file_id ORDER BY allocated_page_page_id ASC)
FROM
(
SELECT
  f.database_id, f.file_id, f.file_name, f.file_total_used_space, f.file_total_size
, file_total_reserved_pages = COUNT(*) OVER() + 9
, p.allocated_page_page_id
, prev_used_page = LAG(p.allocated_page_page_id,1,0) OVER (PARTITION BY f.file_id ORDER BY p.allocated_page_page_id ASC)
, next_used_page = LEAD(p.allocated_page_page_id,1,f.file_total_size - 1) OVER (PARTITION BY f.file_id ORDER BY p.allocated_page_page_id ASC)
FROM (
	SELECT database_id, file_id, file_name = [name], size AS file_total_size
	, file_total_used_space = FILEPROPERTY([name], 'SpaceUsed')
	FROM sys.master_files AS f
	WHERE database_id = DB_ID() AND type = 0
) AS f
INNER JOIN sys.dm_db_database_page_allocations(DB_ID(),default,default,default,'DETAILED') AS p
ON f.file_id = p.allocated_page_file_id
) AS sub1
WHERE sub1.next_used_page <> sub1.allocated_page_page_id + 1
) AS sub2
CROSS APPLY
(
	SELECT usage = 'EMPTY'
		, from_page_id = from_used_page_id + 1
		, to_page_id = sub2.to_page_id
		, consecutive_unused_pages = sub2.consecutive_unused_pages
	UNION ALL
	SELECT
		usage = 'USED'
		, 0
		, sub2.from_used_page_id
		, 0
	WHERE prev_used_page = 0
	UNION ALL
	SELECT
		usage = 'USED'
		, sub2.to_page_id + 1
		, sub2.next_used_page_id
		, 0
	WHERE next_used_page_id < file_total_size-1
) AS pt