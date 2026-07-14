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

## 7. Etapa 4 – Extindere viitoare

Această etapă rămâne de făcut după confirmarea completă a proiectului pe placa fizică.

O direcție de extindere este trecerea la o rezoluție mai mare, cum ar fi 800x600, 1024x768 sau 1920x1080. Pentru o rezoluție mai mare trebuie modificați parametrii de timing și trebuie folosit un ceas de pixel mai rapid.

O altă direcție este adăugarea unei interfețe interactive. De exemplu, proiectul poate fi extins cu un sistem de tip **Drone Security Dashboard**, în care monitorul afișează o hartă simplificată, zone de alertă și o dronă simulată.

| Direcție de extindere | Descriere |
|---|---|
| Rezoluție mai mare | Trecerea de la 640x480 la 800x600, 1024x768 sau Full HD. |
| Control prin tastatură | Deplasarea elementelor de pe ecran folosind comenzi externe. |
| Drone Security Dashboard | Afișarea unei hărți, a unei drone simulate și a unor zone de alertă. |
| Integrare cameră | Detectarea unei mișcări simple și afișarea unei alerte pe monitor. |
| Moduri de afișare | Ecran de test, ecran de control, ecran de alertă și ecran de patrulare. |

| Funcție viitoare | Stadiu |
|---|---|
| Full HD | Neînceput |
| Tastatură | Neînceput |
| Hartă de securitate | Neînceput |
| Cameră | Idee pentru dezvoltare ulterioară |
| Dashboard interactiv | Idee pentru dezvoltare ulterioară |

---

## 8. Probleme întâmpinate și soluții

Pe parcursul proiectului au apărut mai multe probleme care au ajutat la înțelegerea mai bună a funcționării proiectului.

| Problemă | Cauză | Soluție |
|---|---|---|
| Confuzia dintre `sys_clock` și `pix_clk` | Ceasul plăcii este de 100 MHz, dar VGA are nevoie de un clock de pixel separat. | Am folosit `clk_vga_wrapper` pentru generarea ceasului de pixel. |
| Resetul conectat greșit | Resetul pe switch putea ține proiectul permanent în reset dacă switch-ul era pe 0. | Resetul a fost mutat pe butonul U18. |
| Nume diferite între cod și XDC | Porturile din `.xdc` nu se potriveau cu numele din `vga_top`. | Am aliniat porturile: `reset`, `sys_clock`, `Hsync`, `Vsync`, `vgaRed`, `vgaGreen`, `vgaBlue`. |
| Modul de clock negăsit | Instanțierea nu folosea numele exact generat de Vivado. | Am folosit numele corect: `clk_vga_wrapper`. |
| Cod aglomerat în blocurile `always` | Logica pentru animație și text devenise greu de urmărit. | Am mutat calculele auxiliare în `assign` și funcții. |
| Textul nu se putea afișa direct | FPGA-ul nu are funcții software de scriere text. | Am definit un font bitmap și am desenat textul pixel cu pixel. |

### 8.1. Resetul de pe switch la buton

O problemă importantă a fost definirea resetului. Inițial, resetul era gândit pe un switch, dar dacă acesta rămânea pe valoarea care activa resetul, proiectul nu pornea corect și monitorul nu afișa rezultatul dorit.

Soluția a fost folosirea butonului `U18`. Astfel, proiectul rulează normal când butonul nu este apăsat, iar resetul se activează doar când butonul este apăsat.

### 8.2. Separarea logicii pentru lizibilitate

Pe măsură ce au fost adăugate color bars, pătratul animat și textul, codul a devenit mai complex. Pentru lizibilitate, logica a fost separată pe blocuri clare, iar fiecare bloc secvențial a fost păstrat cât mai simplu.

---

## 9. Obiective

### 9.1. Obiective personale

- [ ] Să învăț să lucrez mai bine cu un FPGA.
- [x] Să înțeleg mai bine limbajul SystemVerilog.
- [x] Să pot scrie cod HDL mai clar și mai organizat.
- [ ] Să înțeleg legătura dintre codul SystemVerilog și comportamentul hardware.
- [x] Să mă obișnuiesc cu pașii de lucru în Vivado.
- [x] Să învăț să interpretez mesajele de eroare din Vivado.
- [ ] Să pot explica proiectul pe etape, nu doar să îl rulez.
- [ ] Să documentez procesul de dezvoltare într-un mod clar.

### 9.2. Obiective de proiect

- [ ] Să creez un VGA Controller funcțional.
- [x] Să generez corect semnalele `Hsync` și `Vsync`.
- [x] Să folosesc un ceas de pixel pentru controlul afișării.
- [x] Să simulez proiectul înainte de implementarea pe placă.
- [x] Să implementez proiectul pe FPGA și să verific rezultatul pe monitor.
- [x] Să afișez color bars pentru testarea canalelor RGB.
- [ ] Să afișez un pătrat animat peste fundal.
- [ ] Să afișez textul `NO SIGNAL` folosind un font bitmap.
- [ ] Să actualizez poziția obiectului animat o singură dată pe cadru.
- [ ] Să pregătesc proiectul pentru extinderi viitoare, cum ar fi tastatură, dashboard sau rezoluție mai mare.

---

## 10. Concluzie

Proiectul a evoluat de la un simplu controller VGA la o aplicație grafică de bază, capabilă să afișeze un model de test colorat și un element animat cu text.

Prin acest proiect am înțeles mai bine cum se generează o imagine pe monitor folosind doar hardware digital. Fiecare pixel este controlat în funcție de poziția sa, iar imaginea finală este rezultatul combinării semnalelor de timing, a logicii de culoare și a logicii de animație.

Următorul pas este validarea completă pe placa Basys 3 și extinderea proiectului către funcționalități mai avansate.