# Lisa 5 §6.3 (esindajastruktuur / AureviaFund) — verification record
### Two-agent adversarial review, 2026-08-06 · all fixes below are INCORPORATED in the filed §6.3 text

## ECSPR-accuracy critic (verified against CELEX 32020R1503 ET/EN, ESMA Q&A ESMA35-42-1088, ESMA_QA_2601)

**BLOCKER** — 6.3.6, lause: "platvormil pakutavaid OÜ osasid ei registreerita finantsinstrumentide kontol ega saa füüsiliselt hoidjale üle anda"

- Problem: Misstates the art 10(3) test. The regulation's ET text reads: instrumente, "mida SAAB registreerida INVESTORI NIMEL AVATUD finantsinstrumentide kontol või mida saab füüsiliselt üle anda KONTOHALDURILE". (1) The test is capability ("saab registreerida"), not current fact ("ei registreerita") — Estonian OÜ osad CAN optionally be registered in the Eesti väärtpaberite register, after which they sit on securities accounts, so FI can attack the carve-out as drafted; (2) the draft drops the qualifier "investori nimel avatud"; (3) "hoidjale" is not the regulation's term ("kontohaldurile"); (4) the argument ignores its strongest authorities — Recital 28 (instruments that under national law are registered only with the project owner or its agent, e.g. investments in non-listed companies, are subject to ownership verification and record-keeping, "peetakse samaväärseks vara hoidmisega kvalifitseeritud kontohaldurite poolt") and ESMA Q&A 3.3 (ESMA35-42-1088), which confirms exactly this reading.
- Fix applied: Asendada esimene lause: "Määruse artikli 10 lõike 3 hoidmiskohustus kohaldub üksnes instrumentidele, mida saab registreerida investori nimel avatud finantsinstrumentide kontol või mida saab füüsiliselt üle anda kontohaldurile. Platvormil pakutavad projektiettevõtja osad ei ole registreeritud Eesti väärtpaberite registris ja nende registreerimine seal on platvormil osalemise tingimustega välistatud (T3); pakkumise esemeks olevas vormis ei saa neid registreerida investori nimel avatud finantsinstrumentide kontol ega füüsiliselt kontohaldurile üle anda, kuna osa ei ole väärtpaberitõendiga kehastatud. Määruse põhjenduse 28 kohaselt peetakse selliste instrumentide hoidmist, mis riigisisese õiguse kohaselt on registreeritud üksnes projektiomaniku või tema esindaja juures (osanike nimekiri), samaväärseks vara hoidmisega kvalifitseeritud kontohaldurite poolt ning nende suhtes kohaldatakse omandiõiguse kontrollimist ja arvestuse pidamist (§ 6.3.4); sama kinnitab ESMA vastus 3.3 (ESMA35-42-1088). Kui projektiettevõtja osad registreeritaks väärtpaberite registris, kohalduks artikli 10 lõige 3 täies ulatuses; platvorm sellist projektiettevõtjat esindajastruktuuris ei aktsepteeri."

**MAJOR** — 6.3.1 "kes hoiab osasid investorite arvel"; 6.3.1 "ei koorma hoitavaid osasid"; 6.3.5 "Esindaja arvel hoitavad osad hoitakse"

- Problem: Internal contradiction with 6.3.6. Art 10(3) second sentence attaches the authorisation duty to "hoidmisteenust osutav üksus" ("An entity providing custody services shall hold an authorisation..."). The draft denies in 6.3.6 that the esindaja provides hoidmisteenus, yet describes the esindaja throughout with the verb "hoidma" — self-labelling that invites FI to requalify the activity under art 10(3) sentence 2.
- Fix applied: Läbiv terminoloogiavahetus: 6.3.1: "— kellele osad kuuluvad investorite arvel esinduslepingu alusel"; "ei koorma investorite arvel omatavaid osasid"; 6.3.5: "Esindajale investorite arvel kuuluvaid osasid kajastatakse esindaja oma varast arvestuslikult ja lepinguliselt lahus". Sõna "hoidmine" jätta üksnes § 6.3.6 õigusliku testi käsitlusse.

