Projekt kino
============

V tomto projektu jsme si dali za cíl vyrobit nasvětlení pro divadelní/kino
scénu. Z kartonů jsme vyrobili jeviště, z lego-technic strop a osvětlovací
věže, dírky jsme pak využili pro LED diody, případně přichycení LED pásků.
Vše jsme buď přímo, nebo pomocí tranzistorů připojili k několika
microbitům, které je mohou rozsvěcet a zhasínat. Celé to řídí hlavní
"serverový" microbit, který je instruovaný z počítače a posílá zprávy
našim "klientským" microbitům.

[Video-report z přípravy + výsledná videa](https://www.youtube.com/watch?v=Wm18k5CurfM)

Grafické rozhraní
-----------------

Serverová část je nad limit kurzu, jedná se o GUI (grafické uživatelské
rozhraní) vytvořené v jazyce Python:

```python
import json
from tkinter import simpledialog
import sys

import tkinter as tk


class Zarizeni:

    def __init__(self, kanal, nazev, volby="", hodnota=None):
        self.kanal = kanal
        self.nazev = nazev
        self.hodnota = hodnota
        self.indikator = None

    def __str__(self):
        return f"{self.kanal} {self.nazev} {self.text()}"

    def draw(self, frame, row, col):
        # Název zařízení
        nazev_label = tk.Label(frame, text=f"{self.kanal}/{self.nazev}", background="gray80" if col % 2 else "white")
        nazev_label.grid(row=row, column=col, pady=5, padx=5, sticky="w", columnspan=5)
        row += 1

        # Slidery pro složky RGB
        row, max_col = self.draw_ovladace(frame, row, col)

        # Kruhový widget pro zobrazení barvy
        self.indikator = tk.Canvas(frame, width=30, height=30, bg=self.hex())
        self.indikator.grid(row=row, column=col, pady=5, sticky="n", columnspan=5)
        row += 1

        # Tlačítko pro editaci zařízení
        edit_button = tk.Button(frame, text="Editovat", command=lambda zarizeni=self, indikator=self.indikator: editovat_zarizeni(self, indikator))
        edit_button.grid(row=row, column=col, pady=5, padx=5, sticky="w", columnspan=5)
        row += 1

        # Tlačítko pro smazání zařízení
        delete_button = tk.Button(frame, text="Smazat", command=lambda zarizeni=self, indikator=self.indikator: smazat_zarizeni(self, indikator))
        delete_button.grid(row=row, column=col, pady=5, padx=5, sticky="w", columnspan=5)
        max_col = max(max_col, col + 5)
        return row, max_col + 1

    def draw_ovladace(self, frame, row, col):
        return row, col

    @staticmethod
    def to_rgb(hodnota=None):
        if hodnota is None:
            hodnota = "#000000"
        return [int(hodnota[1:3], 16), int(hodnota[3:5], 16), int(hodnota[5:7], 16)]

    @staticmethod
    def to_hex(hodnota=None):
        return f"#{hodnota[0] // 4:02x}{hodnota[1] // 4:02x}{hodnota[2] // 4:02x}"

    def hex(self):
        return NotImplementedError

    def text(self):
        return NotImplementedError

    # Funkce volaná při změně hodnoty
    def zmen_hodnotu(self, hodnota):
        if self.hodnota != hodnota:
            self.hodnota = hodnota
            if self.indikator:
                self.indikator.configure(bg=self.hex())
            sys.stdout.write(f"{self}\r\n")
            sys.stdout.flush()


class ZarizeniRGB(Zarizeni):

    def __init__(self, kanal, nazev, volby="", hodnota=None):
        if hodnota is None:
            hodnota = [0, 0, 0]
        else:
            hodnota = self.to_rgb(hodnota)
        Zarizeni.__init__(self, kanal, nazev, volby, hodnota)

    def text(self):
        return " ".join(str(_) for _ in self.hodnota)

    def hex(self):
        return(self.to_hex(self.hodnota))

    def draw_ovladace(self, frame, row, col):
        # Slidery pro složky RGB
        def on_slider_click(slider):
            def focus_slider(event):
                slider.focus_set()
            return focus_slider
        for i in range(3):
            posuvnik = tk.Scale(frame, from_=0, to=1023, orient=tk.VERTICAL, showvalue=0, length=160, width=10, takefocus=True, command=lambda value, col=i: self.zmen_hodnotu(value, col))
            posuvnik.set(self.hodnota[i])
            posuvnik.bind("<Button-1>", on_slider_click(posuvnik))
            posuvnik.grid(row=row, column=col + i, pady=0, padx=0, sticky="ew")
            col += 1
        return row + 1, col

    # Funkce volaná při změně hodnoty posuvníku
    def zmen_hodnotu(self, hodnota, index=0):
        _hodnota = self.hodnota[:]
        _hodnota[index] = int(hodnota)
        Zarizeni.zmen_hodnotu(self, _hodnota)


class ZarizeniBarva(ZarizeniRGB):
    def __init__(self, kanal, nazev, volby="", hodnota=None):
        if hodnota is None:
            hodnota = 0
        else:
            hodnota = float(hodnota)
        Zarizeni.__init__(self, kanal, nazev, volby=volby, hodnota=hodnota)
        self.zaklad_rgb = self.to_rgb(volby)

    def text(self):
        return str(self.hodnota)

    def hex(self):
        return self.to_hex([int(_ * self.hodnota // 255) for _ in self.zaklad_rgb])

    def draw_ovladace(self, frame, row, col):
        # Slidery pro složky RGB
        posuvnik = tk.Scale(frame, from_=0, to=1023, orient=tk.VERTICAL, showvalue=0, length=160, width=10, takefocus=True, command=lambda value: self.zmen_hodnotu(value))
        posuvnik.set(self.hodnota)
        posuvnik.bind("<Button-1>", lambda event: posuvnik.focus_set())
        posuvnik.grid(row=row, column=col, pady=0, padx=0, sticky="ew")
        return row + 1, col

    def zmen_hodnotu(self, hodnota):
        Zarizeni.zmen_hodnotu(self, int(hodnota))


# Vlastní dialog pro zadání zařízení a adresy
class ZarizeniDialog(simpledialog.Dialog):

    def __init__(self, parent, title):
        self.kanal = None
        self.nazev = None
        super().__init__(parent, title=title)

    def body(self, master):
        tk.Label(master, text="Kanál:").grid(row=0, column=0, sticky="e")
        tk.Label(master, text="Název zařízení:").grid(row=1, column=0, sticky="e")

        self.kanal_entry = tk.Entry(master)
        self.nazev_entry = tk.Entry(master)

        self.kanal_entry.grid(row=0, column=1, sticky="w")
        self.nazev_entry.grid(row=1, column=1, sticky="w")

        return self.kanal_entry

    def apply(self):
        self.kanal = self.kanal_entry.get()
        self.nazev = self.nazev_entry.get()


# Funkce pro editaci zařízení
def editovat_zarizeni(main_frame, zarizeni):
    nova_hodnota = simpledialog.askinteger("Editovat zařízení", f"Zadejte novou hodnotu pro zařízení {zarizeni.kanal}/{zarizeni.nazev}:", minvalue=0, maxvalue=100)

    if nova_hodnota is not None:
        zarizeni.hodnota = nova_hodnota
        aktualizovat_gui(main_frame)


# Funkce pro smazání zařízení
def smazat_zarizeni(main_frame, zarizeni):
    zarizeni_list.remove(zarizeni)
    aktualizovat_gui(main_frame)


# Funkce pro aktualizaci GUI
def aktualizovat_gui(main_frame):
    # Seznam zařízení
    row = 3
    row_size = 0
    col = 0
    for zarizeni in zarizeni_list:
        if zarizeni == "newline":
            row += row_size + 1
            row_size = 0
            col = 0
            continue
        _row, _col = zarizeni.draw(main_frame, row, col)
        row_size = max(row_size, _row)
        col = _col + 1


# Funkce pro uložení konfigurace do souboru
def ulozit_konfiguraci():
    with open("konfigurace.json", "w") as f:
        data = [{"kanal": zarizeni.kanal, "nazev": zarizeni.nazev, "hodnota": zarizeni.hodnota} for zarizeni in zarizeni_list]
        json.dump(data, f)
    print("Konfigurace uložena do souboru 'konfigurace.json'")


# Funkce pro načtení konfigurace ze souboru
def nacist_konfiguraci(main_frame):
    try:
        with open("konfigurace.json", "r") as f:
            data = json.load(f)
            zarizeni_list.clear()
            for item in data:
                if item.get('typ') == 'newline':
                    zarizeni_list.append("newline")
                    continue
                trida = {"RGB": ZarizeniRGB,
                         "Barva": ZarizeniBarva}.get(item.get("typ"), ZarizeniRGB)
                zarizeni_list.append(trida(item["kanal"], item["nazev"],
                                           item.get("volby", None),
                                           item.get("hodnota")))
            print("Konfigurace načtena ze souboru 'konfigurace.json'")
            aktualizovat_gui(main_frame)
    except FileNotFoundError:
        print("Defaultní konfigurace nenalezena.")


# Hlavní okno
root = tk.Tk()
root.title("Hlavní okno")

# Hlavní rámec
main_frame = tk.Frame(root)
main_frame.pack(padx=20, pady=20)

# Kontrola existence defaultní konfigurace
zarizeni_list = []
aktualizovat_gui(main_frame)
nacist_konfiguraci(main_frame)

# Vazba Enteru na tlačítko OK ve funkci askinteger
root.bind('<Return>', lambda event=None: root.event_generate('<Button-1>', when='tail'))

# Spuštění hlavní smyčky
root.mainloop()
```

a konfigurace:

```json
[
 {"typ": "RGB", "kanal": 4, "nazev": "barva 0"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 1"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 2"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 3"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 4"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 5"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 6"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 7"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 8"},
 {"typ": "RGB", "kanal": 4, "nazev": "barva 9"},
 {"typ": "newline"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 0", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 1", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 2", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 3", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 4", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 5", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 6", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 7", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 8", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "pozice 9", "hodnota": "0", "volby": "#FFFFFF"},
 {"typ": "newline"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 0", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 1", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 2", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 3", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 4", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 5", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 6", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 7", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 8", "volby": "#FFFFFF"},
 {"typ": "Barva", "kanal": 4, "nazev": "sirka 9", "volby": "#FFFFFF"}
]
```

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

Natáčení stop-motion animace
----------------------------

Stop-motion animace je technika, kdy fotíme scénu po jednotlivých snímcích s drobnými změnami (pohyb ruky, posunutí motorky, ...) a následné spojení do jednoho videa. Existuje mnoho programů, které nám s tímto mohou pomoci, my jsme ale zvolili přímý postup bez využití specializovaných aplikací, abychom si ukázali, co vše je k tomuto potřeba.

Fotky jsme snímali pomocí telefonu s fyzickým zoomem 2x (ukázali jsme si i 0.5x a 1x, rozdíl byl hlavně při okrajích kdy širokoúhlá čočka "vidí" širší záběr a výrazně se liší pozorovací úhly, 2x zoom má tyto rozdíly výrazně menší a lépe se hodí pro natáčení našich scén). V aplikaci (FreeDcam) jsme museli nastavit na pevno hodnoty ISO (citlivost snímače - souvisí se šumem a světlostí; 100), rychlost uzávěrky (jak dlouho se bude "vyvolávat" fotografie - světlost; 0.8s), vyvážení bíle (automatika by nám vyrušila barevné efekty; 5000/3800) a zaostření.

Aby se nám mobilní telefon neposunoval, propojili jsme jej s počítačem a snímky pořizovali pomocí [adb](https://developer.android.com/tools/adb). Ten umožňuje simulovat doteky na obrazovce pomocí příkazu ``adb shell "input tap 10 20"`` (dotkni se prstem na poloze x=10 y=20).

Po pořízení fotografie jsme fotky rovnou stahovali do počítače opět pomocí [adb](https://developer.android.com/tools/adb) příkazem ``adb pull -Z "$ADRESAR_FOTEK_TELEFON/$FOTO" "$ADRESAR_FOTEK_PC/"``. Abychom mohli výsledek zkontrolovat, zobrazili jsme si vždy nejnovější fotografii v klasickém prohlížeči obrázků. Abychom nemuseli překlikávat vždy na poslední fotku, nechali jsme počítač vždy zkopírovat poslední staženou fotku a přejmenovat ji na ``.posledni.jpg``, čímž prohlížeč fotek vždy po přepsání sám aktualizoval zobrazovanou ``.posledni.jpg`` fotografii.

Abychom lépe viděli rozdíl mezi předchozím a současným snímkem, nechali jsme počítač vytvořit ještě jeden obrázek složený z poslední fotky a přes ní polo-průhledným obrázkem předposlední fotky. K tomu jsme využili programový balík ``ImageMagic``.

Celý (BASH) skript vypadal následovně (spustitelné v operačním systému GNU/Linux, Windows používá obdobné BAT soubory):

```bash
#!/bin/bash

## Definice proměnných použitých dále v programu
ADRESAR_FOTEK_TELEFON="/storage/self/primary/DCIM/FreeDcam"
ADRESAR_FOTEK_PC="./foto"
POZICE_TLACITKA_VYFOT="2100 500"

## Funkce použité dále v programu
stahni_nove_fotky() {
        # Detekuj nové fotky a stáhni je
        for IMG in $(adb shell "cd $ADRESAR_FOTEK_TELEFON && ls -1"); do
                [ -e "$ADRESAR_FOTEK_PC/$IMG" ] && continue
                adb pull -Z "$ADRESAR_FOTEK_TELEFON/$IMG" "$ADRESAR_FOTEK_PC/"
        done
}

vyfot_fotku() {
        # Stiskni tlačítko vyfotit
        adb shell "input tap $POZICE_TLACITKA_VYFOT"
        # Odkomentuj následující řádek pro vyčkání na uložení fotky
        sleep 1.5
}

aktualizuj_nahled() {
        # Zkopíruj poslední obrázek do .posledni.jpg a vytvoř sloučený obrázek z posledních 2 obrázků
        OBRAZKY=($(ls -t "$ADRESAR_FOTEK_PC" | head -n 2))
        cp "$ADRESAR_FOTEK_PC/${OBRAZKY[0]}" "$ADRESAR_FOTEK_PC/.posledni.jpg"
        convert "$ADRESAR_FOTEK_PC/${OBRAZKY[1]}" -quality 25 -alpha set -channel A -evaluate set 50% +channel "$ADRESAR_FOTEK_PC/.pruhledny.png"
        composite "$ADRESAR_FOTEK_PC/.pruhledny.png" "$ADRESAR_FOTEK_PC/${OBRAZKY[0]}" -quality 25 -alpha on -compose over "$ADRESAR_FOTEK_PC/.nahled.png"
}

## Nyní již vlastní kód
# Vytvoř výstupní složku
mkdir -p "$ADRESAR_FOTEK_PC"

# Do nekonecna porizuj fotky a stahuj je
echo "Pozor, uložení fotky může chvíli trvat, takže poslední fotka nemusí být synchronizovaná!"
while true; do
        echo "ENTER pro vyfocení scény, CTRL+C pro ukončení"
        read
        vyfot_fotku
        stahni_nove_fotky
        aktualizuj_nahled
done
```


Celý postup pak vypadal následovně:

1. Skupina ovládající telefon (počítačem) stiskla ENTER, zkontrolovala výsledek a dala pokyn k nastavení další scény
1. Skupina ovládající světla udělala požadovanou změnu (zpravidla velmi drobnou)
1. Skupina ovládající "herce" udělala změnu na scéně (posunula postavičky, pohnula rukama/hlavou/nohou, ...)

A tak pořád dokola, dokud nebylo dost obrazového materiálu ke zpracování.
