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
        led = data[0]
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