# Lisa 8 — Operatsiooniriski juhtimise kord

*ECSPR art 12 lg 2 p g — operatsiooniriskide kirjeldus. Kooskõlas määrusega (EL) 2022/2554 (DORA); ⚠️ kinnitada, kas kohaldub lihtsustatud IKT-riskijuhtimise raamistik.*

**Versioon:** 1.0 | **Vastutaja:** riskijuht | **Kinnitatud:** juhatus [KUUPÄEV]

---

## 1. Määratlus ja ulatus

Operatsioonirisk on kahju, kliendikahju või regulatiivse rikkumise risk, mis tuleneb ebapiisavatest või ebaõnnestunud sisemistest protsessidest, inimestest ja süsteemidest või välistest sündmustest. See hõlmab õigusriski ja IKT-riski. See ei hõlma strateegilist ja mainet puudutavat riski esmaste kategooriatena, kuigi mõlemad võivad tekkida tagajärgedena.

Ulatus: kõik [ETTEVÕTE OÜ] tegevused, sealhulgas funktsioonid, mida täidavad kolmandad isikud ühingu nimel.

## 2. Operatsiooniriski taksonoomia

### 2.1 Protsessirisk

| Viide | Riskisündmus | Tagajärg | Kontrollid |
|---|---|---|---|
| OP-P1 | Investoril lubatakse investeerida ilma kehtiva teadmiste testi või simulatsioonita | Art 21 rikkumine; kliendikahju | Süsteemne barjäär; 24 kuu kehtivus jõustatud; kvartaalne kontrolltest 25 juhtumil |
| OP-P2 | Järelemõtlemisaeg valesti arvutatud, lühendatud või raha vabastatud enneaegselt | Art 22 rikkumine; tehingu tagasipööramine | Serveripoolne UTC taimer kalendripäevades; raha vabastamine süsteemselt blokeeritud; käsitsi ülekirjutus üksnes kahekordse kinnituse ja vastavuskontrolli kandega |
| OP-P3 | Art 21 lg 7 piirmäära hoiatus jäetud kuvamata | Rikkumine; kliendikahju | Automaatne piirmäära arvutus; blokeeriv aken; nõusolek logitud sisu räsiga |
| OP-P4 | Põhiteabedokument avaldatud olulise puudusega | Art 23 rikkumine; pakkumise peatamine | Lisa 18 kontrollnimekiri; nelja silma põhimõte; versiooni lukustus avaldamisel; avamisjärgne seire |
| OP-P5 | Hoolsusmeetmete toimik puudulik nimekirja lisamisel | Art 5 rikkumine | Süsteem takistab avamist, kui kõik kohustuslikud tõendid ei ole üles laaditud ja vastavuskontroll kinnitanud |
| OP-P6 | Seotud isikust projektiomanik vastu võetud | Art 8 lg 2 rikkumine | Automaatne sõel osanike/juhatuse/töötajate registrite vastu koos käsitsi kinnitusega |
| OP-P7 | 5 mln euro piirmäär ületatud | Pakkumine väljaspool ECSPR-i ulatust | Kinnitus, sõltumatu kontroll, süsteemne kogusumma kontroll |
| OP-P8 | Osade emiteerimine või võõrandamine valesti registreeritud | Investor ei omanda omandiõigust | Nelja silma põhimõte registrikannetel; platvormi kirje võrdlemine äriregistri väljavõttega pärast sulgemist; investori kinnitus |
| OP-P9 | Raha tagastatakse valele investorile | Kahju; kaebus | Makseteenuse pakkuja tasandi kontode sobitamine; saaja käsitsi sisestamine keelatud; võrdlemine |
| OP-P10 | Turundusmaterjal avaldatud ilma kinnituseta | Art 27 rikkumine | Avaldamisõigused piiratud kinnitatud kasutajatega; register võrreldakse avaldatud materjalidega kvartaalselt |
| OP-P11 | Kaebus registreerimata või tähtaeg ületatud | Art 7 rikkumine | Ühtne postkast, mis loob automaatselt pileti; tähtaja taimerid; vanuse aruanne juhatusele igakuiselt |
| OP-P12 | Andmeid ei säilitata või ei ole leitavad | Art 26 rikkumine | Muutmatu lisanduv logi; iga-aastane otsingutest 10 kande alusel |

### 2.2 Inimrisk

