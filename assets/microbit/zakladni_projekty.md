Zakladni projekty
=================

Zobrazení symbolů a znaků
-------------------------

Nejprve se seznámime s jednoduchým zobrazením ikonek, textu a čísel na displeji micro:bitu za použití `Základního` (`basic`) modulu. Abychom nemuseli neustále nahrávat nový kód, vyzkoušíme i obsluhu vstupů pomocí modulu `Vstup` (`input`).

1. Začneme tím, že po spuštění ukážeme ikonku srdíčka. V blokovém zobrazení stačí otevřít modul `Základní`, přidat bloček `při startu` a do něj umístit bloček `ukaž ikonu`. Ikonku srdíčka můžeme změnit kliknutím na šipečku v "parametru" tohoto bločku. Podobný kód můžeme napsat přímo v pythonu využitím knihovny `basic` a funkce `show_icon`. Všimněte si, že se Vám editor snaží pomáhat a při psaní navrhuje vhodné hodnoty (např. `IconNames.` zobrazí nabídku všech ikonek, `basic.` zobrazí všechny funkce). Výsledný kód vypadá následovně::

    # Po spusteni zobraz ikonku srdicka
    basic.show_icon(IconNames.HEART)

2. Nyní se pustíme do tlačítek. Pro ně si budeme muset vybrat modul `Vstup` a vidíme, že máme k dispozici mnoho bločků, které fungují jako začátek (nemají vykrojení nahoře). Nejprve zkusíme `při stisknutí tlačítka A` a do něj vložíme základní bloček `ukaž ikonu`. Tentokrát zvolíme jinou ikonu, než smajlíka a můžeme otestovat, že po stisknutí tlačítka A se změní srdíčko na naší novou ikonku. V kódu python musíme pro stejnou funkci nejprve definovat funkci a následně ji nadefinovat jako obslužnou funkci pro námi zvolený příklad. Výhodou je, že tuto funkci můžeme využít i opakovaně (např. pokud chceme dosáhnout stejného chování pro různé vstupy). Funkce se definuje pomocí `def $název_funckce($parametry):` a tělo funkce se odsadí o 1 tabulátor. Definice funkce končí tam, kde odsazení končí a dále pokračuje klasický kód za funkcí. Řádky začínající znakem `#` se nevykonávají, slouží pouze jako komentáře pro nás pro lidi. Podobně první text ve funkci začínající (a končící) znaky `"""` nevykonává žádnou funkci, ale využívá se jako popis naší funkce. Komentáře jsou velmi důležitou součástí kódu a slouží pro lepší přehlednost a snazší porozumění. Celé to bude vypadat následovně::

    # Definice funkce, kterou použijeme pro obsluhu stisku tlačítka A
    def ukaz_smajlika():
        """Funkce zobrazí na displeji smajlíka"""
        basic.show_icon(IconNames.HAPPY)
    # Registrace naší funkce pro obsluhu stisknutí (`on_button_pressed`) tlačítka A (`Button.A`)
    input.on_button_pressed(Button.A, ukaz_smajlika)

3. Obdobně přidáme kód pro tlačítka B a A+B. Všimněte si, že pokud přidáte více bločků obsluhující stejné tlačítko, zůstane růžové pouze jedno a ostatní zešednou. To je proto, že můžete zaregistrovat pouze jednu obsluhu pro jeden typ události. Šipečkou vybereme tlačítko B, čímž nám bloček opět zrůžoví a my můžeme definovat, co se bude dít po stisku tlačítka B. Zde si vyzkoušíme vlastní tvar pomocí bločku `ukaž tvar`. Myší pak vybereme které diodky mají svítit a které mají být vypnuté. Pro obsluhu tlačítka A+B pak zvolíme `zobraz text` kde můžeme vepsat text, který se bude zobrazovat displeji. V pythonu to bude vypadat následovně::


	def on_button_pressed_b():
		"""Ukaž šipku nahoru"""
		# zde pomocí textu definuji, které diody budou svítit
		# k dispozici mám 5x5 diod, pokud napíšu '.' bude
		# dioda zhasnutá, použitím `#` ji rozsvítím.
		basic.show_leds("""
		    . . # . .
		    . # . # .
		    # . # . #
		    . # . # .
		    # . . . #
		    """)
	input.on_button_pressed(Button.B, on_button_pressed_b)

	def on_button_pressed_ab():
		"""Napiš `Ahoj světe`"""
		basic.show_string("Ahoj svete")
	input.on_button_pressed(Button.AB, on_button_pressed_ab)

