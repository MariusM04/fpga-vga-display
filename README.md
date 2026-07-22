# Sistem de afișare VGA dinamică pe FPGA

**Autor:** Ugureanu Marius-Daniel  
**Facultate:** Inginerie Electrică și Știința Calculatoarelor  
**Specializare:** Electronică Aplicată  
**Placă utilizată:** Basys 3  

## Istoric revizii

| Revision | Date | Author | Comments |
|---|---|---|---|
| 0.1 draft | Iulie 2026 | Marius-Daniel Ugureanu | First draft |
| 0.2 draft | 10 iulie 2026 | Marius-Daniel Ugureanu | Added VGA color bars, moving black box and `NO SIGNAL` text |
| 0.3 draft | 14 iulie 2026 | Marius-Daniel Ugureanu | Added Security Dashboard concept with button-controlled drone |
| 0.4 draft | 20 iulie 2026 | Marius-Daniel Ugureanu | Completed Stage 4 documentation |
| 0.5 draft | 22 iulie 2026 | Marius-Daniel Ugureanu | Replaced the joystick implementation stage with PmodKYPD keypad control and moved the joystick to future development |

---

## Cuprins

- [1. Introducere](#1-introducere)
- [2. Organizarea proiectului pe etape](#2-organizarea-proiectului-pe-etape)
- [3. Etapa 0 – Documentația proiectului](#3-etapa-0--documentația-proiectului)
- [4. Etapa 1 – Design și simulare VGA a controllerului](#4-etapa-1--design-și-simulare-vga-a-controllerului)
- [5. Etapa 2 – Implementare pe FPGA a VGA-ului](#5-etapa-2--implementare-pe-fpga-a-vga-ului)
- [6. Etapa 3 – Test Pattern și animație NO SIGNAL](#6-etapa-3--test-pattern-și-animație-no-signal)
- [7. Etapa 4 – Security Dashboard controlat prin butoane](#7-etapa-4--security-dashboard-controlat-prin-butoane)
- [8. Etapa 5 – Integrarea tastaturii PmodKYPD](#8-etapa-5--integrarea-tastaturii-pmodkypd)
- [9. Etapa 6 – Îmbunătățiri viitoare](#9-etapa-6--îmbunătățiri-viitoare)
- [10. Probleme întâmpinate și soluții](#10-probleme-întâmpinate-și-soluții)
- [11. Obiective](#11-obiective)
- [12. Concluzie](#12-concluzie)

---

## 1. Introducere

În cadrul acestui proiect mi-am propus să realizez un sistem de afișare VGA folosind un FPGA. Ideea principală este generarea directă în hardware a semnalelor video necesare unui monitor VGA și afișarea unor elemente grafice fără folosirea unui procesor sau a unei plăci video clasice.

Proiectul pornește de la rezoluția **640x480@60Hz**, deoarece aceasta este potrivită pentru înțelegerea principiilor de bază ale afișării VGA. La această rezoluție pot fi urmărite mai ușor semnalele de sincronizare, zona activă a imaginii, perioadele de blanking și modul în care poziția fiecărui pixel este determinată cu ajutorul unor numărătoare.

Proiectul a fost dezvoltat progresiv. Prima variantă a avut rolul de a genera semnalele VGA și de a afișa culori simple. Ulterior au fost introduse bare colorate, un dreptunghi animat cu textul `NO SIGNAL`, iar apoi proiectul a fost transformat într-un dashboard de securitate interactiv, în care o dronă simulată poate fi controlată folosind butoanele plăcii.

Următoarea extindere este integrarea unei tastaturi **PmodKYPD 4x4**, folosită pentru controlul dronei și pentru activarea unor comenzi speciale. Integrarea joystick-ului Pmod JSTK2 rămâne o posibilă dezvoltare viitoare.

| Element | Descriere |
|---|---|
| Nume proiect | Sistem de afișare VGA dinamică pe FPGA |
| Placă utilizată | Digilent Basys 3 |
| FPGA | Xilinx Artix-7 |
| Limbaj | SystemVerilog |
| Mediu de lucru | Vivado și Visual Studio Code |
| Rezoluție | 640x480@60Hz |
| Interfață video | VGA |
| Rezultat curent | Security Dashboard VGA cu dronă controlată prin butoane |
| Extindere următoare | Control prin tastatura PmodKYPD 4x4 |

---

## 2. Organizarea proiectului pe etape

Proiectul este împărțit în mai multe etape, astfel încât fiecare funcționalitate să poată fi implementată și verificată separat. Această organizare reduce riscul apariției unor erori greu de identificat și permite păstrarea fiecărei versiuni funcționale în foldere separate și în repository-ul GitHub.

| Etapă | Denumire | Stadiu | Rezultat principal |
|---|---|---|---|
| Etapa 0 | Documentația proiectului | Realizată | Stabilirea scopului, structurii și etapelor de dezvoltare |
| Etapa 1 | Design și simulare VGA a controllerului | Realizată | Crearea modulelor principale și verificarea semnalelor prin simulare |
| Etapa 2 | Implementare pe FPGA a VGA-ului | Realizată | Sinteză, implementare, bitstream și validare pe monitor |
| Etapa 3 | Test Pattern și animație `NO SIGNAL` | Realizată | Color bars, dreptunghi animat și text bitmap |
| Etapa 4 | Security Dashboard controlat prin butoane | Realizată | Dronă controlată manual, zone grafice și statusuri de securitate |
| Etapa 5 | Integrarea tastaturii PmodKYPD | În testare | Controlul dronei și al comenzilor speciale prin tastatura 4x4 |
| Etapa 6 | Îmbunătățiri viitoare | Planificată | Joystick Pmod JSTK2, OLED, mod PATROL și hartă extinsă |

Fiecare etapă are propriul folder, care conține fișierele sursă, constrângerile, simularea și documentația aferentă.

---

## 3. Etapa 0 – Documentația proiectului

Prima etapă a constat în realizarea documentației inițiale. Înainte de implementarea efectivă am stabilit scopul proiectului, placa utilizată, limbajul de descriere hardware, rezoluția de lucru și modul de organizare a etapelor.

Documentația a fost actualizată după fiecare progres important, astfel încât să reflecte starea reală a proiectului.

| Câmp | Detalii |
|---|---|
| Scop | Stabilirea direcției proiectului și a pașilor de lucru |
| Activități | Alegerea plăcii, rezoluției, limbajului și structurii proiectului |
| Placă aleasă | Digilent Basys 3 |
| Limbaj ales | SystemVerilog |
| Rezoluție aleasă | 640x480@60Hz |
| Rezultat | Documentație inițială creată și actualizată permanent |
| Stadiu | Realizată |

---

## 4. Etapa 1 – Design și simulare VGA a controllerului

În această etapă am creat structura de bază a proiectului și am verificat funcționarea controllerului VGA prin simulare.

Fișierul principal este `top.sv`, care conține modulul `vga_top`. Acesta conectează ceasul plăcii, resetul, Clock Wizard-ul și controllerul VGA.

Ceasul de sistem al plăcii Basys 3 este de 100 MHz, însă pentru afișarea VGA este necesar un ceas de pixel de aproximativ 25 MHz. Din acest motiv este folosit modulul `clk_vga_wrapper`, generat în Vivado.

| Fișier / modul | Rol |
|---|---|
| `top.sv` | Modulul principal al proiectului |
| `vga_top` | Conectează semnalele externe cu modulele interne |
| `clk_vga_wrapper` | Generează ceasul de pixel |
| `vga_controller.sv` | Generează sincronizarea și imaginea VGA |
| `tb_vga_top.sv` | Testbench pentru verificarea funcționării |
| `Constraint.xdc` | Mapează semnalele pe pinii plăcii |

### 4.1. Semnalele principale

| Semnal | Rol |
|---|---|
| `sys_clock` | Ceasul de sistem de 100 MHz |
| `reset` | Reset conectat la butonul central |
| `pix_clk` | Ceasul de pixel pentru VGA |
| `Hsync` | Sincronizare orizontală |
| `Vsync` | Sincronizare verticală |
| `vgaRed` | Canalul roșu |
| `vgaGreen` | Canalul verde |
| `vgaBlue` | Canalul albastru |

### 4.2. Simularea controllerului

Prin simulare au fost verificate:

- incrementarea contorului orizontal;
- incrementarea contorului vertical;
- durata impulsurilor `Hsync`;
- durata impulsurilor `Vsync`;
- delimitarea zonei active;
- revenirea numărătoarelor la începutul cadrului;
- menținerea ieșirilor RGB pe negru în afara zonei active.

Testbench-ul a fost rulat pentru mai multe cadre complete, fără erori de sincronizare.

| Verificare | Rezultat |
|---|---|
| Contor orizontal | Corect |
| Contor vertical | Corect |
| `Hsync` | Corect |
| `Vsync` | Corect |
| Zona activă | Corectă |
| Blanking | Corect |
| Simulare completă | Realizată |

---

## 5. Etapa 2 – Implementare pe FPGA a VGA-ului

În această etapă proiectul verificat prin simulare a fost implementat pe placa Basys 3. Scopul a fost trecerea de la modelul simulat la funcționarea reală pe FPGA și afișarea semnalului pe monitor.

Procesul de implementare a inclus sinteza codului, plasarea și rutarea logicii, generarea bitstream-ului și programarea plăcii.

| Pas | Acțiune | Scop |
|---|---|---|
| 1 | Run Synthesis | Transformarea codului SystemVerilog în logică hardware |
| 2 | Run Implementation | Plasarea și rutarea designului pe FPGA |
| 3 | Generate Bitstream | Generarea fișierului de configurare |
| 4 | Open Hardware Manager | Detectarea plăcii Basys 3 |
| 5 | Program Device | Încărcarea bitstream-ului pe placă |
| 6 | Test pe monitor | Confirmarea funcționării semnalului VGA |

### 5.1. Configurarea Clock Wizard-ului

Clock Wizard-ul a fost folosit pentru transformarea ceasului de sistem de 100 MHz într-un ceas de pixel potrivit rezoluției VGA.

| Semnal | Frecvență aproximativă |
|---|---|
| `sys_clock` | 100 MHz |
| `pix_clk` | Aproximativ 25 MHz |

Wrapper-ul folosit în proiect este:

```text
clk_vga_wrapper
```

Acesta este instanțiat în `vga_top` și furnizează semnalul `pix_clk` către `vga_controller`.

### 5.2. Maparea pinilor

Fișierul `Constraint.xdc` conține pinii pentru:

- ceasul de sistem;
- reset;
- semnalele VGA;
- canalele RGB;
- butoanele folosite ulterior pentru control.

| Funcție | Pin |
|---|---|
| Clock 100 MHz | W5 |
| Reset / BTNC | U18 |
| Hsync | P19 |
| Vsync | R19 |

Canalele RGB sunt conectate la pinii corespunzători conectorului VGA al plăcii Basys 3.

### 5.3. Rezultatul Etapei 2

| Cerință | Rezultat |
|---|---|
| Sinteză fără erori | Realizată |
| Implementare fără erori critice | Realizată |
| Bitstream generat | Realizat |
| Placă detectată | Realizată |
| Programare FPGA | Realizată |
| Semnal VGA afișat pe monitor | Realizat |
| Reset funcțional | Realizat |

Etapa 2 a confirmat că proiectul funcționează în hardware real și a pregătit baza pentru introducerea elementelor grafice din Etapa 3.

---

## 6. Etapa 3 – Test Pattern și animație `NO SIGNAL`

În această etapă am trecut de la afișarea simplă la realizarea unei imagini dinamice. Scopul a fost testarea canalelor RGB, poziționarea elementelor grafice și implementarea unei animații direct în hardware.

| Element | Descriere |
|---|---|
| Fundal | Model de test format din bare colorate |
| Element animat | Dreptunghi negru |
| Text | `NO SIGNAL` |
| Tip mișcare | Automată |
| Coliziune | Ricoșare la marginile ecranului |
| Actualizare | O dată la fiecare cadru |
| Stadiu | Realizată și testată |

### 6.1. Afișarea barelor colorate

Barele colorate sunt generate direct în `vga_controller`, pe baza coordonatelor pixelului curent.

Ecranul este împărțit în mai multe regiuni, iar pentru fiecare regiune este aleasă o combinație RGB.

Culorile principale afișate sunt:

- alb;
- galben;
- cyan;
- verde;
- magenta;
- roșu;
- albastru;
- negru.

| Semnal | Rol |
|---|---|
| `h_count` | Poziția orizontală a pixelului |
| `v_count` | Poziția verticală a pixelului |
| `active_area` | Indică zona vizibilă |
| RGB | Stabilește culoarea pixelului |

### 6.2. Dreptunghiul animat

Peste modelul de test a fost adăugat un dreptunghi negru care se deplasează automat pe ecran.

Poziția este memorată prin coordonatele X și Y, iar direcția este memorată separat pentru fiecare axă.

| Element | Implementare |
|---|---|
| Poziție orizontală | Registru X |
| Poziție verticală | Registru Y |
| Direcție orizontală | Stânga / dreapta |
| Direcție verticală | Sus / jos |
| Coliziune | Comparare cu marginile ecranului |
| Reacție | Inversarea direcției |

Mișcarea este actualizată la `frame_tick`, adică o singură dată la fiecare cadru.

### 6.3. Randarea textului `NO SIGNAL`

Textul este afișat folosind un font bitmap. Fiecare caracter este reprezentat printr-o matrice de biți.

| Pas | Descriere |
|---|---|
| 1 | Calcularea poziției locale în dreptunghi |
| 2 | Determinarea caracterului |
| 3 | Selectarea rândului din bitmap |
| 4 | Verificarea bitului pentru pixelul curent |
| 5 | Afișarea pixelului alb sau păstrarea fundalului negru |

### 6.4. Rezultatul Etapei 3

| Cerință | Rezultat |
|---|---|
| Color bars | Realizate |
| Dreptunghi animat | Realizat |
| Ricoșare la margini | Realizată |
| Text bitmap | Realizat |
| `NO SIGNAL` | Realizat |
| Testare pe monitor | Realizată |

---

## 7. Etapa 4 – Security Dashboard controlat prin butoane

În Etapa 4 proiectul a fost transformat dintr-un model de test video într-o interfață grafică interactivă de tip **Security Dashboard**.

Pe monitor este afișată o hartă simplificată, împărțită în mai multe zone. Utilizatorul controlează o dronă simulată cu ajutorul butoanelor plăcii Basys 3.

| Element | Descriere |
|---|---|
| Interfață | Security Dashboard VGA |
| Obiect controlat | Dronă simulată |
| Dimensiune dronă | 20x20 pixeli |
| Control | Butoanele direcționale |
| Zone | `BASE`, `SAFE`, `CHECK`, `ALERT` |
| Statusuri | `SAFE`, `CHECKING`, `ALERT` |
| Stadiu | Realizată și testată |

### 7.1. Structura dashboard-ului

| Zonă | Poziție | Culoare | Rol |
|---|---|---|---|
| `BASE` | Stânga sus | Albastru | Zona de bază |
| `ALERT` | Dreapta sus | Roșu | Zona periculoasă |
| `SAFE` | Stânga jos | Verde | Zona sigură |
| `CHECK` | Dreapta jos | Galben | Zona de verificare |
| Hartă centrală | Centrul ecranului | Albastru închis | Suprafața de deplasare |

Pe fundal este afișată o grilă, iar în partea superioară este afișat titlul `SECURITY DASHBOARD` și statusul curent.

### 7.2. Controlul dronei

| Buton | Pin | Acțiune |
|---|---|---|
| BTNU | T18 | Sus |
| BTNR | T17 | Dreapta |
| BTND | U17 | Jos |
| BTNL | W19 | Stânga |
| BTNC | U18 | Reset |

Coordonatele dronei sunt memorate în registrele `drone_x` și `drone_y`.

| Direcție | Modificare |
|---|---|
| Sus | Scade `drone_y` |
| Jos | Crește `drone_y` |
| Stânga | Scade `drone_x` |
| Dreapta | Crește `drone_x` |

Butoanele sunt sincronizate cu ceasul de pixel, iar poziția dronei este actualizată la `frame_tick`.

### 7.3. Detectarea zonelor

Pentru fiecare zonă sunt definite coordonatele, lățimea și înălțimea. Controllerul verifică dacă dreptunghiul dronei se suprapune cu dreptunghiul unei zone.

| Status | Condiție | Culoare | Viteză |
|---|---|---|---|
| `SAFE` | Drona nu este în `ALERT` sau `CHECK` | Verde / cyan | Mică |
| `CHECKING` | Drona este în zona `CHECK` | Galben | Medie |
| `ALERT` | Drona este în zona `ALERT` | Roșu / magenta | Mare |

Starea `ALERT` are prioritate față de celelalte stări.

### 7.4. Limitarea deplasării

Pentru a împiedica ieșirea dronei din hartă au fost definite limite minime și maxime.

| Limită | Rol |
|---|---|
| `DRONE_MIN_X` | Marginea din stânga |
| `DRONE_MAX_X` | Marginea din dreapta |
| `DRONE_MIN_Y` | Marginea de sus |
| `DRONE_MAX_Y` | Marginea de jos |

### 7.5. Organizarea modulelor

```text
vga_top
├── clk_vga_wrapper
└── vga_controller
    ├── timing VGA
    ├── sincronizare butoane
    ├── control poziție dronă
    ├── detectare zone
    ├── selectare status
    ├── randare text
    └── compoziție RGB
```

| Fișier | Rol |
|---|---|
| `top.sv` | Conectează modulele și semnalele externe |
| `vga_controller.sv` | Controlează VGA, dashboard-ul și drona |
| `clk_vga_wrapper` | Generează ceasul de pixel |
| `Constraint.xdc` | Mapează VGA, resetul și butoanele |

### 7.6. Rezultatul Etapei 4

| Cerință | Rezultat |
|---|---|
| Security Dashboard | Realizat |
| Hartă cu grilă | Realizată |
| Zone grafice | Realizate |
| Dronă 20x20 pixeli | Realizată |
| Control prin butoane | Realizat |
| Limitare la margini | Realizată |
| Status `SAFE` | Realizat |
| Status `CHECKING` | Realizat |
| Status `ALERT` | Realizat |
| Viteză dependentă de status | Realizată |
| Text bitmap | Realizat |
| Testare pe monitor | Realizată |

Etapa 4 reprezintă versiunea de bază folosită pentru integrarea tastaturii PmodKYPD din Etapa 5.

---

## 8. Etapa 5 – Integrarea tastaturii PmodKYPD

Etapa 5 extinde dashboard-ul prin integrarea tastaturii **PmodKYPD 4x4**. Tastatura este folosită pentru controlul dronei și pentru activarea unor funcții speciale, fără a elimina controlul existent prin butoanele plăcii Basys 3.

PmodKYPD este o tastatură matricială cu patru rânduri și patru coloane. FPGA-ul comandă pe rând coloanele și citește starea rândurilor pentru a determina tasta apăsată.

| Element | Descriere |
|---|---|
| Periferic | Digilent PmodKYPD |
| Tip interfață | Tastatură matricială 4x4 |
| Semnale fizice | 4 coloane și 4 rânduri |
| Metodă de citire | Scanare succesivă a coloanelor |
| Modul nou | `pmod_kypd.sv` |
| Rol | Controlul dronei și activarea comenzilor speciale |
| Stadiu | Implementată, aflată în testare și depanare |

### 8.1. Maparea tastelor

Tastele au fost alese astfel încât deplasarea să fie ușor de înțeles și de prezentat.

| Tastă | Funcție |
|---|---|
| `2` | Deplasare în sus |
| `6` | Deplasare spre dreapta |
| `8` | Deplasare în jos |
| `4` | Deplasare spre stânga |
| `0` | Deblocarea dronei din zona `SAFE` |
| `D` | Revenirea dronei în zona `BASE` și oprirea modului automat |
| `A` | Pornirea modului de deplasare automată |

Tastele de deplasare sunt combinate cu butoanele fizice ale plăcii. Astfel, drona poate fi controlată atât din butoanele Basys 3, cât și din tastatura PmodKYPD.

### 8.2. Principiul de scanare a tastaturii

Tastatura este organizată sub forma unei matrice:

```text
             COLOANE
          C1  C2  C3  C4
        +---+---+---+---+
R1      | 1 | 2 | 3 | A |
        +---+---+---+---+
R2      | 4 | 5 | 6 | B |
        +---+---+---+---+
R3      | 7 | 8 | 9 | C |
        +---+---+---+---+
R4      | 0 | F | E | D |
        +---+---+---+---+
```

Modulul `pmod_kypd` activează câte o coloană pe nivel logic `0`, apoi citește cele patru rânduri. Combinația dintre coloana activă și rândul detectat identifică tasta apăsată.

| Semnal | Direcție față de FPGA | Rol |
|---|---|---|
| `kypd_cols[3:0]` | Ieșire | Activează succesiv coloanele tastaturii |
| `kypd_rows[3:0]` | Intrare | Citește rândurile tastaturii |
| `key[3:0]` | Intern | Codul hexadecimal al tastei |
| `key_valid` | Intern | Indică faptul că o tastă stabilă este apăsată |

Pentru evitarea detectărilor instabile este folosită o logică simplă de debounce. O tastă este acceptată numai după ce aceeași combinație a fost detectată la mai multe scanări consecutive.

### 8.3. Schema bloc a Etapei 5

```text
                    +----------------------+
                    |   Tastatură PmodKYPD |
                    |   matrice 4 x 4      |
                    +----------+-----------+
                               |
                     rows[3:0] / cols[3:0]
                               |
                               v
                    +----------------------+
                    |     pmod_kypd.sv     |
                    | scanare + debounce   |
                    | decodare tastă       |
                    +----------+-----------+
                               |
                        key / key_valid
                               |
                               v
+----------------+    +----------------------+    +----------------------+
| Butoane Basys  |--->|        top.sv        |--->| vga_controller.sv    |
| U, D, L, R     |    | combinare comenzi    |    | mișcare + zone       |
+----------------+    | A / D / 0            |    | SAFE / BASE / AUTO   |
                      +----------+-----------+    +----------+-----------+
                                 |                           |
                                 |                           v
                                 |                 +--------------------+
                                 +---------------->| Semnale VGA RGB,   |
                                                   | Hsync și Vsync     |
                                                   +---------+----------+
                                                             |
                                                             v
                                                   +--------------------+
                                                   |    Monitor VGA     |
                                                   +--------------------+
```

Schema arată fluxul complet al informației. Tastatura este citită de `pmod_kypd.sv`, iar codul tastei este transmis către `top.sv`. Modulul principal transformă tastele în comenzi de mișcare și în comenzi speciale, apoi le transmite către `vga_controller.sv`. 

(((((verifica maine si intreaba ce schema sa pastrezi )))))

```text
+------------------+
|  Tastatură       |
|  PmodKYPD        |
+--------+---------+
         |
         v
+------------------+
|  pmod_kypd.sv    |
|  Citește tasta   |
+--------+---------+
         |
         v
+------------------+
|     top.sv       |
| Combină comenzile|
+--------+---------+
         |
         v
+------------------+
| vga_controller.sv|
| Controlează drona|
+--------+---------+
         |
         v
+------------------+
|   Monitor VGA    |
+------------------+
Tastatura PmodKYPD este citită de modulul pmod_kypd.sv. Tasta detectată este transmisă către top.sv, unde este transformată într-o comandă de deplasare sau într-o comandă specială. Comanda este apoi trimisă către vga_controller.sv, care actualizează poziția dronei și imaginea afișată pe monitor.


### 8.4. Organizarea modulelor

```text
vga_top
├── clk_vga_wrapper
├── pmod_kypd
└── vga_controller
```

| Fișier / modul | Rol |
|---|---|
| `top.sv` | Conectează tastatura, butoanele, Clock Wizard-ul și controllerul VGA |
| `pmod_kypd.sv` | Scanează matricea, face debounce și decodează tasta |
| `vga_controller.sv` | Controlează dashboard-ul, drona și funcțiile speciale |
| `clk_vga_wrapper` | Generează ceasul de pixel |
| `Constraint.xdc` | Mapează semnalele VGA, butoanele și pinii Pmod JA |

### 8.5. Conectarea în `top.sv`

În modulul principal sunt adăugate porturile:

```systemverilog
input  logic [3:0] kypd_rows,
output logic [3:0] kypd_cols
```

Modulul `pmod_kypd` furnizează:

```systemverilog
logic [3:0] kypd_key;
logic       kypd_key_valid;
```

Tastele `2`, `4`, `6` și `8` sunt transformate în aceleași semnale de deplasare folosite anterior de butoanele plăcii.

Comenzile speciale sunt transmise separat către controller:

```systemverilog
key_a
key_d
key_0
```

### 8.6. Blocarea în zona SAFE

Când drona intră în zona verde `SAFE`, controllerul o poziționează în centrul zonei și blochează deplasarea.

| Situație | Comportament |
|---|---|
| Intrare în `SAFE` | Drona este centrată și blocată |
| Apăsarea tastelor de direcție | Nu produce mișcare cât timp drona este blocată |
| Apăsarea tastei `0` | Drona este deblocată |
| Ieșirea completă din `SAFE` | Sistemul poate activa din nou blocarea la următoarea intrare |

Această funcție simulează o zonă de aterizare sau de staționare sigură.

### 8.7. Revenirea în BASE

La apăsarea tastei `D`, drona este mutată direct în centrul zonei `BASE`.

Comanda `D` realizează simultan:

- poziționarea dronei în `BASE`;
- anularea blocării din `SAFE`;
- oprirea modului automat;
- revenirea la controlul manual.

### 8.8. Modul de mișcare automată

Tasta `A` activează deplasarea automată a dronei. Direcția este generată pseudo-aleator și este modificată periodic sau atunci când drona ajunge la marginile hărții.

Pentru generarea direcției este folosit un registru de tip LFSR. Acesta nu produce numere complet aleatoare, dar generează o secvență suficient de variată pentru o animație hardware.

| Situație | Comportament |
|---|---|
| Se apasă `A` | Modul automat este activat |
| Drona ajunge la margine | Direcția este inversată |
| Se apasă o comandă manuală | Controlul manual are prioritate |
| Se apasă `D` | Modul automat este oprit și drona revine în `BASE` |
| Drona intră în `SAFE` | Drona este blocată conform regulii zonei |

### 8.9. Constrângerile PmodKYPD

Tastatura este conectată la portul Pmod **JA**. Fișierul `Constraint.xdc` conține opt pini suplimentari:

- patru ieșiri pentru `kypd_cols`;
- patru intrări pentru `kypd_rows`.

```tcl
## PmodKYPD connected to Pmod port JA

set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } [get_ports {kypd_cols[0]}]
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports {kypd_cols[1]}]
set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 } [get_ports {kypd_cols[2]}]
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports {kypd_cols[3]}]

set_property -dict { PACKAGE_PIN G3 IOSTANDARD LVCMOS33 } [get_ports {kypd_rows[0]}]
set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 } [get_ports {kypd_rows[1]}]
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports {kypd_rows[2]}]
set_property -dict { PACKAGE_PIN H1 IOSTANDARD LVCMOS33 } [get_ports {kypd_rows[3]}]
```

### 8.10. Stadiul Etapei 5

| Cerință | Stadiu |
|---|---|
| Crearea modulului `pmod_kypd.sv` | Realizată |
| Adăugarea tastaturii în `top.sv` | Realizată |
| Adăugarea pinilor în XDC | Realizată |
| Control cu `2`, `4`, `6`, `8` | În testare |
| Blocarea dronei în `SAFE` | În testare |
| Deblocarea cu `0` | În testare |
| Revenirea în `BASE` cu `D` | În testare |
| Mișcarea automată cu `A` | În testare |
| Testarea și eliminarea bugurilor | În curs |
| Validarea finală pe monitor | De realizat |

---

## 9. Etapa 6 – Îmbunătățiri viitoare

După integrarea tastaturii PmodKYPD, proiectul poate fi extins cu funcționalități suplimentare.

| Funcționalitate | Descriere | Stadiu |
|---|---|---|
| Pmod JSTK2 | Control analogic al dronei prin joystick și comunicație SPI | Planificată |
| OLED Pmod | Afișarea statusului pe un display extern | Planificată |
| Mod automat `PATROL` | Drona urmează un traseu prestabilit | Planificată |
| Hartă mai complexă | Mai multe zone și obstacole | Planificată |
| Coordonate X/Y | Afișarea poziției dronei pe ecran | Planificată |
| Moduri de control | Selectare între butoane, tastatură și joystick | Planificată |
| Full HD | Trecerea la o rezoluție mai mare | Opțională |
| Senzori externi | Integrarea unor senzori de distanță sau mișcare | Opțională |

### 9.1. Integrarea joystick-ului Pmod JSTK2

Joystick-ul Pmod JSTK2 rămâne o dezvoltare viitoare. Acesta va comunica prin SPI și va furniza valorile axelor X și Y.

Integrarea va necesita:

- un modul SPI Master;
- citirea și reconstruirea pachetului de date;
- aplicarea unei zone moarte în jurul poziției centrale;
- transformarea valorilor analogice în comenzi de deplasare;
- posibilitatea reglării vitezei în funcție de înclinarea joystick-ului.

Arhitectura planificată este:

```text
Pmod JSTK2
    │ SPI
    ▼
pmod_jstk2_spi
    │ joy_x / joy_y / buttons
    ▼
joystick_decoder
    │ direcție și viteză
    ▼
vga_controller
```

Această funcționalitate nu face parte din versiunea curentă a Etapei 5.

### 9.2. Mod automat `PATROL`

În acest mod, drona se va deplasa automat pe un traseu prestabilit. Utilizatorul poate comuta între control manual și control automat.

### 9.3. Afișarea coordonatelor

Coordonatele `drone_x` și `drone_y` pot fi convertite în caractere și afișate în dashboard.

### 9.4. Integrarea unui OLED Pmod

Un display OLED extern poate afișa:

- statusul curent;
- poziția dronei;
- modul de control;
- starea perifericelor conectate.

### 9.5. Rezoluții mai mari

Trecerea la o rezoluție mai mare ar necesita:

- un alt ceas de pixel;
- modificarea parametrilor VGA;
- verificarea resurselor FPGA;
- optimizarea logicii de randare.

Etapa 6 reprezintă direcția de dezvoltare ulterioară și nu este obligatorie pentru versiunea de bază a proiectului.

---

## 10. Probleme întâmpinate și soluții

| Problemă | Cauză | Soluție |
|---|---|---|
| Confuzia dintre `sys_clock` și `pix_clk` | VGA necesită un ceas separat | Folosirea `clk_vga_wrapper` |
| Reset conectat greșit | Switch-ul putea menține resetul activ | Mutarea resetului pe BTNC |
| Nume diferite între cod și XDC | Porturile nu corespundeau | Alinierea numelor |
| Modul de clock negăsit | Numele instanței era greșit | Folosirea numelui corect |
| Fișiere vechi folosite de Vivado | Proiectul indica spre alte foldere | Verificarea proprietății `Location` |
| Bitstream vechi | Nu fusese regenerat proiectul | Reset Runs și Generate Bitstream |
| Text greu de afișat | FPGA-ul nu are funcții software | Font bitmap |
| Mișcare prea rapidă | Poziția era actualizată prea des | Actualizare la `frame_tick` |
| Butoane nesincronizate | Intrări asincrone | Sincronizare pe două registre |
| Detectarea instabilă a tastelor | Contactele mecanice pot produce mai multe tranziții | Scanare periodică și debounce în `pmod_kypd.sv` |

### 10.1. Resetul de pe switch la buton

Resetul a fost mutat pe butonul central U18. Astfel, proiectul rulează normal când butonul nu este apăsat.

### 10.2. Organizarea fișierelor

Fișierele au fost separate pe etape pentru a evita modificarea accidentală a unei versiuni funcționale.

Structura generală este:

```text
Vscode_vga
├── etapa_3_test_pattern_no_signal
├── etapa_4_security_dashboard_buttons
└── etapa_5_pmod_kypd_keypad
```

### 10.3. Separarea logicii

Logica VGA, logica tastaturii și controlul dronei sunt păstrate în module diferite pentru claritate și testare independentă.

---

## 11. Obiective

### 11.1. Obiective personale

- [x] Să învăț să lucrez mai bine cu un FPGA.
- [x] Să înțeleg mai bine limbajul SystemVerilog.
- [x] Să pot scrie cod HDL mai clar și mai organizat.
- [x] Să înțeleg legătura dintre cod și hardware.
- [x] Să mă obișnuiesc cu pașii de lucru în Vivado.
- [x] Să interpretez mesajele de eroare din Vivado.
- [x] Să pot explica proiectul pe etape.
- [x] Să documentez procesul de dezvoltare.
- [x] Să controlez un obiect grafic prin intrări fizice.
- [ ] Să finalizez testarea tastaturii PmodKYPD și eliminarea bugurilor.

### 11.2. Obiective de proiect

- [x] Controller VGA funcțional.
- [x] Generarea semnalelor `Hsync` și `Vsync`.
- [x] Generarea ceasului de pixel.
- [x] Simularea proiectului.
- [x] Implementarea pe Basys 3.
- [x] Afișarea color bars.
- [x] Afișarea unui obiect animat.
- [x] Afișarea textului `NO SIGNAL`.
- [x] Actualizarea obiectului la `frame_tick`.
- [x] Realizarea Security Dashboard-ului.
- [x] Afișarea dronei de 20x20 pixeli.
- [x] Controlul dronei prin butoane.
- [x] Detectarea zonelor.
- [x] Statusurile `SAFE`, `CHECKING`, `ALERT`.
- [x] Modificarea vitezei în funcție de status.
- [x] Organizarea proiectului pentru Etapa 5.
- [x] Crearea modulului `pmod_kypd.sv`.
- [x] Adăugarea tastaturii în `top.sv`.
- [x] Adăugarea constrângerilor pentru portul Pmod JA.
- [ ] Validarea tastelor `2`, `4`, `6`, `8`.
- [ ] Validarea comenzilor `A`, `D` și `0`.
- [ ] Eliminarea bugurilor din logica de control.
- [ ] Testarea finală a Etapei 5.
- [ ] Integrarea joystick-ului Pmod JSTK2 ca dezvoltare viitoare.

---

## 12. Concluzie

Proiectul a evoluat de la un controller VGA simplu la o aplicație grafică interactivă implementată integral pe FPGA.

Primele etape au avut rolul de a proiecta, simula și implementa controllerul VGA pe placa Basys 3. După confirmarea funcționării semnalelor de sincronizare și a canalelor RGB, au fost introduse un model de test, un obiect animat și textul bitmap `NO SIGNAL`.

În Etapa 4 a fost realizat un Security Dashboard. Drona simulată poate fi controlată cu butoanele plăcii, iar poziția acesteia determină statusurile `SAFE`, `CHECKING` și `ALERT`. Interfața modifică textul, culorile și viteza în funcție de starea curentă.

Etapa 5 este dedicată integrării tastaturii PmodKYPD. Pentru aceasta a fost adăugat modulul `pmod_kypd.sv`, care scanează matricea tastaturii, elimină apăsările instabile și transmite codul tastei către modulul principal. Tastele `2`, `4`, `6` și `8` controlează deplasarea, tasta `0` deblochează drona din zona `SAFE`, tasta `D` o readuce în `BASE`, iar tasta `A` activează mișcarea automată.

Integrarea joystick-ului Pmod JSTK2 a fost mutată în planul de dezvoltare viitoare. Aceasta va necesita comunicație SPI și interpretarea valorilor axelor X și Y, dar nu face parte din versiunea curentă aflată în testare.

Organizarea proiectului pe etape și păstrarea fișierelor în GitHub permit continuarea dezvoltării fără pierderea versiunilor funcționale. Proiectul demonstrează utilizarea mai multor concepte importante: generare VGA, numărătoare, registre, logică secvențială și combinatorie, randare grafică, sincronizarea intrărilor și integrarea unei tastaturi matriceale externe.
