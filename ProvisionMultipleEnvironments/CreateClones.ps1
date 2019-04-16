$SQLCloneServer= 'http://win-8a2lqanso51:14145'
$Server = 'WIN-8A2LQANSO51'
$Instance = 'SQL2019'
$dbname = 'AdventureWorks2017'

## Connect to clone server
Connect-SqlClone -ServerUrl $SQLCloneServer
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $Server -InstanceName $Instance

## Get the necessary image
$imagename = $dbname + "_" + (Get-Date -Format "yyyyMMdd")
$image = Get-SqlCloneImage -Name $imagename
 
$ClonePrefix = 'ADW'
$Count = 15 # or however many you want 
 
## Create clones 
for ($i=0;$i -lt $Count;$i++)
{
    ##outside of demos, this would be multiple instances in multiple VMs or machines
    $image | New-SqlClone -Name $ClonePrefix$i -Location $sqlServerInstance | Wait-SqlCloneOperation
};
 
