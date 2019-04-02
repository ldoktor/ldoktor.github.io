Pomocné materiály pro programování Micro:bitů
=============================================

[Micro:bit](https://microbit.org/) je jednočipový počítač navržený pro školní děti. Je cenově relativně dostupný a v základu umožní spoustu jednoduchých projektů. Díky své rozšířenosti pro něj existuje mnoho návodů, programových prostředí i různých rozšíření (například [propojení s legem](https://rpishop.cz/pro-microbit/3693-elecfreaks-microbit-wonder-building-kit-bez-microbitu.html)). Pokročilí studenti pak mohou pomocí `breakout board` vyvést všechny výstupy na `breadboard` (nepájivé pole) a připojit si v podstatě cokoliv ke svému Micro:bitu (nativním napětím je 3.3V, digitální vstupy zpravidla snesou 5V logiku ale pozor na přetížení).

Pro nákup Micro:bitů, sad a základních rozšiřujících destiček mohu doporučit [rpishop](https://rpishop.cz), pro breadboardy a jednotlivé součástky [Aliexpress](https://www.aliexpress.com/) či [Banggood](https://www.banggood.com); pokud spěcháte na doručení tak [GME](https://www.gme.cz/) či [Drátek](https://dratek.cz).

Základní projekty
-----------------

* Zobrazení symbolů a znaků [kód](https://makecode.microbit.org/_7PVHdwVmtEEW)
* Skokometr [kód](https://makecode.microbit.org/_cAha1i881ETL)
* Morseovka [kód](https://makecode.microbit.org/_he62hT77k95d)
* Mikuláš - roznos dárků dětem [kód](https://makecode.microbit.org/_cP6d8EPW5F6p)
* Koleda [kód](https://makecode.microbit.org/_a3JUJCECsT4k)
* Sfoukni svíčku [kód](https://makecode.microbit.org/_K4wa4D3izJPs)
* Kostka [kód](https://makecode.microbit.org/_JLWFq1gA8MAg)

Ovládání pinů
-------------

* Semafor - [breadboard](semafor.jpg), [schéma](semafor-schema.jpg)
* Křižovatka - [breadobard](2xsemafor.jpg), [schéma](2xsemafor-schema.jpg)
* Vstupy - [breadboard](vstupy-pulls.jpg), [kód](vstupy-pulls-code.jpg), [otázky](vstupy-pulls.pdf)
* Had - [breadboard](semafor.jpg), [jednoduché](had-simple.jpg), [funkce](had-funkce.jpg), [funkce se stmíváním](had-funkce-analog.jpg), [list](had-list.jpg), [list se stmíváním](had-list-analog.jpg)

Alarm
-----

* Senzor - [kód](alarm-senzor.jpg)
* Ovladač - [kód](alarm-ovladac.jpg)

Autíčko
-------

* [Kitronik :move motor](https://github.com/KitronikLtd/pxt-kitronik-move-motor)
* [Waweshark Joystick](https://github.com/waveshare/JoyStick)
* Vysílač - [jednoduchý](move-motor-vysilac.jpg), [komplexní](move-motor-vysilac2.jpg), [spojitý](move-motor-vysilac-joystick.jpg), [spojitý-kód](https://github.com/ldoktor/microbit-waveshark-joystick-rc-transmitter), [spojitý s kalibrací](move-motor-vysilac-joystick2.jpg)
* Přijímač - [jednoduchý](move-motor-prijimac.jpg), [kompletní](move-motor-prijimac2.jpg), [kompletní-kód](https://github.com/ldoktor/microbit-move-basic-receiver)

Wonder Building Kit
-------------------

* [Ukázkové programy](https://elecfreaks.com/learn-en/microbitKit/Wonder_Building_Kit/index.html)
* Často je za potřebí přidat do projektu rozšíření ``Wukong``, které je možno vyhledat přímo ve schválených rozšířeních, nebo přidat pomocí [https://github.com/elecfreaks/pxt-wukong](https://github.com/elecfreaks/pxt-wukong)

Groove shield
-------------

* [Návod](https://github.com/SeeedDocument/Grove_kit_for_microbit/raw/master/res/Guide-Grove%20kit%20for%20microbit.pdf)
* Nutno přidat rozšíření [github.com/seeed-studio/pxt-grove](github.com/seeed-studio/pxt-grove)