4. Poslední, co si v tomto projetku vyzkoušíme je animace. Jelikož nám došly tlačítka, vyzkoušíme gesto zatřesení. Opět jej najdeme v modulu `Vstup` a vybereme `při pohybu XXX`. Jako argument vybereme `došlo k zatřesení`. Tělo tohoto bločku se vykoná, pokud micro:bitem zatřeseme. A co se v takovém případě má stát? Chceme zobrazit několikrát střídavě 2 ikonky, ne moc pomalu, ale také né moc rychle. Abychom nemuseli opakovat stejné sekvence, využijeme modulu `Smyčky` a zvolíme `opakuj XXX krát`. Dovnitř tohoto bločku můžeme vložit co chceme opakovat. V našem případě chceme `ukaž ikonu XXX`. Jelikož ikony budeme střídat a micro:bit je extrémně rychlý, musíme přidat čekací bloček `čekej XXX ms`. 100ms (0.1 sekundy) by mělo být tak akorát. Následně opět `ukaž ikonu XXX` ale tentokrát zvolíme jinou (doporučuji velké a malé srdíčko či diamant). Aby i tato druhá ikonka byla vidět, je nutné přidat další čekání `čekej XXXms`. Vyzkoušejte různé intervaly. V pythonu bude vše vypadat následovně::

	def on_gesture_shake():
		"""Zobraz animaci diamantu"""
		# 10x opakuj kód, který je odsazený
		for index in range(10):
		    # Ukaz velky diamant
		    basic.show_icon(IconNames.DIAMOND)
		    # Pockej, aby jej bylo videt
		    basic.pause(100)
		    # Ukaz maly diamant
		    basic.show_icon(IconNames.SMALL_DIAMOND)
		    # Pockej, aby jej bylo videt
		    basic.pause(100)
	input.on_gesture(Gesture.SHAKE, on_gesture_shake)

