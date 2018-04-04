# AKiSO-Bash
Bash scripts written for the AKiSO course labs at WUST.

## List 2.
zad. 1. 1.
Wytłumacz jakie pliki zawierają katalogi /dev oraz /proc. 

Wszystko w systemie Linux traktowane jest albo jako plik, albo jako katalog. 

Katalog /dev zawiera specjalne pliki dla każdego sprzętu podłączonego do komputera. Uogólniając, urządzenia te dzielą się na „block devices” (urządzenia, które przechowują albo przetrzymują dane - FDD, HDD, CD-ROM) oraz „character devices” (urządzenia, które transmitują lub przesyłają dane - porty szeregowe, myszki, porty równoległe [drukarki])

Katalog /proc jest wyjątkowy, ponieważ pełni rolę wirtualnego systemu plików. Nie zawiera on w rzeczywistości plików, lecz informacje o środowisku (pamięć systemowa, zamontowane urządzenia, konfiguracja sprzętowa). Wiele narzędzi systemowych odwołuje się do plików w /proc, np. lsmod to to samo, co cat /proc/modules. Zmiana plików w tym katalogu wpływa na zmianę parametrów jądra (sysctl) w trakcie działania systemu. Wszystkie pliki, poza kcore, mtrr, self mają rozmiar 0.

Przykłady: 
'cat /boot/vmlinuz > /dev/dsp' 
-> dźwięk kernela do karty dźwiękowej

lspci 
-> synonim cat /proc/pci

zad. 1. 2.
Wykorzystując polecenie dd odczytaj pierwszy sektor z dysku głównego (uwaga na prawa dostępu) lub podpiętego pendrive'a i wyświetl przez hexdump -C. 

dd if=/dev/sda bs=512 count=1 | hexdump -C

zad. 1.3.
Z katalogu proc wyświetl informacje o pamięci oraz procesorze.

cat /proc/cpuinfo (lscpu)
cat /proc/meminfo

zad. 2.
Zapoznaj się z programem ps (man ps). Naucz się posługiwać tym programem, aby umieć sprawdzać co najmniej istnienie i parametry wybranych procesów (PID procesu i rodzica, stan procesu, priorytet, nice, ilość pamięci, zużycie czasu procesora).

ps aux 
-> user, pid, %cpu, %mem, vsz (virtual memory size), rss (non-swapped physical mem used), stat

ps aux -l 
-> niceness

ps -axjf
-> na linux

Opisy stanów procesów:

D - Uninterruptible sleep (usually IO)
R - Running or runnable (on run queue)
S - Interruptible sleep (waiting for an event to complete)
T - Stopped, either by a job control signal or because it is being traced.
W - paging (not valid since the 2.6.xx kernel)
X - dead (should never be seen)
Z - Defunct ("zombie") process, terminated but not reaped by its parent.

zad. 3.
(5pt) Zapoznaj się z kompilatorem języka C (polecenie gcc) oraz języka C++ (polecenie g++). Uruchom poniższy program w języku C. Wytłumacz każdy z powyższych kroków. Co oznaczają opcje -Wall oraz -pedantic? Zobacz man gcc.

- Wall - wyświetla wszystkie ostrzeżenia na temat konstrukcji, uznawanych za wątpliwe (questionable) przez użytkowników, ale są łatwe do uniknięcia lub zmodyfikowania. Włącza wiele flag warningów.

- pedantic - wyświetla wszystkie ostrzeżenia wymagane przez standard ISO C, odrzuca programy wykorzystujące zabronione rozszerzenia. Dla C wersję standardu definiujemy przez -std

zad. 4.
(5pt) Uruchom potok co najmniej trzech poleceń działających przez jakiś zauważalny czas. Mogą to być odpowiednio dobrane polecenia systemowe. Sprawdź poleceniem ps i odpowiedz jakie zachodzi pokrewieństwo między tymi procesami (jeśli w ogóle zachodzi)

ps aux | grep root | grep pawelnarolski | more -> wyświetli wszystkie procesy należące do roota lub użytkownika (ls -l | grep psd)

najbardziej spektakularne:

find / | grep Pobrane | sort 

Zależności pomiędzy procesami w pipie?
WAITING CHANNEL - name of the kernel function in which the process is sleeping, a "-" if the process is running, or a "*" if the process is multi-threaded and ps is not displaying threads.

zad. 5.
(5pt) Poleceniem mkfifo (man mkfifo) utwórz potok nazwany (ang. named FIFO). Wywołując polecenie cat w różnych terminalach spowoduj wpisywanie danych do potoku przez jeden(ne) proces(y), i odczytywanie i wyświetlanie ich przez inne. Zaobserwuj, kiedy polecenie cat czytające z potoku czeka na więcej danych, a kiedy kończy pracę. Analogicznie, kiedy czeka na więcej danych (z klawiatury) polecenie cat piszące do potoku?

terminal 1:
mkfifo pipe

terminal 2:
cat < pipe
(terminal czeka, aż z 1. wyślemy jakieś dane)

terminal 1:
ls -l > pipe

terminal 2:
(wyświetla wynik polecenia ls -l)

zad. 6.
(8pt) Napisz program w języku C, który wykorzystując sekwencje Esc (ang. escape sequences) standardu ANSI wyświetli na ekranie napis "Hello, World!", po kolei we wszystkich dostępnych przez terminal kolorach. Czy terminal może wyświetlić 256 kolorów?

Rozwiązanie.
program wywołujemy w potoku:

tput colors | ./zadanie6

Wyjaśnienie:
1. Za pomocą polecenia tput colors otrzymujemy liczbę kolorów obsługiwanych przez terminal.
2. Otrzymaną liczbę przekazujemy potokiem do programu, który ją odczytuje z potoku, a następnie wyświetla napis Hello World w odpowiedniej liczbie kolorów.

zad. 7.
(10pt) Napisz potok poleceń, który zamienia wszystkie nazwy plików w danym katalogu (bez podkatalogów) na małe litery, czyli wszystkie duże litery występujące w nazwach plików zostaną zamienione na małe, a małe litery pozostają oczywiście dalej małe.

Kod: 

ls | while read uppercase; do lowercase=`echo "${uppercase}" | tr '[:upper:]' '[:lower:]'`; mv "$uppercase" "$lowercase"; done

Wyjaśnienie:
tr - translate characters
mv - move files

Jak działa polecenie:
1. Wypisujemy wszystkie nazwy plików za pomocą rozszerzenia ls.
2. W pętli while: Do czasu, aż nie przejdziemy przez wszystkie pliki: - "prześlij" potokiem nazwę pliku do polecenia tr, które zamieni wielkie litery na małe litery (według podanego wzorca) - przypisz nazwę pliku bez wielkich liter do zmiennej lowercase - zamień nazwę pliku z uppercase na lowercase
