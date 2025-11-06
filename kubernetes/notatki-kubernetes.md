
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
