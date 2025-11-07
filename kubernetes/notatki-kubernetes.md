
- OCI - format obrazów
- Borg - alternatywa Kubernetesa od Google
- Docker swarm - też do orkierstacji, ale już kończy rozwój
- w praktyce Kubernetes jest jedynym wyborem

- _pod_ - kontener lub kilka
- _scheduler_ - wskazuje gdzie można uruchomić pod
- _controls manager_ - zajmuje się realizcją zapytań do api server-a
- K3s to uproszczony Kubernetes
- `kubectl` - klient Kubernetesa
- `minikube` - Kubernetes do lokalnego uruchamiania
- `kubectl get nodes` - lista node-ów zarejestrownych w klastrze
- `minikube ssh` - połączenie po ssh do głównego kontenera minikube
- w Kubernetes-ie de facto nie ma docker-a. K8s używa bezpośrednio containerd.
- `kubectl creare -f <yaml>` - tworzy pody zdefiniowane w yaml-u
- `kubectl port-forward pods/basic-nginx 8080:80` - przekierowujemy port poda 80 na nasz port 8080
- nazwy plików yaml w K8s typu _deployment_ nie mają znaczenia
- `get pods -l company=pirates` - pokazanie kodów, które mają company=pirates
- do podów odwołujemy się po ich label-kach
- Można też najpierw zrobić usługę, a potem pod-y. Kontrolery na bieżaco śledzą sytuację i dokonfigurują, co trzeba.
- `kubectl replace -f deployment.yaml` - przeładowuje plik po zmianach
- kontenery wewnątrz jednego pod-a mogą się komunikować po localhost
- `kubectl rollout restart deployment infov6` - reset deploymentu
- `kubectl describe pod infov6-59b7f8c6bf-p575n` - pokazuje szczegóły konkretnego pod-a (do debugowania)
- `kubectl rollout undo deployment infov6` - wycofanie zmian

- `kubectl create configmap podinfo-cofig --from-literal version=1 --from-literal msg="Welcame to devops"` - stworzenie mapy konfiguracji z polecenia, bez pliku YAML
- w YAML-u `|-` oznacza wieloliniowy tekst z usunięciem znaku nowej linii
- config map-y - są po to, że dokonfigurowywać nasze pod-y. Zapisujemy sobie jakieś dane do użycia później.

- _namespace_ - grupowanie zasobów w Kubernetes w obrębie klastra
- `kubectl create namespace myapi`
- `--dry-run=client` - symulacja komendy
- `--dry-run=client -oyaml` - pokazuje YAML, ale nie wykonuje komendy
- `kubectl edit deployments.apps -n myapi mydeploy` - edycja istniejącego deploy-mentu
- `kubectl delete deplooyments.apps web01` - usuwanie poda

## Services
- Kubernetes pozwala łączyć się pod-om ze sobą wzajemnie po nazwach hostów. Przy łączeniu się adresem ip, load balanser przekierowuje do własciwej repliki.
- lepiej używać pełnej nazwy hosta np. `web01.default.svc.cluster.local.` zamiast `web01`. Wtedy oszczędzamy DNS-a
- `kubectl get svc` - pokazuje serwisy
- `k logs --selector app=web01 --prefix --timestamps --since 5m --tail 500 | grep pod/web01-7d78477f84-xvgzk/nginx | wc -l` - pokazanie jak load balancer rozłożył ruch
- load balancer rozkłada to losowo z miarę równym prawdopodobieństwem

## Sekrety
- `kubectl create secret generic docker-reg \
    --from-file=.dockerconfigjson=$HOME/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson`
- `kubectl get secrets` - wypisanie sekretów
- sekrety nie są szfrowane, tylko w bas64 w klastrze

## Storage
- 



