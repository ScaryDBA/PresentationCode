docker pull mysql;

docker run --name HamShackMySQL -p 3306:3306 -e MYSQL_ROOT_PASSWORD='cthulhu1988' -d mysql;
docker run --name HamShackProd -p 3308:3306 -e MYSQL_ROOT_PASSWORD='cthulhu1988' -d mysql;
docker run --name HamShackShadow -p 3310:3306 -e MYSQL_ROOT_PASSWORD='cthulhu1988' -d mysql;


docker exec -it HamShackMySQL bash;

## bash to test connection
mysql -u root -p $cthulhu1988


## JDBC connection string
jdbc:mysql://localhost:3306/sys?allowPublicKeyRetrieval=true



