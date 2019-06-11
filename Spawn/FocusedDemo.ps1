## create a blank image
spawnctl create data-image -f ./demo.yaml



## create a container
spawnctl create data-container --image grantdemo --name democontainer

## get details if needed
spawnctl get data-container democontainer -o json


## switch to t-sql & modify structures & data
## save the version
spawnctl save data-container democontainer
## switch to T-sql modify data
## save it again
## Switch to T-SQL again
## save it again

spawnctl get data-containers

##get a version
spawnctl load data-container democontainer --revision=rev.1



