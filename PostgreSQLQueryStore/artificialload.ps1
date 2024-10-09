## all failing with SSL problems, or, the one that works is going to the wrong place

# SSL Connect-AzAccount -TenantID b4c9f32e-da17-4ded-9c95-ce9da38f25d9
#Connect-AzAccount -TenantID 4831b504-ff9a-4f49-8d9f-87edfdabb7ff
##Connect-AzAccount -TenantID 0d0c2253-15fe-4de5-a939-75774da006a1
##Connect-AzAccount -TenantID 50402ed6-c5bf-46fb-b64a-467e0c619f24
##Connect-AzAccount -TenantID 5462087e-144c-4361-bf1d-f32528f435f4
##Connect-AzAccount -TenantID 68faa42b-24f3-4125-a101-5b973606c7bb

# Works Connect-AzAccount -TenantID 72f988bf-86f1-41af-91ab-2d7cd011db47

# SSL Connect-AzAccount -TenantID 86b34d58-51b7-459e-9031-ad148c11ae54
#SSL Connect-AzAccount -TenantID a5e0da2c-8ea8-462b-90ce-344bc9961d5d
#SSL Connect-AzAccount -TenantID cdba790c-246a-4e5e-8182-7909e098ae83
Get-AzResourceGroup


$hsrdb = New-Object -TypeName System.Data.OleDb.OleDbConnection
# Replace the placeholders with your actual values
$serverName = "hamshackpostgres"
$databaseName = "hamshackradio"
$userName = "grant@hamshackpostgres"
$password = '$cthulhu1988'

psql -c 'select * from radio.radiodetails(1)' -h hamshackpostgres.postgres.database.azure.com -p 5432 -U grant@hamshackradio -W $cthulhu1988

$dburl = "postgresql://exusername:expw@exhostname:5432/postgres"
$data = "select * from extable" | psql --csv $dburl | ConvertFrom-Csv

psql -h hamshackpostgres.postgres.database.azure.com -p 5432 -U grant@postgres



$MyServer = "hamshackpostgres.postgres.database.azure.com"
$MyPort = "5432"
$MyDB = "postgres"
$MyUid = "grant"
$MyPass = "*cthulhu1988"

$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Encrypt=yes;Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection
$DBConn.ConnectionString = $DBConnectionString
$DBConn.Open()

$DBCmd = $DBConn.CreateCommand()
$DBCmd.CommandText = "SELECT * FROM radio.radiodetails(1);"
$DBCmd.ExecuteReader()

$DBConn.Close()



#AZURE CLI
az account set --subscription 808576db-7c4d-4e40-b2ce-fde858aa263f

#az postgres flexible-server connect -n <servername> -u <username> -p "<password>" -d <databasename>
az postgres flexible-server connect -n hamshackerver -u grant -p "*cthulhu1988" -d hamshackradio



SELECT * FROM qs_view
WHERE db_id = 24797
AND start_time > '5/1/2024'
