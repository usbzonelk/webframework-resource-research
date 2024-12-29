docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=123456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest

-------
docker pull mariadb
docker run --detach \
  --name mariadb \
  --env MARIADB_ROOT_PASSWORD=123456 \
  --env MARIADB_DATABASE=laravel \
  -p 61011:3306 \
  mariadb:latest
php artisan migrate
composer run dev
