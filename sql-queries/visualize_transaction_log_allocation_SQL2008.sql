SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#LOGINFO') IS NOT NULL DROP TABLE #LOGINFO;
CREATE TABLE #LOGINFO(
RUID int NULL, FileID int NULL, FileSize bigint NULL, StartOffset bigint NULL, FSeqNo bigint NULL, Status int NULL, Parity int NULL, CreateLSN bigint NULL
);

INSERT INTO #LOGINFO
EXEC(N'DBCC LOGINFO');

SELECT
  database_id = DB_ID()
, database_name = DB_NAME()
, file_id = li.FileID
, file_name = df.name
, vlf_begin_offset = li.StartOffset
, vlf_size_mb = CONVERT(float, ROUND(li.FileSize / 1024.0 / 1024.0, 2))
, vlf_sequence_number = li.FSeqNo
, vlf_active = CASE WHEN li.Status = 2 THEN 1 ELSE 0 END
, vlf_status = li.Status
, vlf_active_desc = CASE WHEN li.Status = 2 THEN 'Active' ELSE 'Unused' END
, vlf_status_desc = CASE li.Status WHEN 0 THEN 'Unused' WHEN 1 THEN 'Initialized' WHEN 2 THEN 'Active' END
, vlf_parity = li.Parity
, vlf_first_lsn = '(unavailable)'
, vlf_create_lsn = CONVERT(nvarchar(25),li.CreateLSN)
FROM #LOGINFO AS li
INNER JOIN sys.database_files AS df ON df.file_id = li.FileID