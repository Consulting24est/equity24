# Lisa 10 — IT-strateegia ja infosüsteemide kasutamise kord

*ECSPR art 12 lg 2 p f. Kooskõlas määrusega (EL) 2022/2554 (DORA) — ⚠️ kinnitada ulatus ja art 16 lihtsustatud IKT-riskijuhtimise raamistiku kohaldumine.*

**Versioon:** 1.0 | **Vastutaja:** tehnoloogiajuht | **Kinnitatud:** juhatus [KUUPÄEV]

---

## 1. Strateegia ja põhimõtted

Platvorm **on** reguleeritud teenus. Selle ülesehituse eesmärk on, et **vastavuskohustusi jõustab süsteem, mitte inimese hoolsus**. Iga investorikaitse nõue ECSPR artiklites 19, 21, 22 ja 23 on rakendatud serveripoolse barjäärina, millest ei saa mööda minna kasutajaliidese, töötaja ega klienditoe kaudu ilma kahekordse kinnituse ja püsiva logikandeta.

Põhimõtted: (1) regulatiivsed kontrollid koodis, mitte protseduuris; (2) auditeeritavus vaikimisi — iga klienti puudutav sündmus muutmatult logitud; (3) tõestatud tehnoloogia uudse asemel; (4) andmete asukoht EMP-s; (5) ükski sõltuvus, millest ühing ei saa [6] kuu jooksul väljuda; (6) turvalisus finantsteenuste platvormile, mitte sisulehele vastaval tasemel.

## 2. Arhitektuur

| Kiht | Komponent | Märkused |
|---|---|---|
| Esitluskiht | [React / Next.js] veebirakendus, responsiivne | Ühtki investeerimistoimingut ei saa täita kliendipoolselt |
| API | [Node.js / Python] REST API | Kogu autoriseerimine ja kõik regulatiivsed barjäärid jõustatakse serveripoolselt |
| Põhiteenused | Investoriteenus; hindamismootor; pakkumiste teenus; põhiteabedokumendi teenus; investeerimismootor; osaluste register; teavitusteenus; aruandlusteenus | Investeerimis- ja hindamismootor on eraldi juurutatavad ja eraldi testitavad |
| Andmed | [PostgreSQL] põhibaas lugemisrepliikaga; objektisalvestus dokumentidele; lisanduv sündmuslogi | Ainult EMP piirkond |
| Integratsioonid | [KYC-TEENUS]; [MAKSETEENUSE PAKKUJA]; ID-kaart / Smart-ID; e-äriregister; sanktsioonide sõel; e-post/SMS | Igal defineeritud tõrkerežiim |
| Taristu | [PILVETEENUS], EMP piirkond, mitu kättesaadavustsooni | Hallatud koodina |
| Seire | Mõõdikud, struktureeritud logid, jälgimine, hoiatused | Regulatiivsete barjääride mõõdikutel eraldi häired |

## 3. Regulatiivsete kontrollide rakendamine

| ECSPR nõue | Süsteemne rakendus | Test |
|---|---|---|
| Art 19 lg 6 riskihoiatus | Kuvatakse versioonihaldusega sisuhoidlast igal pakkumise vaatel; versioon ja ajatempel salvestatakse iga vaate kohta | Regressioon + kvartaalne valim |
| Art 21 lg 1–3 teadmiste test | Hindamismootor; tulemus ja kehtivus salvestatud; investeerimis-API lükkab tagasi iga päringu ilma kehtiva hinnanguta | Automaattest pidevintegratsioonis; kvartaalne kontrolltest |
| Art 21 lg 4 hoiatus testi mitteläbimisel | Blokeeriv aken; sõnaselge kinnitus salvestatud sisu räsiga | Automaatne |
| Art 21 lg 5 kahjumi simulatsioon | Arvutatakse deklareeritud finantsandmete alusel; 10% netovarast; tulemus salvestatud | Automaatne |
| Art 21 lg 6 kaheaastane ülevaatus | Kehtivusväli; automaatne uuendamise teade; investeerimine blokeeritud pärast kehtivuse lõppu | Automaatne |
| Art 21 lg 7 piirmäär | Serveripoolne võrdlus suuremaga (1000 eurot; 5% deklareeritud netovarast), agregeeritult investori investeeringute lõikes ⚠️; blokeeriv hoiatus; sõnaselge nõusolek arusaamise tõendiga | Automaatne + kvartaalne test |
| Art 22 järelemõtlemisaeg | Serveripoolne taimer, 4 kalendripäeva, UTC; taganemise lõpp-punkt kättesaadav kogu perioodi; raha vabastamine blokeeritud kuni lõpuni | Automaatne + kvartaalne täisvalimi ülevaatus |
| Art 23 põhiteabedokument | Versioonihaldusega dokument; avaldamine blokeeritud ilma registreeritud vastavuskontrolli kinnituseta; iga investorile kuvatud versioon salvestatakse investeeringu juurde | Automaatne |
| Art 25 teatetahvel | Üksnes kuulutuste kirjed. **Sobitusmootorit, korralduste raamatut ega täitmise teed koodibaasis ei ole.** Viitehind kuvatakse mittesiduva märkusega | Iga-aastane arhitektuuriülevaatus |
| Art 26 andmed | Lisanduv sündmuslogi; 5-aastane säilitamine; otsingu-API | Iga-aastane otsingutest |
| Art 27 turundus | Avaldamisõigused piiratud; iga materjali kirje juures nõutav kinnituse viide | Kvartaalne võrdlemine |
| Art 8 lg 2 seotud isikud | Sõelteenus osanike, juhatuse ja töötajate registrite vastu projektiomaniku vastuvõtmisel ja uuesti enne avamist | Pakkumise kohta |
| 5 mln euro piirmäär | Kogusumma kontroll projektiomaniku lõikes jooksva 12 kuu kohta; range blokk | Pakkumise kohta |