**MAJOR** — 6.3.3(a) "kantakse investorile üle makseteenuse pakkuja kaudu viivitamata pärast laekumist"

- Problem: Ambiguous fund flow with licensing exposure. If dividends/liquidation proceeds first land on the esindaja's own account (the esindaja is the legal osanik, so this is the default), the esindaja handles client funds — a payment service under Directive (EU) 2015/2366 Annex I (money remittance), for which neither the esindaja nor the taotleja is authorised; 6.3.6 analyses only instrument custody, not funds. Art 10(5) requires that the projektiomanik makes "funding ... or any other payment" ("või muid makseid") only via an authorised payment service provider — which covers dividend payments.
- Fix applied: Asendada: "Dividendid, likvideerimisjaotis ja muud väljamaksed maksab projektiettevõtja investoritele otse direktiivi (EL) 2015/2366 kohase makseteenuse pakkuja kaudu, esindaja edastatud jaotusandmete alusel; esindaja ei võta investorite rahalisi vahendeid vastu ega hoia neid ühelgi hetkel oma kontol (määruse art 10 lg 5)."

**MAJOR** — 6.3.6 järeldus "ei osuta esindaja taotleja hinnangul sellist hoidmisteenust, mis eeldaks tegevusluba" koos 6.3.7 avalikustamisloeteluga

- Problem: The blanket denial overshoots and misses a positive art 10(1) duty. Under Recital 28 and ESMA Q&A 3.3, the register-keeping over unregistered instruments is "omandiõiguse kontrollimine ja arvestuse pidamine" — a form of vara hoidmise teenus considered equivalent to qualified custody, and where such safekeeping is provided, art 10(1) obliges the CSP to inform clients of the nature and terms of the service, references to applicable national law, and whether it is provided directly or by a third party. 6.3.7's disclosure list contains none of these art 10(1) items. Also art 25(4) presupposes this qualification (ownership-change notification duty applies to CSPs "kes osutavad vara hoidmise teenuseid vastavalt artikli 10 lõikele 1").
- Fix applied: Lisada 6.3.6 lõppu: "Samas käsitab taotleja esindaja registripidamist omandiõiguse kontrollimise ja arvestuse pidamisena põhjenduse 28 tähenduses ning täidab artikli 10 lõike 1 teavitamiskohustust: investorile esitatakse teenuse laad ja tingimused, viited kohaldatavale riigisisesele õigusele (äriseadustik, võlaõigusseadus) ning teave, et arvestust peab kolmas isik — esindaja." 6.3.7 loetellu lisada vastav punkt.

**MAJOR** — 6.3.1/6.3.10 — esindaja kui taotleja tütarettevõtja; lisa 14 viide "esindaja kui seotud isik"

- Problem: Art 8(1) is unaddressed: "Ühisrahastusteenuse osutaja ei või omada osalust üheski oma ühisrahastusplatvormil olevas ühisrahastuspakkumises." A 100% subsidiary of the taotleja becoming the registered osanik of every projektiettevõtja is, prima facie, the taotleja indirectly holding a participation in every offer on its own platform. The section never argues why nominee legal title held for investors' account is not "osaluse omamine" within art 8(1); FI will certainly raise it, and the unresolved TÄPSUSTADA (tütarettevõtja vs kontserni üksus) must be decided with this provision in view.
- Fix applied: Lisada (nt 6.3.6 või uue alapunktina): "Esindaja omandab osad üksnes investorite arvel ja nende juhiste alusel ega investeeri oma, taotleja ega kontserni arvel; esindajal puudub majanduslik huvi pakkumiste suhtes. Taotleja hinnangul ei ole tegemist osaluse omamisega ühisrahastuspakkumises määruse artikli 8 lõike 1 tähenduses; analüüs on esitatud lisas 14."

**MAJOR** — 6.3.5 "Esindaja maksejõuetuse ... korral antakse osad üle investoritele endile või asendusesindajale" ja 6.3.7

