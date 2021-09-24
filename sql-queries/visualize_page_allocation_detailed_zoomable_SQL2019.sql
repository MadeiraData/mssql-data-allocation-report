DECLARE @DatabaseName sysname = DB_NAME(), @ObjectName sysname = '[CyberProfiles].[Profile]', @ObjectType sysname = 'Table', @MaxItems int = 128
DECLARE @FileId int = NULL, @FromPage bigint = 0, @ToPage bigint = NULL

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
, p.PageGroup
, from_page_id = MIN(p.page_id)
, to_page_id = MAX(p.page_id)
, page_count = COUNT(p.page_id)
, free_kb = SUM(ISNULL(pinfo.free_bytes, 8 * 1024)) / 1024
, used_kb = SUM(ISNULL(pinfo.free_bytes_offset, 0)) / 1024
FROM
(
SELECT p.allocated_page_file_id
, page_id = p.allocated_page_page_id
, p.page_type
, page_type_desc = ISNULL(p.page_type_desc, 'EMPTY')
, free_bytes = CASE WHEN ISNULL(p.page_type_desc, 'EMPTY') = 'EMPTY' THEN 8192 ELSE ISNULL((100 - p.page_free_space_percent) / 100.0 * 8192, 0) END
, used_bytes = CASE WHEN ISNULL(p.page_type_desc, 'EMPTY') = 'EMPTY' THEN 0 ELSE ISNULL(p.page_free_space_percent / 100.0 * 8192, 8192) END
, PageGroup = NTILE(@MaxItems) OVER(ORDER BY p.allocated_page_page_id)
FROM sys.dm_db_database_page_allocations(DB_ID(@DatabaseName),@TableId,@IndexId,default,'DETAILED') AS p
WHERE (@FileId IS NULL OR p.allocated_page_file_id = @FileId)
AND (@FromPage IS NULL OR p.allocated_page_page_id >= @FromPage)
AND (@ToPage IS NULL OR p.allocated_page_page_id <= @ToPage)
) AS p
INNER JOIN 
(
	SELECT file_id, file_name = [name], size AS file_total_size
	, file_total_used_space = FILEPROPERTY([name], 'SpaceUsed')
	FROM sys.database_files AS f
	WHERE type = 0
) AS f
ON f.file_id = p.allocated_page_file_id
OUTER APPLY sys.dm_db_page_info(DB_ID(@DatabaseName), f.file_id, p.page_id, 'DETAILED') AS pinfo
GROUP BY
  f.file_name
, f.file_id
, p.PageGroup