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

| A   | B   | smer  |
| --- | --- | ----- |
| 0   | 0   | desno |
| 0   | 1   | gor   |
| 1   | 0   | levo  |
| 1   | 1   | dol   |

Moduli
* `kaca_engine`
  * skrbi za premik kače, hrani podatke o polju in sadežih
  * opis stanja igre:
    * `1AB` @ X, Y - na X, Y je kača s smerjo `AB`

  * __output__ 
    * sprites:
      * 00000 = prazno
      * 001AB = kača spredaj, glej zgoraj za smer
      * 010AB = kača zadaj, glej zgoraj za smer
      * 011AB = kača ovinek: (trenutno še ni implementirano, bolj idejno)
        * |_ = desno = 00
        * _| = gor   = 01
        * -| = levo  = 10
        * |- = dol   = 11
      * 100AB = kača vmes
      * 11111 = sadež
