SELECT
  f.file_name
, f.file_id
, page_identifier = CONCAT(f.file_id, ':', p.allocated_page_page_id)
, page_id = p.allocated_page_page_id
, p.page_type
, page_type_desc = ISNULL(p.page_type_desc, 'EMPTY')
, free_bytes = ISNULL((100 - p.page_free_space_percent) / 100.0 * 8192, 0)
, used_bytes = ISNULL(p.page_free_space_percent / 100.0 * 8192, 8192)
, free_bytes_percent = ISNULL(p.page_free_space_percent, 100)
, p.is_mixed_page_allocation
, p.object_id
, schema_name = sch.[name]
, object_name = ob.[name]
, p.index_id
, index_name = ix.[name]
, p.partition_id
FROM (
	SELECT database_id, file_id, file_name = [name], size AS file_total_size
	, file_total_used_space = FILEPROPERTY([name], 'SpaceUsed')
	FROM sys.master_files AS f
	WHERE database_id = DB_ID() AND type = 0
) AS f
INNER JOIN sys.dm_db_database_page_allocations(DB_ID(),default,default,default,'DETAILED') AS p
ON f.file_id = p.allocated_page_file_id
LEFT JOIN sys.objects AS ob ON p.object_id = ob.object_id
LEFT JOIN sys.schemas AS sch ON ob.schema_id = sch.schema_id
LEFT JOIN sys.indexes AS ix ON p.object_id = ix.object_id AND p.index_id = ix.index_id