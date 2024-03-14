Projekt kino
============

V tomto projektu jsme si dali za cíl vyrobit nasvětlení pro divadelní/kino
scénu. Z kartonů jsme vyrobili jeviště, z lego-technic strop a osvětlovací
věže, dírky jsme pak využili pro LED diody, případně přichycení LED pásků.
Vše jsme buď přímo, nebo pomocí tranzistorů připojili k několika
microbitům, které je mohou rozsvěcet a zhasínat. Celé to řídí hlavní
"serverový" microbit, který je instruovaný z počítače a posílá zprávy
našim "klientským" microbitům.


Grafické rozhraní
-----------------

Serverová část je nad limit kurzu, jedná se o GUI (grafické uživatelské
rozhraní) vytvořené v jazyce Python:

* TODO

a její funkcí je umožnit ovládání jednotlivých zařízení připojených k
několika microbitům. Tato část posílá na sériovou konzoli zprávy ve
formátu ``KANÁL NÁZEV HODNOTA``, kde:

* KANÁL - udává kanál, na kterém bude poslouchat microbit, který chceme
  instruovat
* NÁZEV - udává název funkce/diodu/pásek na cílovém microbitu
* HODNOTA udává hodnotu, kterou této funkci/diodě/pásku chceme předat

vše oddělené pomocí mezer.


| ZPRÁVA               | POPIS |
| ---------------------|------------------------------------------|
| 0 5 1023             | Rozsviť diodu 5 na microbitu na kanále 0 |
| 15 pasek 1023 0 1023 | Rozsviť pásek ``pasek`` připojený k microbitu na kanále 15 barvou #FF00FF |
| 7 servox 78          | Nastav servox připojené k microbitu na kanále 7 na pozici 78 |

Řídící microbit (server)
------------------------

