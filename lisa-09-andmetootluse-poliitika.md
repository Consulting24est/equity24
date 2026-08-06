# Lisa 9 — Andmete haldamise ja töötlemise poliitika

*ECSPR art 12 lg 2 p f — andmetöötlussüsteemide kontrolli- ja kaitsesüsteemide, vahendite ja protseduuride kirjeldus. Rakendab ka määrust (EL) 2016/679 (isikuandmete kaitse üldmäärus) ja isikuandmete kaitse seadust.*

**Versioon:** 1.0 | **Vastutaja:** andmekaitsespetsialist | **Kinnitatud:** juhatus [KUUPÄEV]

---

## 1. Ulatus ja rollid

Kohaldub kõigile [ETTEVÕTE OÜ] töödeldavatele andmetele mis tahes kujul ja mis tahes isiku poolt, kes tegutseb ühingu nimel.

- **Vastutav töötleja:** [ETTEVÕTE OÜ], registrikood [REG NR], [AADRESS].
- **Andmekaitsespetsialist:** [NIMI / FIRMA], [E-POST]. ⚠️ *Hinnata, kas määramine on kohustuslik üldmääruse art 37 alusel; ühing määrab spetsialisti igal juhul vabatahtlikult.*
- **Järelevalveasutus:** Andmekaitse Inspektsioon.

## 2. Andmete liigitus

| Klass | Määratlus | Näited | Käitlemine |
|---|---|---|---|
| **Piiratud** | Avalikustamine tekitaks tõsist kahju | Isikut tõendavad dokumendid, netovara deklaratsioonid, teadmiste testi tulemused, vahendite päritolu tõendid, pangaandmed, projektiomanike karistusregistri andmed | Krüpteeritud puhkeolekus ja edastamisel; juurdepääs üksnes dokumenteeritud ärivajadusel; kogu juurdepääs logitakse; eksport üksnes andmekaitsespetsialisti loal; mitte kunagi e-postis |
| **Konfidentsiaalne** | Sisemine, avalikustamine kahjulik | Investorite kontaktandmed, investeeringute andmed, mitteavalikud hoolsusmeetmete andmed, juhatuse protokollid, intsidentide kanded | Krüpteeritud; rollipõhine juurdepääs; logitakse |
| **Sisemine** | Ei ole avalikuks kasutamiseks | Protseduurid, sisearuanded, projektide nimekiri | Rollipõhine juurdepääs |
| **Avalik** | Mõeldud avaldamiseks | Veebisaidi sisu, avaldatud põhiteabedokumendid, kinnitatud turundusmaterjal | Piiranguid ei ole; kohalduvad terviklikkuse kontrollid |

## 3. Isikuandmete töötlemise toimingute register (üldmääruse art 30)

| Toiming | Andmesubjektid | Kategooriad | Õiguslik alus | Säilitamine |
|---|---|---|---|---|
| Investorite registreerimine ja tuvastamine | Investorid | Nimi, sünniaeg, isikut tõendav dokument, aadress, kodakondsus, kontakt, riikliku taustaga isiku ja sanktsioonide sõela tulemused | Art 6 lg 1 p b leping; art 6 lg 1 p c juriidiline kohustus | 5 aastat suhte lõppemisest (ECSPR art 26); pikem, kui rahapesu tõkestamise õigus nõuab ⚠️ |
| Investori hindamine (teadmiste test, simulatsioon, netovara) | Investorid | Finantsolukord, sissetulek, varad, kohustused, investeerimiskogemus, testivastused | Art 6 lg 1 p c — ECSPR art 21 | 5 aastat suhte lõppemisest |
| Investeerimistehingud ja nõusolekud | Investorid | Summad, ajatemplid, kuvatud hoiatused, nõusolekud, järelemõtlemisaja sündmused, osalused | Art 6 lg 1 p b, p c | 5 aastat suhte lõppemisest |
| Projektiomanike hoolsusmeetmed | Projektiomanike juhatuse liikmed ja kasusaajad | Isikuandmed, **karistusregistri andmed**, finants- ja äriteave, meediakajastus | Art 6 lg 1 p c — ECSPR art 5; **üldmääruse art 10** karistusandmete puhul ⚠️ | 5 aastat pakkumise sulgemisest |
| Kaebuste menetlemine | Kaebajad | Kaebuse sisu, kirjavahetus, tulemus | Art 6 lg 1 p c — ECSPR art 7 | 5 aastat sulgemisest |
| Turundus võimalikele klientidele | Potentsiaalsed kliendid | Kontaktandmed, kaasatus | Art 6 lg 1 p a nõusolek või p f õigustatud huvi ettevõtetevahelise suhtluse puhul ⚠️ | Kuni vastuväiteni; nõusoleku kanded 3 aastat |
| Töötajate ja töövõtjate haldus | Töötajad | Tavapärased personaliandmed | Art 6 lg 1 p b, p c | Eesti tööõiguse kohaselt |
| Turvalisus ja juurdepääsu logimine | Kõik kasutajad | IP, seade, sessioon, toimingud | Art 6 lg 1 p f õigustatud huvi; p c | [12] kuud, pikem intsidendiga seotud juhul |

