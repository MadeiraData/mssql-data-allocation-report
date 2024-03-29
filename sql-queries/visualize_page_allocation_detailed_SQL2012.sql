DECLARE @DatabaseName sysname = DB_NAME(), @ObjectName sysname = '[CyberProfiles].[Profile]', @ObjectType sysname = 'Table', @MaxItems int = 128

SET NOCOUNT ON;
DECLARE @IndexId int = NULL, @TableId int = NULL;

IF @ObjectType = 'Index'
BEGIN
	SELECT @TableId = object_id
	FROM sys.indexes
	WHERE name = @ObjectName

	IF @@ROWCOUNT <> 1 RAISERROR(N'Unable to determine table to which index "%s" belongs', 16, 1, @ObjectName);

	SET @IndexId = INDEXPROPERTY(@TableId, @ObjectName, 'IndexID');
END
ELSE IF @ObjectType = 'Table'
BEGIN
	SET @TableId = OBJECT_ID(@ObjectName);
END
ELSE IF @ObjectType <> 'Database'
BEGIN
	RAISERROR(N'Object Type "%s" is not supported', 16, 1, @ObjectType);
END

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
FROM sys.dm_db_database_page_allocations(DB_ID(@DatabaseName),@TableId,@IndexId,default,'DETAILED') AS p
INNER JOIN 
(
	SELECT file_id, file_name = [name], size AS file_total_size
	, file_total_used_space = FILEPROPERTY([name], 'SpaceUsed')
	FROM sys.database_files AS f
	WHERE type = 0
) AS f
ON f.file_id = p.allocated_page_file_id
LEFT JOIN sys.objects AS ob ON p.object_id = ob.object_id
LEFT JOIN sys.schemas AS sch ON ob.schema_id = sch.schema_id
LEFT JOIN sys.indexes AS ix ON p.object_id = ix.object_id AND p.index_id = ix.index_id