- Problem: Overpromise stated as fact. Estonian law has no general trust regime; assets titled to the esindaja prima facie fall into its pankrotivara, and the esindajakonto protections of the securities-register regime deliberately do not apply here (the osad are unregistered — that is the very premise of 6.3.6). A contractual transfer clause does not bind a pankrotihaldur. The creditor-claims opinion placeholder gates one sentence, but the insolvency transfer mechanism is asserted unconditionally, and the residual risk is not routed into investor disclosure (KIIS risk factors).
- Fix applied: Sõnastada: "Esindaja maksejõuetuse korral kohaldub esinduslepingus sätestatud üleandmise kord; selle kehtivus esindaja pankroti korral tugineb lisatud õiguslikule arvamusele [ADVOKAADIBÜROO, KUUPÄEV]. Jääkrisk, et investorite arvel omatavad osad võivad arvata esindaja pankrotivara hulka, avalikustatakse investeerimise põhiteabedokumendi riskitegurite osas (C-osa) ja T2-s."

**MAJOR** — 6.3.7 "avalikustatakse: igas investeerimise põhiteabedokumendis; ..."

- Problem: ESMA_QA_2601 (4.7.2025) requires the KIIS to disclose specific nominee items: the structure's purpose and functioning, how investor rights are exercised through the nominee, its costs, and whether use of the nominee is mandatory or optional. The draft only says the structure "avalikustatakse" without these content elements — and since 6.3 opens with "Otsest struktuuri ei kasutata", the mandatory nature must be stated expressly.
- Fix applied: Täiendada 6.3.7: "Investeerimise põhiteabedokumendis (lisa 18.1, D- ja F-osa) avalikustatakse esindajastruktuuri eesmärk ja toimimine, investori õiguste teostamise viis esindaja kaudu, esindajaga seotud kulud investorile (0 eurot, § 6.3.9) ning asjaolu, et esindajastruktuur on kohustuslik — otseosalus projektiettevõtjas ei ole võimalik."

**MAJOR** — 6.3.10 "lisa 15 (esindajateenuse käsitlus tegevuse edasiandmisena, kui asjakohane)"

- Problem: The "kui asjakohane" hedge is untenable. Per ESMA_QA_2601, nominee services forming part of the operation of the platform must be described in the application; the esindaja is a separate legal entity performing operational functions of the service (register-keeping, entries, distributions data). FI will expect a definitive classification under art 9 (tegevuse edasiandmine) with the taotleja retaining full responsibility — or a reasoned position why art 9 does not apply — not a conditional cross-reference.
- Fix applied: Asendada: "lisa 15 (esindaja registripidamise ja kannete tegemise funktsioonide käsitlus tegevuse edasiandmisena määruse artikli 9 tähenduses; taotleja vastutus klientide ees säilib täies ulatuses)".

**MINOR** — 6.3.8 "Platvorm ei sobita korraldusi, ei täida tehinguid ega määra hindu; kanne tehakse üksnes mõlema poole kinnitatud juhise alusel"

- Problem: Correct as far as it goes (matches art 25(2); waiving the reference price is stricter than art 25(5) requires), but incomplete: it does not state that the transfer contract is concluded between the investors themselves outside platform protocols, and omits the art 25(3)(b) duty (selling client must make the investeerimise põhiteabedokument available), the art 25(3)(d) duty (mittekogenud investorist ostja saab art 19(2) teabe ja art 21(4) riskihoiatuse), and the art 25(4) mapping (ownership-change notification = kanne esindaja registris).
- Fix applied: Lisada: "Võõrandamisleping sõlmitakse investorite vahel väljaspool platvormi protokolle (art 25 lg 2). Müüki reklaamiv investor teeb kättesaadavaks investeerimise põhiteabedokumendi (art 25 lg 3 p b); mittekogenud investorist ostjale esitatakse artikli 19 lõike 2 teave ja artikli 21 lõike 4 riskihoiatus (art 25 lg 3 p d). Omandiõiguse muutusest teavitamine ja kanne esindaja registris vastavad artikli 25 lõikele 4."

