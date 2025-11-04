Ansible
- Można użyć maszyny przesiadkowej, albo ze swojej - obie wersje są ok, ale każda ma swoje problemy
- Na maszynach docelowych nie ma żadnego demona ansible, Ansible robi coś (jednokierunkowe polecenia) z głównej maszyny
- Zainstalować ansible
- ansible-config view - pokazuje konfigurację
touch .ansible.cfg - tworzymy nowy plik konfiguracyjny
- W jakimś naszym katalogu tworzymy plik touch inventory.yaml i tam definiujemy nasze maszyny
- Można dopisać inventory do config-a, albo podawać za każdym razem w komendzie "ansible -i inventory.yaml"
- włączanie ansible - `ansible -i inventory all -a date`
- najpierw trzeba ręcznie zrobić jednorazowo ssh 
- hasło do maszyny można podać w inventory.yaml, albo bepieczniej dodać maszynom klucz ssh maszyny z ansible
- `ansible -m <moduł>`
- moduł package instaluje paczki
	`ansible all -m package -a 'name=htop state=present'`
- `-b` - jako inny użytownik (root)
- Lista dostępnych modułów na https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html#modules
- Listę komend możemy trzymać w pliku yaml (playbook-u)
- Nazewnictwo:
	- task (moduł + argumenty)
	- rola (lista tasków do wykonania w sekwencji)
	- playbook przypisanie komputerów do roli
- można używać obu rozszerzeń plików `.yml` i `.yaml`
- Struktura katalogów roli: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html
- jak używamy playbooka, to wtedy
 `ansible-playbook -i <inventory> <playbook>`
- używać modułu fail, żeby przerywać wykonywanie, jak coś jest nie tak
- do template-ów język jinja2 https://jinja.palletsprojects.com/en/stable/templates/

- Moduł `authorized_key` do wgrywania kluczy ssh
- flaga `-l <nazwa_maszyny>` uruchamia tylko na wybranej maszynie
- Moduł `lineinfile` dopisuje coś do pliku
- lepiej nie używać _handlerów_ tylko register-when, bo wtedy zawsze widać, czy są pomijane, czy używane (a przy notify się w ogóle może nie pojawiać)

- `ansible-galaxy collection` - repozytorium z kolekcjami
- Można używać gotowych kolekcji, albo tworzyć własne. Kolekcja to zbiór pluginów.

Uważać na 'no' w yaml-u bo to oznaczas false, więc trzeba w cudzysłowach lub apostrofach, żeby interpretował jako test
Font iosevka
_Zuul_ system CI do Ansible
fish shell