## Inne
- landscape.cncf.io/
](https://board.net/p/r.0d70fb7df088f0562d74a45082424617

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

Volume
- `docker volume ls` - pokazuje listę wolumenów
- możemy trzymać pliki wewnątrz kontenera, po restarcie kontenera je zachowamy, ale po usunięciu kontenera przepadną
- `docker run -v <lokalny_katalog>:<ścieżka_na_kontenerze> <nazwa_obrazu>` - dodawanie wolumenu
- `docker volume create <nazwa_wolumenu>` - tworzenie wolumenu
- `docker volume inspect <nazwa_wolumenu>` - pokazuje, w którym katalogu jest przechowywany wolumen
- `docker run -d -p 8081:8081 -v <nazwa_wolumenu>:<ścieżka_na_kontenerze> <nazwa_obrazu>`
- używanie `docker volume` będzie trochę szybsze niż podawanie ścieżki w `docker run`
- Po zatrzymaniu kontenera, tracimy to co było w pamięci podręcznej kontenera
- `docker run ... --restart unless-stopped` - nasz obraz będzie uruchamiany po każdym starcie docker-a dopóki go wprost nie zatrzymamy

Network
- `docker network ls` - pokazuje listę inteferjsów sieciowych
- domyślnie kontenery są w sieci `bridge` - mają łączność między sobą, można się do nich połączyć z zewnątrz
- dobry obraz do diagnostyki sieciowej - `nicolaka/netshoot`
- `docker network create <network_name>`
- `docker run --rm -it --network <network_name> ...` - podłączenie do określonej sieci. Dzięki temu możemy komunikować się między kontenerami po `hostname`

Budowanie
- `docker build --build-arg DEST_FILE=ninja.html -t nginx-ninja:v2 .` - przekazywanie argumentów do Dockerfile-a
- kolejność w Dockerfile-u - od najmniej zmienianych kroków
- `ENTRYPOINT ["/src/api"]` - polecenie uruchamiane po starcie kontenera
- `docker images -f "dangling=true"` - wypisanie dangling kontenerów
- `docker image prune -f` - czyszczenie z dangling images


- lekkie, bezpieczne dystrubucje do kontenera:
	- distroless od Google
	- www.chainguard.dev/containers- bezpieczniejsze
	- Chiselled Ubuntu images

ctrl + l - przewijanie konsoli
`ipcalc`
`mkdir -p`  tworzy całe drzewo katalogów


---

# Kubernetes

- OCI - format obrazów
- Borg - alternatywa Kubernetesa od Google
- Docker swarm - też do orkierstacji, ale już kończy rozwój
- w praktyce Kubernetes jest jedynym wyborem

- _pod_ - kontener lub kilka
- _scheduler_ - wskazuje gdzie można uruchomić pod
- _controls manager_ - zajmuje się realizcją zapytań do api server-a
- K3s to uproszczony Kubernetes
- `kubectl` - klient Kubernetesa
- `minikube` - Kubernetes do lokalnego uruchamiania
- `kubectl get nodes` - lista node-ów zarejestrownych w klastrze
- `minikube ssh` - połączenie po ssh do głównego kontenera minikube
- w Kubernetes-ie de facto nie ma docker-a. K8s używa bezpośrednio containerd.
- `kubectl creare -f <yaml>` - tworzy pody zdefiniowane w yaml-u
- `kubectl port-forward pods/basic-nginx 8080:80` - przekierowujemy port poda 80 na nasz port 8080
- nazwy plików yaml w K8s typu _deployment_ nie mają znaczenia
- `get pods -l company=pirates` - pokazanie kodów, które mają company=pirates
- do podów odwołujemy się po ich label-kach
- Można też najpierw zrobić usługę, a potem pod-y. Kontrolery na bieżaco śledzą sytuację i dokonfigurują, co trzeba.
- `kubectl replace -f deployment.yaml` - przeładowuje plik po zmianach
- kontenery wewnątrz jednego pod-a mogą się komunikować po localhost
- `kubectl rollout restart deployment infov6` - reset deploymentu
- `kubectl describe pod infov6-59b7f8c6bf-p575n` - pokazuje szczegóły konkretnego pod-a (do debugowania)
- `kubectl rollout undo deployment infov6` - wycofanie zmian

- `kubectl create configmap podinfo-cofig --from-literal version=1 --from-literal msg="Welcame to devops"` - stworzenie mapy konfiguracji z polecenia, bez pliku YAML
- w YAML-u `|-` oznacza wieloliniowy tekst z usunięciem znaku nowej linii
- config map-y - są po to, że dokonfigurowywać nasze pod-y. Zapisujemy sobie jakieś dane do użycia później.

- _namespace_ - grupowanie zasobów w Kubernetes w obrębie klastra
- `kubectl create namespace myapi`
- `--dry-run=client` - symulacja komendy
- `--dry-run=client -oyaml` - pokazuje YAML, ale nie wykonuje komendy
- `kubectl edit deployments.apps -n myapi mydeploy` - edycja istniejącego deploy-mentu
- `kubectl delete deplooyments.apps web01` - usuwanie poda

## Services
- Kubernetes pozwala łączyć się pod-om ze sobą wzajemnie po nazwach hostów. Przy łączeniu się adresem ip, load balanser przekierowuje do własciwej repliki.
- lepiej używać pełnej nazwy hosta np. `web01.default.svc.cluster.local.` zamiast `web01`. Wtedy oszczędzamy DNS-a
- `kubectl get svc` - pokazuje serwisy
- `k logs --selector app=web01 --prefix --timestamps --since 5m --tail 500 | grep pod/web01-7d78477f84-xvgzk/nginx | wc -l` - pokazanie jak load balancer rozłożył ruch
- load balancer rozkłada to losowo z miarę równym prawdopodobieństwem

## Sekrety
- `kubectl create secret generic docker-reg \
    --from-file=.dockerconfigjson=$HOME/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson`
- `kubectl get secrets` - wypisanie sekretów
- sekrety nie są szfrowane, tylko w bas64 w klastrze

## Storage
- `emptyDir: {}` - przepada po resecie pod-a
- `hostPath` jest niebezpieczne, bo piszemy po dysku nod-a
- pod `storage-provisioner` - to dodatkowy element minikube do obsługi storage (to nie jest od Kubernetesa). Akurat to też jest słabe, bo to też jest hostpath
- `persistentvolume` - odpowiada za przydzielenie fizycznego zasobu
- `persistentvolumeclaim` - zajmuje się żadaniami dostępu do zasobu

- _cloud controller manager_ odpowiada za kontakt z chmurą (np.load balancer)
- 


- landscape.cncf.io/
- Gitops
- en.wikipedia.org/wiki/Hetzner - tańsza chmura
- docs.tigera.io/calico

- cluster ip - umożliwia komunikację wewnątrz klastra
- node port - umożliwia wpuszcznie ruchusieciowego do klastra
- load balancer też używa node port-u

---

- do lokalnego użytku (np. testy w CI) zamiast minikube lepiej użyć kind (https://kind.sigs.k8s.io/)
- `microk8s`, `k3s` - ma takie same API jak Kubernetes, ale pod spodem dziaął inaczej (korzysta z innej bazy danych itp.)
- https://github.com/kelseyhightower/kubernetes-the-hard-way - instrukcja jak postawić od zera Kubernetes-a
- https://github.com/kubernetes-sigs/kubespray - narzędzie ułatwiające instalację K8s


## Kubernetes na bare metal
- nie chcemy używać swap - chcemy mieć przewidywalną wydajność
- włączamy forwardowanie ipv4, żeby poprawnie przekazywać ruch między sieciami
- używamy systemd do zarządzania grupami kontrolnymi (cgroups)
- `kubelet` - agent zarządzający kontenerami zgodnie z instrukcjami kotrolra
- `kubectl` - do komunikacji z klastrem
- `kubeadm` - do inicjalizacji i konfuguracji klastra

- niewidoczny kontener "pause" jest po to, żeby nie starcić adresu ip czy restartach kontenera
- `scp $CP:/home/kurs/.kube/config $HOME/.kube/config` - dzięki temu możemy z naszego lokalnego  kubectl możemy wysyłać do control-plane na serwerze 00control


## Helm
- packet manager dla Kubernetes-a
- chart - instrukcja z parametrami dla Kubernetes-a. Można wyeksportować wiele yaml-i do chart-a w formacie OCI (jak w Docker)
- k9s (k9scli.io) - terminalowy dobry UI do zarządzania klastrami

-


## Inne:
- `watch` - cykliczne wywoływanie jakiejś komendy 
- Calico