**MINOR** — 6.3.8 "Teadetetahvli (art 25)" ja paketi sõnastik

- Problem: The official Estonian text of Regulation 2020/1503 titles Article 25 "Teatetahvel" and uses "teatetahvlit" throughout — not "teadetetahvel" as the package glossary mandates. FI reads the ET regulation daily; a non-official coinage in a licence application reads as imprecision.
- Fix applied: Kasutada määruse ametlikku terminit "teatetahvel (art 25)" ja parandada paketi sõnastik vastavalt (kogu paketis ühetaoliselt).

**MINOR** — 6.3.1/6.3.10 — puudub viide osade võõrandatavuse tingimusele

- Problem: Art 2(1)(n): osad qualify as ühisrahastuse eesmärgil aktsepteeritud instrumendid only if not subject to "piirangud, mis sisuliselt takistaksid nende võõrandamist". For an Estonian OÜ the default notarial form of the transfer disposition and the osanike ostueesõigus are exactly such candidate restrictions; the nominee structure does not remove the issue for transfers of the underlying osa to/from the esindaja. The section never conditions platform admission on the projektiettevõtja põhikiri eliminating these restrictions.
- Fix applied: Lisada 6.3.1 või 6.3.10: "Platvorm aktsepteerib üksnes projektiettevõtjaid, kelle põhikiri välistab osade võõrandamist sisuliselt takistavad piirangud (sh ostueesõiguse kohaldumise ja vorminõude äriseadustikus lubatud ulatuses), et osad vastaksid määruse artikli 2 lõike 1 punkti n tingimustele; vt lisa 16 § 2."

**Verdict:** The draft is structurally the right shape for an FI nominee disclosure — it captures ESMA's two hard conditions (esindaja only after a project-specific investment decision, 6.3.2; explicit FI disclosure and request for a seisukoht, 6.3.6) and correctly opinion-gates the creditor-segregation analysis — but it is not yet fit to enter the application, for one blocking reason and a cluster of majors. The core §6.3.6 carve-out is argued on the wrong limb of art 10(3): the regulation's verified ET text turns on instruments \"mida SAAB registreerida INVESTORI NIMEL AVATUD finantsinstrumentide kontol või mida saab füüsiliselt üle anda KONTOHALDURILE\" — a capability test the draft's factual \"ei registreerita\" does not engage (Estonian OÜ osad can optionally be registered in the väärtpaberite register), while the draft simultaneously ignores its best authorities, Recital 28 and ESMA Q&A 3.3, which support the position via the ownership-verification-and-record-keeping equivalence. Around that core: the package calls the esindaja a \"hoidja\" while denying hoidmisteenus, leaves dividend flows ambiguous enough to raise a Directive 2015/2366 payment-services exposure the section never analyses, never addresses the art 8(1) osaluse keeld triggered by a taotleja group entity becoming osanik of every project company, states insolvency wind-down as fact, hedges the art 9 outsourcing classification, and omits the ESMA_QA_2601 KIIS content items (mandatory/optional, functioning, costs). All are fixable with the wording supplied; once the BLOCKER and MAJOR fixes are applied, retaining the explicit FI-seisukoha request in §8, the section is fit for filing. Sources: EUR-Lex CELEX 32020R1503 (ET and EN texts — art 10, art 25, art 8, art 2(1), Recital 28); ESMA Q&A ESMA35-42-1088 (answers 3.3 and 3.4); ESMA_QA_2601 of 4 July 2025 on nominee structures (via eurocrowd.org summary).

## Estonian legal-language critic (register, glossary, placeholder hygiene)

**BLOCKER** — 6.3.5, esimene lause: "Esindaja arvel hoitavad osad hoitakse esindaja oma varast arvestuslikult ja lepinguliselt lahus."

