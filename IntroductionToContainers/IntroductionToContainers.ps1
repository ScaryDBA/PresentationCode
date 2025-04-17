## first, see what docker commands we have available
docker --help


## Let's see the images we currently have downloaded
docker images


## what containers are actually configured and are they running
docker ps -a


## get an image
docker pull mcr.microsoft.com/mssql/server:2017-latest
docker pull mcr.microsoft.com/mssql/server:2022-latest


docker ps -a

## remove an image
docker rmi 6243e166bb2a
## force remove
docker rmi 5494536a73c1 -f
## will fail if a container still exists


## create and run a container
docker run -e 'ACCEPT_EULA=Y' `
    -e 'SA_PASSWORD=$cthulhu1988' `
   -p 1433:1433 `
   --name DemoContainer `
   -d mcr.microsoft.com/mssql/server:2022-latest

## check status
docker ps


## switch over to ADS, connect to the instance
## get the ip address
ipconfig


## stop a container
docker stop Demo19

## start an container
docker start Demo19

## now what's the status
docker ps -a


## create a container with a data volume
docker run -e 'ACCEPT_EULA=Y' `
-e 'SA_PASSWORD=$cthulhu1988' `
-p 1433:1433 `
--name VolDemo `
-v C:\bu:/var/opt/mssql `
-d mcr.microsoft.com/mssql/server:2022-latest






## switch to ADS, create db & data   


## permissions in 2019 are different than 2017
docker exec -it Demo17vol "bash"

##bash commands
chgrp -R 0 /var/opt/mssql
chmod -R g=u /var/opt/mssql


##stop the running container
docker stop Demo17vol

## create a new container using the same volume
docker run -e 'ACCEPT_EULA=Y' `
    -e 'SA_PASSWORD=$cthulhu1988' `
    -p 1450:1433 `
    --name Demo22New `
    -v sqlvol:/var/opt/mssql `
    -d mcr.microsoft.com/mssql/server:2022-latest


  
docker ps -a

## stop the 2019 container & restart the 2017
docker stop Demo19New
docker start Demo17vol


docker ps -a

## will need to update thc container ID
docker logs Demo19New








## shared drive and volumes
## first show the shared drives in Docker Desktop
docker run `
    --name DemoSharedVol `
    -p 1433:1433 `
    -e "ACCEPT_EULA=Y" `
    -e 'SA_PASSWORD=$cthulhu1988' `
    -v C:\bu:/bu `
    -d mcr.microsoft.com/mssql/server:2022-latest


    docker run `
    --name PostgresFundamentals `
    -e POSTGRES_PASSWORD=cthulhu1988* `
    -d postgres

docker exec -it DemoSharedVol "bash"    

docker exec -it -u root DemoSharedVol "bash"


##switch to ADS & restore database





## control the container with dockerfiles
## show demodockerfile

## create a new image from dockerfile
## note: may need to copy & paste this, not F8
docker build -t demodockerfileimage .

docker images

## create a new container from new image
docker run `
    --name DemoCustom `
    -p 1470:1433 `
    -d `
    -e 'SA_PASSWORD=$cthulhu1988' `
    -e 'ACCEPT_EULA=Y' `
    demodockerfileimage

docker cp C:\Docker\sql\AdventureWorks2017.bak DemoCustom:/bu


docker exec -it DemoCustom "bash"    

docker logs DemoCustom


## go whole hog with Spawn





## clean up
docker stop Demo19
docker stop Demo19New
docker stop Demo17vol
docker stop DemoSharedVol
docker stop DemoCustom
docker rm Demo19
docker rm Demo19New
docker rm Demo17vol
docker rm DemoSharedVol
docker rm DemoCustom
docker volume rm sqlvol
docker rmi demodockerfileimage



docker ps -a
docker images


docker run `
    --name SQLServer2022 `
    -p 1433:1433 `
    -e "ACCEPT_EULA=Y" `
    -e 'SA_PASSWORD=$cthulhu1988' `
    -v C:\Docker\SQL:/bu `
    -d sqlservereap.azurecr.io/mssql/rhel/server:2022-latest


docker run `
--name SQLServer2022 `
-p 1433:1433 `
-e "ACCEPT_EULA=Y" `
-e 'SA_PASSWORD=$cthulhu1988' `
-v C:\Docker\SQL:/bu `
-d mcr.microsoft.com/mssql/rhel/server:2022-CTP2.0-rhel


docker exec -u root -it SQLServer2022 "sudo /opt/mssql/bin/mssql-conf traceflag 12050 12059 12061 on"
docker exec -u root -it SQLServer2022 "/bin/bash"
docker exec -it -u 0 SQLServer2022 /bin/bash


"c:\Program Files\Microsoft Corporation\RMLUtils\ostress" -U"sa" -P"$cthulhu1988" -Q"EXEC Warehouse.GetStockItemsbySupplier 4;" -n1 -r75 -q -oworkload_wwi_regress -dWideWorldImporters

docker run `
    --name HamShackSQL `
    -p 1433:1433 `
    -e "ACCEPT_EULA=Y" `
    -e 'SA_PASSWORD=*cthulhu1988' `
    -v C:\bu:/bu `
    -d mcr.microsoft.com/mssql/server:2022-latest

docker stop HamShackSQL
docker rm HamShackSQL