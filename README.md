# fpga-vga-display
# Proiect VGA Controller pe FPGA

## 1. Introducere

În cadrul acestui proiect mi-am propus să realizez un **controller VGA** folosind un FPGA. Ideea principală a proiectului este să pot afișa o imagine simplă pe un monitor prin interfața VGA, folosind semnale generate direct în Verilog.

Am ales să încep cu rezoluția **640x480**, deoarece este o rezoluție de bază pentru VGA și este potrivită pentru a înțelege cum funcționează afișarea pe monitor. Înainte să afișez imagini mai complexe, forme sau animații, prima etapă este să fac semnalul VGA să funcționeze corect.

Scopul proiectului nu este doar să apară ceva pe ecran, ci și să înțeleg mai bine cum se generează semnalele video, cum se folosesc contoarele, cum se lucrează cu un ceas intern și cum se face trecerea de la simulare la implementarea pe placa FPGA.

---

## 2. Obiectivele proiectului

Prin acest proiect vreau să ating mai multe obiective:

- să învăț să lucrez mai bine cu un FPGA;
- să înțeleg mai bine limbajul Verilog;
- să pot scrie cod Verilog fără să depind complet de AI;
- să înțeleg cum se generează semnale pentru un monitor VGA;
- să învăț cum funcționează sincronizarea prin semnalele `HSYNC` și `VSYNC`;
- să folosesc un ceas intern pentru controlul afișării pixelilor;
- să creez un VGA Controller funcțional;
- să simulez proiectul înainte de implementarea pe placă;
- să implementez proiectul pe FPGA și să verific rezultatul pe un monitor real;
- să afișez pe monitor elemente simple, cum ar fi linii, culori sau forme geometrice;
- să înțeleg legătura dintre codul Verilog și comportamentul hardware;
- să mă obișnuiesc cu pașii de lucru în Vivado: creare proiect, simulare, sinteză, implementare și generare bitstream.

---

## 3. Etapele proiectului

Proiectul este împărțit în două etape principale:
1. **Specificații Project**
2. **VGA Controller și simulare**
3. **Implementarea pe placa FPGA**
3. **Implementarea pe placa FPGA**

Am ales această împărțire deoarece este mai sigur să verific mai întâi funcționarea semnalelor în simulare, înainte să programez placa și să testez direct pe monitor.

---

## 4. Prima etapă: VGA Controller și simulare

Prima etapă este realizarea unui **VGA Controller** pentru rezoluția **640x480**.

În această etapă vreau să generez corect semnalele necesare pentru VGA. Nu urmăresc încă o imagine complicată, ci vreau mai întâi să obțin un semnal stabil și corect, astfel încât monitorul să poată primi informația.

Pentru VGA sunt importante două semnale de sincronizare:

## 6. Etapa 2: Implementarea pe placa FPGA

**Perioadă: Săptămâna 2**

După ce controllerul VGA este verificat în simulare, urmează implementarea pe placa FPGA.

În această etapă voi face legătura dintre semnalele generate în Verilog și pinii fizici ai plăcii Basys 3. Pentru acest lucru este nevoie de fișierul de constrângeri, unde sunt specificați pinii pentru ieșirea VGA.

La început, obiectivul nu este să afișez ceva foarte complex, ci să verific dacă monitorul primește un semnal VGA corect.

Primul test poate fi afișarea unei culori simple pe tot ecranul. De exemplu, pot afișa un fundal roșu, verde, albastru, negru sau alb.

După ce fundalul apare corect pe monitor, următorul pas este afișarea unor elemente simple.

Elementele care pot fi afișate în această etapă sunt:

- linie orizontală;
- linie verticală;
- pătrat;
- dreptunghi;
- chenar pe marginea ecranului;
- zone colorate;
- forme simple care se deplasează pe ecran.

Un obiectiv important pentru această etapă este să observ pe monitor că se mișcă ceva. De exemplu, pot afișa un pătrat care se deplasează de la stânga la dreapta sau o linie care se schimbă în timp.