- Problem: Tähenduse pöördumine: "esindaja arvel" tähendab, et osasid hoitakse esindaja ENDA arvel — täpselt vastupidi kogu ülejäänud paragrahvile (6.3.1 "investorite arvel"; sama lõigu lõpus "investorite arvel hoitavatele osadele"). FI menetleja loeb sellest välja sisulise vastuolu varade lahususe tuumiklauses. Lisaks stiiliviga "hoitavad osad hoitakse" (kordus).
- Fix applied: Osad, mida esindaja hoiab investorite arvel, hoitakse esindaja oma varast arvestuslikult ja lepinguliselt lahus.

**MAJOR** — 6.3.6, viimane lause: "⚠️ Õiguslik arvamus [ADVOKAADIBÜROO, KUUPÄEV] on lisatud"

- Problem: Emoji ⚠️ asub VÄLJASPOOL nurksulge, st kohatäidete puhastus seda ei püüa ja märk jääb FI-le esitatavasse teksti. Emoji ei kuulu ametlikku taotlusdokumenti üheski olukorras. Sama emoji esineb ka 6.3.5 sulgudes. Ühendplaceholder [ADVOKAADIBÜROO, KUUPÄEV] tuleks lahutada kaheks.
- Fix applied: Õiguslik arvamus ([ADVOKAADIBÜROO], [KUUPÄEV]) on lisatud; taotleja esitab küsimuse sõnaselgelt põhitaotluse §-s 8 ja palub Finantsinspektsiooni seisukohta.

**MAJOR** — 6.3.5: "[Õiguslik analüüs selle kohta, et esindaja võlausaldajate nõuded ei ulatu investorite arvel hoitavatele osadele, on lisatud — ⚠️ ADVOKAADIBÜROO, KUUPÄEV.]"

- Problem: Kohatäite hügieen: terve kandev lause on nurksulgudes, kuigi asendamist vajavad ainult büroo nimi ja kuupäev. Kohatäidete puhastamisel kaoks kogu lause (sh sisuline väide, mida FI just ootab). Nurksulgudesse tohib jääda üksnes muutuv osa.
- Fix applied: Õiguslik analüüs selle kohta, et esindaja võlausaldajate nõuded ei ulatu investorite arvel hoitavatele osadele, on lisatud ([ADVOKAADIBÜROO], [KUUPÄEV]).

**MAJOR** — Sissejuhatav plokk: "*(Käesolev valik asendab varasema tööversiooni valikubloki.)*"

- Problem: Registri rikkumine: sisemine koostamisprotsessi märkus ("tööversioon", "valikublokk") ei kuulu FI-le esitatavasse taotlusesse; see mõjub mustandina ja tekitab küsimuse, milline "varasem versioon" FI-l olemas on. Muudatuste selgitus kuulub saatekirja või muudatuste loetellu.
- Fix applied: Kustutada lause §-st 6.3; vajadusel lisada saatekirja: "Taotluse § 6.3 on võrreldes [KUUPÄEV] esitatud versiooniga asendatud: otsese osaluse struktuuri asemel kasutatakse esindajastruktuuri."

**MAJOR** — 6.3.6 tervikuna (ja § 6.3 sissejuhatus) — puudub lause esindajastruktuuri heakskiitmise kohta

- Problem: Paketi varasem hoiatustekst nõuab, et esindajastruktuur tuleb FI-le avalikustada JA FI peab selle heaks kiitma. Praegune tekst küsib FI seisukohta üksnes hoidmisteenuse (art 10 lg 3) küsimuses; struktuuri enda heakskiidu taotlemine jääb sõnastamata. FI menetleja küsib selle kindlasti üle.
- Fix applied: Lisada 6.3.6 lõppu (või sissejuhatusse): "Taotleja esitab esindajastruktuuri kasutamise käesoleva taotluse raames Finantsinspektsioonile heakskiitmiseks ega rakenda seda enne heakskiidu saamist."

**MAJOR** — 6.3.1: "Esindaja ainus tegevusala on platvormi vahendusel tehtud investeeringute esindajana hoidmine"

