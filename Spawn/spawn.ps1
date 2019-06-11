## https://spawn.cc/docs/spawnctl
## https://github.com/red-gate/spawn-demo/


## creates an image
spawnctl create data-image -f ./development.yaml

## create a sql server image
spawnctl create data-image -f ./sqlserver.yaml




## lists all existing images
spawnctl get data-images

## gets info on a specific image
spawnctl get data-image 11236

## remove an image
spawnctl delete data-image 11237

## modify images
spawnctl update data-image granttest --tag v1.0

## will only work if you have access to the team
spawnctl update data-image granttest --team test


## create a container
spawnctl create data-container --image granttest --name testcontainer

## and a sql server container
spawnctl create data-container --image TestSS --name sqlservertest


## containers?
spawnctl get data-containers

## container
spawnctl get data-container testcontainer

## Detailed info on a container
spawnctl get data-container sqlservertest -o json




## version the container, the magic begins
spawnctl save data-container testcontainer

## rest to a previous version
spawnctl reset data-container testcontainer

## pick a version
spawnctl load data-container testcontainer --revision=rev.3

## pick another version
spawnctl load data-container testcontainer --revision=rev.5



## graduate -- make an image out of it
spawnctl graduate data-container testcontainer --revision rev.5

## create a container from this
spawnctl create data-container --image testcontainer-graduate-1


## clean up
spawnctl delete data-container testcontainer-graduate-1-ewqxrnsy
spawnctl delete data-container testcontainer
spawnctl delete data-container sqlservertest
spawnctl delete data-image TestSS
spawnctl delete data-image testcontainer-graduate-1
spawnctl delete data-image granttest

spawnctl get data-images