| Viide | Risk | Kontrollid |
|---|---|---|
| OP-H1 | Võtmeisikust sõltuvus (juhatuse liige, tehnoloogiajuht, vastavusjuht) | Dokumenteeritud protseduurid iga kriitilise protsessi kohta; ühe omanikuga juhendeid ei ole; asendajad nimetatud lisas 11; ristkoolituse päevik |
| OP-H2 | Ebapiisav pädevus | Kohustuslik koolitus hindamisega; õigused peatatakse koolituse võlgnevuse korral |
| OP-H3 | Sisemine pettus või õiguste kuritarvitamine | Ülesannete lahusus; minimaalsete õiguste põhimõte; kahekordne kinnitamine maksetel ja ülekirjutustel; muutmatu logimine; isiklike tehingute kord; rikkumisest teavitamise kanal |
| OP-H4 | Lubamatu kõrvalekalle protseduurist | Kõik ülekirjutused nõuavad kahekordset kinnitust ja tekitavad vastavuskontrolli teavituse |
| OP-H5 | Töötaja lahkumine kriitilisel hetkel (pakkumise sulgemine) | Sulgemisjuhend, mida saab täita iga kaks koolitatud töötajat |

### 2.3 IKT- ja turvarisk

| Viide | Risk | Kontrollid |
|---|---|---|
| OP-T1 | Platvormi katkestus käimasoleva pakkumise ajal või sulgemisel | Mitme kättesaadavustsooniga majutus; seire; taasteaeg 4 h / andmekao piir 1 h; pakkumise perioodi dokumenteeritud pikendamine, kui katkestus mõjutas oluliselt osalemist, koos investorite teavitamisega |
| OP-T2 | Osaluse registri andmete rikkumine või kadu | Ajahetke varukoopiad iga [1] tunni järel; igapäevane koopia teise asukohta; kvartaalne taastetest; krüptograafiline räsiahel |
| OP-T3 | Küberrünne, konto ülevõtmine | Mitmeastmeline autentimine kohustuslik töötajatele ja pakutud investoritele; veebirakenduse tulemüür; päringute piiramine; saladuste haldus; kvartaalne haavatavuse skann; iga-aastane väline läbistustest |
| OP-T4 | KYC-teenuse integratsiooni tõrge | Dokumenteeritud käsitsi varulahendus vastavuskontrolli kinnitusega iga juhtumi kohta; teisene pakkuja hinnatud |
| OP-T5 | Makseteenuse integratsiooni tõrge | Vahendid jäävad igal juhul makseteenuse pakkuja juures kaitstuks; käsitsi võrdlemise kord; lepinguline teenustase ja eskaleerimine |
| OP-T6 | Vigane tootmiskeskkonna juurutus | Muudatuste haldus lisa 10 alusel; kohustuslik regressioonitestide komplekt kõigi investorikaitse barjääride kohta; reedeti juurutusi ei tehta; iga juurutuse juures tagasipööramise kava |
| OP-T7 | Isikuandmetega seotud rikkumine | Avastamine, tõkestamine, teavitus Andmekaitse Inspektsioonile 72 h jooksul, andmesubjektide teavitamine vajaduse korral (lisa 9) |

### 2.4 Kolmandate isikute risk
Vt lisa 15. Peamised: makseteenuse pakkuja, KYC-teenus, pilvemajutus, arendustöövõtja, raamatupidamisteenus. Iga on hinnatud, lepinguga tagatud auditiõigus ja väljumissätted ning tulemuslikkuse seire teenustaseme vastu.

### 2.5 Õigus- ja regulatiivse muutuse risk
Vastavuskontroll teostab õigusruumi seiret igakuiselt: ESMA väljaanded ja küsimused-vastused; Finantsinspektsiooni juhendid, otsused ja märgukirjad; ECSPR-i ja delegeeritud aktide muudatused; DORA ja rahapesu tõkestamise määruse rakendamine; Eesti õigusaktide muudatused. Olulised muudatused toovad kaasa mõjuhinnangu ja tähtajalise tegevuskava, mille kinnitab juhatus.

### 2.6 Väliste sündmuste risk
Ruumide kaotus; kommunaal- või ühendustõrge; pandeemia; tarnija maksejõuetus; sanktsioonid või geopoliitilised piirangud. Käsitletud lisas 11.

## 3. Riskide ja kontrollide enesehindamine

Teostatakse **poolaastas** iga funktsiooni poolt, riskijuhi juhtimisel.

Meetod: (1) kinnita protsesside loetelu; (2) tuvasta riskisündmused protsesside kaupa; (3) hinda algne risk; (4) tuvasta kontrollid ja hinda nende ülesehitus; (5) hinda toimimise tõhusus testimise ja intsidentide alusel; (6) määra jääkrisk; (7) lepi kokku tegevused vastutajate ja tähtaegadega; (8) esita juhatusele.

Kontrolli tõhusust ei tohi hinnata „tõhusaks“ ilma tõenditeta — kunagi testimata kontroll on parimal juhul „osaliselt tõhus“.

## 4. Intsidentide haldus

### 4.1 Liigitus