- Problem: Grammatiliselt rikutud nominaalfraas: "investeeringute esindajana hoidmine" ei tähenda midagi — hoitakse osasid, mitte investeeringuid, ja "esindajana" ripub lauses õhus. FI menetleja peab tegevusala määratlust täpseks lugema (see piiritleb esindaja lubatud tegevuse).
- Fix applied: Esindaja ainus tegevusala on platvormi vahendusel omandatud osade hoidmine investorite arvel.

**MAJOR** — 6.3.6 vs 6.3.9: "esitab küsimuse sõnaselgelt põhitaotluse §-s 8" ja "kooskõlas §-ga 8 — investorite tasud on 0 eurot"

- Problem: Sama ristviide (§ 8) kannab kahte eri sisu: 6.3.6 järgi on § 8 koht, kus esitatakse FI-le hoidmisteenuse küsimus; 6.3.9 järgi on § 8 tasude säte. Vähemalt üks viide on vale ja FI menetleja märkab vastuolu kohe.
- Fix applied: Kontrollida põhitaotluse numeratsiooni ja parandada üks viide, nt 6.3.9: "(kooskõlas §-ga [X] (tasud): investoritelt tasusid ei võeta)".

**MAJOR** — 6.3.3(b): "Hääleõigust teostab esindaja investorite juhiste alusel [juhiste kogumise ja hääletamise kord — TÄPSUSTADA esinduslepingus]"

- Problem: Puudub vaikimisi reegel juhiste puudumise või vastuoluliste juhiste puhuks — esimene küsimus, mille FI menetleja esindajastruktuuri kohta esitab. Nurksulgudes TÄPSUSTADA sellest ei päästa: põhimõte peab olema taotluses endas, detailid võivad jääda esinduslepingusse.
- Fix applied: Hääleõigust teostab esindaja üksnes investori juhise alusel; juhise puudumisel esindaja vastava osaluse ulatuses hääletamisel ei osale [juhiste kogumise ja hääletamise täpne kord — TÄPSUSTADA esinduslepingus].

**MAJOR** — 6.3.2: "Esindajat kasutatakse üksnes selliste osade hoidmiseks, mille suhtes investor on eelnevalt teinud investeerimisotsuse konkreetse ühisrahastuspakkumise kohta."

- Problem: Kaks probleemi: (1) topeltrektsioon "mille suhtes ... otsuse ... kohta" on vigane; (2) puudub seos mittekogenud investori järelemõtlemisajaga (4 kalendripäeva) — FI küsib, kas osa kantakse esindaja registrisse enne või pärast järelemõtlemisaja möödumist.
- Fix applied: Esindajat kasutatakse üksnes selliste osade hoidmiseks, mille kohta investor on eelnevalt teinud investeerimisotsuse konkreetse ühisrahastuspakkumise alusel. Osa kantakse esindaja registrisse alles pärast pakkumise lõppemist ja mittekogenud investori järelemõtlemisaja (4 kalendripäeva) möödumist.

**MAJOR** — 6.3.10: "lisa 15 (esindajateenuse käsitlus tegevuse edasiandmisena, kui asjakohane)"

- Problem: "Kui asjakohane" on kõhklus küsimuses, milles taotleja PEAB seisukoha võtma: kas kontserni kuuluvale esindajale antud ülesanded on tegevuse edasiandmine või mitte. Lahtijätmine garanteerib FI järelepärimise.
- Fix applied: lisa 15 (esindajateenuse käsitlus: taotleja käsitab esindajale antud ülesandeid tegevuse edasiandmisena ning kohaldab lisas 15 kirjeldatud korda) — või põhjendatud vastupidine seisukoht, kuid üks kahest tuleb valida.

**MINOR** — 6.3.4: "Paragrahvis 6.4 kirjeldatud..." vs 6.3.6 "§-s 8", 6.3.9 "§-ga 8", 6.3.10 "lisa 16 § 5"

