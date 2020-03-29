SELECT
  f.file_name
, f.file_id
, page_identifier = CONCAT(f.file_id, ':', f.page_id)
, f.page_id
, p.page_type
, page_type_desc = ISNULL(p.page_type_desc, 'EMPTY')
, free_bytes = ISNULL(p.free_bytes, 8 * 1024)
, used_bytes = ISNULL(p.free_bytes_offset, 0)
, free_bytes_percent = ISNULL(p.free_bytes * 100 / (p.free_bytes + p.free_bytes_offset), 100)
, p.is_mixed_extent
, p.object_id
, schema_name = sch.[name]
, object_name = ob.[name]
, p.index_id
, index_name = ix.[name]
, p.partition_id
FROM (
	SELECT database_id, file_id, file_name = [name], size, c.page_id
	FROM sys.master_files AS f
	CROSS APPLY
	(
		SELECT TOP(f.size) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS page_id
		FROM sys.all_columns a CROSS JOIN sys.all_columns b
	) AS c 
	WHERE database_id = DB_ID() AND type = 0
) AS f
OUTER APPLY sys.dm_db_page_info(f.database_id, f.file_id, page_id, 'DETAILED') AS p
LEFT JOIN sys.objects AS ob ON p.object_id = ob.object_id
LEFT JOIN sys.schemas AS sch ON ob.schema_id = sch.schema_id
LEFT JOIN sys.indexes AS ix ON p.object_id = ix.object_id AND p.index_id = ix.index_id