| Raskusaste | Määratlus | Teavitus | Reageerimine |
|---|---|---|---|
| **P1 kriitiline** | Investeerimisprotsess ei toimi; kliendi vahendid ohus; kinnitatud isikuandmete rikkumine; kinnitatud regulatiivne rikkumine kliendikahjuga | Juhatus kohe; Finantsinspektsioon kohe; Andmekaitse Inspektsioon 72 h jooksul | Kohe; uuendused iga tund |
| **P2 suur** | Oluline funktsioon halvenenud; võimalik regulatiivne rikkumine; turvaintsidendi kahtlus; oluline andmekvaliteedi tõrge | Juhatus 4 h jooksul; Finantsinspektsioon olulisuse korral | 4 h jooksul; uuendused iga päev |
| **P3 keskmine** | Lokaalne tõrge möödapääsulahendusega; protsessitõrge, mis mõjutab väheseid kliente | Riskijuht samal päeval | 1 tööpäeva jooksul |
| **P4 väike** | Kliendimõju puudub; kontroll tuvastas | Ainult logitakse | Järgmises väljalaskes |

### 4.2 Protsess
Avasta → registreeri intsidentide registris [1] tunni jooksul → liigita → tõkesta → hinda kliendimõju ja teavitamiskohustust (vastavuskontroll 2 tööpäeva jooksul) → kõrvalda → **algpõhjuse analüüs 5 tööpäeva jooksul P1/P2 puhul** → parandusmeetmed vastutajate ja tähtaegadega → sulge alles pärast tegevuste täitmist ja kontrollimist → esita juhatusele.

### 4.3 Intsidentide registri väljad
ID; avastamise kuupäev/kellaaeg; toimumise kuupäev/kellaaeg; avastaja; kirjeldus; raskusaste; mõjutatud süsteemid ja protsessid; mõjutatud kliendid (arv ja identiteet); rahaline mõju; regulatiivne rikkumine jah/ei ja säte; tehtud teavitused koos ajatemplitega; tõkestamismeetmed; algpõhjus; parandusmeetmed vastutaja ja tähtajaga; sulgemiskuupäev; õppetunnid; kas olemasolev kontroll ebaõnnestus ja milline.

### 4.4 Klientide heastamine
Kui kliendid kandsid kahju: tuvastatakse **kõik** mõjutatud kliendid (mitte üksnes kaebajad); määratakse asjakohane hüvitis; võetakse iga kliendiga proaktiivselt ühendust; hüvitis makstakse; kanne tehakse kaebuste ja intsidentide registrisse; esitatakse juhatusele. **Proaktiivne heastamine on kohustuslik** — kaebuste ootamine ei ole teadaoleva kontrollivea puhul aktsepteeritav reageering.

## 5. Kahjuandmed

Kõik operatsioonikahjud üle [250] euro ja kõik napipääsemised sõltumata väärtusest registreeritakse: kuupäev, kategooria, põhjus, brutokahju, tagasisaamised, netokahju ja seos riskiregistriga. Vaadatakse üle kvartaalselt trendi tuvastamiseks ja kasutatakse enesehindamise kalibreerimiseks.

## 6. Seos talitluspidevusega

Iga P1 intsident käivitab automaatselt hindamise talitluspidevuse kava (lisa 11) vastu. Kava käivitamine on juhatuse otsus; kui juhatust ei saa kokku kutsuda, võib iga juhatuse liige selle käivitada, kinnitusega 24 tunni jooksul.

## 7. Aruandlus

| Aruanne | Adressaat | Sagedus |
|---|---|---|
| Intsidentide kokkuvõte | Juhatus | Igakuine + kohe P1/P2 puhul |
| Kahjuandmed ja napipääsemised | Juhatus | Kvartaalne |
| Enesehindamise tulemused | Juhatus | Poolaastane |
| Kontrollide testimise tulemused | Juhatus | Kvartaalne |
| Operatsiooniriski ülevaade | Juhatus | Igakuine |
| Olulise intsidendi teavitus | Finantsinspektsioon | Viivitamata |

## 8. Peamised operatsiooniriski näitajad

| Näitaja | Roheline | Kollane | Punane |
|---|---|---|---|
| P1 intsidente kvartalis | 0 | 1 | >1 |
| P2 intsidente kvartalis | ≤1 | 2–3 | >3 |
| Platvormi käideldavus | >99,5% | 99,0–99,5% | <99,0% |
| Keskmine taasteaeg (P1) | <2 h | 2–4 h | >4 h |
| Ebaõnnestunud kontrollitestid | 0 | 1 | >1 |
| Tähtaja ületanud parandusmeetmed | 0 | 1–2 | >2 |
| Varukoopia taastetesti tulemus | Läbitud | Osaline | Ebaõnnestus |
| Süsteemse barjääri käsitsi ülekirjutused | 0 | 1–2 kvartalis | >2 kvartalis |

---
*Kinnitatud: [ETTEVÕTE OÜ] juhatus, [KUUPÄEV].*
