# gitlist
1. Instalujemy PHP7.2 na Ubuntu 16.04
Gdy mamy zainstalowany system Ubuntu 16.04 w wersji serwerowej, mamy już zainstalowany PHP w wersji 7.0, dla naszego artykułu nie potrzebujemy wyższej wersji (w sumie wersja 5 jest równie dobra) ale pokażę jak podbić wersję do PHP 7.2.

Dodajmy pierw odpowiednie repozytoria do czystej instancji VPSa:

apt-get install python-software-properties software-properties-common 
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php 
apt-get update
Teraz usuńmy poprzednie (jeśli istnieją) instalacje:


1
apt-get remove php5-common -y


lub opcja purge, usuwanie z konfiguracjami:


1
apt-get purge php5-common -y


Teraz instalacja cora PHP7:

apt-get install php7.2 php7.2-fpm php7.2-xml -y
i czyścimy śmieci:


1
apt-get --purge autoremove -y


Wynik jaki uzyskaliśmy:

# php -v
PHP 7.2.3-1+ubuntu16.04.1+deb.sury.org+1 (cli) (built: Mar 6 2018 11:18:25) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
 with Zend OPcache v7.2.3-1+ubuntu16.04.1+deb.sury.org+1, Copyright (c) 1999-2018, by Zend Technologies
2. Instalujemy GIT’a
Git jest dziś dostarczany do niemal każdej dystrybucji systemu operacyjnego. Jeśli z jakiegoś przypadku nie masz zainstalowanego git’a, oto komenda naprawiająca ten błąd.

apt-get install git
W wyniku oczywiście otrzymamy najnowszą wersję uznaną przez prowajdera:

# git --version
git version 2.7.4
3. Instalujemy Apache2
Kolejny krok to instalacja serwera, który będzie obsługiwał klienta webowego. Wybieram Apache ze względu na własne zasiedzenie przy nim. Nie ma też problemu z wykorzystaniem konkurencyjnych produktów.

apt-get install apache2 libapache2-mod-php
Dodajemy jeszcze moduł rewrite, aby pozbyć się niepotrzebnych nazw skryptów z url’a. Po tym musimy zrestartować serwer. Nie wystarczy sam reload, to jest za poważna zmiana ustawień.

a2enmod rewrite
service apache2 restart
Wynik:

Zainstalowany Apache2

 

4. Dodajemy stronę git.e-strix.com
Teraz dodamy konfigurację naszej strony. Jest to konieczne aby zmienić wyświetlany domyślny katalog dla apache.

Notatka: Ważne jest aby dodać do naszych hostów adres IP i nazwę domeny. Dla mnie to będzie git.e-strix.com. Osobiście korzystam z hostingu i definicji rekordów A.

cd /etc/apache2/sites-available
i dalej tworzymy plik konfiguracyjny naszej strony:

vim git.e-strix.com.conf
Notatka: Możesz nie mieć zainstalowanego edytora tekstowego. Dla mojej pracy używam Vim’a, bo go lubię i znam. Nie ma powodów żeby wybierać tylko jego. Jeśli wolisz Nano czy masz zainstalowany program MidnightCommander z wewnętrznym edytorem, śmiało wybierz najlepszą dla siebie opcje.

Zawarość pliku:

<VirtualHost *:80>
        ServerAdmin kontakt@e-strix.pl
        ServerName git.e-strix.com
        DocumentRoot /var/www/git.e-strix.com/public_html/

        <Directory "/var/www/git.e-strix.com/public_html/">
                DirectoryIndex index.php index.html

                Options FollowSymLinks
                AllowOverride All
        </Directory>

        ErrorLog /var/www/git.e-strix.com/error.log
        CustomLog /var/www/git.e-strix.com/access.log combined

</VirtualHost>
Tworzymy katalog docelowy, gdzie będą przechowywane pliki aplikacji GitList:

mkdir -p /var/www/git.e-strix.com/public_html
i każemy apache udostępnić naszą stronę w sieci:

a2ensite git.e-strix.com.conf
service apache2 reload
Notatka: Pamiętaj o dodaniu przekierowania DNS na IP serwera na którym stawiasz serwer.

Efekt:


5. Instalujemy GitList
Aplikacja GitList jest stworzona w PHP i jest prosta w obsłudze, dlatego postanowiłem o niej napisać. Jako programista nie mam zamiaru poświęcać więcej czasu na administrację serwer niż jest to konieczne. Dlatego wybieram narzędzia oparte o PHP aby nie bawić się w budowanie, publikowanie i namiętne analizowanie dzienników.

Zatem podążając wg instrukcji:

Pobieramy GitList z gitlist.org i wypakowujemy do naszego katalogu /var/www/gitlist.e-strix.com/public_html/
Zmieniamy nazwę pliku config.ini-example na config.ini
Podmieniamy ścieżkę repozytorium
Tworzymy catalog cache z uprawnieniami czytanie/pisanie wg. instrukcji
Notatka: Ja wybrałem wersję 0.3 –  z powodu błędu jaki uzyskałem w nowszej wersji. W przyszłości spróbuję aktualizować aplikację, natomiast na chwilę obecną będę obserwował. Błędy wynikają niestety z wersji PHP7, dla wersji 7.2 build z 6 marca dalej nie pomógł.

cd /var/www/git.e-strix.com/public_html
wget https://s3.amazonaws.com/gitlist/gitlist-0.3.tar.gz
Rozpakujemy pobrane archiwum i zmienimy nazwę katalogu na public_html, jako ten z którego korzysta serwer. W dalszej kolejności należy nadać właściciela dla wszystkich plików.

Notatka: Jeśli korzystasz z użytkownika root do wykonania wszystkich czynność (zakładam że tak, i instalujesz na świeżej instancji serwera), to zmuszony jesteś nadać odpowiednie prawa do wszystkich katalogów i plików, lub najprościej zmienić właściciela plików. Domyślnym użytkownikiem, który obsługuje serwer apache jest www-data, i grupa www-data.

tar zxvf gitlist-0.3.tar.gz
rm gitlist-0.3.tar.gz
cd ..
chown -R www-data:www-data public_html/
W porządku teraz wg instrukcji musimy stworzyć katalog cache i nadać mu pełne prawa (sic!) w naszej aplikacji, więc wjedźmy do katalogu public_html i zróbmy to o co nas proszą:

cd public_html/
chmod 777 cache
Notatka: Katalog oczywiście się utworzy z właścicielem i grupą „root”, przy tych uprawnieniach nie mamy się co martwić brakiem uprawnień, ponieważ uprawnienia 777 są najwyższe jakie mogą być.

Teraz dodajmy konfigurację czyli zgodnie z ww. instrukcją, edytujemy plik config.ini i określamy gdzie będzie znajdowało się nasze repozytorium.

vim config.ini
Domyślnie jest ustawiona wartość „/home/git/repositories/„, myślę że spokojnie możemy wykorzystać ten katalog. Dla mojej pracy nie ma szczególnych wymagań co do tej struktury, a zatem do dzieła przejdźmy do dodania użytkownika git.

[git]
client = '/usr/bin/git' ; Your git executable path
repositories = '/home/git/repositories/' ; Path to your repositories
Dodajemy użytkownika i uzupełnimy potrzebne dane:

adduser git
Teraz należy dodać nasz katalog repozytorium:

mkdir -p /home/git/repositories/
Teraz wejdźmy do środka i dodajmy nasze pierwsze repozytorium:

cd /home/git/repositories/

git init --bare project1.git
chown -R git:git project1.git/
Czas sprawdzić czy nasze repozytorium działa i czy możemy się do niego dostać. Najlepiej sprawdzić to poprzez wykorzystanie innej maszyny, zatem przechodzimy na komputer lokalny lub inny dostępny i spróbujemy pobrać nasz projekt:

git clone git@git.e-strix.com:repositories/project1.git
No masz, działa…

Teraz wejdźmy do środka i zróbmy komit inicjalizacyjny:

cd project1/
touch .gitignore
git add .gitignore
git commit -m "init commit"
git push
Notatka: Pamiętaj o nadaniu odpowiednich uprawnień lub przypinanie użytkownika do odpowiedniej grupy w systemie.

 

W rezultacie otrzymamy wynik:



FacebookTwitterPinterestWykopFacebook MessengerLinkedIn



http://e-strix.com/