Această parte este importantă deoarece demonstrează că proiectul nu funcționează doar în simulare, ci și pe hardware real.

Dacă reușesc să afișez forme simple și să modific poziția lor pe ecran, înseamnă că partea de bază a controllerului VGA funcționează corect.

Scopul acestei etape este verificarea practică a semnalului VGA pe monitor și confirmarea faptului că placa FPGA poate controla afișarea în timp real.





 ## 7. Etapa 3: Creșterea rezoluției și adăugarea unui sistem de securitate interactiv
 etapa4: sa apara figuri /schimbare de culoare (tablouri / ) 
 etapa 5 : cresterea rezolutiei 
 etapa 6 : ce vreau eu 
**Perioadă: Săptămâna 3**

După ce afișarea la rezoluția **640x480** funcționează corect, proiectul poate fi extins prin creșterea complexității și prin adăugarea unei funcționalități interactive.

În această etapă vreau să trec de la o simplă afișare de forme geometrice la o interfață grafică mai utilă, care să poată fi folosită ca model pentru un sistem de monitorizare și securitate.

Ideea principală pentru etapa finală este realizarea unui **sistem de tip Drone Security Dashboard**, afișat pe monitor prin VGA și controlat din tastatură.

Acest sistem poate simula o zonă supravegheată, o dronă de securitate și mai multe zone de alertă. Pe monitor poate apărea o hartă simplificată, iar utilizatorul poate controla elementele de pe ecran folosind tastatura.

---

### 7.1. Creșterea rezoluției

O primă direcție de îmbunătățire este trecerea către o rezoluție mai mare față de 640x480.

Pentru început, proiectul pornește de la rezoluția de bază, deoarece aceasta este mai simplă și mai potrivită pentru testarea semnalului VGA. După ce sistemul funcționează corect, se poate încerca trecerea către o rezoluție mai mare, cum ar fi:

- 800x600;
- 1024x768;
- 1280x720;
- Full HD, adică 1920x1080, ca obiectiv de extindere.

Creșterea rezoluției face proiectul mai complex, deoarece este nevoie de un ceas mai rapid și de o logică mai bine organizată. Cu cât rezoluția este mai mare, cu atât trebuie procesați mai mulți pixeli într-un timp mai scurt.

Pentru o rezoluție mai mare, nu este eficient să fie salvată întreaga imagine în memoria internă a FPGA-ului. Din acest motiv, o soluție mai potrivită este generarea imaginii direct în funcție de poziția pixelului curent de pe ecran.

Astfel, culoarea fiecărui pixel poate fi stabilită pe baza coordonatelor sale. Această metodă este potrivită pentru afișarea de linii, chenare, zone de alertă, meniuri și obiecte simple.

---

### 7.2. Ideea principală: Drone Security Dashboard

Funcționalitatea principală adăugată în această etapă este realizarea unui dashboard de securitate pentru o dronă.

Pe monitor poate fi afișată o hartă simplificată a unei zone supravegheate, de exemplu:

- o curte;
- o clădire;
- un depozit;
- o zonă industrială;
- un perimetru de securitate.

Această zonă poate fi împărțită în mai multe sectoare. Fiecare sector poate avea o stare diferită:

- zonă sigură;
- zonă selectată;
- zonă în verificare;
- zonă cu alertă;
- zonă în care drona trebuie să se deplaseze.

Drona poate fi reprezentată pe monitor printr-un punct, un pătrat sau un simbol simplu. Poziția acesteia se poate modifica pe ecran, fie automat, fie prin comenzi primite de la tastatură.

Această idee este utilă deoarece transformă proiectul dintr-o simplă afișare VGA într-o aplicație interactivă, asemănătoare cu un sistem real de supraveghere.

---

### 7.3. Controlul prin tastatură

Tastatura poate fi folosită pentru controlul sistemului afișat pe monitor.