**Eriliigilised ja karistusandmed.** Projektiomanike juhatuse liikmete ja tegelike kasusaajate karistusregistri andmeid töödeldakse üldmääruse art 10 alusel, tuginedes ECSPR art 5 lg 2 p a juriidilisele kohustusele. ⚠️ *Kinnitada juristiga selle töötluse riigisisene õiguslik alus enne esimese projektiomaniku vastuvõtmist — see on tegelik vastavuseeldus, mitte formaalsus.* Sellised andmed on piiratud klassis, hoitakse eraldi kuni [3] nimelise isiku juurdepääsuga ja kustutatakse säilitustähtaja saabudes eranditult.

## 4. Andmekaitse põhimõtete rakendamine

| Põhimõte | Rakendamine |
|---|---|
| Seaduslikkus, õiglus, läbipaistvus | Privaatsusteade igas kogumispunktis selges keeles; kihiline teade platvormil; kogumist ei toimu ilma nimetatud eesmärgita |
| Eesmärgi piirang | Investori hindamiseks kogutud andmeid kasutatakse **üksnes** hindamiseks ja regulatiivseks säilitamiseks — mitte kunagi turundussegmentimiseks ega hinnastamiseks |
| Võimalikult väheste andmete kogumine | Netovara kogutakse **vahemikena**, mitte täpsete summadena, kui vahemik on art 21 lg 5 ja lg 7 arvutuste jaoks piisav; isikut tõendavaid dokumente ei säilitata pärast kontrolli, kui KYC-teenus neid lepingu alusel säilitab |
| Õigsus | Investorid saavad oma andmeid vaadata ja parandada; teadmiste test ja finantsandmed uuendatakse seaduses ettenähtud ülevaatuspunktides |
| Säilitamise piirang | Automatiseeritud säilitusgraafik kustutustöödega; säilitatud andmete iga-aastane ülevaatus |
| Usaldusväärsus ja konfidentsiaalsus | Vt § 6 |
| Vastutus | Käesolev poliitika, töötlemistoimingute register, mõjuhinnangud, koolituspäevik ja andmekaitsespetsialisti aastaaruanne juhatusele |

## 5. Andmesubjekti õigused

| Õigus | Menetlus | Tähtaeg |
|---|---|---|
| Juurdepääs | Kontrollitud taotlus aadressile info@equity24.io; isik tuvastatakse; andmed kogutakse kõigist süsteemidest juhendi alusel | 1 kuu, pikendatav 2 kuu võrra |
| Parandamine | Iseteenindus võimaluse korral; muul juhul taotluse alusel | 1 kuu |
| Kustutamine | Hinnatakse **ülekaaluka säilituskohustuse vastu ECSPR art 26 ja rahapesu tõkestamise õiguse alusel** — investeerimis- ja hindamisandmeid ei saa säilitustähtaja jooksul üldjuhul kustutada; taotlejale selgitatakse seda ja põhjust | 1 kuu |
| Piiramine | Märgistus rakendatakse; töötlemine piiratud säilitamisega | 1 kuu |
| Ülekantavus | Masinloetav eksport andmete kohta, mille subjekt on esitanud lepingu või nõusoleku alusel | 1 kuu |
| Vastuväide | Turundusvastuväide täidetakse kohe ja jäädavalt | Kohe |
| Automatiseeritud otsused | Investorite liigitus ja art 21 barjäärid on **reeglipõhised, mitte profiilianalüüs**; tulemusi selgitatakse investorile ja need vaadatakse taotluse korral inimese poolt üle | — |

Kõik taotlused registreeritakse koos kuupäevade, tegevuste ja tulemusega ning esitatakse juhatusele kvartaalselt.

## 6. Turvakontrollid

**Juurdepääs.** Rollipõhine, minimaalsete õiguste põhimõttel. Antakse üksnes dokumenteeritud kinnitusel; vaadatakse üle **poolaastas** ja kohe rolli muutumisel või lahkumisel. Mitmeastmeline autentimine kohustuslik kõigile töötajatele. Jagatud kontosid ei kasutata. Tootmisandmetele juurdepääs nõuab nimelist kinnitust ja logitakse täielikult. Lahkumine käivitab õiguste tühistamise samal päeval.

**Krüpteerimine.** TLS 1.2+ edastamisel. AES-256 puhkeolekus kõigi piiratud ja konfidentsiaalsete andmete puhul. Andmebaasi tasandi krüpteerimine isikut tõendavatele dokumentidele ja finantsdeklaratsioonidele. Võtmeid hallatakse [võtmehaldusteenuses], rotatsioon [kord aastas], juurdepääs eraldi andmetele juurdepääsust.

**Võrk.** Segmenteeritud keskkonnad (tootmine / testimine / arendus). Tootmisandmeid ei kasutata mittetootmiskeskkondades — testandmed on sünteetilised või pöördumatult anonüümitud. Veebirakenduse tulemüür, päringute piiramine, teenusetõkestusründe kaitse. Halduslik juurdepääs üksnes [VPN / bastioni] kaudu.