- Problem: Ristviidete stiil on ebaühtlane: kord "Paragrahvis 6.4", kord "§-s 8"; ka EL-i artikliviited kõiguvad ("art 10 lg 3" pealkirjas, "art 25" tekstis, paketi vanem tekst "art 10(3)"). Eesti reguleeriva lisa stiil nõuab ühte süsteemi.
- Fix applied: Ühtlustada: dokumendisisesed viited kujul "§-s 6.4", "§-ga 8", "lisa 16 §-s 5"; ECSPR-i viited esmamainimisel "ECSPR artikli 10 lõige 3", edaspidi "art 10 lg 3" ja "art 25".

**MINOR** — 6.3.1: "[taotleja 100% tütarettevõtja / taotlejaga samasse kontserni kuuluv üksus — TÄPSUSTADA ja kajastada lisas 12]"

- Problem: "100% tütarettevõtja" ei ole korrektne eesti keel (protsendimäär vajab omadussõnalist vormi või ümbersõnastust).
- Fix applied: [taotleja 100%-line tütarettevõtja / taotlejaga samasse konsolideerimisgruppi kuuluv üksus — TÄPSUSTADA ja kajastada lisas 12]

**MINOR** — 6.3.1: "kes hoiab osasid investorite arvel esinduslepingu alusel"

- Problem: Esindajasuhte standardvormel on poolik: esindaja hoiab osasid OMA NIMEL ja investorite arvel. Täpsustus on oluline ka 6.3.6 hoidmisteenuse analüüsi toetamiseks (osanikustaatus äriregistris on esindaja nimel).
- Fix applied: kes hoiab osasid oma nimel ja investorite arvel esinduslepingu alusel

**MINOR** — 6.3.1: "kantakse projektiettevõtja osanike nimekirja üks osanik"

- Problem: Alates 2023. a äriseadustiku muudatustest kantakse osanike andmed äriregistrisse; pelk "osanike nimekiri" jätab lahtiseks, kus kanne õiguslikult asub. FI menetleja ootab täpsust.
- Fix applied: kantakse projektiettevõtja osanikuna äriregistrisse (osanike nimekirja) üks osanik — AureviaFund OÜ ...

**MINOR** — 6.3.3(a): "võõrandamise tulem" ja "kuuluvad ... investorile ning kantakse investorile üle ... viivitamata pärast laekumist"

- Problem: "Tulem" on raamatupidamise kasumi/kahjumi termin, siin mõeldakse saadavat tulu; "investorile" kordub lauses kaks korda; "viivitamata" asetseb lauselõpus kohmakalt (õiguskeele standardvormel on "põhjendamatu viivituseta").
- Fix applied: Majanduslikud õigused — dividendid, likvideerimisjaotis ja võõrandamisest saadav tulu — kuuluvad täies ulatuses investorile ning kantakse talle makseteenuse pakkuja kaudu üle põhjendamatu viivituseta pärast laekumist.

**MINOR** — 6.3.4: "iga investori osalus (kogus, omandamise kuupäev ja hind, tehinguajalugu)"

- Problem: "Kogus" on osaühingu osa kohta ebatäpne — osa iseloomustab arv ja nimiväärtus, mitte kogus. FI menetleja küsib, mida registris tegelikult kajastatakse.
- Fix applied: iga investori osalus (osade arv ja nimiväärtus, omandamise kuupäev ja hind ning tehingute ajalugu)

**MINOR** — 6.3.4: "iga seisu räsi säilitatakse võltsimiskindluse tagamiseks"

- Problem: "Seisu räsi" on ilma eelneva selgituseta arusaamatu žargoon — "seis" ja "räsi" pole kumbki varem defineeritud.
- Fix applied: iga registriseisu kohta arvutatud räsiväärtus (hash) säilitatakse võltsimiskindluse tagamiseks

**MINOR** — 6.3.6: "platvormil pakutavaid OÜ osasid ei registreerita finantsinstrumentide kontol ega saa füüsiliselt hoidjale üle anda" ja "esindaja positsioon"

