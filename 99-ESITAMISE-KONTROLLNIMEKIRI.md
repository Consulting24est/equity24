# Esitamise kontrollnimekiri ja lõplik kvaliteedikontroll

*Tehakse üks kord, vahetult enne taotluse esitamist. Iga „ei“ tähendab, et taotlust ei esitata.*

---

## A. Dokumentide täielikkus

### Põhidokument
☐ `01-POHITAOTLUS.md` täidetud, kõik kohatäited asendatud, digitaalselt allkirjastatud kõigi juhatuse liikmete poolt

### Kohustuslikud lisad (art 12 lg 2)
☐ Lisa 2 Põhikiri — **äriregistris registreeritud versioon**, mitte kavand
☐ Lisa 3 Omavahendite kinnitus + pangaväljavõte + [audiitori kinnitus]
☐ Lisa 4 Sise-eeskirjad
☐ Lisa 5 Tegevuskava + finantsprognoos + osanike rahastuskohustus
☐ Lisa 6 Riskipoliitika
☐ Lisa 7 Raamatupidamise sise-eeskiri
☐ Lisa 8 Operatsiooniriski kord
☐ Lisa 9 Andmetöötluse poliitika
☐ Lisa 10 IT-strateegia
☐ Lisa 11 Talitluspidevuse kava **+ varuteenindamise kokkulepe (lisa 11-A)**
☐ Lisa 12 Omanike struktuur — **digitaalselt allkirjastatud** + skeem + registriväljavõtted + kasusaajate dokumendid + vahendite päritolu tõendid
☐ Lisa 13 iga juhatuse liikme kohta: CV + sobivuse kinnitus (**digitaalselt allkirjastatud**) + **FI sobivuse küsimustik** + **karistusregistri väljavõte (≤3 kuud)** + isikut tõendav dokument + diplomid + registriväljavõtted
☐ Lisa 13.3 Kollektiivse sobivuse hinnang
☐ Lisa 14 Huvide konflikti poliitika + seotud isikute register
☐ Lisa 15 Tegevuse edasiandmise kord + register
☐ Lisa 16 Makseteenuste kinnitus — **digitaalselt allkirjastatud**
☐ Lisa 17 Kaebuste menetlemise kord + kaebuse vorm
☐ Lisa 18 Põhiteabedokumendi hindamise kord
☐ Lisa 18.1 Põhiteabedokumendi vorm
☐ Lisa 19 Investeerimispiirangute kord
☐ Lisa 20 Makseteenuse pakkuja leping + kinnituskiri + registriväljavõte **(inglise keeles)**
☐ Lisa 20.1 Makseteenuse pakkuja tüüptingimused **(inglise keeles)**
☐ Lisa 21 Menetlustasu tasumise tõend

### Täiendavad dokumendid
☐ T1 Rahapesu tõkestamise kord
☐ T2 Investori kasutustingimused
☐ T3 Projektiomaniku leping
☐ T4 Veebilehe kohustuslik teave
☐ T5 Teadmiste testi küsimustepank
☐ T6 Tasustamise poliitika
☐ T7 Rikkumisest teavitamise kord
☐ T8 Registrite spetsifikatsioon

---

## B. Kohatäidete kontroll

☐ Otsi kogu paketist stringid `[` ja `]` — **ühtki kohatäidet ei tohi jääda**
☐ Otsi `XXX`, `TBD`, `TODO`, `[SUMMA]`, `[NIMI]`, `[KUUPÄEV]`
☐ Otsi `⚠️` — iga märgistus on kas lahendatud või teadlikult jäetud koos selgitusega põhitaotluse §-s 8

*Käsurea kontroll:*
```
grep -rn "\[.*\]" *.md | grep -v "^.*\[x\]" | wc -l    # peab olema 0
grep -rn "⚠️" *.md | wc -l                              # iga vaadatud üle
```

---

## C. Kooskõla kontroll

Iga fakt peab olema **identne** kõigis dokumentides. Kontrolli rida-realt.

| Fakt | Väärtus | Kontrollitud lisades |
|---|---|---|
| Ärinimi | | 01, kõik |
| Registrikood | | 01, kõik |
| Aadress | | 01, 02, 12, 16 |
| Veebisaidi domeen | | 01, 05, 17, T2, T4 |
| Osakapital | | 02, 03, 12 |
| Taotletavad teenused | | 01, 02, 05 |
| Instrumendi liik | | 05, 18.1, 19, T3 |
| Omavahendite summa | | 03, 05, 07 |
| Omavahendite nõue | | 03, 05, 06, 07 |
| Makseteenuse pakkuja nimi | | 05, 15, 16, 20, T2, T3 |
| Juhatuse liikmed | | 01, 04, 05, 12, 13 |
| Vastavusjuht | | 04, 06, 13 |
| Edukustasu % | | 05, 18.1, T3, T4 |
| Nimekirja lisamise tasu | | 05, 18.1, T3, T4 |
| Investorite tasud (0 €) | | 05, 18.1, T2, T4 |
| Turunduskanalid | | 05, 14 |
| Turustamise riigid | | 01, 05 |
| Edasiantud tegevused | | 05, 08, 10, 11, 15 |
| Säilitamistähtaeg (5 a) | | 04, 09, 17, 18, 19, T8 |
| Kaebustele vastamise tähtaeg | | 04, 17, T2, T4 |
| Järelemõtlemisaeg (4 kalendripäeva) | | 05, 18.1, 19, T2, T4, T5 |
| 5 mln euro piirmäär | | 04, 05, 18, 18.1, T3 |
| 10 000 € osakapitali nõue projektiettevõtjale | | 02, 05, 18.1, T3 |
| Varuteenindaja nimi | | 11, 15, T2 |

