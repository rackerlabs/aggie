# Aggie

## Installation
* `wget PATH/aggie.tar.gz`
* `tar zxf aggie.tar.gz`
* `mv bin/aggie /usr/local/bin`
* `*/10 * * * * /usr/local/bin/aggie command Elixir.Aggie ship_logs 930035`

## Development / Deployment
Aggie is an [Elixir](http://elixir-lang.org/) application. It uses [Distillery](https://github.com/bitwalker/distillery) to cut releases via `MIX_ENV=prod mix release`. Aggie will be compiled into a tarball that can be deployed to the target host. It must be installed somewhere that access the in-cloud ELK container via internal IP, _and_ and be able to hit CentralElk's IP to push data.

To deploy Aggie you can `scp` the tarball to the host:
`scp aggie/_build/prod/rel/aggie/releases/0.1.0/aggie.tar.gz root@HOST:~/`

After uploading the tarball to the host, simply unzip `tar zxf aggie.tar.gz` and then run Aggie: `~/bin/aggie command Elixir.Aggie ship_logs 930035`.

Aggie is best run via a cron job: `*/10 * * * * /usr/local/bin/aggie command Elixir.Aggie ship_logs 930035`

## Setup CentralElk:
``` sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce
sudo sysctl -w vm.max_map_count=262144
sudo docker run -d -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk
```
