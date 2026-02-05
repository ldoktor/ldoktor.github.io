Vzduchový výtah
===============

Pomůcky
-------

<img align="right" src="vytah/vytah.png">

Dílky k vytištění:

* [spodek](vytah/00_spodek.3mf)
* [přechod větrák->střed](vytah/10_prechod.3mf)
* [mřížka](vytah/20_mrizka.3mf)
* [potrubí](vytah/30_stred.3mf)

Celá sestava ve formátu FreeCAD [zde](vytah/vytah.FCStd)

Další potřebné pomůcky:

* 12cm PC ventilátor
* L298N DC Motor Driver
* Kalíšek/Papír
* Sonar module
* Micro:bit + breakout module

Detekce pater
-------------

<img src="vytah/00_detekce_pater.png">

Ovládání
--------

<img src="vytah/01_ovladani.png">

Řízení
------

<img src="vytah/02_rizeni.png">

Řízení regulátorem PID
----------------------

<img src="vytah/03_pid.png">
<img src="vytah/03_pid2.png">

```python
def set_new_floor(floor: number):
    global FLOOR, TARGET
    FLOOR = floor
    if floor == 0:
        TARGET = 3015
    elif floor == 1:
        TARGET = 3000
    elif floor == 2:
        TARGET = 3200
    elif floor == 3:
        TARGET = 2400
    elif floor == 4:
        TARGET = 2200
    elif floor == 5:
        TARGET = 2000
    elif floor == 6:
        TARGET = 1800
    elif floor == 7:
        TARGET = 1300
    else:
        TARGET = 500
    basic.show_number(FLOOR)

def on_button_pressed_a():
    if FLOOR <= 8:
        set_new_floor(FLOOR + 1)
input.on_button_pressed(Button.A, on_button_pressed_a)

def on_button_pressed_b():
    if FLOOR > 0:
        set_new_floor(FLOOR - 1)
input.on_button_pressed(Button.B, on_button_pressed_b)

POWER = 0
output = 0
LAST_ERROR = 0
derivative = 0
INTEGRAL = 0
ERROR = 0
height = 0
TARGET = 0
FLOOR = 0
FLOOR = 4
FAN_PIN = AnalogPin.P1
set_new_floor(FLOOR)
# PID
# Metoda Ziegler-Nicols
# Kp = 1, Ki = 0, Kd = 0
# Zvyšovat/Snižovat Kp dokud nevzniknou ustálené kmity
# Ku = Kp při ustálených kmitech
# Tu = Perioda ustálených kmitů (Od horní úvrati k horní úvrati)
# Kp = 0.6*Ku
# Ki = 2*Kp/Tu
# Kd = Kp*Tu/8
#
# Ziegler-Nicols selhává pro zarušené soustavy, korigovat:
# Kp = Kp*0.7
# Ki = Ki*0.3
# Kd = Kd*1.2
#
# Kp samostatné udržuje offset od žádané hodnoty
# Ki dorovnává offset
# Kd reaguje na prudké změny
#
# Ki trpí na nasycení, proto je důležitý anti-wind-up, který omezí
# min/max hodnotu stavu INTEGRAL
Kp = 0.6
Ki = 0.1
Kd = 0.01
INTEGRAL_MAX = 1022 / Ki
PID_PERIOD = 100
TIME_DELTA = PID_PERIOD / 1000
PID_NEXT_RUN = control.millis()

def on_forever():
    global PID_NEXT_RUN, height, ERROR, INTEGRAL, derivative, output, POWER, LAST_ERROR
    # Počkej na další periodu
    if control.millis() < PID_NEXT_RUN:
        return
    PID_NEXT_RUN = control.millis() + PID_PERIOD
    height = sonar.ping(DigitalPin.P2, DigitalPin.P2, PingUnit.MICRO_SECONDS)
    # PID
    ERROR = height - TARGET
    INTEGRAL = INTEGRAL + ERROR * TIME_DELTA
    INTEGRAL = min(INTEGRAL_MAX, max(0 - INTEGRAL_MAX, INTEGRAL))
    derivative = (ERROR - LAST_ERROR) / TIME_DELTA
    output = Kp * ERROR + Ki * INTEGRAL + Kd * derivative
    POWER = min(1022, max(0, output))
    pins.analog_write_pin(FAN_PIN, POWER)
    serial.write_value("ERROR", ERROR)
    serial.write_value("POWER", POWER)
    serial.write_value("height", height)
    serial.write_value("P", Kp * ERROR)
    serial.write_value("I", Ki * INTEGRAL)
    serial.write_value("D", Kd * derivative)
    serial.write_value("INTEGRAL", INTEGRAL)
    LAST_ERROR = ERROR
basic.forever(on_forever)
```
