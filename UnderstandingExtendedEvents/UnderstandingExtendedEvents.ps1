##connect up to the database
$connstring = "Data Source=TCP:localhost;User ID=sa;Password=cthulhu1988"
$server = Connect-DbaInstance -ConnectionString $connstring

## get a listing of all sessions on the server
Get-DbaXESession -SqlInstance $server | Format-Table Name, Status, Events

## start and stop a session
Start-DbaXESession -SqlInstance $server -Session QueryPerformanceOnADW
Stop-DbaXESession -SqlInstance $server -Session QueryPerformanceOnADW


Import-Module SqlServer.XEvent
Import-Module SqlServer.XEvent

## Read the output file
$mysession = Get-DbaXESession -SqlInstance $server -Session QueryPerformance 
$mysession.Targets

##Get-DbaXESession -SqlInstance $server -Session QueryPerformance | Read-DbaXEFile
## Read from the performance output. Stop the session first, containers
Get-ChildItem C:\bu\QueryPerformance*.xel | Read-DbaXEFile | Format-Table object_name, duration, statement



