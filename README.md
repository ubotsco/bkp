# Postgres Backup


```
docker build --build-arg PGVERSION=17 -t ghcr.io/ubotsco/bkp:17 .
docker push ghcr.io/ubotsco/bkp:17

docker build --build-arg PGVERSION=16 -t ghcr.io/ubotsco/bkp:16 .
docker push ghcr.io/ubotsco/bkp:16
```
