https://board.net/p/r.0d70fb7df088f0562d74a45082424617

Slides: https://docs.google.com/presentation/d/1S-Rs9FObiDcs5ry3KJa4n7ou6M6mH42jwPPW572hXqU/edit?slide=id.g31bcb11b552_0_208#slide=id.g31bcb11b552_0_208

---
- kernel jest tylko jeden na hoście

- alternatywa docker hub https://quay.io/ albo od dostawców chmurowych Azure, AWS itp., GitHub

- docker pull redis/redis-stack@<sha256> - możemy wymusić konkretnym obraz po sha

- parametry docker run
	`--rm` - usuwa kontener po jego zamknięciu
	`-p 8080:80` - przekierowuje port z 80 kontenera na 8080 na głownym systemie
	`-d` - kontener ma działać w tle
	`--name` - nadajemy kontenerowi własną nazwę

- `docker ps` - pokazuje uruchomione kontenery
- `docker ps` - pokazuje wszystkie kontenery (w tym zatrzymane)
- `docker stop` - zatrzymanie kontenera, bez usuwania
- `docker start` - ponowne uruchomienie zatrzymanego kontenera
- `docker create` - tworzy kontener, ale go nie uruchamia
- `docker rm <nazwa obrazu, lub id>` - usuwa kontener
- `docker image rm <nazwa obrazu>` - usuwa obraz
- `docker exec -it <obraz> /bin/sh` - przekierowujemy stdin terminala kontenera, na nasz terminal
- `docker exec -it redis-rocks whoami` - wysyłamy komendę `whoami` w kontenerze i odbieramy odpowiedź na nasz terminal
- `docker logs` - pokazuje stdout kontenera

# Volume
- `docker volume ls` - pokazuje listę wolumenów
- możemy trzymać pliki wewnątrz kontenera, po restarcie kontenera je zachowamy, ale po usunięciu kontenera przepadną
- `docker run -v <lokalny_katalog>:<ścieżka_na_kontenerze> <nazwa_obrazu>` - dodawanie wolumenu
- `docker volume create <nazwa_wolumenu>` - tworzenie wolumenu
- `docker volume inspect <nazwa_wolumenu>` - pokazuje, w którym katalogu jest przechowywany wolumen
- `docker run -d -p 8081:8081 -v <nazwa_wolumenu>:<ścieżka_na_kontenerze> <nazwa_obrazu>`
- używanie `docker volume` będzie trochę szybsze niż podawanie ścieżki w `docker run`
- Po zatrzymaniu kontenera, tracimy to co było w pamięci podręcznej kontenera
- `docker run ... --restart unless-stopped` - nasz obraz będzie uruchamiany po każdym starcie docker-a dopóki go wprost nie zatrzymamy

# Network
- `docker network ls` - pokazuje listę inteferjsów sieciowych
- domyślnie kontenery są w sieci `bridge` - mają łączność między sobą, można się do nich połączyć z zewnątrz
- dobry obraz do diagnostyki sieciowej - `nicolaka/netshoot`
- `docker network create <network_name>`
- `docker run --rm -it --network <network_name> ...` - podłączenie do określonej sieci. Dzięki temu możemy komunikować się między kontenerami po `hostname`

# Budowanie
- `docker build --build-arg DEST_FILE=ninja.html -t nginx-ninja:v2 .` - przekazywanie argumentów do Dockerfile-a
- kolejność w Dockerfile-u - od najmniej zmienianych kroków
- `ENTRYPOINT ["/src/api"]` - polecenie uruchamiane po starcie kontenera
- `docker images -f "dangling=true"` - wypisanie dangling kontenerów
- `docker image prune -f` - czyszczenie z dangling images


- docker / podman ... co się nadaje i co się używa?
- jakie lekkie, bezpieczne dystrubucje do kontenera
  - distroless od Google
  - www.chainguard.dev/containers - bezpieczniejsze
  - Chiselled Ubuntu images
  - 