**Ülekirjutuste kontroll.** Iga regulatiivse barjääri käsitsi ülekirjutus nõuab kahte volitatud kasutajat ja kohustuslikku vabatekstilist põhjendust, tekitab kohese teavituse vastavuskontrollile ning esitatakse juhatusele igakuiselt. Eesmärk on null ülekirjutust; üle kahe kvartalis on punane riskinäitaja.

## 4. Muudatuste haldus

| Etapp | Nõue |
|---|---|
| Taotlus | Pilet äriliste põhjendustega; regulatiivse mõju märgistus |
| Regulatiivne hinnang | Iga muudatus, mis puudutab investeerimisprotsessi, hindamismootorit, põhiteabedokumendi käsitlust, tasusid, riskihoiatusi või teatetahvlit, nõuab **vastavuskontrolli kirjalikku kinnitust enne arendust** |
| Arendus | Eraldi haru; otsekandeid põhiharusse ei tehta; saladusi koodis ei hoita |
| Ülevaatus | Kohustuslik kaasülevaatus; regulatiivselt mõjukate muudatuste puhul teine ülevaataja vastavuskontrollist |
| Testimine | Ühik-, integratsiooni- ja **kohustuslik regulatiivne regressioonikomplekt**, mis katab iga § 3 barjääri. Ebaõnnestunud regulatiivne test blokeerib väljalaske absoluutselt — erandeid ei tehta |
| Testkeskkond | Juurutatakse sünteetiliste andmetega; kasutaja aktsepteerimistesti kinnitus |
| Kinnitamine | Tehnoloogiajuht ning regulatiivselt mõjukate muudatuste puhul vastavuskontroll |
| Väljalase | Planeeritud aknad; mitte reedeti ega viimasel tööpäeval enne pakkumise sulgemist; tagasipööramise kava dokumenteeritud |
| Väljalaskejärgne | Seire [24] tundi; mõjutatud barjääride kontroll tootmiskeskkonnas testkonto abil |
| Erakorraline | Lubatud P1 intsidentide puhul; tagantjärele kinnitamine ja täielik dokumenteerimine 1 tööpäeva jooksul |

Kõik muudatused logitakse koos autori, ülevaataja, kinnitaja, pileti, juurutusaja ja tagasipööramise olekuga; säilitatakse 5 aastat.

## 5. Juurdepääsu haldus

| Kontroll | Standard |
|---|---|
| Andmine | Rollipõhine; kinnitab otsene juht ja tehnoloogiajuht; minimaalsed õigused |
| Autentimine | Mitmeastmeline autentimine kohustuslik kõigile töötajatele ja töövõtjatele; ühekordne sisselogimine võimaluse korral; investoritele pakutud ja soovitatud |
| Privilegeeritud juurdepääs | Ainult nimelised kontod; õiguste ajutine tõstmine põhjendusega; täielikult logitud; ülevaatus kord kuus |
| Tootmisandmed | Juurdepääs nõuab piletit ja kinnitust; ajaliselt piiratud; kõik päringud logitakse |
| Ülevaatus | Poolaastane täielik juurdepääsu ülevaatus; kohene rolli muutumisel |
| Tühistamine | Samal päeval lahkumisel, kontrollnimekirja alusel |
| Teenuskontod | Dokumenteeritud omanik; volitused saladuste halduris; rotatsioon [kord aastas] |

## 6. Lubatud kasutus

Ühingu süsteemid on äriliseks kasutuseks. Keelatud: volituste jagamine; kinnitamata tarkvara paigaldamine; piiratud andmete salvestamine isiklikesse seadmetesse või kinnitamata pilveteenustesse; isikliku e-posti või sõnumirakenduste kasutamine kliendisuhtluses; turvakontrollide väljalülitamine; kliendiandmetele juurdepääs ilma ärivajaduseta. Kogu kliendisuhtlus toimub ühingu süsteemide kaudu, et see jäädvustuks art 26 andmestikku. Rikkumine on distsiplinaarrikkumine.

