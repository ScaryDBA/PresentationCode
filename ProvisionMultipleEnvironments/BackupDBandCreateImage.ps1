## 1. Setup
$SQLCloneServer = 'http://devmaria:14145'
$Server = 'production'
$backupdir = 'https://provisiondiag932.blob.core.windows.net/backups'
$resourceGroupName = 'Provision'
$storageAccountName = 'provisiondiag932'
$storageAccount = Get-AzStorageAccount `
                     -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageAccountKeys = Get-AzStorageAccountKey `
                     -ResourceGroupName $resourceGroupName -Name $storageAccountName
$key = $storageAccountKeys[0].value
$storagecontext = New-AzStorageContext `
                     -StorageAccountName $storageAccountName -StorageAccountKey $key


##Connect to clone server
Connect-SqlClone -ServerUrl $SQLCloneServer

## create a list of all your clones with their masks
$Clones =
@(
    @{
        'name' = 'Sales';
        'mask' = New-SqlCloneMask -Path 'C:\masking\Sales.DMSMaskSet'
    },
    @{
        'name' = 'InventoryReporting';
        'mask' = New-SqlCloneMask -Path 'C:\masking\InventoryReporting.DMSMaskSet'
    },
    @{
        'name' = 'InventoryManagement';
        'mask' = New-SqlCloneMask -Path 'C:\masking\InventoryManagement.DMSMaskSet'
    },
    @{
        'name' = 'SalesSupport';
        'mask' = New-SqlCloneMask -Path 'C:\masking\SalesSupport.DMSMaskSet'
    },
    @{
        'name' = 'Shipping';
        'mask' = New-SqlCloneMask -Path 'C:\masking\Shipping.DMSMaskSet'
    }
)
## make a list of the machine names of all your instances
$Instances = @(@{ 'name' = 'devmaria' }, @{ 'name' = 'devachmed' }, @{ 'name' = 'devtod' })

## add to each object the sql clone server instance
$instances | foreach{
    $_.instancename = Get-SqlCloneSqlServerInstance -MachineName $_.name 
    }

    
## Due to unresolved conflict with -Initialize in backup, removing files first
get-azstorageblob -Context $storagecontext `
                  -Container 'backups' | Remove-AzStorageBlob
## 2. Create the database backups
$clones | foreach{
    Backup-SqlDatabase `
    -Database $_.Name `
    -ServerInstance $Server -Initialize `
    -BackupFile "$($backupdir)/$($_.Name).bak" -SqlCredential "mybackuptoURL"
}
## Copy the backups to a local directory
## This is only necessary in a non-AD security context
## A fully networked solution would not require this step
cd 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy'
.\azcopy /source:$backupdir /dest:C:\BU /sourcekey:$key /S /Y

## 3. Clean up old clones and images
## Clone server definitions
$devMaria = Get-SqlCloneSqlServerInstance -MachineName "devmaria"

## Determine where to store images
$ImageDestination = Get-SqlCloneImageLocation `
                     -Path '\\provisiondiag932.file.core.windows.net\images'
## Remove existing clones and images
$Clones | foreach{
    Get-SqlClone -Name $_.name | Remove-SqlClone | Wait-SqlCloneOperation
    Get-SqlCloneImage -Name $_.name | Remove-SqlCloneImage | Wait-SqlCloneOperation
}
## 4. Create an image with clean data
$Clones | foreach{
    $_.Image = New-SqlCloneImage `
     -Name $_.name -SqlServerInstance $devMaria[0] `
     -BackupFileName "C:\BU\$($_.name).bak" -Destination $ImageDestination `
     -Modifications $_.Mask | Wait-SqlCloneOperation
}

## 5. Create new clones
$Clones | foreach{
    $NewImage = Get-SqlCloneImage -Name $_.name
    $CurrentClone = $_
    $Instances | foreach{
        New-SqlClone -Name $CurrentClone.name -Location $_.instancename -Image $NewImage `
        | Wait-SqlCloneOperation
    }
}
