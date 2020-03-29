# Microsoft SQL Server Data Allocation Reports

Queries and reports to visualize your SQL data page allocations.

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

- The compact report uses the `sys.dm_db_database_page_allocations` system function which is undocumented and not officially supported. It was introduced in **SQL Server 2012** and newer.
- The detailed report uses the `sys.dm_db_page_info` system function which was only introduced in **SQL Server 2019** and newer.

## Examples

At this time, there are currently two report types included:

### A. Detailed Page Allocation

This report displays your data file's contents per each data page.

It shows you the page allocation type (DATA / INDEX / LOB / IAM / EMPTY / etc.), and also the object and index it belongs to.

![Detailed Page Allocation Screenshot](https://raw.githubusercontent.com/EitanBlumin/mssql-data-allocation-report/master/media/screenshot1.png "Detailed Page Allocation Screenshot")

### B. Compact Page Allocation

This report displays your biggest continuous USED / EMPTY pages in your data file.

Each bar in this report represents a continuous **range** of pages, and its height represents the number of pages in that range.

![Compact Page Allocation Screenshot](https://raw.githubusercontent.com/EitanBlumin/mssql-data-allocation-report/master/media/screenshot2.png "Compact Page Allocation Screenshot")

## Future Plans

Additional plans for future development:

- Additional report formats besides Power BI (e.g. Qlik, Reporting Services, Power Pivot, etc.)
- Similar allocation report for transaction logs

## License & Contribution

This is an open-source project licensed under the MIT agreement.

You are more than welcome to contribute by forking this project and making improvements and adding features.

If you wish to develop these reports for a new platform, please create a separate folder for it.