Tyto zprávy putují po sériové konzoli do řídícího (server) microbitu.
Ten čte zprávy na sériové konzoli, zjistí, na jaký kanál má zprávu
přeposlat a odešle ji. [Micropython](https://python.microbit.org/v/3)
základní kód:

```python

from microbit import *
import radio

# Opakuj do nekonečně
while True:
    # Přečti řádku ze sériové konzole
    line = input().split(' ', 1)
    # Kanál je prvním argumentem ve formátu číslo (integer - int)
    kanal = int(line[0])
    display.set_pixel(x, y, 0 if display.get_pixel(x, y) else 9)
    # Nastav skupinu/kanál rádia
    radio.config(group=kanal)
    # Odešli zbytek řádky ke zpracování microbitům na tomto kanále
    radio.send(line[1])
```

V praxi jsme pak používali lehce složitější verzi s vizualizací
odesílaného kanálu a obsluze případné chyby:

```python

from microbit import *
import radio


# Opakuj do nekonečně
while True:
    try:
        # Přečti řádku ze sériové konzole
        line = input().split(' ', 1)
        channel = int(line[0])
        # Vizualizace odesílaného kanálu
        x = channel // 5
        y = channel % 5
        display.set_pixel(x, y, 0 if display.get_pixel(x, y) else 9)
        # Nastav skupinu/kanál rádia
        radio.config(group=channel)
        # Odešli zbytek řádky ke zpracování microbitům na tomto kanále
        radio.send(line[1])
    except Exception as details:
        # V případě chybi ji vypiš na seriovou konzoli
        print(details)
```


Klientské microbity (client)
----------------------------

Klientské microbity mají na sobě připojené LED diody/pásky či motůrky.
Pár ukázek [Micropython](https://python.microbit.org/v/3) kódů které
slouží jako inspirace a zároveň kostra programu pro děti:

```python
# Ovládání LED diod připojených na piny 0, 1, 2, 3, 4
from microbit import *
import radio


# Nastav skupinu rádia
radio.on()
radio.config(group=0)

while True:
    try:
        prijato = radio.receive()
        # Zkontroluj, že přišla nějaká zpráva
        if not prijato:
            continue
        # Zprávu rozděl po mezerníkách
        data = prijato.split(' ')
        # Získej diodu a hodnotu
        dioda = data[0]
        hodnota = int(data[1])
        # Rozsviť požadovanou diodu
        if dioda == "0":
            pin0.write_analog(hodnota)
        elif dioda == "1":
            pin1.write_analog(hodnota)
        elif dioda == "2":
            pin2.write_analog(hodnota)
        elif dioda == "3":
            pin3.write_analog(hodnota)
        elif dioda == "4":
            pin4.write_analog(hodnota)
        else:
            print("ERROR: %s" % prijato)
    except Exception as details:
        # Vytiskni chybu na seriovou konzoli
        print(str(details))
```

```python

# Ovládání LED pásku připojeného na pinu 1 s 11 diodami
from microbit import *
import radio
import neopixel


# Nastav skupinu rádia
radio.on()
radio.config(group=0)

# Zapni led pásek
pasek = neopixel.NeoPixel(pin1, 11)

while True:
    try:
        prijato = radio.receive()
        # Zkontroluj, že přišla nějaká zpráva
        if not prijato:
            continue
        # Zprávu rozděl po mezerníkách
        data = prijato.split(' ')
        # Získej diodu a hodnotu
        modul = data[0]
        hodnota = int(data[1])
        # Rozsviť všechny diody LED pásku
        if modul == "pasek":
            r = hodnota
            g = int(data[2])
            b = int(data[3])
            pasek.fill((r // 4, g // 4, b // 4))
            pasek.show()
        else:
            print("ERROR: %s" % prijato)
    except Exception as details:
        # Vytiskni chybu na seriovou konzoli
        print(str(details))
```

Pro simulaci denního světla lze využít LED pásek s pohyblivým světlem:

```python
from microbit import *
import radio
import neopixel


# Nastav skupinu rádia
radio.on()
radio.config(group=0)

# Zapni led pásek
DELKA = 27  # Počet diod
POZICE = 0  # Pozice kam svítit
SIRKA = 3   # Kolik LED rozsvítit okolo středu
BARVA = (255, 255, 255)   # Jakou barvou svítit
PASEK = neopixel.NeoPixel(pin1, 11)
# Otestuj funkci po spuštění
PASEK.fill((0, 0, 255))
PASEK.show()

def zobraz_pasek():
    # Překresli LED pásek
    PASEK.clear()
    PASEK[POZICE] = BARVA
    for i in range(1, SIRKA):
        PASEK[max(POZICE - i, 0)] = BARVA
        PASEK[min(POZICE + i, DELKA-1)] = BARVA
    PASEK.show()

while True:
    try:
        prijato = radio.receive()
        # Zkontroluj, že přišla nějaká zpráva
        if not prijato:
            continue
        # Zprávu rozděl po mezerníkách
        data = prijato.split(' ')
        # Získej diodu a hodnotu
        modul = data[0]
        hodnota = int(data[1])
        if modul == "pozice":
            # Změň pozici a překresli pásek
            # hodnota je 0 - 1023, přepočítej na 0 - (DELKA-1)
            POZICE = hodnota * DELKA // 1024
            zobraz_pasek()
        elif modul == "barva":
            # Změň barvu a překresli pásek
            # hodnota ke 0 - 1023, přepočítej na 0 - 255
            BARVA = (hodnota // 4, int(data[2]) // 4, int(data[3]) // 4)
            zobraz_pasek()
        elif modul == "pasek":
            # Rozsviť všechny diody LED pásku
            r = hodnota
            g = int(data[2])
            b = int(data[3])
            # hodnota ke 0 - 1023, přepočítej na 0 - 255
            PASEK.fill((r // 4, g // 4, b // 4))
            PASEK.show()
        else:
            print("ERROR: %s" % prijato)
    except Exception as details:
        # Vytiskni chybu na seriovou konzoli
        print(str(details))
```

Můžeme zobrazit i několik pohyblivých světel na jednom led pásku_

```python
from microbit import *
import radio
import neopixel


# Nastav skupinu rádia
radio.on()
radio.config(group=4)

class Svetlo:
    def __init__(self, pozice=0, sirka=0, barva=(0, 0, 0)):
        self.pozice = pozice
        self.sirka = sirka
        self.barva = barva

    def __str__(self):
        return " ".join(str(_) for _ in (self.pozice, self.sirka, self.barva))

# Zapni led pásek
DELKA = 300  # Počet diod
SVETLA = [Svetlo() for _ in range(5)]
PASEK = neopixel.NeoPixel(pin1, DELKA)
# Otestuj funkci po spuštění
PASEK.fill((0, 0, 255))
#PASEK[0] = (254, 0, 0)
PASEK.show()

def zobraz_pasek():
    # Překresli LED pásek
    PASEK.clear()
    for svetlo in SVETLA:
        PASEK[svetlo.pozice] = svetlo.barva
        i=0
        for i in range(1, svetlo.sirka):
            PASEK[max(svetlo.pozice - i, 0)] = svetlo.barva
            PASEK[min(svetlo.pozice + i, DELKA-1)] = svetlo.barva
    PASEK.show()

while True:
    try:
        prijato = radio.receive()
        # Zkontroluj, že přišla nějaká zpráva
        if not prijato:
            continue
        # Zprávu rozděl po mezerníkách
        data = prijato.split(' ')
        # Získej diodu a hodnotu
        modul = data[0]
        index = int(data[1])
        hodnota = int(data[2])
        if modul == "pozice":
            # Změň pozici a překresli pásek
            # hodnota je 0 - 1023, přepočítej na 0 - (DELKA-1)
            SVETLA[index].pozice = hodnota * DELKA // 1024
            zobraz_pasek()
        elif modul == "barva":
            # Změň barvu a překresli pásek
            # hodnota ke 0 - 1023, přepočítej na 0 - 255
            SVETLA[index].barva = (hodnota // 4, int(data[3]) // 4, int(data[4]) // 4)
            zobraz_pasek()
        elif modul == "sirka":
            # Změň šířku světla a překresli pásek
            SVETLA[index].sirka = hodnota * DELKA // 512
            zobraz_pasek()
        elif modul == "pasek":
            # Rozsviť všechny diody LED pásku
            r = hodnota
            g = int(data[3])
            b = int(data[4])
            # hodnota ke 0 - 1023, přepočítej na 0 - 255
            PASEK.fill((r // 4, g // 4, b // 4))
            #PASEK[0] = (r // 4, g // 4, b // 4)
            PASEK.show()
        else:
            print("ERROR: %s" % prijato)
    except Exception as details:
        # Vytiskni chybu na seriovou konzoli
        print(str(details))
```

Pro otestování komunikace jsme nejprve použili (trošku složitější)
kód který rozsvěcí přímo diody na displeji microbitu:

```python
from microbit import *
import radio


# Nastav skupinu rádia
radio.on()
radio.config(group=0)

while True:
    try:
        prijato = radio.receive()
        # Zkontroluj, že přišla nějaká zpráva
        if not prijato:
            continue
        # Zprávu rozděl po mezerníkách
        data = prijato.split(' ')
        # Získej diodu a novou hodnotu
        dioda = int(data[0])
        hodnota = int(data[1])
        # Rozsviť diodu 0-25 pomocí souřadnic 0-5, 0-5
        # hodnotu poděl 114 protože microbit očekává hodnotu 0-9
        display.set_pixel(dioda //  5, dioda % 5, hodnota // 102)
    except Exception as details:
        # Vytiskni chybu na seriovou konzoli
        print(str(details))
```
