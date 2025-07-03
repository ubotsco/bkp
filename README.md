# Postgres Backup


```
export VERSION="2"

docker build --platform linux/amd64 --build-arg PGVERSION=17 -t "ghcr.io/ubotsco/bkp:17-${VERSION}" .
docker push "ghcr.io/ubotsco/bkp:17-${VERSION}"

docker build --platform linux/amd64 --build-arg PGVERSION=16 -t "ghcr.io/ubotsco/bkp:16-${VERSION}" .
docker push "ghcr.io/ubotsco/bkp:16-${VERSION}"
```
