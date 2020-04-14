# Microsoft SQL Server Data Allocation Reports

Queries and reports to visualize your SQL data and transaction log page allocations.

See which pages are reserved for which objects, and which pages are not used.

## Parameters

`Server`

Specifies the SQL Server instance to connect to.

`Database`

Specifies the database name which you wish to analyze.

## Permissions

The minimum permissions that are required to see this report are:

- `VIEW DATABASE STATE` permission in the database.
- `CREATE DATABASE`, `ALTER ANY DATABASE`, or `VIEW ANY DEFINITION`.

## Remarks

- The compact report uses the `sys.dm_db_database_page_allocations` system function which is undocumented and not officially supported. It was introduced in **SQL Server 2012** and later.
- The detailed transaction log report uses the `sys.dm_db_log_info` system function which was only introduced in **SQL Server 2016 SP 2** and later.
- The detailed data report uses the `sys.dm_db_page_info` system function which was only introduced in **SQL Server 2019** and later.

## Examples

At this time, there are currently two report types included:

### A. File Allocation Summary

This report is a summary free/used report for your data and log files.

You can use the data slicers to filter by specific data or log files (if you have more than one in your database). The filters will affect all other pages.

### B. Page Allocation Compact

This report displays your biggest continuous USED / EMPTY pages in your data file.

Each bar in this report represents a continuous **range** of pages, and its height represents the number of pages in that range.

![Compact Page Allocation Screenshot](https://raw.githubusercontent.com/MadeiraData/mssql-data-allocation-report/master/media/screenshot2.png "Compact Page Allocation Screenshot")

### C. Allocation by Object

This report summarizes the data utilization of your database objects.

You can use this report to drill-through to the detailed page report.

### D. Page Allocation Detailed

This report displays your data file's contents per each data page.

It shows you the page allocation type (DATA / INDEX / LOB / IAM / EMPTY / etc.), and also the object and index it belongs to.

![Detailed Page Allocation Screenshot](https://raw.githubusercontent.com/MadeiraData/mssql-data-allocation-report/master/media/screenshot1.png "Detailed Page Allocation Screenshot")

### E. Transaction Log Detailed

This report displays your transaction log file's contents, highlighting the active / non active VLFs.

![Transaction Log Detailed Screenshot](https://raw.githubusercontent.com/MadeiraData/mssql-data-allocation-report/master/media/screenshot3.png "Transaction Log Detailed Screenshot")

## Future Plans

Additional plans for future development:

- Additional report formats besides Power BI (e.g. Qlik, Reporting Services, Power Pivot, etc.)

## License & Contribution

This is an open-source project licensed under the MIT license.

You are more than welcome to contribute by forking this project and making improvements and adding features.

If you wish to develop these reports for a new platform, please create a separate folder for it.
