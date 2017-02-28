# Aggie

## RPC Log Aggregator

Aggie is a CLI tool written in Elixir that will drop into an RPC env. It can digest ELK and RSyslog streams at this point. It pushes the info to a central ELK where support can get their hands on it.

-   Run as a syslog endpoint daemon on port 7777
    `./aggie --syslog --tenant-id 930035`
-   Run as an ELK-stack consumer (normally via CRON)
    `./aggie`
