prometheus, grafana - do metryk kodu

inspekcje kodu dobrze robi się GitLab-ie
SonarQube - do inspekcji kodu w CI/CD

---

* `git switch -` – wraca na poprzednią gałąź
* `git log -p` – pokazuje diff-y w logu
* `git log -n 2` – ostatnie 2 commity
* `git show <sha>` – pokazuje diff konkretnego commita
* `git rm <nazwa_pliku>` – przestajemy śledzić plik
* `git rm <nazwa_pliku>` – przestajemy śledzić plik
AI command line – Crash?

### LFS do dużych plików > 300 MB
```
git lfs install
git lfs track "*.zip"
git lfs ls-files
git lfs pointer --file=<nazwa pliku>
```
takie pliki nie będą wysyłane do zdalnego repo, tylko wskaźnik do niego. Są przechowywane w oddzielnej przestrzeni LFS.
Takie duże pliki można pobrać używając `git lfs pull`

### git ignore

* `git status --ignored` – pokazuje które pliki są ignorowane
* Gotowe przykładowe pliki `.gitignore` – https://github.com/github/gitignore

### git cherrypick

`git cherrypick 123465..78946` – cherrypick-ujemy zakres commitów

### git reset

- Unikamy `git reset` - nie tworzy commita z cofnięciem zmian, tylko zmieniamy historię. A już na pewno nie robimy go na serwerze.
- Nie można cofnąc zmian po hard reset.

### git stash

`git stash`
`git stash pop`
`git stash list` – lista stash-y
`git stash show` – pokazuje diffa

## Testy automatyczne

`python -m unittest discover -s tests` – jak testy są w podktalogu `tests`, a nie luzem w głównym katalogu. Plik z testem powinien zaczynać się od `tests_`.

`pytest` potrafi uruchomić też testy napisane w `unittest`

---

### Sprawdzić:
- GitLab Duo
- git protect - przenoszenie repo na inne serwery, backup między serwerami
- SonarQube w IDE

- czy Bamboo jest w praktyce tym samym co GitLab, czy Github actions?



board.net