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
| 0.4 draft | 20 iulie 2026 | Marius-Daniel Ugureanu | Completed Stage 4 documentation and prepared Stage 5 for Pmod JSTK2 integration through SPI |

---

## Cuprins

- [1. Introducere](#1-introducere)
- [2. Organizarea proiectului pe etape](#2-organizarea-proiectului-pe-etape)
- [3. Etapa 0 – Documentația proiectului](#3-etapa-0--documentația-proiectului)
- [4. Etapa 1 – Design și simulare VGA a controllerului](#4-etapa-1--design-și-simulare-vga-a-controllerului)
- [5. Etapa 2 – Implementare pe FPGA a VGA-ului](#5-etapa-2--implementare-pe-fpga-a-vga-ului)
- [6. Etapa 3 – Test Pattern și animație NO SIGNAL](#6-etapa-3--test-pattern-și-animație-no-signal)
- [7. Etapa 4 – Security Dashboard controlat prin butoane](#7-etapa-4--security-dashboard-controlat-prin-butoane)
- [8. Etapa 5 – Integrarea joystick-ului Pmod JSTK2 prin SPI](#8-etapa-5--integrarea-joystick-ului-pmod-jstk2-prin-spi)
- [9. Etapa 6 – Îmbunătățiri viitoare](#9-etapa-6--îmbunătățiri-viitoare)
- [10. Probleme întâmpinate și soluții](#10-probleme-întâmpinate-și-soluții)
- [11. Obiective](#11-obiective)
- [12. Concluzie](#12-concluzie)

---

## 1. Introducere

În cadrul acestui proiect mi-am propus să realizez un sistem de afișare VGA folosind un FPGA. Ideea principală este generarea directă în hardware a semnalelor video necesare unui monitor VGA și afișarea unor elemente grafice fără folosirea unui procesor sau a unei plăci video clasice.

Proiectul pornește de la rezoluția **640x480@60Hz**, deoarece aceasta este potrivită pentru înțelegerea principiilor de bază ale afișării VGA. La această rezoluție pot fi urmărite mai ușor semnalele de sincronizare, zona activă a imaginii, perioadele de blanking și modul în care poziția fiecărui pixel este determinată cu ajutorul unor numărătoare.

Proiectul a fost dezvoltat progresiv. Prima variantă a avut rolul de a genera semnalele VGA și de a afișa culori simple. Ulterior au fost introduse bare colorate, un dreptunghi animat cu textul `NO SIGNAL`, iar apoi proiectul a fost transformat într-un dashboard de securitate interactiv, în care o dronă simulată poate fi controlată folosind butoanele plăcii.

Următoarea extindere este integrarea unui joystick Pmod JSTK2, care comunică prin protocolul SPI și va permite controlul mai natural al dronei.

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
| Extindere următoare | Control prin joystick Pmod JSTK2 folosind SPI |

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
| Etapa 5 | Integrarea joystick-ului Pmod JSTK2 prin SPI | În dezvoltare | Citirea axelor și controlul dronei prin joystick |
| Etapa 6 | Îmbunătățiri viitoare | Planificată | OLED, mod PATROL, hartă extinsă și alte funcționalități |

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

Etapa 4 reprezintă ultima versiune complet funcțională înainte de integrarea joystick-ului.

---

## 8. Etapa 5 – Integrarea joystick-ului Pmod JSTK2 prin SPI

Etapa 5 extinde dashboard-ul prin integrarea unui periferic extern, Pmod JSTK2. Acesta va permite controlul mai natural al dronei prin intermediul unui joystick pe două axe.

Joystick-ul este analogic la nivel mecanic, însă modulul Pmod realizează conversia internă și transmite către FPGA valori digitale prin protocolul SPI.

| Element | Descriere |
|---|---|
| Periferic | Digilent Pmod JSTK2 |
| Comunicație | SPI |
| Axe | X și Y |
| Date suplimentare | Buton joystick și trigger |
| Rol | Controlul dronei |
| Stadiu | În dezvoltare |

### 8.1. Conectarea joystick-ului

Joystick-ul va fi conectat la un port Pmod al plăcii Basys 3.

| Semnal | Direcție față de FPGA | Rol |
|---|---|---|
| `jstk_cs` | Ieșire | Selectează perifericul |
| `jstk_sclk` | Ieșire | Ceas SPI |
| `jstk_mosi` | Ieșire | Date trimise de FPGA |
| `jstk_miso` | Intrare | Date primite de FPGA |
| 3.3 V | Alimentare | Alimentează modulul |
| GND | Alimentare | Referință electrică |

Nu este necesară o intrare analogică directă pe FPGA.

### 8.2. Modulul SPI Master

Va fi creat modulul:

```text
pmod_jstk2_spi.sv
```

Rolul acestuia este:

- generarea ceasului SPI;
- controlul semnalului `CS`;
- transmisia pe `MOSI`;
- recepția pe `MISO`;
- gruparea biților în octeți;
- extragerea valorilor axelor;
- generarea semnalului `data_valid`.

Automatul de stări va conține, în principiu:

```text
IDLE
↓
CS_ACTIVE
↓
TRANSFER
↓
CS_INACTIVE
↓
DATA_VALID
```

| Stare | Rol |
|---|---|
| `IDLE` | Așteaptă un nou transfer |
| `CS_ACTIVE` | Selectează joystick-ul |
| `TRANSFER` | Trimite și primește date |
| `CS_INACTIVE` | Încheie transferul |
| `DATA_VALID` | Semnalizează date noi |

### 8.3. Interpretarea axelor

Modulul SPI va furniza valorile:

```text
joy_x
joy_y
```

Aceste valori vor fi interpretate astfel:

| Valoare | Interpretare |
|---|---|
| X mic | Stânga |
| X central | Fără mișcare orizontală |
| X mare | Dreapta |
| Y mic | Sus sau jos, în funcție de orientare |
| Y central | Fără mișcare verticală |
| Y mare | Direcția verticală opusă |

Orientarea exactă a axei Y va fi stabilită prin testare.

### 8.4. Zona moartă

Pentru a evita mișcarea accidentală a dronei va fi introdusă o zonă moartă.

| Condiție | Comandă |
|---|---|
| X sub pragul inferior | Stânga |
| X între praguri | Oprire pe axa X |
| X peste pragul superior | Dreapta |
| Y sub pragul inferior | Direcție verticală |
| Y între praguri | Oprire pe axa Y |
| Y peste pragul superior | Direcție verticală opusă |

### 8.5. Modulul de interpretare

Va fi creat modulul:

```text
joystick_decoder.sv
```

Acesta va primi:

```text
joy_x
joy_y
data_valid
```

și va genera:

```text
joy_up
joy_down
joy_left
joy_right
```

### 8.6. Organizarea proiectului

```text
top.sv
├── clk_vga_wrapper
├── pmod_jstk2_spi
├── joystick_decoder
└── vga_controller
```

Fluxul de date va fi:

```text
Pmod JSTK2
    │ SPI
    ▼
pmod_jstk2_spi
    │ joy_x, joy_y, buttons, data_valid
    ▼
joystick_decoder
    │ joy_up, joy_down, joy_left, joy_right
    ▼
vga_controller
    │
    ▼
Dronă pe Security Dashboard
```

| Fișier | Rol |
|---|---|
| `top.sv` | Conectează toate modulele |
| `vga_controller.sv` | Păstrează dashboard-ul |
| `pmod_jstk2_spi.sv` | Implementează comunicația SPI |
| `joystick_decoder.sv` | Transformă axele în direcții |
| `Constraint.xdc` | Adaugă pinii Pmod |
| `tb_pmod_jstk2_spi.sv` | Testează comunicația SPI |

Clock Wizard-ul VGA va fi păstrat, deoarece rezoluția rămâne aceeași. Modulul SPI va folosi ceasul de sistem de 100 MHz și un divizor intern pentru obținerea unui ceas SPI mai lent.

### 8.7. Planul de implementare

| Pas | Activitate | Rezultat urmărit |
|---|---|---|
| 1 | Copierea Etapei 4 | Păstrarea versiunii funcționale |
| 2 | Crearea folderului Etapei 5 | Organizarea proiectului |
| 3 | Adăugarea semnalelor SPI | Pregătirea conexiunii |
| 4 | Adăugarea pinilor în XDC | Conectarea fizică |
| 5 | Implementarea SPI Master | Generarea transferurilor |
| 6 | Citirea axelor X și Y | Obținerea poziției joystick-ului |
| 7 | Implementarea dead zone | Eliminarea mișcării accidentale |
| 8 | Testarea pe LED-uri | Verificarea direcțiilor |
| 9 | Conectarea la dashboard | Controlul dronei |
| 10 | Testarea finală | Validarea sistemului complet |

În timpul testării, butoanele plăcii vor fi păstrate în paralel cu joystick-ul.

### 8.8. Stadiul Etapei 5

| Cerință | Stadiu |
|---|---|
| Folder separat | Pregătit / în organizare |
| Reutilizarea Etapei 4 | Stabilită |
| Păstrarea Clock Wizard-ului | Stabilită |
| Semnale SPI în top | De realizat |
| Pini Pmod în XDC | De realizat |
| Modul SPI Master | De realizat |
| Citirea axelor | De realizat |
| Dead zone | De realizat |
| Test LED-uri | De realizat |
| Controlul dronei | De realizat |
| Test final | De realizat |

---

## 9. Etapa 6 – Îmbunătățiri viitoare

După integrarea joystick-ului, proiectul poate fi extins cu funcționalități suplimentare.

| Funcționalitate | Descriere | Stadiu |
|---|---|---|
| OLED Pmod | Afișarea statusului pe un display extern | Planificată |
| Mod automat `PATROL` | Drona urmează un traseu prestabilit | Planificată |
| Hartă mai complexă | Mai multe zone și obstacole | Planificată |
| Coordonate X/Y | Afișarea poziției dronei pe ecran | Planificată |
| Viteză analogică | Viteza depinde de înclinarea joystick-ului | Planificată |
| Joystick + butoane | Joystick pentru mișcare și butoane pentru moduri | Planificată |
| Full HD | Trecerea la o rezoluție mai mare | Opțională |
| Senzori externi | Integrarea unor senzori de distanță sau mișcare | Opțională |

### 9.1. Mod automat `PATROL`

În acest mod, drona se va deplasa automat pe un traseu prestabilit. Utilizatorul poate comuta între control manual și control automat.

### 9.2. Afișarea coordonatelor

Coordonatele `drone_x` și `drone_y` pot fi convertite în caractere și afișate în dashboard.

### 9.3. Integrarea unui OLED Pmod

Un display OLED extern poate afișa:

- statusul curent;
- poziția dronei;
- modul de control;
- starea comunicației SPI.

### 9.4. Rezoluții mai mari

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
| Complexitatea joystick-ului | Necesită SPI și interpretare X/Y | Separarea în module distincte |

### 10.1. Resetul de pe switch la buton

Resetul a fost mutat pe butonul central U18. Astfel, proiectul rulează normal când butonul nu este apăsat.

### 10.2. Organizarea fișierelor

Fișierele au fost separate pe etape pentru a evita modificarea accidentală a unei versiuni funcționale.

Structura generală este:

```text
Vscode_vga
├── etapa_3_test_pattern_no_signal
├── etapa_4_security_dashboard_buttons
└── etapa_5_pmod_jstk2_joystick
```

### 10.3. Separarea logicii

Logica VGA, logica joystick-ului și interpretarea direcțiilor sunt păstrate în module diferite pentru claritate și testare independentă.

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
- [ ] Să integrez complet un periferic extern prin SPI.

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
- [ ] Implementarea controlerului SPI.
- [ ] Citirea joystick-ului Pmod JSTK2.
- [ ] Implementarea zonei moarte.
- [ ] Controlul dronei prin joystick.
- [ ] Testarea finală a Etapei 5.

---

## 12. Concluzie

Proiectul a evoluat de la un controller VGA simplu la o aplicație grafică interactivă implementată integral pe FPGA.

Primele etape au avut rolul de a proiecta, simula și implementa controllerul VGA pe placa Basys 3. După confirmarea funcționării semnalelor de sincronizare și a canalelor RGB, au fost introduse un model de test, un obiect animat și textul bitmap `NO SIGNAL`.

În Etapa 4 a fost realizat un Security Dashboard. Drona simulată poate fi controlată cu butoanele plăcii, iar poziția acesteia determină statusurile `SAFE`, `CHECKING` și `ALERT`. Interfața modifică textul, culorile și viteza în funcție de starea curentă.

Etapa 5 este dedicată integrării joystick-ului Pmod JSTK2 prin SPI. Pentru aceasta vor fi adăugate un modul SPI Master și un modul pentru interpretarea axelor X și Y. Controlul prin butoane va fi păstrat temporar pentru testare.

Organizarea proiectului pe etape și păstrarea fișierelor în GitHub permit continuarea dezvoltării fără pierderea versiunilor funcționale. Proiectul demonstrează utilizarea mai multor concepte importante: generare VGA, numărătoare, registre, automate de stare, randare grafică, sincronizarea intrărilor și integrarea perifericelor externe.