## 7. Talitluspidevus ja vastupidavus

| Näitaja | Eesmärk |
|---|---|
| Käideldavus (investeerimisprotsess) | 99,5% kuus |
| Taasteaeg — investeerimisprotsess | 4 tundi |
| Andmekao piir — kõik kliendiandmed | 1 tund |
| Taasteaeg — aruandlus ja tugiprotsessid | 24 tundi |
| Varukoopiate sagedus | Pidev logipõhine + tunnine hetktõmmis |
| Varukoopiate säilitamine | 35 päeva ajahetke taastet; kuine arhiiv 7 aastat |
| Koopia teises asukohas | Igapäevane, eraldi EMP piirkond |
| Taastetest | **Kvartaalne, dokumenteeritud, tulemused juhatusele** |
| Tõrkesiirde test | Kord aastas |

Testimata varukoopia ei ole varukoopia. Kvartaalne taastetest mõõdab tegelikku taasteaega ja andmete täielikkust ning selle tulemus on juhatusele raporteeritav riskinäitaja.

## 8. Turvalisus

- Turvaline arendus: OWASP Top 10 kontrollid; sõltuvuste skaneerimine pidevintegratsioonis; staatiline analüüs; saladusi versioonihaldusse ei salvestata.
- Haavatavuste haldus: automaatne skaneerimine [nädalane]; kriitilised kõrvaldatakse [7] päeva, kõrged [30] päeva, keskmised [90] päeva jooksul.
- Läbistustestid: **kord aastas sõltumatu ettevõtte poolt**, samuti enne iga suuremat arhitektuurimuudatust. Aruanne ja kõrvaldamise kava juhatusele.
- Seire: häired autentimise anomaaliate, õiguste tõstmise, massilise andmetele juurdepääsu ja regulatiivse barjääri iga tõrke korral.
- Intsidentidele reageerimine: lisa 8 § 4 kohaselt; turvaintsidendid järgivad lisaks tõkestamise/likvideerimise/taastamise järjestust ja käivitavad lisa 9 rikkumise protsessi, kui isikuandmed on kaasatud.

## 9. Kolmandate isikute IKT

| Pakkuja | Teenus | Kriitilisus | Väljumine |
|---|---|---|---|
| [PILVETEENUS] | Majutus | Kriitiline | Ainult standardteenused; taristu koodina teisaldatav; [6] kuu väljumiskava |
| [MAKSETEENUSE PAKKUJA] | Maksed ja kaitsemeetmed | Kriitiline | Alternatiivne pakkuja hinnatud; vahendid kaitstud sõltumatult |
| [KYC] | Isiku tuvastamine | Kõrge | Käsitsi varulahendus dokumenteeritud; teisene pakkuja hinnatud |
| [ARENDUSPARTNER] | Arendus | Kõrge | Lähtekood ühingu enda hoidlas; täielik dokumentatsioon; teadmiste ülekande klausel |
| [SEIRE] | Seire | Keskmine | Asendatav |

Iga on registreeritud kolmandate isikute registris (lisa 15) koos lepingu viite, töödeldavate andmete, asukoha, teenustaseme, auditiõiguste, väljumissätete ja viimase hindamise kuupäevaga. ⚠️ *DORA nõuab IKT-lepingute registrit ettenähtud vormis — kinnitada kohalduv vorm.*

## 10. Lähtekood ja intellektuaalomand

Kogu lähtekood kuulub ühingule ja seda hoitakse ühingu enda hoidlates tema enda kontode all. Töövõtulepingud loovutavad intellektuaalomandi tingimusteta. [Kvartaalne] tervikliku koodibaasi, taristu määratluste ja juurutamisdokumentatsiooni arhiiv hoitakse [teises asukohas / deponeerituna] ja see on lisa 11 tegevuse lõpetamise kava nimeline sõltuvus.

## 11. Dokumentatsioon

Hoitakse ajakohasena: arhitektuuriskeem ja andmevood; andmebaasi struktuur; API dokumentatsioon; juhendid iga kriitilise toimingu kohta (pakkumise sulgemine, taganemise menetlemine, võrdlemine, intsidentidele reageerimine, taastamine); § 3 regulatiivsete kontrollide maatriks; kolmandate isikute register; muudatuste logi. Dokumentatsiooni ajakohasust kontrollitakse igal poolaastasel enesehindamisel — dokumenteerimata kriitilised protsessid registreeritakse inimriski leiuna.

## 12. Aruandlus juhatusele

Igakuiselt: käideldavus, intsidendid, barjääride ülekirjutuste arv, olulised turvahoiatused. Kvartaalselt: haavatavuste seis, taastetesti tulemus, juurdepääsu ülevaatuse tulemus, muudatuste maht ja ebaõnnestumiste määr. Kord aastas: läbistustesti leiud, IT-strateegia ülevaatus, kolmandate isikute hindamised.

---
*Kinnitatud: [ETTEVÕTE OÜ] juhatus, [KUUPÄEV].*