☐ **Rahavoo kirjeldus lisas 16 § 3 vastab täpselt makseteenuse lepingule (lisa 20)** — kõige sagedasem ebakõla
☐ Turundusplaan lisas 5 § 11 vastab sellele, mida ühing tegelikult teha kavatseb

---

## D. Sisulised kontrollid

☐ **Juhatuse kollektiivne sobivus** — kas vähemalt ühel liikmel on tõendatav finantssektori kogemus? Kui ei, **ärge esitage** enne lahendamist
☐ **Lisa 12 § 7 tabel** — kas iga ≥20% osaniku ja juhatuse liikme kontrollitav üksus on loetletud? Kas need on kantud sõela nimekirja?
☐ **Lisa 11 § 7.3 varuteenindaja** — kas leping on sõlmitud? Kui ei, kas põhitaotluse § 8 selgitab kava ja ajakava?
☐ **AIFMD õiguslik arvamus** — hangitud ja lisatud?
☐ **Art 10 lg 3 hoidmisanalüüs** — juristi kinnitatud?
☐ **Partnerprogrammi struktuur** — juristi kinnitatud, et fikseeritud tasu mudel ei kujuta endast tegevusloata vahendamist?
☐ Kas omavahendid katavad nõude **koos varuga** ega tugine kapitaliseeritud tarkvarale?
☐ Kas finantsprognoosis jäävad omavahendid igal ajal üle nõude, ka negatiivses stsenaariumis?

---

## E. Keel ja vorm

☐ Kogu pakett **eesti keeles**, v.a lisad 20 ja 20.1
☐ Terminoloogia ühtne kogu paketis (vt terminisõnastik)
☐ **„KIID“ ei esine kusagil** — üksnes „investeerimise põhiteabedokument“
☐ Tõlge kvalifitseeritud tõlkija poolt kinnitatud
☐ **Eesti finantsõiguse jurist on kogu paketi läbi vaadanud** ja ülevaatus on dokumenteeritud
☐ Digitaalallkirjad kehtivad ja õigete isikute poolt
☐ Failinimed selged; PDF-id loetavad; tabelid ei ole katkenud

---

## F. Õigusaktide viidete kontroll

☐ Kõik delegeeritud määruste numbrid kontrollitud Euroopa Liidu Teatajast
☐ ECSPR artiklinumbrid kontrollitud konsolideeritud tekstist
☐ Eesti õigusaktide sätete numbrid kontrollitud Riigi Teatajast
☐ **Finantsinspektsiooni järelevalvepoliitika juhend** läbi loetud ja pakett sellega kooskõlla viidud
☐ DORA kohaldumine kinnitatud
☐ RahaPTS-i praegune kohaldumine kinnitatud

---

## G. Esitamine

☐ Menetlustasu **1000 eurot** tasutud õigele kontole õige viitega
☐ Saaja, konto ja viide kontrollitud **vahetult enne maksmist** fi.ee-lt
☐ Maksekinnitus lisatud lisana 21
☐ Taotlusportaali [taotlus.fi.ee](https://taotlus.fi.ee/) konto loodud ja toimib
☐ Kõik failid üles laaditud
☐ **Esitatud paketi täielik koopia salvestatud** koos esitamise ajatempliga
☐ Esitamise kinnitus salvestatud

---

## H. Pärast esitamist

☐ **Nimeline vastutaja** määratud suhtluseks Finantsinspektsiooniga
☐ Vastamise siseeesmärk: **5 tööpäeva** iga teabenõude kohta
☐ Kirjavahetuse register avatud
☐ Juhatuse päevakorda lisatud alaline punkt „tegevusloa menetluse seis“
☐ Kalender: **25 tööpäeva** täielikkuse hindamiseks; **3 kuud** otsuseks täielikust taotlusest

> **Menetlusaeg peatub**, kui Finantsinspektsioon küsib lisateavet. Aeglane vastamine on ainus suurim kontrollitav menetluse pikenemise põhjus. Kolm nädalat vastuse koostamiseks tähendab kolm nädalat lisandunud menetlusaega.

---

## I. Ausus enda vastu

Enne saatmist küsi endalt kolm küsimust:

1. **Kas ma esitaksin selle paketi, kui teaksin, et seda loetakse kriitiliselt?** Kui vastus on „nad ilmselt ei märka“, on koht, mida mõeldakse, just see, mida parandada.
2. **Kas mõni dokument on täidetud vormi täitmise, mitte tegeliku töökorralduse pärast?** Finantsinspektsioon eristab neid. Poliitika, mida keegi ei kavatse järgida, on halvem kui puuduv poliitika.
3. **Kas ma tean, mida ma teen esimesel päeval pärast tegevusloa saamist?** Kui ei, ei ole pakett veel valmis — see kirjeldab ettevõtet, mida ei ole olemas.
