# Kaca

Projekt pri predmetu Digitalno Načrtovanje.

## Ideja

* VGA izhod za prikazovanje slike
* giroskop za premikanje levo, desno, gor in dol
    * premikali bi se lahko tudi z gumbi
* na 7 segmentnem zaslonu bi se izpisovalo število točk (število pojedenih sadežev)
* verjetno bova uporabila tudi pomnilne komponente vezja, saj bo potrebno "sliko kače" nekam shraniti

### Dodatno

* naključno generiranje sadežev
* start / end screen


## Informacije

* `kaca_engine`
  * skrbi za premik kače, hrani podatke o polju in sadežih
  * opis stanja igre:
    * `1AB` @ X, Y - na X, Y je kača s smerjo `AB`
    * +-+-+--------+
      |A|B| smer   |
      +-+-+--------+
      |0|0| desno  |
      |0|1| gor    |
      |1|0| levo   |
      |1|1| dol    |
      +-+-+--------+
