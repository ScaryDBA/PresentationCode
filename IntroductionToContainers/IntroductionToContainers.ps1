## first, see what docker commands we have available
docker --help


## Let's see the images we currently have downloaded
docker images


## what containers are actually configured and are they running
docker ps -a


## get an image
docker pull mcr.microsoft.com/mssql/server:2017-latest
docker pull mcr.microsoft.com/mssql/server:2019-CTP2.5-ubuntu


docker ps -a

## remove an image
docker rmi 5494536a73c1
## force remove
docker rmi 7af596b24973 -f
## will fail if a container still exists


## create and run a container
docker run -e 'ACCEPT_EULA=Y' `
    -e 'SA_PASSWORD=$cthulhu1988' `
   -p 1433:1433 `
   --name Demo17 `
   -d mcr.microsoft.com/mssql/server:2017-latest

## check status
docker ps


## switch over to ADS, connect to the instance
## get the ip address
ipconfig


## stop a container
docker stop Demo17

## start an container
docker start Demo17

## now what's the status
docker ps -a


## create a container with a data volume
docker run -e 'ACCEPT_EULA=Y' `
-e 'SA_PASSWORD=$cthulhu1988' `
-p 1450:1433 `
--name Demo17vol `
-v sqlvol:/var/opt/mssql `
-d mcr.microsoft.com/mssql/server:2017-latest


## switch to ADS, create db & data   

docker stop Demo17vol


## create a new container using the same volume
docker run -e 'ACCEPT_EULA=Y' `
    -e 'SA_PASSWORD=$cthulhu1988' `
    -p 1450:1433 `
    --name Demo19 `
    -v sqlvol:/var/opt/mssql `
    -d mcr.microsoft.com/mssql/server:2019-CTP2.5-ubuntu




docker stop Demo19


## will crash because everything has been upgraded
docker start Demo17vol


docker ps -a

## will need to update thc container ID
docker logs 8d79c80ff4b7






## shared drive and volumes
## first show the shared drives in Docker Desktop
docker run `
    --name DemoSharedVol `
    -p 1460:1433 `
    -e "ACCEPT_EULA=Y" `
    -e 'SA_PASSWORD=$cthulhu1988' `
    -v C:\Docker\SQL:/bu `
    -d mcr.microsoft.com/mssql/server:2019-CTP2.5-ubuntu


docker exec -it DemoSharedVol "bash"    


##switch to ADS & restore database





## control the container with dockerfiles
## show demodockerfile

## create a new image from dockerfile
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

docker cp     

    docker exec -it DemoCustom "bash"    



## go whole hog with Spawn





## clean up
docker stop Demo17
docker stop Demo19
docker stop Demo17vol
docker stop DemoSharedVol
docker stop DemoCustom
docker rm Demo17
docker rm Demo19
docker rm Demo17vol
docker rm DemoSharedVol
docker rm DemoCustom
docker volume rm sqlvol
docker rmi demodockerfileimage



docker ps -a

