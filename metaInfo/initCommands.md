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

-------
docker pull postgres

docker run -d --rm \
  -e POSTGRES_PASSWORD=123456 \
  -e POSTGRES_USER=root \
  -e POSTGRES_DB=DataDriven \
  -p 61014:5432 \
  postgres

--------
Erlang install:
curl -fsSO https://elixir-lang.org/install.sh
sh install.sh elixir@1.18.1 otp@27.1.2
installs_dir=$HOME/.elixir-install/installs
export PATH=$installs_dir/otp/27.1.2/bin:$PATH
export PATH=$installs_dir/elixir/1.18.1-otp-27/bin:$PATH
iex

~ Erlang/OTP 27 [erts-15.1.2] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [jit:ns]
~ Elixir 1.18.1 (compiled with Erlang/OTP 27)
curl https://new.phoenixframework.org/myapp | sh
mix phx.new myApp --no-html --no-assets --no-live 

------

https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
 rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
