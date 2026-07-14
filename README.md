# Sistem de afișare VGA dinamică pe FPGA

**Autor:** Ugureanu Marius-Daniel  
**Facultate:** Inginerie Electrică și Știința Calculatoarelor  
**Specializare:** Calculatoare  
**Placă utilizată:** Basys 3  

## Istoric revizii

| Revision | Date | Author | Comments |
|---|---|---|---|
| 0.1 draft | Iulie 2026 | Marius-Daniel Ugureanu | First draft |
| 0.2 draft | 10 iulie 2026 | Marius-Daniel Ugureanu | Updated version with VGA color bars, moving black box and `NO SIGNAL` text |

---

## Cuprins

- [1. Introducere](#1-introducere)
- [2. Organizarea proiectului pe etape](#2-organizarea-proiectului-pe-etape)
- [3. Etapa 0 – Documentația proiectului](#3-etapa-0-documentatia-proiectului)
- [4. Etapa 1 – Structura inițială a proiectului](#4-etapa-1-structura-initiala-a-proiectului)
- [5. Etapa 2 – Realizarea fișierului de timing VGA](#5-etapa-2-realizarea-fisierului-de-timing-vga)
- [6. Etapa 3 – Implementarea pe placă și test vizual](#6-etapa-3-implementarea-pe-placa-si-test-vizual)
  - [6.1. Afișarea barelor colorate](#61-afisarea-barelor-colorate)
  - [6.2. Pătratul animat cu textul „NO SIGNAL”](#62-patratul-animat-cu-textul-no-signal)
  - [6.3. Randarea textului](#63-randarea-textului)
- [7. Etapa 4 – Extindere viitoare](#7-etapa-4-extindere-viitoare)
- [8. Probleme întâmpinate și soluții](#8-probleme-intampinate-si-solutii)
  - [8.1. Resetul de pe switch la buton](#81-resetul-de-pe-switch-la-buton)
  - [8.2. Separarea logicii pentru lizibilitate](#82-separarea-logicii-pentru-lizibilitate)
- [9. Obiective](#9-obiective)
  - [9.1. Obiective personale](#91-obiective-personale)
  - [9.2. Obiective de proiect](#92-obiective-de-proiect)
- [10. Concluzie](#10-concluzie)

---

## 1. Introducere

În cadrul acestui proiect mi-am propus să realizez un **controller VGA** folosind un FPGA. Ideea principală este să pot genera semnale video direct din hardware și să afișez pe un monitor elemente grafice simple, fără să folosesc un procesor sau o placă video clasică.

Proiectul pornește de la rezoluția **640x480@60Hz**, deoarece aceasta este o rezoluție de bază pentru VGA și este potrivită pentru înțelegerea principiilor de funcționare. La această rezoluție pot urmări mai ușor semnalele de sincronizare, zona activă a imaginii și felul în care poziția pixelului este controlată prin numărătoare orizontale și verticale.

Scopul proiectului nu este doar să apară ceva pe ecran, ci să înțeleg cum se ajunge de la cod SystemVerilog la comportament hardware real. Din acest motiv, proiectul este împărțit pe etape: documentare, simulare, implementare pe placă, testare vizuală și extindere.

| Element | Descriere |
|---|---|
| Nume proiect | Sistem de afișare VGA dinamică pe FPGA |
| Placă utilizată | Digilent Basys 3 |
| FPGA | Xilinx Artix-7 |
| Limbaj | SystemVerilog |
| Mediu de lucru | Vivado |
| Rezoluție inițială | 640x480@60Hz |
| Interfață video | VGA |
| Rezultat curent | Color bars + pătrat animat cu textul `NO SIGNAL` |

---

## 2. Organizarea proiectului pe etape

Proiectul este organizat în mai multe etape, astfel încât fiecare pas să poată fi verificat separat. Această împărțire este utilă deoarece un proiect FPGA poate deveni greu de urmărit dacă se încearcă direct afișarea unei imagini complexe. Mai întâi trebuie confirmat că semnalele VGA sunt corecte, apoi se pot adăuga forme, culori, animații și alte funcționalități.

| Etapă | Denumire | Stadiu | Rezultat urmărit |
|---|---|---|---|
| Etapa 0 | Documentația proiectului | Realizată | Stabilirea scopului, a pașilor și a structurii documentului. |
| Etapa 1 | Structura inițială a proiectului | Realizată | Crearea top-level-ului și conectarea modulelor principale. |
| Etapa 2 | Fișierul de timing VGA | Realizată | Generarea semnalelor `Hsync`, `Vsync` și a zonei active. |
| Etapa 3 | Implementarea pe placă și test vizual | În lucru / testare | Afișarea color bars și a pătratului animat cu `NO SIGNAL`. |
| Etapa 4 | Extindere viitoare | Neîncepută | Trecerea către rezoluții mai mari și funcții interactive. |

---

## 3. Etapa 0 – Documentația proiectului

Prima etapă a fost realizarea documentației proiectului. Înainte de implementarea efectivă, am stabilit ce vreau să obțin, ce placă folosesc, ce rezoluție aleg și cum voi împărți proiectul.

Documentația are rolul de a păstra o evidență clară a pașilor făcuți. Ea ajută și la prezentarea proiectului, deoarece arată evoluția de la o idee simplă până la un rezultat vizual pe monitor.

| Câmp | Detalii |
|---|---|
| Scop | Stabilirea direcției proiectului și a etapelor de lucru. |
| Activități | Definirea obiectivelor, alegerea plăcii, alegerea rezoluției și descrierea fluxului de lucru. |
| Decizii importante | Folosirea plăcii Basys 3, a limbajului SystemVerilog și a rezoluției 640x480@60Hz. |
| Rezultat | Documentație inițială creată și actualizată pe parcursul proiectului. |
| Observație | Documentația a fost adaptată după progresul real al proiectului, nu doar după planul inițial. |

---

## 4. Etapa 1 – Structura inițială a proiectului

În această etapă am creat structura de bază a proiectului. Am separat partea de top-level de partea care generează efectiv semnalele VGA.

Fișierul principal este modulul `vga_top`, care are rolul de a conecta semnalele externe ale plăcii cu logica internă a proiectului. Acesta primește ceasul de sistem al plăcii, semnalul de reset și trimite către conectorul VGA semnalele de sincronizare și canalele de culoare.

Ceasul de sistem nu este folosit direct pentru afișarea VGA. Pentru rezoluția 640x480@60Hz este necesar un ceas de pixel de aproximativ 25 MHz. Din acest motiv, am folosit un modul generat în Vivado, `clk_vga_wrapper`, care produce semnalul `pix_clk`.

| Fișier / Modul | Rol |
|---|---|
| `top.sv` | Modulul principal al proiectului. Conectează clock-ul, resetul și controllerul VGA. |
| `vga_top` | Top-level-ul care leagă semnalele externe de logica internă. |
| `clk_vga_wrapper` | Wrapper generat de Vivado pentru obținerea ceasului de pixel. |
| `vga_controller` | Modulul care generează timing-ul VGA și imaginea afișată. |
| `Constraint.xdc` | Fișierul care mapează porturile pe pinii fizici ai plăcii. |

| Semnal | Rol |
|---|---|
| `sys_clock` | Ceasul principal de 100 MHz al plăcii Basys 3. |
| `reset` | Reset conectat pe butonul U18. |
| `pix_clk` | Ceasul de pixel folosit pentru VGA. |
| `Hsync` | Semnalul de sincronizare orizontală. |
| `Vsync` | Semnalul de sincronizare verticală. |
| `vgaRed`, `vgaGreen`, `vgaBlue` | Canalele RGB trimise către monitor. |

---

## 5. Etapa 2 – Realizarea fișierului de timing VGA

În această etapă am realizat modulul principal de control VGA, numit `vga_controller`.

Acesta este fișierul care generează timing-ul pentru rezoluția 640x480. Pentru ca monitorul să afișeze corect imaginea, nu este suficient să trimit doar valori RGB. Trebuie generate și semnalele de sincronizare, iar fiecare pixel trebuie trimis la momentul potrivit.

Modulul `vga_controller` folosește două numărătoare: un contor orizontal, care parcurge pixelii de pe o linie, și un contor vertical, care parcurge liniile unui cadru.

| Componentă | Descriere |
|---|---|
| Contor orizontal | Parcurge pozițiile de pe o linie VGA. |
| Contor vertical | Parcurge liniile cadrului VGA. |
| Zona activă | Partea vizibilă a imaginii, unde semnalele RGB sunt afișate. |
| Zona de blanking | Partea nevizibilă, folosită pentru sincronizarea monitorului. |
| `Hsync` | Semnal de sincronizare pentru fiecare linie. |
| `Vsync` | Semnal de sincronizare pentru fiecare cadru. |

| Parametru VGA | Valoare folosită |
|---|---|
| Rezoluție activă | 640x480 |
| Clock de pixel | Aproximativ 25 MHz |
| Front porch / sync / back porch | Folosite pentru sincronizarea monitorului |
| Polaritate sincronizare | Activă pe 0 pentru `Hsync` și `Vsync` |

Prin această etapă am confirmat structura de bază a controllerului VGA. Dacă numărătoarele funcționează corect, pot fi generate ulterior culori, forme și animații în funcție de poziția pixelului curent.

---

## 6. Etapa 3 – Implementarea pe placă și test vizual

După realizarea timing-ului VGA, proiectul a fost trecut prin pașii de sinteză, implementare și generare bitstream. În această etapă am trecut de la ideea de afișare simplă la un test vizual mai complex.

Inițial, scopul era afișarea unei culori simple pe tot ecranul, pentru a verifica dacă semnalul VGA ajunge corect la monitor. După aceea, testul a fost extins prin generarea unor **color bars**, asemănătoare cu un model clasic de test video.

| Pas | Acțiune | Scop |
|---|---|---|
| 1 | Run Synthesis | Verificarea codului și transformarea lui în logică hardware. |
| 2 | Run Implementation | Plasarea și rutarea designului pe FPGA. |
| 3 | Generate Bitstream | Generarea fișierului `.bit`. |
| 4 | Program Device | Încărcarea proiectului pe placa Basys 3. |
| 5 | Test pe monitor | Confirmarea vizuală a semnalului VGA. |

### 6.1. Afișarea barelor colorate

Barele colorate sunt generate direct în `vga_controller`, folosind poziția pixelului curent. În loc să fie citită o imagine din memorie, culoarea fiecărui pixel este decisă în funcție de coordonatele `h_count` și `v_count`.

Ecranul este împărțit în zone orizontale și verticale. Pentru fiecare zonă este aleasă o culoare RGB diferită. Astfel, monitorul afișează bare de culoare precum alb, galben, cyan, verde, magenta, roșu, albastru și negru.

| Element | Detalii |
|---|---|
| Unde este realizat | În modulul `vga_controller`. |
| Cum este generat | Prin comparații între coordonatele pixelului și zonele ecranului. |
| Rol | Testarea canalelor RGB și a sincronizării VGA. |
| Avantaj | Nu necesită memorie video, deoarece imaginea este generată direct logic. |

### 6.2. Pătratul animat cu textul „NO SIGNAL”

După testul cu bare colorate, am introdus un element animat: un pătrat/dreptunghi negru care se deplasează pe ecran și conține textul **„NO SIGNAL”**.

Pătratul este generat tot pe baza coordonatelor pixelului. În cod există o poziție pentru colțul stânga-sus al pătratului, iar pentru fiecare pixel se verifică dacă acesta se află în interiorul zonei pătratului. Dacă pixelul este în pătrat, culoarea fundalului este înlocuită cu negru.

Pentru mișcare, poziția pătratului este actualizată o singură dată pe cadru, nu la fiecare pixel. Actualizarea se face la final de cadru, folosind un semnal de tip `frame_tick`.

| Element | Detalii |
|---|---|
| Obiect afișat | Pătrat / dreptunghi negru animat. |
| Text afișat | `NO SIGNAL`. |
| Mișcare | Poziția se actualizează la final de cadru. |
| Coliziune | La atingerea marginilor, direcția se schimbă. |
| Efect dorit | Mișcare de tip logo care ricoșează pe ecran. |

### 6.3. Randarea textului

Textul **„NO SIGNAL”** nu este scris ca într-un program software obișnuit. În FPGA, textul trebuie desenat pixel cu pixel. Pentru asta am folosit un font bitmap simplu.

Fiecare literă este definită printr-o matrice mică de biți. Un bit de 1 înseamnă pixel aprins, iar un bit de 0 înseamnă pixel stins.

| Pas | Descriere |
|---|---|
| 1 | Se calculează poziția locală a pixelului în interiorul pătratului. |
| 2 | Se determină caracterul din text căruia îi aparține pixelul. |
| 3 | Se determină rândul și coloana din bitmap-ul literei. |
| 4 | Dacă bitul din font este 1, pixelul este alb. |
| 5 | Dacă bitul este 0, pixelul rămâne negru. |

Această parte a proiectului a fost una dintre cele mai importante, deoarece arată că FPGA-ul nu afișează doar culori fixe, ci poate genera grafică simplă în timp real, folosind logică digitală.

---

## 7. Etapa 4 – Dashboard VGA interactiv controlat prin butoanele plăcii

Această etapă reprezintă continuarea proiectului după validarea afișării VGA cu modelul de test color bars și pătratul animat cu textul `NO SIGNAL`.

Scopul acestei etape este transformarea proiectului dintr-un test video într-o interfață grafică interactivă de tip **Security Dashboard**, afișată pe monitor prin VGA. În locul fundalului de test, ecranul va conține o hartă simplificată, zone de stare și o dronă simulată care poate fi controlată folosind butoanele plăcii Basys 3.

În prima variantă, controlul dronei va fi realizat cu butoanele plăcii, deoarece acestea sunt mai ușor de integrat și permit testarea logicii de mișcare fără a introduce încă un periferic extern. După ce această variantă este funcțională, proiectul poate fi extins către un joystick Pmod.

| Element | Descriere |
|---|---|
| Tip interfață | Security Dashboard VGA |
| Control inițial | Butoanele plăcii Basys 3 |
| Obiect controlat | Dronă simulată |
| Dimensiune dronă | 20x20 pixeli |
| Statusuri afișate | SAFE, CHECKING, ALERT |
| Scop | Control interactiv al dronei și detectarea zonelor de stare |
| Stadiu | Definit / urmează implementarea |

### 7.1. Controlul dronei prin butoane

Drona va fi reprezentată pe monitor printr-un pătrat de **20x20 pixeli**. Poziția acesteia va fi memorată prin două coordonate: `drone_x` și `drone_y`.

Controlul se va realiza cu butoanele plăcii Basys 3:

| Buton | Pin | Acțiune |
|---|---|---|
| BTNU | T18 | Mută drona în sus |
| BTNR | T17 | Mută drona spre dreapta |
| BTND | U17 | Mută drona în jos |
| BTNL | W19 | Mută drona spre stânga |
| BTNC | U18 | Reset / revenire la poziția inițială |

Pe ecran, coordonata verticală crește de sus în jos. Din acest motiv, pentru deplasarea în sus se va scădea coordonata `drone_y`, iar pentru deplasarea în jos se va crește coordonata `drone_y`.

### 7.2. Structura dashboard-ului

Ecranul va fi împărțit într-o zonă principală de afișare, asemănătoare unei hărți de securitate. În colțuri vor fi desenate mai multe zone cu roluri diferite.

| Zonă | Poziție pe ecran | Culoare | Rol |
|---|---|---|---|
| BASE ZONE | Colț stânga sus | Albastru | Zona de pornire / bază |
| ALERT ZONE | Colț dreapta sus | Roșu | Zonă periculoasă |
| SAFE ZONE | Colț stânga jos | Verde | Zonă sigură |
| CHECK ZONE | Colț dreapta jos | Galben | Zonă de verificare |

Drona va porni din zona centrală a ecranului. În funcție de zona în care intră, statusul afișat pe monitor se va modifica.

### 7.3. Statusurile sistemului

Dashboard-ul va avea trei stări principale:

| Status | Condiție | Comportament |
|---|---|---|
| SAFE | Drona este în zona sigură sau în afara zonelor speciale | Mișcare lentă |
| CHECKING | Drona intră în zona galbenă | Mișcare medie / stare de verificare |
| ALERT | Drona intră în zona roșie | Mișcare rapidă și stare de alertă |

În modul `SAFE`, drona se va deplasa lent, asemănător cu mișcarea pătratului animat din etapa anterioară. În modul `CHECKING`, se poate folosi o viteză intermediară. În modul `ALERT`, viteza de deplasare va crește pentru a evidenția faptul că sistemul a detectat o zonă periculoasă.

### 7.4. Logica de detecție a zonelor

Zonele vor fi definite ca dreptunghiuri pe ecran, folosind coordonatele pixelilor. Pentru fiecare zonă se vor stabili limitele pe axa X și pe axa Y.

Dacă poziția dronei intră în limitele unei zone, sistemul va schimba statusul afișat.

Exemplu de logică:

- dacă drona este în zona roșie, statusul devine `ALERT`;
- dacă drona este în zona galbenă, statusul devine `CHECKING`;
- dacă drona este în afara zonelor speciale, statusul rămâne `SAFE`.

Această logică este asemănătoare cu detecția coliziunilor folosită anterior pentru pătratul animat, dar în loc de marginile ecranului se folosesc limitele zonelor de securitate.

### 7.5. Rezultatul urmărit în Etapa 4

La finalul acestei etape, proiectul trebuie să afișeze pe monitor o interfață VGA de tip dashboard, cu zone colorate și o dronă controlabilă din butoanele plăcii.

Rezultatul urmărit este:

- afișare VGA funcțională;
- fundal de tip Security Dashboard;
- patru zone definite pe ecran: BASE, SAFE, CHECK și ALERT;
- dronă simulată de 20x20 pixeli;
- control prin butoanele plăcii Basys 3;
- status vizual: SAFE, CHECKING sau ALERT;
- viteză diferită de deplasare în funcție de status.

---

## 8. Etapa 5 – Control prin joystick Pmod JSTK2

După validarea dashboard-ului controlat prin butoanele plăcii, proiectul va fi extins prin integrarea unui periferic extern: **Pmod JSTK2**.

Motivul pentru care joystick-ul nu este introdus direct în prima variantă este reducerea complexității. În Etapa 4 se verifică mai întâi logica de mișcare, desenarea dashboard-ului și schimbarea statusului în funcție de poziția dronei. După ce această parte funcționează corect, butoanele plăcii vor putea fi înlocuite cu un joystick extern.

Pmod JSTK2 va permite un control mai natural al dronei, deoarece oferă două axe de mișcare: axa X pentru stânga/dreapta și axa Y pentru sus/jos.

| Element | Descriere |
|---|---|
| Periferic | Pmod JSTK2 |
| Tip control | Joystick pe două axe |
| Comunicație | SPI |
| Rol | Control mai natural al dronei pe ecran |
| Funcție suplimentară | Butonul joystick-ului poate fi folosit pentru reset sau revenire la bază |

### 8.1. Trecerea de la butoane la joystick

În varianta cu butoane, drona se mișcă în patru direcții fixe: sus, jos, stânga și dreapta. În varianta cu joystick, direcția va fi determinată de poziția joystick-ului.

Astfel, sistemul va putea interpreta:

- joystick spre dreapta → drona se deplasează spre dreapta;
- joystick spre stânga → drona se deplasează spre stânga;
- joystick în sus → drona se deplasează în sus;
- joystick în jos → drona se deplasează în jos;
- buton joystick apăsat → reset sau revenire la bază.

### 8.2. Avantajul folosirii joystick-ului

Folosirea joystick-ului transformă proiectul într-un sistem mai apropiat de o aplicație reală. În loc ca utilizatorul să controleze drona prin butoane separate, acesta poate folosi un periferic dedicat pentru deplasare.

Această etapă demonstrează integrarea unui periferic extern cu un sistem de afișare VGA pe FPGA.

### 8.3. Rezultatul urmărit în Etapa 5

La finalul acestei etape, drona afișată pe monitor trebuie să poată fi controlată prin Pmod JSTK2.

Rezultatul urmărit este:

- citirea datelor de la joystick;
- transformarea poziției joystick-ului în comenzi de mișcare;
- controlul dronei prin axele X și Y;
- folosirea butonului joystick-ului pentru reset sau revenire la bază;
- păstrarea statusurilor SAFE, CHECKING și ALERT;
- integrarea perifericului extern în proiectul VGA.

---

## 9. Etapa 6 – Îmbunătățiri viitoare

După integrarea joystick-ului, proiectul poate fi extins cu funcționalități suplimentare.

| Funcționalitate | Descriere |
|---|---|
| OLED Pmod | Afișarea statusului SAFE / CHECKING / ALERT pe display-ul extern |
| Mod automat PATROL | Drona se deplasează singură pe un traseu prestabilit |
| Hartă mai complexă | Adăugarea mai multor zone și obstacole |
| Afișare coordonate | Afișarea poziției X/Y a dronei pe ecran |
| Full HD | Trecerea la o rezoluție mai mare, cu modificarea timing-ului VGA |
| Joystick + butoane | Folosirea joystick-ului pentru mișcare și a butoanelor pentru schimbarea modurilor |

Această etapă este planificată ca dezvoltare viitoare și nu este obligatorie pentru prima variantă funcțională.

---

## 10. Probleme întâmpinate și soluții

Pe parcursul proiectului au apărut mai multe probleme care au ajutat la înțelegerea mai bună a funcționării proiectului.

| Problemă | Cauză | Soluție |
|---|---|---|
| Confuzia dintre `sys_clock` și `pix_clk` | Ceasul plăcii este de 100 MHz, dar VGA are nevoie de un clock de pixel separat. | Am folosit `clk_vga_wrapper` pentru generarea ceasului de pixel. |
| Resetul conectat greșit | Resetul pe switch putea ține proiectul permanent în reset dacă switch-ul era pe 0. | Resetul a fost mutat pe butonul U18. |
| Nume diferite între cod și XDC | Porturile din `.xdc` nu se potriveau cu numele din `vga_top`. | Am aliniat porturile: `reset`, `sys_clock`, `Hsync`, `Vsync`, `vgaRed`, `vgaGreen`, `vgaBlue`. |
| Modul de clock negăsit | Instanțierea nu folosea numele exact generat de Vivado. | Am folosit numele corect: `clk_vga_wrapper`. |
| Cod aglomerat în blocurile `always` | Logica pentru animație și text devenise greu de urmărit. | Am mutat calculele auxiliare în `assign` și funcții. |
| Textul nu se putea afișa direct | FPGA-ul nu are funcții software de scriere text. | Am definit un font bitmap și am desenat textul pixel cu pixel. |
| Posibilă problemă la butoane | Butoanele mecanice pot genera apăsări instabile dacă nu sunt filtrate. | Pentru prima variantă se poate folosi o actualizare doar la `frame_tick`, iar ulterior se poate adăuga debounce. |
| Complexitatea joystick-ului | Pmod JSTK2 necesită comunicare SPI, deci este mai complex decât butoanele plăcii. | Mai întâi se implementează controlul cu butoane, apoi se trece la joystick. |

### 10.1. Resetul de pe switch la buton

O problemă importantă a fost definirea resetului. Inițial, resetul era gândit pe un switch, dar dacă acesta rămânea pe valoarea care activa resetul, proiectul nu pornea corect și monitorul nu afișa rezultatul dorit.

Soluția a fost folosirea butonului `U18`. Astfel, proiectul rulează normal când butonul nu este apăsat, iar resetul se activează doar când butonul este apăsat.

### 10.2. Separarea logicii pentru lizibilitate

Pe măsură ce au fost adăugate color bars, pătratul animat și textul, codul a devenit mai complex. Pentru lizibilitate, logica a fost separată pe blocuri clare, iar fiecare bloc secvențial a fost păstrat cât mai simplu.

### 10.3. Trecerea de la animație automată la control manual

În varianta cu pătratul `NO SIGNAL`, mișcarea era automată și era controlată prin direcții interne. Pentru dashboard, mișcarea dronei trebuie controlată de utilizator. Acest lucru schimbă logica proiectului, deoarece poziția obiectului nu mai depinde doar de direcții interne, ci și de semnale externe venite de la butoane sau joystick.

---

## 11. Obiective

### 11.1. Obiective personale

- [ ] Să învăț să lucrez mai bine cu un FPGA.
- [x] Să înțeleg mai bine limbajul SystemVerilog.
- [x] Să pot scrie cod HDL mai clar și mai organizat.
- [ ] Să înțeleg legătura dintre codul SystemVerilog și comportamentul hardware.
- [x] Să mă obișnuiesc cu pașii de lucru în Vivado.
- [x] Să învăț să interpretez mesajele de eroare din Vivado.
- [ ] Să pot explica proiectul pe etape, nu doar să îl rulez.
- [ ] Să documentez procesul de dezvoltare într-un mod clar.
- [ ] Să învăț cum se poate controla un obiect pe ecran folosind intrări fizice.
- [ ] Să înțeleg cum se poate integra un periferic extern într-un proiect FPGA.

### 11.2. Obiective de proiect

- [x] Să creez un VGA Controller funcțional.
- [x] Să generez corect semnalele `Hsync` și `Vsync`.
- [x] Să folosesc un ceas de pixel pentru controlul afișării.
- [x] Să simulez proiectul înainte de implementarea pe placă.
- [x] Să implementez proiectul pe FPGA și să verific rezultatul pe monitor.
- [x] Să afișez color bars pentru testarea canalelor RGB.
- [x] Să afișez un pătrat animat peste fundal.
- [x] Să afișez textul `NO SIGNAL` folosind un font bitmap.
- [x] Să actualizez poziția obiectului animat o singură dată pe cadru.
- [ ] Să realizez un dashboard VGA cu zone de securitate.
- [ ] Să afișez o dronă simulată de 20x20 pixeli.
- [ ] Să controlez drona folosind butoanele plăcii Basys 3.
- [ ] Să implementez statusurile SAFE, CHECKING și ALERT.
- [ ] Să modific viteza dronei în funcție de status.
- [ ] Să pregătesc proiectul pentru control prin Pmod JSTK2.
- [ ] Să extind proiectul cu joystick extern prin SPI.
- [ ] Să pregătesc proiectul pentru extinderi viitoare, cum ar fi OLED Pmod, dashboard mai complex sau rezoluție mai mare.

---

## 12. Concluzie

Proiectul a evoluat de la un simplu controller VGA la o aplicație grafică de bază, capabilă să afișeze un model de test colorat și un element animat cu text.

Prin acest proiect am înțeles mai bine cum se generează o imagine pe monitor folosind doar hardware digital. Fiecare pixel este controlat în funcție de poziția sa, iar imaginea finală este rezultatul combinării semnalelor de timing, a logicii de culoare și a logicii de animație.

În continuare, proiectul va fi extins către un dashboard interactiv de securitate. Prima variantă va folosi butoanele plăcii Basys 3 pentru controlul unei drone simulate pe ecran. După validarea acestei funcționalități, proiectul va putea fi dezvoltat mai departe prin integrarea unui joystick Pmod JSTK2, pentru un control mai natural și mai apropiat de o aplicație reală.