**Logimine.** Lisanduvad, võltsimiskindlad logid: autentimine, juurdepääs piiratud andmetele, kõik muudatused investorite kirjetes, kõik investeerimisprotsessi sündmused (kuvatud hoiatused, nõusolekud, järelemõtlemisaja algus/lõpp, taganemine), kõik halduslikud ülekirjutused. Logisid säilitatakse § 3 kohaselt ja ükski käidufunktsioon ei saa neid muuta.

**Lõppseadmed.** Täisketta krüpteerimine, ekraanilukk, hallatud paigad, lõppseadmekaitse, kaugkustutus. Piiratud andmeid ei salvestata lokaalselt.

**Partnerid.** Isikuandmeid ei jagata ilma kirjaliku volitatud töötleja lepinguta (art 28), dokumenteeritud edastamismehhanismita ja turvahinnanguta (lisa 15).

**Testimine.** Kvartaalne automaatne haavatavuse skaneerimine; iga-aastane väline läbistustest; kriitiliste leidude kõrvaldamine [7] päeva jooksul, kõrgete [30] päeva jooksul.

## 7. Rahvusvahelised edastused

Isikuandmeid töödeldakse vaikimisi Euroopa Majanduspiirkonnas. Kui volitatud töötleja tegutseb väljaspool EMP-d, toimub edastamine üksnes kaitse piisavuse otsuse või lepingu tüüptingimuste alusel, mida toetab edastamise mõjuhinnang. Edastuste registris on loetletud töötleja, riik, mehhanism, andmekategooriad ja hindamise kuupäev.

## 8. Andmekaitsealased mõjuhinnangud

Mõjuhinnang teostatakse enne: platvormi käivitamist; finants- või karistusandmete uut töötlemist; investoreid mõjutava automatiseeritud otsuse kasutuselevõttu; iga uut olulist volitatud töötlejat; iga uut rahvusvahelist edastust. Mõjuhinnangud kinnitab andmekaitsespetsialist ja suure jääkriski korral konsulteeritakse järelevalveasutusega.

## 9. Isikuandmetega seotud rikkumine

1. **Avastamine ja tõkestamine** — kohe, tuvastaja poolt, eskaleerides andmekaitsespetsialistile ja tehnoloogiajuhile.
2. **Hindamine** — andmekaitsespetsialist otsustab [24] tunni jooksul, kas esineb oht õigustele ja vabadustele.
3. **Teavitada Andmekaitse Inspektsiooni 72 tunni jooksul** teadasaamisest, kui oht ei ole ebatõenäoline.
4. **Teavitada andmesubjekte põhjendamatu viivituseta**, kui oht on suur, selges keeles ja koos leevendusnõuannetega.
5. **Teavitada Finantsinspektsiooni**, kui rikkumine on ka oluline tegevus- või turvaintsident.
6. **Registreerida** iga rikkumine rikkumiste registris, sh need, millest ei teavitatud, koos põhjendusega.
7. **Kõrvaldada ja üle vaadata** — algpõhjuse analüüs, parandusmeetmed, kontrollide muutmine.

## 10. Andmete kvaliteet ja terviklikkus

Investorite ja osaluste andmed on ühingu tundlikeim andmestik. Kontrollid: sisendi valideerimine igas sisestuspunktis; viiteterviklikkus andmebaasis; igapäevane platvormi osaluste võrdlemine makseteenuse pakkuja teatatud positsiooniga ja pärast sulgemist äriregistri väljavõttega; igakuine andmekvaliteedi aruanne (kohustuslike väljade täidetus, dubleerimine, aegunud hinnangute arv); nelja silma põhimõte iga käsitsi paranduse puhul investori osaluses koos põhjuse logimisega.

## 11. Säilitamine ja hävitamine

Automatiseeritud säilitusgraafik § 3 kohaselt. Kustutamine on jäädav ja hõlmab varukoopiaid [90] päeva jooksul kustutuskuupäevast. Paberkandjad hävitatakse. Peetakse kustutuslogi. **Õiguslik ootamiskohustus** tühistab kustutamise, kui on pooleli kohtuvaidlus, järelevalvemenetlus või kaebus; ootamiskohustuse kehtestab ja lõpetab andmekaitsespetsialist juhatuse teavitamisega.

## 12. Koolitus ja vastutus

Kõik töötajad läbivad andmekaitse koolituse tööle asumisel ja kord aastas. Piiratud andmetele juurdepääsuga töötajad läbivad täiendava koolituse. Andmekaitsespetsialist annab juhatusele vähemalt kord aastas aru: töötlemistoimingute register, andmesubjektide taotlused, rikkumised, mõjuhinnangud, koolituse läbimine, partnerite hindamised ja avatud riskid.

---
*Kinnitatud: [ETTEVÕTE OÜ] juhatus, [KUUPÄEV].*