5. Experiemntujte, měňte hodnoty, zkoušejte další basic bločky a užijte si legraci. Můj kód pro referenci naleznete [zde](https://makecode.microbit.org/_h4E5YievsgFf)

Skokometr
---------

Konečně nastal čas se trošku zapotit a vyzkoušet, kdo udělá víc výskoků za 1 minutu. Aby soutěž proběhla férově, bude nám výskoky měřit micro:bit. Jak na to?

1. Abychom mohli počítat kroky, musí si nejprve micro:bit vyhradit místo pro aktuální počet kroků. To uděláme tak, že si vytvoříme proměnnou (v modulu `Proměnné`). Úplně nahoře je speciální tlačítko `Vytvořit proměnnou...`, kterým si nadefinujeme její název. Ten by měl být vhodný, jelikož jej budeme využívat všude v kódu. Navrhuji `skok`, `skoku` či `pocet_skoku`. Tímto jsme vytvořili proměnnou a můžeme ji v kódu používat či upravovat. Začneme tím, že do bločku `po spuštění` přidáme `Proměnné.nastav XXX na YYY` kde do XXX přetáhneme naší proměnnou a do YYY vepíšeme 0 (aby všichni startovali s 0). V pythonu proměnné definujeme jednoduše tak, že zapíšu název proměnné a rovnítkem do ní přiřadím hodnotu::

    # Pocet skoku od spusteni microbitu
    skok = 0

2. Proměnnou máme vytvořenou, jak ji ale ukážeme uživateli? Jednoduše, použitím `Základní.zobraz číslo XXX`. Nechceme jej ale zobrazit pouze jednou, neboť se nám bude toto číslo měnit dle aktuální situace. Zvolíme tedy bloček `Základní.opakuj stále` a do něj vložíme `Základní.zobraz číslo XXX`. V předchozím projektu jsme za XXX přímo vepisovali hodnoty, nyní využijeme `Proměnné` a přetáhneme naši elipsovitou proměnnou `skok` místo čísla. Pokaždé, když se tento kód bude vykonávat podívá se micro:bit do paměti a zobrazí nám právě tu aktuální hodnotu naší proměnné. V pythonu to vypadá následovně::

    def zobraz_skoky():
		"""Zobraz skoky na displeji"""
		basic.show_number(skok)
	# Neustale opakuj funkci "zobraz_skoky"
	basic.forever(zobraz_skoky)

3. Nyní se nám tedy již proměnná vynuluje při spuštění a neustále se zobrazuje na displeji. Její hodnota se ale nemění, pojďme to změnit. Skok detekujeme jednoduše pomocí gesta `došlo k zatřesení`, které jsme již používali v minulém projektu. Dovnitř pak vložíme `Proměnné.změň XXX o YYY`. Za XXX opět dosadíme naší proměnnou do YYY napíšeme 1. Proč 1? Abychom přičetli k aktuálnímu číslu 1 skok. Pozor, pokud byste použili `Proměnné.nastav XXX na YYY` vždy byste nastavili hodnotu proměnné na konstantní hodnotu, je nutné použít `změň`. V pythonu bude vše malinko komplikovanější, neboť proměnnou `skok` jsme si definovali mimo naší funkci, je tedy globální proměnnou. Abychom ji mohli měnit, musíme funkci říci, že tuto proměnnou potřebujeme nejen jako lokální funkci, ale že její hodnotu chceme propagovat výše pomocí slovíčka `global XXX`. Vše bude vypadat následovně::

	def zvys_skok():
		"""Zvys pocet skoku o 1"""
		# Musím říci pythonu, že chci globální proměnnou "skok"
		# upravovat a propagovat tuto změnu mimo tělo funkce
		global skok
		# Přičti k proměnné skok 1
		# Jedná se o zkrácený zápis, je možné napsat i `skok = skok + 1`
		skok += 1
	# Registruj funkci zvys_skok pri zatreseni
	input.on_gesture(Gesture.SHAKE, zvys_skok)

4. Nahrajte, otestujte, zapněte stopky a můžete závodit. Celý kód je dostupný [zde](https://makecode.microbit.org/_T1UaV27LkKDM)

Pokročilý display
-----------------

Zde si ukážeme, jak manipulovat přímo s jednotlivými diodami na displeji. Využijeme k tomu modul `Displej` (`led`) a jelikož má micro:bit diod 25, budeme hojně využívat modul `Smyčky` (cykly `for`).

1. Přepínání všech diod displeje. Jde o to změnit hodnotu každé diody, pokud byla rozsvícená, zhasnout, pokud zhasnutá, rozsvítit. Jedna z možností je využít 2 vnořených cyklu a měnit diody po sloupcích. Do bločku `opakuj stále` (případně `při stisknutí tlačítka XXX`, nechám to na vás) vložíme bloček `Smyčky.pro XXX od 0 do YYY`, do něj vložíme druhý bloček `Smyčky.pro XXX od 0 do YYY`. Jelikož oba bločky využívají proměnnou `pořadí`, musíme alespoň jeden z nich nahradit jinou proměnnou. Doporučuji ale nahradit obě proměnné novými proměnnými `x` a `y`, které uvnitř cyklů využijeme pro indexování diod. Vnitřek vnitřní smyčky bude jednoduchý, použijeme `přepni x XXX y YYY` kde za XXX a YYY dosadíme hodnoty z našich vnořených cyklů. Abychom změny viděli, vložme i krátkou 100ms pauzu (`Základní.čekej XXX`) za volání `přepni` a sledujte, jak se překresluje celý displej. A jak to funguje? Jednoduše shora dolů, nejprve se nastaví X na 0 a začne se vykonávat vnitřní cyklus. Ten nastaví Y na 0 a začne vykonávat své tělo. Uvnitř těla přepne diodu na pozici X, Y (0, 0). Nakonec zvýší hodnotu Y (1) a zkontroluje, jestli je větší, než 4. Není, proto opět vykoná své tělo, čímž přepne diodu na pozici X, Y (0, 1). Opět zvýší hodnotu Y (2) a pokračuje až dokud není hodnota Y == 4. V ten moment se ukončí a přijde ke slovu opět vnější smyčka. Ta zvýší hodnotu X (1) a znovu začne vykonávat vnitřní cyklus. Nyní je ale hodnota X == 1 a první co vnitřní cyklus udělá je, že vynuluje Y na 0. Opět opakuje přepínání diod na pozicích X, Y == (1, 0) postupně až do X, Y == (1, 4). Takto to pokračuje až dokud neskončí poslední vnořený cyklus na hodnotě X, Y = (4, 4). Zvýšením Y o jedna vnitřní cyklus končí, neboť není menší či rovno 4, stejně tak vnější cyklus zvedne svou hodnotu X na 5 a ukončí se. V závislosti na tom, jestli voláte tuto funkci opakovaně (`opakuj stále`) nebo jednorázově (`při stisknutí tlačítka XXX`) se displej přepíše jednou či neustále bliká. V pythonu to vypadá následovně::

	def prepni_displej(pauza=100):
		"""Prepne vsechny diody na displeji po sloupcich"""
		for x in range(5):
		    for y in range(5):
		        led.toggle(x, y)
		        basic.pause(pauza)
	input.on_button_pressed(Button.A, prepni_displej)

2. Zkuste kód upravit tak, aby přepínal diody po řádcích

3. Zkuste upravit kód tak, aby kreslil pouze na diagonále (rada: stačí vám pouze jeden cyklus, chcete přepnout pouze diody na pozicích `0, 0; 1, 1; 2, 2; 3, 3; 4, 4`).

4. Zkuste upravit kód tak, aby kreslil diagonálu otočenou o 90° (rada: tělo bude úplně stejně, pouze pozice `x` musí začínat od 4, čili pracujete s diodami na pozicích `4, 0; 3, 1; 2, 2; 1, 3; 0, 4`. K tomu můžete využít odečítání od maximální hodnoty - `4 - x`)

5. Zkuste upravit kód tak, aby kreslil diagonálu otočenou o 180° a 270°. Opět budete odečítat od maximální hodnoty, jen na jiných místech.

6. Zkuste vytvořit šrafy. Zde je možností několik, nejsnazší mi přijde udělat to stejně jako když přepínáte všechny hodnoty, ale přidat si proměnnou, která si bude pamatovat, jestli jste v předchozím kroku přepínali, či ne a přepínat pouze pokud jste v předchozím kroku nepřepínali. Pozor, na závěr si musíte vždy uložit, jestli jste přepínali, či nikoliv, k čemuž nám může pomoci `Proměnné.nastav XXX na YYY` do kterého vložíme `Logika.není XXX`.

Výsledek kde jsem vše složil do [následujícího programu](https://makecode.microbit.org/_00sKsV8eE02i) a přidal obsluhu tlačítek (klidně si prostudujte jak, ale nebudeme to zde blíže vysvětlovat).

Další projekty
==============

* Morseovka [kód](https://makecode.microbit.org/_bTLW6HRRDbhk)
* Mikuláš - roznos dárků dětem [kód](https://makecode.microbit.org/_cP6d8EPW5F6p)
* Koleda [kód](https://makecode.microbit.org/_a3JUJCECsT4k)
* Sfoukni svíčku [kód](https://makecode.microbit.org/_K4wa4D3izJPs)
* Kostka [kód](https://makecode.microbit.org/_JLWFq1gA8MAg)