```dockerfile
  FROM nginx:1.27.3

  LABEL maintainer="asdf"

  ENV NINJA_NGINX_VERSION="0.1"

  ARG DEST_FILE="index.html"

  RUN apt-get update && \
      apt-get install -y \
      iproute2 \
      wget \
      && rm -rf /var/lib/apt/lists/

  COPY index.html /usr/share/nginx/html/${DEST_FILE}
```

```dockerfile
  FROM golang:1.24 AS build

  LABEL maintainer="ererer"

  RUN apt-get update && \
      apt-get install -y curl \
      && rm -rf /var/lib/apt/lists/

  WORKDIR /src

  COPY go.mod go.sum ./
  RUN go mod download

  # kod kopiujemy na koniec, bo bedzie sie czesto zmienial
  COPY cmd/ ./cmd/
  COPY pkg/ ./pkg/

  RUN CGO_ENABLED=0 go build -o ./api cmd/web/main.go


  # Stage 2
  FROM gcr.io/distroless/static-debian12
  # kopiujemy z poprzedniego stage-a
  COPY --from=build /src/api /app/api

  # uzytkownik w kontenerze
  USER nonroot

  EXPOSE 8080

  ENTRYPOINT ["/app/api"]
```
 
# Docker compose
- `docker compose up` - pobiera obrazy i uruchamia zdefiniowane kontenery

```yml
services:
  postgres:
    image: postgres:16
    ports:
     - 5432:5432
    volumes:
      - db-data:/var/lib/postgresql/data
      - ./messages.sql:/docker-entrypoint-initdb.d/messages.sql
    secrets:
      - db-password
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db-password
      - POSTGRES_USER=api
  api:
    image: go-app:v2
    ports:
    - 8080:8080
    secrets:
    - db-password
    environment:
     - DB_USER=api
     - DB_PASSWORD_FILE=/run/secrets/db-password
     - DB_HOST=postgres
     - DB_PORT=5432
volumes:
  db-data:
secrets:
  db-password:
    file: /tmp/db-password.txt
```

- _CGroup_ - mechanizm systemowy do ograniczania zasobów kontenerom 
- `docker stats <container-name>` - statystyki działającego kontenera
- `docker run ... -m 10mb ...` - limit pamięci 10 MB
- `OOMKilled` - proces ubity ze względu na przekroczenie limitu pamięci (w docker inspect)

# Inne
+ `ctrl + l` - przewijanie konsoli
+ `ipcalc`
+ `mkdir -p`  tworzy całe drzewo katalogów
+ `hexdump -c file.txt` - podgląd w hex-ie, każdy znak oddzielnie
+ `kyaml` - następca `yaml`

---

