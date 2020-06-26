use master;
go
create database TestingVolume;
GO

use TestingVolume;
GO

CREATE TABLE dbo.TestTable
(ID int primary key not null identity(1,1),
MyVals varchar(200));
GO

insert dbo.TestTable
(MyVals)
SELECT @@VERSION;


select @@VERSION,
t.MyVals
from dbo.TestTable as t;

--switch back, stop the 19 container


--change the connection to port 1460
RESTORE DATABASE AdventureWorks FROM DISK = '/bu/adventureworks2017.bak'
WITH MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/adw.mdf',
MOVE 'AdventureWorks2017_log' TO '/var/opt/mssql/data/adw_log.ldf'


backup database TestingVolume
to disk = '/bu/tv.bak'
with init

