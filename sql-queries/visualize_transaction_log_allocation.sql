SELECT database_id, DB_NAME(database_id) AS database_name
, file_id, FILE_NAME(file_id) AS file_name
, vlf_begin_offset, vlf_size_mb, vlf_sequence_number, vlf_active, vlf_status
, vlf_parity, vlf_first_lsn, vlf_create_lsn
FROM sys.dm_db_log_info(DB_ID())