Utilizatorul poate trimite comenzi către sistem, iar FPGA-ul modifică în timp real imaginea afișată.

Prin tastatură se pot realiza următoarele acțiuni:

- deplasarea dronei pe hartă;
- schimbarea direcției de deplasare;
- selectarea unei zone de securitate;
- activarea modului de patrulare;
- oprirea patrulării;
- revenirea dronei la bază;
- schimbarea paginii afișate pe monitor;
- resetarea sistemului;
- simularea unei alerte;
- schimbarea modului de afișare.

De exemplu, tastele pot fi folosite pentru deplasarea dronei în sus, jos, stânga și dreapta. Alte taste pot fi folosite pentru schimbarea modului de funcționare.

Astfel, proiectul devine interactiv, deoarece utilizatorul nu doar privește imaginea de pe monitor, ci poate controla direct ceea ce se întâmplă pe ecran.


---



### 7.6. Posibilă integrare cu o cameră

O extindere mai avansată a proiectului ar fi integrarea unei camere.

Camera ar putea fi folosită pentru a urmări o zonă și pentru a detecta schimbări simple în imagine.

Pentru început, nu este obligatoriu să fie realizată o procesare video complexă. Camera poate fi folosită într-un mod simplificat, pentru detectarea unei schimbări într-o anumită zonă.

Sistemul ar putea detecta:

- mișcare într-o zonă;
- schimbarea luminozității;
- apariția unui obiect;
- trecerea unui obiect printr-un sector;
- activarea unei zone de alertă.

Dacă sistemul detectează mișcare într-o zonă, pe monitor se poate activa o alertă vizuală. De exemplu, zona respectivă poate fi evidențiată, iar drona poate fi trimisă către acel sector.

Această funcționalitate poate fi prezentată ca o posibilă dezvoltare viitoare a proiectului.

---

### 7.7. Moduri de afișare pe monitor

Pentru ca sistemul să fie mai ușor de folosit, monitorul poate afișa mai multe pagini sau moduri.

Utilizatorul poate schimba aceste moduri folosind tastatura.

Exemple de ecrane posibile:

- ecran principal cu titlul proiectului;
- ecran cu harta zonei supravegheate;
- ecran cu poziția dronei;
- ecran cu starea zonelor de securitate;
- ecran de alertă;
- ecran de patrulare automată;
- ecran de control manual;
- ecran de test VGA.

Această organizare face proiectul mai clar și mai ușor de prezentat. În loc să existe o singură imagine pe ecran, utilizatorul poate naviga între mai multe pagini.

---

### 7.8. Utilitatea proiectului

Această funcționalitate poate fi utilă deoarece reprezintă un model simplificat pentru un sistem real de supraveghere.

Un astfel de sistem ar putea fi folosit pentru:

- monitorizarea unei curți;
- supravegherea unei clădiri;
- verificarea unui depozit;
- supravegherea unui perimetru;
- afișarea rapidă a zonelor cu probleme;
- controlul unei drone de securitate;
- urmărirea unor alerte în timp real.

Chiar dacă proiectul este realizat într-o variantă simplificată, el demonstrează ideea de bază: FPGA-ul poate genera o interfață video, poate primi comenzi de la tastatură și poate modifica imaginea în timp real.

---

### 7.9. Rezultatul urmărit în etapa finală

La finalul acestei etape vreau ca proiectul să nu fie doar un controller VGA simplu, ci o aplicație interactivă.

Rezultatul urmărit este un sistem care afișează pe monitor o hartă simplificată, o dronă simulată și mai multe zone de securitate.

Utilizatorul va putea controla sistemul din tastatură, iar imaginea de pe monitor se va modifica în timp real.

Varianta finală a proiectului poate include:

- afișare VGA funcțională;
- interfață grafică simplă;
- hartă de securitate;
- zone de alertă;
- dronă simulată;
- control din tastatură;
- mod de patrulare automată;
- mod de control manual;
- posibilitate de extindere cu o cameră.
