# Kaca

Projekt pri predmetu Digitalno Načrtovanje.

## Ideja

* VGA izhod za prikazovanje slike
* giroskop za premikanje levo, desno, gor in dol
    * premikali bi se lahko tudi z gumbi
* na 7 segmentnem zaslonu bi se izpisovalo število točk (število pojedenih sadežev)
* uporabila bova tudi pomnilne komponente vezja, saj bo potrebno "sliko kače" nekam shraniti

### Dodatno

* naključno generiranje sadežev
* start / end screen


## Informacije

Smeri:

| A   | B   | smer                          |
| --- | --- | ----------------------------- |
| 0   | 0   | ![](./assets/00100.png) desno |
| 0   | 1   | ![](./assets/00101.png) gor   |
| 1   | 0   | ![](./assets/00110.png) levo  |
| 1   | 1   | ![](./assets/00111.png) dol   |

Moduli
* `kaca_engine`
  * skrbi za premik kače, hrani podatke o polju in sadežih
  * opis stanja igre:
    * `1AB` @ X, Y - na X, Y je kača s smerjo `AB`
  * __vhodi__
    * smer_premika = 2-bitni vektor, ki določa smer premika kače (glej zgoraj)
    * allow_snake_move = bit, ki določa, ali se kača lahko premakne (1 = da, 0 = ne)

  * __izhodi__ 
    * spriti
      * 00000 = prazno
      * 001AB = kača spredaj, glej zgoraj za smer
      * 010AB = kača zadaj, glej zgoraj za smer
      * 011AB = kača ovinek: (trenutno še ni implementirano, bolj idejno)
        * |_ = 00
        * _| = 01
        * -| = 10
        * |- = 11
      * 100AB = kača vmes
      * 11111 = sadež
* `index2sprite`
    * preslika index sprita v sprite vektor (dolžine 256 (16 * 16)), ki se ga zatem lahko zapiše na zaslon
    * asinhron
    * __vhodi__
        * sprite index = 'id' sprita, videni zgoraj
    * __izhodi__
        * sprite image bits = vektor 256 bitov (0 = črna, 1 = bela)

* `framebuffer_RAM2`
  * skrbi za preslikavo stanja igre v pixle. Podamo mu želene koordinate, vrne pa nam 1-bitni pixel na tem mestu.
  * podpira vpis spritov: podamo mu koordinate in sprite index - ta bo zapisan na "display"
  * __vhodi__
    * sprite index = 'id' sprita, videni zgoraj
    * X, Y koordinate, kamor se sprite zapiše
    * X, Y koordinate, kjer želimo prebrati pixel
  * __izhodi__
    * 1-bitni pixel na X, Y koordinatah, podanih zgoraj

### VPRAŠANJA ZA NEJCA

### Todo
* [x] - score na 7 segmentni display
* [ ] - start / end logika (recmo pritisneš knof in se začne) @samolego
    * ali želiva, da se ob pritisku na gumb igra resetira? To je namreč precej dela, ker je treba celoten ram zbrisat in vse nastavit nazaj na začetno stanje
* [ ] - premikanje kače - TEŽAVE: dva modula pišeta na isti signal!
  * [ ] z gumbi
  * [ ] z giroskopom
* [x] - naključno generiranje sadežev @samolego