- Problem: Kolm registriprobleemi: (1) "OÜ osasid" on argivorm, ametlikus tekstis "osaühingu osasid"; (2) glossaariumi termin "ühisrahastuse eesmärgil aktsepteeritud instrumendid" on just selles analüüsis kasutamata, kuigi art 10 lg 3 kohaldub nimelt neile; (3) "positsioon" on anglitsism; (4) alusevahetusega "ega saa ... üle anda" vajab asesõna.
- Fix applied: Taotleja seisukoht: platvormil pakutavaid ühisrahastuse eesmärgil aktsepteeritud instrumente (osaühingu osasid) ei registreerita finantsinstrumentide kontol ega ole neid võimalik füüsiliselt hoidjale üle anda; esindaja õiguslik seisund põhineb äriseadustiku kohasel osaniku staatusel ja võlaõiguslikul esinduslepingul.

**MINOR** — 6.3.8: "Platvorm ei sobita korraldusi, ei täida tehinguid ega määra hindu"

- Problem: "Ei täida tehinguid" on toorlaen (execute transactions); MiFID-i eestikeelne terminoloogia räägib korralduste täitmisest ning art 25 keelab sisemise sobitamissüsteemi ja ostu-müügihuvide kokkuviimise.
- Fix applied: Platvorm ei kasuta sisemist sobitamissüsteemi: ta ei vii kokku ostu- ja müügihuve, ei täida korraldusi ega määra hindu; kanne tehakse üksnes mõlema poole kinnitatud juhise alusel.

**MINOR** — 6.3.10: "lisa 16 § 5 (hoidmise analüüsi muudatus)" ja "T2 ja T3"

- Problem: (1) "Hoidmise analüüs" kaldub glossaariumi terminist kõrvale — mujal (sh 6.3.6 pealkiri) on "hoidmisteenus"; (2) T3 esineb §-s 6.3 esimest ja ainsat korda ilma seletuseta, samas kui T2 ja T4 on 6.3.7-s sulgudes lahti kirjutatud.
- Fix applied: lisa 16 §-s 5 (hoidmisteenuse analüüsi muudatus); ... T2 (investori kasutustingimused) ja T3 ([DOKUMENDI NIMETUS — TÄPSUSTADA])

**MINOR** — 6.3.9: "(kooskõlas §-ga 8 — investorite tasud on 0 eurot)"

- Problem: Mõttekriips sulgude sees selgituse sidumiseks on kõnekeelne; "tasud on 0 eurot" mõjub tabelikeelena, ametlik vorm on eitav lause.
- Fix applied: Esindaja ei võta investoritelt tasu (kooskõlas §-ga [X]: investoritelt tasusid ei võeta). Esindaja tegevuskulud katab taotleja.

**Verdict:** Mustand on struktuurilt tugev ja glossaariumiga valdavalt kooskõlas (investeerimise põhiteabedokument, teadetetahvel, hoidmisteenus, tegevuse edasiandmine ja talitluspidevuse kava on kõik õigesti kasutusel), kuid praegusel kujul ei tohi see taotlusesse minna: 6.3.5 esimene lause ütleb varade lahususe tuumikkohas tähenduselt vastupidist ("esindaja arvel" pro "investorite arvel"), kaks ⚠️-märgistust ja valesti paigutatud nurksulud tähendavad, et kohatäidete puhastuse järel jääks teksti kas emoji või kaoks kandev lause, ning neli sisulist auku (esindajastruktuuri heakskiidu taotlemata jätmine, hääletamise vaikereegli puudumine, järelemõtlemisaja seose puudumine, lisa 15 "kui asjakohane" kõhklus ja § 8 topeltviide) genereeriksid FI järelepärimised, mille vältimiseks kogu paragrahv üldse ümber kirjutati. Kõik leiud on lokaalsed ja parandatavad esitatud sõnastustega; pärast BLOCKER-i ja MAJOR-ite sisseviimist on tekst FI menetluskõlblik ning MINOR-id tõstavad selle ühtlasesse ametlikku registrisse.
