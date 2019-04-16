import-module sqlps  
  
# create variables  
$storageAccount = "provisiondiag932"  
$storageKey = "rqAgLRL2EB4shThdU0P8mFPpe+ab4IjygNYPBs9igWwMVLt9w+5eDIS4VGzmQZAip1UVilXCOHEJVTT9PsupWw=="  
$secureString = convertto-securestring $storageKey  -asplaintext -force  
$credentialName = "mybackuptoURL"  
  
#cd to computer level  
cd SQLServer:\SQL\$env:COMPUTERNAME  
# get the list of instances  
$instances = Get-childitem  
#pipe the instances to new-sqlcredentail cmdlet to create SQL credential  
$instances | new-sqlcredential -Name $credentialName  -Identity $storageAccount -Secret $secureString  