```

 Harmonogram
 
9:00 - 10:30 I blok
10:30 - 10:45 Przerwa 15 min
10:45 - 12:00 II blok
12:00 - 12:15 Przerwa 15 min
12:15 - 13:15 III Blok
13:15 - 14:00 Przerwa obiadowa 45m
14:00 - 15:30 IV blok
15:30 - 15:45 Przerwa 15 min
15:45 - 17:00 V blok

Slides: https://docs.google.com/presentation/d/1S-Rs9FObiDcs5ry3KJa4n7ou6M6mH42jwPPW572hXqU/edit?slide=id.g31bcb11b552_0_208#slide=id.g31bcb11b552_0_208 

Docker
docker version

hostname
ip a

ls /
cat /etc/os-release

ps aux

docker run -it debian bash

hostname
ip a
apt-get update
apt-get install iproute2

systemctl status docker.service
ls -la /var/run/docker.sock
ls -la /var/run/docker.pid

pidof dockerd
cat /var/run/docker.pid
docker info

https://hub.docker.com/
https://hub.docker.com/_/debian

docker pull quay.io/prometheus/node-exporter

docker search ubuntu

docker search ubuntu --limit 10 --filter=stars=3

docker pull nginx
docker pull redis/redis-stack
docker images

docker pull redis/redis-stack:7.4.0-v8

docker pull redis/redis-stack@sha256:f3a4ca8891fcef481109e663463206d1639a870cba2e5a49a696363abf4e7f95

docker pull redis/redis-stack:7.2.0-v20

docker run --rm -p 8080:80 nginx

http://localhost:8080/

ip addr show dev eth0

docker run -d --name webserver -p 8081:80 nginx
docker ps

https://github.com/moby/moby/blob/master/internal/namesgenerator/names-generator.go
http://localhost:8081/

docker run -d --name redis-rocks -p 8001:8001 redis/redis-stack
http://localhost:8001/

http://localhost:8001/redis-stack/workbench
SET training01 k8s-rocks
GET training01

docker ps
docker ps -a
docker stop redis-rocks
docker ps -a

docker create -p 8080:80 --name nginx007 nginx
docker start containerID

curl localhost:8080

docker ps -a
docker rm fervent_robinson

docker images
docker image rm debian:latest

# remove debian container
docker rm b6b24e22b38d
docker image rm debian:latest

docker container stop 686b7d7722d1
docker container start 686b7d7722d1

# running container
docker rm --force nginx007

docker exec -it redis-rocks /bin/sh
redis-cli

SET Training01 redis-test
GET Traininig01

docker exec -it redis-rocks whoami

docker run --name hello hello-world

docker logs hello

docker restart hello
docker logs hello

docker rm --force redis-rocks

docker run -d --name redis-rocks -p 8001:8001 redis/redis-stack

docker volume ls

docker exec -it redis-rocks ls -R /data/

http://localhost:8001/redis-stack/workbench
SET mode writable-layer

docker restart redis-rocks

SET mode writable-layer
SAVE

docker exec -it redis-rocks ls -R /data/

docker restart redis-rocks

docker run -d --name redis-rocks -p 8001:8001 -v /redis-data/:/data redis/redis-stack

docker exec -it redis-rocks redis-cli SAVE

ls /redis-data/

docker volume create redis-vol

docker volume inspect redis-vol

docker run -d --name redis-rocks -p 8001:8001 -v redis-vol:/data redis/redis-stack

docker exec -it redis-rocks redis-cli SAVE

docker volume inspect redis-vol | jq ".[].Mountpoint"

sudo ls -la /var/lib/docker/volumes/redis-vol/_data

docker run -d --name redis-rocks --restart unless-stopped  -p 8001:8001 -v redis-vol:/data redis/redis-stack

docker ps
systemctl restart docker.service
docker ps
docker start webserver

volume-nocopy

sudo apt-get install -y nfs-kernel-server
sudo systemctl status nfs-kernel-server.service

sudo mkdir /nfs
sudo chown nobody:nogroup /nfs

ip addr show dev eth0
sudo vim /etc/exports

echo "/nfs 10.4.0.0/24(rw)" | sudo tee -a /etc/exports

cat /etc/exports

sudo systemctl restart nfs-kernel-server

nc 10.4.0.XXX 2049 -v
sudo mkdir /nfs-dump
 sudo mount 10.4.0.10:/nfs /nfs-dump/
 
 docker volume ls
 
 docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=10.4.0.XXX,rw \
  --opt device=:/nfs \
  redis-nfs
  
  docker rm --force redis-rocks
  
  docker run -d --name redis-rocks --restart unless-stopped  -p 8001:8001 -v redis-nfs:/data redis/redis-stack
  
  docker exec -it redis-rocks redis-cli SAVE
  
  docker volume inspect redis-nfs
  
 docker inspect redis-rocks
 df -h
 
 open /nfs
 
 Network
 
 docker network ls
 
 docker inspect bridge
 ipcalc 172.17.0.0/16
 
 docker run --rm -d --name nginx02 nginx
 docker run --rm -it --name curl101 nicolaka/netshoot

 docker inspect bridge
 curl 172.17.0.4
 
#  doesn't resolve
curl nginx02

docker network create demo01

docker run --rm -it --network demo01 --name curl102 nicolaka/netshoot
docker inspect demo01

docker run --rm -d --network demo01 --name nginx03 nginx

# in netshoot container
curl nginx03



mkdir -p /home/kurs/src/docker-website
cd /home/kurs/src/docker-website

touch Dockerfile

FROM nginx:1.27.3

LABEL maintainer="nginx@ninja.pl"

ENV NINJA_NGINX_VERSION="0.1"

# comment
RUN apt-get update && \
 apt-get install -y \
 iproute2 \
 wget \
 && rm -rf /var/lib/apt/lists/ 

COPY index.html /usr/share/nginx/html/index.html


docker build -t nginx-ninja:v1 .

docker images

docker run --rm --name ninja01 -p 8080:80 nginx-ninja:v1

docker build --build-arg DEST_FILE=ninja.html -t nginx-ninja:v2 .

docker run --rm --name ninja01 -p 8080:80 nginx-ninja:v2

http://localhost:8080/ninja.html

git clone https://github.com/max-mulawa/materials.git
cd materials/docker/go-app

FROM golang:1.24

LABEL maintainer="random dev"

RUN apt-get update && \
 apt-get install -y curl

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download 

COPY cmd/ ./cmd/
COPY pkg/ ./pkg/

RUN CGO_ENABLED=0 go build -o ./api cmd/web/main.go

EXPOSE 8080

ENTRYPOINT ["/src/api"]
docker build -t go-app:v1 .

docker images

docker run --rm --name goapp -p 8080:8080 go-app:v1

http://localhost:8080/

ps aux | grep api

FROM golang:1.24 AS build

LABEL maintainer="random dev"

RUN apt-get update && \
 apt-get install -y curl

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download 

COPY cmd/ ./cmd/
COPY pkg/ ./pkg/

RUN CGO_ENABLED=0 go build -o ./api cmd/web/main.go

# end result (image build)
FROM gcr.io/distroless/static-debian12
COPY --from=build /src/api /app/api

USER nonroot

EXPOSE 8080

ENTRYPOINT ["/app/api"]


docker build -t go-app:v2 .

docker pull gcr.io/distroless/static-debian12

docker run --rm --name goapp -p 8080:8080 go-app:v2

docker login -u mulawam
dckr_pat_doQZzGaaECUl2OhjlSXAtdqS47A

docker tag go-app:v2 mulawam/go-app:v2-xx
docker images

docker push mulawam/go-app:v2-xx

docker images -f "dangling=true"


echo -n "mypass" > /tmp/db-password.txt


fullName: "Tyson Fury"
country: "NO"
active: true

heavyweightChamption:
- 2015
- 2020
record: [30, 3, 1]

features:
  weight: 240
  height: 204


fights:
  - with: Usyk
    result: loss
    date: 2024-12-22
  - with: Usyk
    result: loss
    date: 2023-12-05

notes: >
  Line 1
  Line 1 cnt

notes: |
  Line 1
  Line 2
  
cat fighter.yaml | yq


services:
  postgres:
    image: postgres:16
    ports:
     - 5432:5432
    volumes:
      - db-data:/var/lib/postgresql/data
      - ./messages.sql:/docker-entrypoint-initdb.d/messages.sql
    secrets:
      - db-password
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db-password
      - POSTGRES_USER=api
  api:
    image: go-app:v2
    ports:
    - 8080:8080
    secrets:
    - db-password
    environment:
     - DB_USER=api
     - DB_PASSWORD_FILE=/run/secrets/db-password
     - DB_HOST=postgres
     - DB_PORT=5432
volumes:
  db-data:
secrets:
  db-password:
    file: /tmp/db-password.txt

docker compose up
curl localhost:8080/messages

curl -X POST -H 'Content-Type: application/json' -d '{"id":1,"title":"my title", "description":"my body"}' http://localhost:8080/messages

curl localhost:8080/messages


docker run --rm -p 8080:80 nginx
ps aux | grep docker-proxy

sudo nft list ruleset
sudo nft list table ip nat
curl 10.4.0.XX:8080
sudo nft list table ip nat

docker run -d --name mem-test polinux/stress stress --vm 1 --vm-bytes 15M

docker run -d --name mem-test -m 10mb polinux/stress stress --vm 1 --vm-bytes 15M

docker rm -f mem-test
docker run -d --name mem-test -m 10mb polinux/stress stress --vm 1 --vm-bytes 8M

docker stats mem-test

mount | grep cgrou

find /sys/fs/cgroup -name *ContainerID*
```
