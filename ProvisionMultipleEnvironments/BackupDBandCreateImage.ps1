$SQLCloneServer= 'http://devmaria:14145'
$Server = 'production'
$backupdir = 'https://provisiondiag932.blob.core.windows.net/backups'
$resourceGroupName = 'Provision'
$storageAccountName = 'provisiondiag932'
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName
$key = $storageAccountKeys[0].value
$storagecontext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key
$Salesdb = 'Sales'
$IMdb = 'InventoryManagement'
$IRdb = 'InventoryReporting'
$SSdb = 'SalesSupport'
$Shipdb = 'Shipping'

## Due to unresolved conflict with -Initialize in backup, removing files first
get-azstorageblob -Context $storagecontext -Container 'backups' | Remove-AzStorageBlob

## Create the database backups
$backup = $backupdir + '/' + $Salesdb + ".bak"
Backup-SqlDatabase -Database $Salesdb -ServerInstance $Server -Initialize -BackupFile $backup -SqlCredential "mybackuptoURL"
$backup = $backupdir + '/' + $IMdb + ".bak"
Backup-SqlDatabase -Database $IMdb -ServerInstance $Server -Initialize -BackupFile $backup -SqlCredential "mybackuptoURL"
$backup = $backupdir + '/' + $IRdb + ".bak"
Backup-SqlDatabase -Database $IRdb -ServerInstance $Server -Initialize -BackupFile $backup -SqlCredential "mybackuptoURL"
$backup = $backupdir + '/' + $SSdb + ".bak"
Backup-SqlDatabase -Database $SSdb -ServerInstance $Server -Initialize -BackupFile $backup -SqlCredential "mybackuptoURL"
$backup = $backupdir + '/' + $Shipdb + ".bak"
Backup-SqlDatabase -Database $Shipdb -ServerInstance $Server -Initialize -BackupFile $backup -SqlCredential "mybackuptoURL"

## Copy the backups to a local directory
## This is only necessary in a non-AD security context
## A fully networked solution would not require this step
cd 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy'
.\azcopy /source:$backupdir /dest:C:\BU /sourcekey:$key /S /Y

## Connect to clone server
Connect-SqlClone -ServerUrl $SQLCloneServer
 
## Clone server definitions
$devMaria = Get-SqlCloneSqlServerInstance -MachineName "devmaria"
$devAchmed = Get-SqlCloneSqlServerInstance -MachineName "devachmed"
$devtod = Get-SqlCloneSqlServerInstance -MachineName "devtod"

## Determine where to store images
$ImageDestination = Get-SqlCloneImageLocation -Path '\\provisiondiag932.file.core.windows.net\images' # Point to the file share we want to use to store the image

## Remove existing clones
Get-SqlClone -Name $Salesdb | Remove-SqlClone | Wait-SqlCloneOperation
Get-SqlClone -Name $IMdb | Remove-SqlClone | Wait-SqlCloneOperation
Get-SqlClone -Name $IRdb | Remove-SqlClone | Wait-SqlCloneOperation
Get-SqlClone -Name $SSdb | Remove-SqlClone | Wait-SqlCloneOperation
Get-SqlClone -Name $Shipdb | Remove-SqlClone | Wait-SqlCloneOperation

## Remove existing images
Get-SqlCloneImage -Name $Salesdb | Remove-SqlCloneImage | Wait-SqlCloneOperation
Get-SqlCloneImage -Name $IMdb | Remove-SqlCloneImage | Wait-SqlCloneOperation
Get-SqlCloneImage -Name $IRdb | Remove-SqlCloneImage | Wait-SqlCloneOperation
Get-SqlCloneImage -Name $SSdb | Remove-SqlCloneImage | Wait-SqlCloneOperation
Get-SqlCloneImage -Name $Shipdb | Remove-SqlCloneImage | Wait-SqlCloneOperation

## Create an image with clean data
$localbackup = 'C:\BU\' + $Salesdb + ".bak"
$SalesImage = New-SqlCloneImage -Name $Salesdb -SqlServerInstance $devMaria[0] -BackupFileName $localbackup -Destination $ImageDestination | Wait-SqlCloneOperation 
$localbackup = 'C:\BU\' + $IMdb + ".bak"
$IMImage = New-SqlCloneImage -Name $IMdb -SqlServerInstance $devMaria[0] -BackupFileName $localbackup -Destination $ImageDestination | Wait-SqlCloneOperation 
$localbackup = 'C:\BU\' + $IRdb + ".bak"
$IRImage = New-SqlCloneImage -Name $IRdb -SqlServerInstance $devMaria[0] -BackupFileName $localbackup -Destination $ImageDestination | Wait-SqlCloneOperation 
$localbackup = 'C:\BU\' + $SSdb + ".bak"
$SSImage = New-SqlCloneImage -Name $SSdb -SqlServerInstance $devMaria[0] -BackupFileName $localbackup -Destination $ImageDestination | Wait-SqlCloneOperation 
$localbackup = 'C:\BU\' + $Shipdb + ".bak"
$ShippingImage = New-SqlCloneImage -Name $Shipdb -SqlServerInstance $devMaria[0] -BackupFileName $localbackup -Destination $ImageDestination | Wait-SqlCloneOperation 

## Create new clones
$SalesImage = Get-SqlCloneImage -Name $Salesdb
New-SqlClone -Name $Salesdb -Location $devAchmed[0] -Image $SalesImage | Wait-SqlCloneOperation
New-SqlClone -Name $Salesdb -Location $devtod[0] -Image $SalesImage | Wait-SqlCloneOperation
New-SQLClone -Name $Salesdb -Location $devMaria[0] -Image $SalesImage | Wait-SqlCloneOperation
$IMImage = Get-SqlCloneImage -Name $IMdb
New-SqlClone -Name $IMdb -Location $devAchmed[0] -Image $IMImage | Wait-SqlCloneOperation
New-SqlClone -Name $IMdb -Location $devtod[0] -Image $IMImage | Wait-SqlCloneOperation
New-SQLClone -Name $IMdb -Location $devMaria[0] -Image $IMImage | Wait-SqlCloneOperation
$IRImage = Get-SqlCloneImage -Name $IRdb
New-SqlClone -Name $IRdb -Location $devAchmed[0] -Image $IRImage | Wait-SqlCloneOperation
New-SqlClone -Name $IRdb -Location $devtod[0] -Image $IRImage | Wait-SqlCloneOperation
New-SQLClone -Name $IRdb -Location $devMaria[0] -Image $IRImage | Wait-SqlCloneOperation
$SSImage = Get-SqlCloneImage -Name $SSdb
New-SqlClone -Name $SSdb -Location $devAchmed[0] -Image $SSImage | Wait-SqlCloneOperation
New-SqlClone -Name $SSdb -Location $devtod[0] -Image $SSImage | Wait-SqlCloneOperation
New-SQLClone -Name $SSdb -Location $devMaria[0] -Image $SSImage | Wait-SqlCloneOperation
$ShippingImage = Get-SqlCloneImage -Name $Shipdb
New-SqlClone -Name $Shipdb -Location $devAchmed[0] -Image $ShippingImage | Wait-SqlCloneOperation
New-SqlClone -Name $Shipdb -Location $devtod[0] -Image $ShippingImage | Wait-SqlCloneOperation
New-SQLClone -Name $Shipdb -Location $devMaria[0] -Image $ShippingImage | Wait-SqlCloneOperation



