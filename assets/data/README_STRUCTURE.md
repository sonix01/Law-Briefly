```markdown
# Law Briefly — Offline Content Architecture

---

## System Architecture

```
assets/data/  (JSON Files)
       │
       ▼
LocalLegalRepository
(lib/data/repositories/legal_repository.dart)
       │
       ▼
Legal Models
(lib/data/models/legal_models.dart)
       │
       ▼
Flutter UI Screens
(screens consume models — NEVER raw JSON)
       │
       ▼  (future)
AI Indexing Layer  /  Marketplace Layer
```

---

## Core Architecture Rules

- UI **NEVER** contains legal text directly.
- Case Laws are **NEVER** embedded inside Section or Article JSON.
- Sections store only `case_law_ids` (array of string references).
- Articles store only `case_law_ids` (array of string references).
- Adding new content = editing JSON files ONLY. Zero Flutter code changes.
- Each Act is a single JSON file.
- Constitution is a single JSON file (array of Parts).
- Case Laws are separate JSON files (flat arrays, indexed by `id`).
- Repository is the only code that reads JSON.

---

## Folder Structure

```
assets/
└── data/
    │
    ├── acts/
    │   ├── bharatiya_nyaya_sanhita_2023.json
    │   ├── bharatiya_sakshya_adhiniyam_2023.json
    │   ├── bharatiya_nagarik_suraksha_sanhita_2023.json
    │   ├── indian_contract_act_1872.json
    │   ├── code_of_civil_procedure_1908.json
    │   ├── code_of_criminal_procedure_1973.json
    │   ├── transfer_of_property_act_1882.json
    │   ├── specific_relief_act_1963.json
    │   ├── limitation_act_1963.json
    │   ├── companies_act_2013.json
    │   ├── information_technology_act_2000.json
    │   ├── consumer_protection_act_2019.json
    │   ├── right_to_information_act_2005.json
    │   └── [any_new_act].json
    │
    ├── constitution/
    │   └── constitution_of_india.json
    │
    ├── case_laws/
    │   ├── criminal_law_cases.json
    │   ├── constitutional_cases.json
    │   ├── contract_law_cases.json
    │   ├── evidence_law_cases.json
    │   ├── property_law_cases.json
    │   └── [any_new_category].json
    │
    ├── academic/
    │   └── academic_years.json
    │
    └── README_STRUCTURE.md
```

---

## ID Naming Convention

```
Acts          →  bsa_2023       bns_2023       ica_1872
Chapters      →  bsa_ch1        bsa_ch2        bns_ch17
Sections      →  bsa_s1         bsa_s57        ica_s73
Parts         →  part_1         part_3         part_4a
Articles      →  art_14         art_21         art_21a        preamble
Case Laws     →  cl_praful      cl_maneka      cl_kesavananda
Academic Yr   →  y1             y2             y3
Subjects      →  y1_s1          y2_s3          y3_s2
```

---

## 1. ACT JSON — Complete Example

### File: `assets/data/acts/bharatiya_sakshya_adhiniyam_2023.json`

```json
{
  "id": "bsa_2023",
  "title": "Bharatiya Sakshya Adhiniyam",
  "short_title": "BSA",
  "year": 2023,
  "category": "evidence",
  "is_active": true,
  "description": "An Act to consolidate and to provide for general rules and principles of evidence. This Act replaces the Indian Evidence Act, 1872.",
  "chapters": [
    {
      "id": "bsa_ch1",
      "chapter_number": "I",
      "title": "Preliminary",
      "sections": [
        {
          "id": "bsa_s1",
          "section_number": "1",
          "title": "Short title, extent and commencement",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "This Act may be called the Bharatiya Sakshya Adhiniyam, 2023. It extends to the whole of India. It shall come into force on such date as the Central Government may, by notification in the Official Gazette, appoint, and different dates may be appointed for different provisions of this Act."
            }
          ],
          "case_law_ids": []
        },
        {
          "id": "bsa_s2",
          "section_number": "2",
          "title": "Definitions",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "In this Act, unless the context otherwise requires,— (a) 'court' includes all Judges and Magistrates, and all persons, except arbitrators, legally authorised to take evidence; (b) 'document' means any matter expressed or described upon any substance by means of letters, figures, or marks, or by more than one of those means, intended to be used, or which may be used, for the purpose of recording that matter; (c) 'evidence' means and includes— (i) all statements which the court permits or requires to be made before it by witnesses, in relation to matters of fact under inquiry, such statements are called oral evidence; (ii) all documents including electronic records produced for the inspection of the court, such documents are called documentary evidence."
            },
            {
              "type": "explanation",
              "label": "Explanation.—",
              "text": "It is immaterial by what means or upon what substance the letters, figures or marks are formed, or whether the evidence is intended for, or used in, a court or not."
            }
          ],
          "case_law_ids": []
        }
      ]
    },
    {
      "id": "bsa_ch2",
      "chapter_number": "II",
      "title": "Relevancy of Facts",
      "sections": [
        {
          "id": "bsa_s3",
          "section_number": "3",
          "title": "Evidence may be given of facts in issue and relevant facts",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "Evidence may be given in any suit or proceeding of the existence or non-existence of every fact in issue and of such other facts as are hereinafter declared to be relevant, and of no others."
            },
            {
              "type": "explanation",
              "label": "Explanation.—",
              "text": "This section shall not enable any person to give evidence of a fact which he is disentitled to prove by any provision of the law for the time being in force relating to civil procedure."
            }
          ],
          "case_law_ids": []
        },
        {
          "id": "bsa_s4",
          "section_number": "4",
          "title": "Relevancy of facts forming part of same transaction",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "Facts which, though not in issue, are so connected with a fact in issue as to form part of the same transaction, are relevant, whether they occurred at the same time and place or at different times and places."
            }
          ],
          "case_law_ids": []
        },
        {
          "id": "bsa_s7",
          "section_number": "7",
          "title": "Facts relevant when they show motive, preparation, and previous or subsequent conduct",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "The following facts are relevant:— (a) any fact which shows or constitutes a motive or preparation for any fact in issue or relevant fact; (b) the conduct of any party, or of any agent to any party, to any suit or proceeding, in reference to such suit or proceeding, or in reference to any fact in issue therein or relevant thereto, and the conduct of any person an offence against whom is the subject of any proceeding."
            }
          ],
          "case_law_ids": []
        }
      ]
    },
    {
      "id": "bsa_ch5",
      "chapter_number": "V",
      "title": "Documentary Evidence",
      "sections": [
        {
          "id": "bsa_s57",
          "section_number": "57",
          "title": "Primary evidence",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "Primary evidence means the document itself produced for the inspection of the court."
            },
            {
              "type": "explanation",
              "label": "Explanation 1.—",
              "text": "Where a document is executed in several parts, each part is primary evidence of the document."
            },
            {
              "type": "explanation",
              "label": "Explanation 2.—",
              "text": "Where a document is executed in counterpart, each counterpart being executed by one or some of the parties only, each counterpart is primary evidence as against the parties executing it."
            }
          ],
          "case_law_ids": ["cl_praful_desai", "cl_tomaso_bruno"]
        },
        {
          "id": "bsa_s58",
          "section_number": "58",
          "title": "Secondary evidence",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "Secondary evidence means and includes— (1) certified copies given under the provisions hereinafter contained; (2) copies made from the original by mechanical processes which in themselves ensure the accuracy of the copy, and copies compared with such copies; (3) copies made from or compared with the original; (4) counterparts of documents as against the parties who did not execute them; (5) oral accounts of the contents of a document given by some person who has himself seen it."
            }
          ],
          "case_law_ids": ["cl_praful_desai"]
        },
        {
          "id": "bsa_s63",
          "section_number": "63",
          "title": "Admissibility of electronic records",
          "is_repealed": false,
          "is_omitted": false,
          "status_note": null,
          "content": [
            {
              "type": "main",
              "label": null,
              "text": "Notwithstanding anything contained in this Act, any information contained in an electronic record which is printed on paper, stored, recorded or copied in optical or magnetic media produced by a computer shall be deemed to be also a document, if the conditions mentioned in this section are satisfied in relation to the information and computer in question and shall be admissible in any proceedings, without further proof or production of the original, as evidence of any contents of the original or of any fact stated therein of which direct evidence would be admissible."
            },
            {
              "type": "proviso",
              "label": "Proviso.—",
              "text": "Where any information is to be given in evidence by virtue of this section, a certificate doing any of the following things, that is to say,— (a) identifying the electronic record containing the statement and describing the manner in which it was produced; (b) giving such particulars of any device involved in the production of that electronic record as may be appropriate for the purpose of showing that the electronic record was produced by a computer; shall be evidence of anything stated in the certificate."
            }
          ],
          "case_law_ids": ["cl_tomaso_bruno", "cl_anvar_basheer"]
        }
      ]
    }
  ]
}
```

---

## 2. CONSTITUTION JSON — Complete Example

### File: `assets/data/constitution/constitution_of_india.json`

```json
[
  {
    "id": "part_1",
    "part_number": "I",
    "title": "The Union and its Territory",
    "articles": [
      {
        "id": "preamble",
        "article_number": "Preamble",
        "title": "Preamble of the Constitution of India",
        "is_preamble": true,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "WE, THE PEOPLE OF INDIA, having solemnly resolved to constitute India into a SOVEREIGN SOCIALIST SECULAR DEMOCRATIC REPUBLIC and to secure to all its citizens: JUSTICE, social, economic and political; LIBERTY of thought, expression, belief, faith and worship; EQUALITY of status and of opportunity; and to promote among them all FRATERNITY assuring the dignity of the individual and the unity and integrity of the Nation; IN OUR CONSTITUENT ASSEMBLY this twenty-sixth day of November, 1949, do HEREBY ADOPT, ENACT AND GIVE TO OURSELVES THIS CONSTITUTION."
          }
        ],
        "case_law_ids": []
      },
      {
        "id": "art_1",
        "article_number": "1",
        "title": "Name and territory of the Union",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "(1) India, that is Bharat, shall be a Union of States.\n(2) The States and the territories thereof shall be as specified in the First Schedule.\n(3) The territory of India shall comprise—\n(a) the territories of the States;\n(b) the Union territories specified in the First Schedule; and\n(c) such other territories as may be acquired."
          }
        ],
        "case_law_ids": []
      },
      {
        "id": "art_3",
        "article_number": "3",
        "title": "Formation of new States and alteration of areas, boundaries or names of existing States",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "Parliament may by law—\n(a) form a new State by separation of territory from any State or by uniting two or more States or parts of States or by uniting any territory to a part of any State;\n(b) increase the area of any State;\n(c) diminish the area of any State;\n(d) alter the boundaries of any State;\n(e) alter the name of any State."
          },
          {
            "type": "proviso",
            "label": "Proviso.—",
            "text": "No Bill for the purpose shall be introduced in either House of Parliament except on the recommendation of the President and unless, where the proposal contained in the Bill affects the area, boundaries or name of any of the States, the Bill has been referred by the President to the Legislature of that State for expressing its views thereon within such period as may be specified in the reference or within such further period as the President may allow and the period so specified or allowed has expired."
          }
        ],
        "case_law_ids": []
      }
    ]
  },
  {
    "id": "part_3",
    "part_number": "III",
    "title": "Fundamental Rights",
    "articles": [
      {
        "id": "art_12",
        "article_number": "12",
        "title": "Definition",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "In this Part, unless the context otherwise requires, 'the State' includes the Government and Parliament of India and the Government and the Legislature of each of the States and all local or other authorities within the territory of India or under the control of the Government of India."
          }
        ],
        "case_law_ids": []
      },
      {
        "id": "art_14",
        "article_number": "14",
        "title": "Equality before law",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "The State shall not deny to any person equality before the law or the equal protection of the laws within the territory of India."
          }
        ],
        "case_law_ids": ["cl_maneka_gandhi", "cl_vishaka"]
      },
      {
        "id": "art_21",
        "article_number": "21",
        "title": "Protection of life and personal liberty",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "No person shall be deprived of his life or personal liberty except according to procedure established by law."
          }
        ],
        "case_law_ids": ["cl_maneka_gandhi", "cl_vishaka", "cl_olga_tellis"]
      },
      {
        "id": "art_21a",
        "article_number": "21A",
        "title": "Right to education",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": "Inserted by the Constitution (Eighty-sixth Amendment) Act, 2002",
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "The State shall provide free and compulsory education to all children of the age of six to fourteen years in such manner as the State may, by law, determine."
          }
        ],
        "case_law_ids": []
      },
      {
        "id": "art_32",
        "article_number": "32",
        "title": "Remedies for enforcement of rights conferred by this Part",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "(1) The right to move the Supreme Court by appropriate proceedings for the enforcement of the rights conferred by this Part is guaranteed.\n(2) The Supreme Court shall have power to issue directions or orders or writs, including writs in the nature of habeas corpus, mandamus, prohibition, quo warranto and certiorari, whichever may be appropriate, for the enforcement of any of the rights conferred by this Part.\n(3) Without prejudice to the powers conferred on the Supreme Court by clauses (1) and (2), Parliament may by law empower any other court to exercise within the local limits of its jurisdiction all or any of the powers exercisable by the Supreme Court under clause (2).\n(4) The right guaranteed by this article shall not be suspended except as otherwise provided for by this Constitution."
          }
        ],
        "case_law_ids": ["cl_maneka_gandhi"]
      }
    ]
  },
  {
    "id": "part_4a",
    "part_number": "IVA",
    "title": "Fundamental Duties",
    "articles": [
      {
        "id": "art_51a",
        "article_number": "51A",
        "title": "Fundamental duties",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": "Inserted by the Constitution (Forty-second Amendment) Act, 1976",
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "It shall be the duty of every citizen of India—\n(a) to abide by the Constitution and respect its ideals and institutions, the National Flag and the National Anthem;\n(b) to cherish and follow the noble ideals which inspired our national struggle for freedom;\n(c) to uphold and protect the sovereignty, unity and integrity of India;\n(d) to defend the country and render national service when called upon to do so;\n(e) to promote harmony and the spirit of common brotherhood amongst all the people of India transcending religious, linguistic and regional or sectional diversities; to renounce practices derogatory to the dignity of women;\n(f) to value and preserve the rich heritage of our composite culture;\n(g) to protect and improve the natural environment including forests, lakes, rivers and wild life, and to have compassion for living creatures;\n(h) to develop the scientific temper, humanism and the spirit of inquiry and reform;\n(i) to safeguard public property and to abjure violence;\n(j) to strive towards excellence in all spheres of individual and collective activity so that the nation constantly rises to higher levels of endeavour and achievement;\n(k) who is a parent or guardian to provide opportunities for education to his child or, as the case may be, ward between the age of six and fourteen years."
          }
        ],
        "case_law_ids": []
      }
    ]
  },
  {
    "id": "part_20",
    "part_number": "XX",
    "title": "Amendment of the Constitution",
    "articles": [
      {
        "id": "art_368",
        "article_number": "368",
        "title": "Power of Parliament to amend the Constitution and procedure therefor",
        "is_preamble": false,
        "is_repealed": false,
        "is_omitted": false,
        "status_note": null,
        "content": [
          {
            "type": "main",
            "label": null,
            "text": "(1) Notwithstanding anything in this Constitution, Parliament may in exercise of its constituent power amend by way of addition, variation or repeal any provision of this Constitution in accordance with the procedure laid down in this article.\n(2) An amendment of this Constitution may be initiated only by the introduction of a Bill for the purpose in either House of Parliament, and when the Bill is passed in each House by a majority of the total membership of that House and by a majority of not less than two-thirds of the members of that House present and voting, it shall be presented to the President who shall give his assent to the Bill and thereupon the Constitution shall stand amended in accordance with the terms of the Bill."
          }
        ],
        "case_law_ids": ["cl_kesavananda"]
      }
    ]
  }
]
3. CASE LAWS JSON — Complete Examples (Stored Separately)
CRITICAL: Case laws are NEVER inside act or constitution JSON.
Sections and articles store only the id references.
File: assets/data/case_laws/evidence_law_cases.json
json
[
  {
    "id": "cl_praful_desai",
    "title": "State of Maharashtra v. Praful B. Desai",
    "citation": "(2003) 4 SCC 601",
    "court": "Supreme Court of India",
    "year": "2003",
    "related_section_ids": ["bsa_s57", "bsa_s58"],
    "related_article_ids": [],
    "related_act_ids": ["bsa_2023"],
    "facts": "The question arose whether a witness could give evidence through video conferencing in a criminal trial. The accused was abroad and the prosecution sought to examine witnesses through video link from another country. The High Court held video conferencing was not permissible under the Code of Criminal Procedure.",
    "issues": "1. Whether evidence by video conferencing amounts to 'presence' of the witness within the meaning of the Code of Criminal Procedure.\n2. Whether video conferencing satisfies the requirements of examination-in-chief, cross-examination and re-examination.\n3. Whether the court can allow a mode of recording evidence not expressly mentioned in the statute.",
    "judgment": "The Supreme Court held that evidence can be recorded by video conferencing. Such evidence has the same sanctity as evidence recorded in court with the witness physically present. The court allowed video conferencing as a valid mode of recording evidence in criminal trials.",
    "reasoning": "The court interpreted the words 'presence' and 'appearing' in a purposive manner. The purpose of requiring the presence of a witness is to enable the court to observe the demeanour of the witness and to test his credibility under cross-examination. Video conferencing enables the court to observe the witness and conduct cross-examination effectively. Technological advancement cannot be an impediment to justice.",
    "significance": "This case opened the door for electronic recording of evidence in criminal trials in India. It has been widely followed and its ratio applied to examine witnesses abroad, ill witnesses, and child victims."
  },
  {
    "id": "cl_tomaso_bruno",
    "title": "Tomaso Bruno v. State of Uttar Pradesh",
    "citation": "(2015) 7 SCC 178",
    "court": "Supreme Court of India",
    "year": "2015",
    "related_section_ids": ["bsa_s57", "bsa_s63"],
    "related_article_ids": [],
    "related_act_ids": ["bsa_2023"],
    "facts": "Italian nationals were accused of murdering their business associate in a hotel room in Agra. The case depended substantially on electronic evidence including CCTV footage and mobile records. The Sessions Court convicted the accused on the basis of this evidence.",
    "issues": "1. Whether electronic evidence was properly proved in accordance with law.\n2. Whether the chain of custody of electronic records was properly established.\n3. Whether CCTV footage is admissible without a certificate under Section 65B of the Indian Evidence Act (now Section 63 of BSA).",
    "judgment": "The Supreme Court set aside the conviction and acquitted the accused. The electronic evidence had not been proved in accordance with law. No certificate as required had been produced and the conditions for secondary evidence of electronic records had not been satisfied.",
    "reasoning": "Electronic records are secondary evidence. They must be proved by producing a certificate as required by Section 65B of the Indian Evidence Act (now Section 63 of BSA). The requirement of the certificate is mandatory. In the absence of such certification, the evidence is inadmissible. The prosecution failed to discharge this burden.",
    "significance": "Authoritative statement on the admissibility of electronic evidence in India. The requirement of the certificate under Section 65B (now Section 63, BSA) is mandatory and not merely directory."
  },
  {
    "id": "cl_anvar_basheer",
    "title": "Anvar P.V. v. P.K. Basheer",
    "citation": "(2014) 10 SCC 473",
    "court": "Supreme Court of India",
    "year": "2014",
    "related_section_ids": ["bsa_s63"],
    "related_article_ids": [],
    "related_act_ids": ["bsa_2023"],
    "facts": "An election petition challenged the result of a Kerala Legislative Assembly election. The petitioner sought to produce compact discs and printouts of electronic records as evidence without producing the certificate required under Section 65B of the Indian Evidence Act.",
    "issues": "1. Whether a CD or electronic record can be admitted in evidence without the certificate required under Section 65B.\n2. Whether oral evidence can substitute for the Section 65B certificate.\n3. What is the correct interpretation of Sections 65A and 65B of the Indian Evidence Act.",
    "judgment": "The Supreme Court held that electronic evidence is admissible ONLY if the certificate under Section 65B is produced. Oral evidence of the contents of an electronic record is not permissible. The earlier decision in Navjot Sandhu was overruled to the extent it held otherwise.",
    "reasoning": "Sections 65A and 65B form a complete code in relation to admissibility of electronic evidence. The legislature has created a specific and exhaustive provision. Courts cannot bypass this provision by resorting to oral evidence of the contents of electronic records.",
    "significance": "Overruled the contrary position taken in State (NCT of Delhi) v. Navjot Sandhu. Settled the law that the Section 65B certificate is a mandatory requirement. This remains the governing law under Section 63 of BSA."
  }
]

Linking System — Complete Example
How a Section References Case Laws
In act JSON (Section stores only IDs):
{
  "id": "bsa_s57",
  "section_number": "57",
  "title": "Primary evidence",
  "content": [...],
  "case_law_ids": [
    "cl_praful_desai",
    "cl_tomaso_bruno"
  ]
}

In case_laws JSON (Case Law stored separately with full content):

{
  "id": "cl_praful_desai",
  "title": "State of Maharashtra v. Praful B. Desai",
  "citation": "(2003) 4 SCC 601",
  "court": "Supreme Court of India",
  "year": "2003",
  "facts": "...",
  "issues": "...",
  "judgment": "...",
  "reasoning": "...",
  "significance": "..."
}

Repository resolves the link

// LocalLegalRepository
Future<List<CaseLaw>> getCaseLawsByIds(List<String> ids) async {
  final all = await getCaseLaws();
  return all.where((c) => ids.contains(c.id)).toList();
}

// Reader Screen usage
final section = await repository.getSectionById('bsa_s57');
final caseLaws = await repository.getCaseLawsByIds(section.caseLawIds);

How an Article References Case Laws
In constitution JSON (Article stores only IDs):


{
  "id": "art_21",
  "article_number": "21",
  "title": "Protection of life and personal liberty",
  "content": [...],
  "case_law_ids": [
    "cl_maneka_gandhi",
    "cl_vishaka",
    "cl_olga_tellis"
  ]
}

In case_laws JSON (completely separate file):
{
  "id": "cl_maneka_gandhi",
  "title": "Maneka Gandhi v. Union of India",
  "citation": "AIR 1978 SC 597",
  "related_article_ids": ["art_14", "art_21", "art_32"],
  "facts": "...",
  "judgment": "...",
  "significance": "..."
}
Adding New Content — Step by Step
To Add a New Act
Create assets/data/acts/[act_name_year].json
Use the Act JSON schema shown above exactly
Set "case_law_ids": [] for every section initially
Register file in pubspec.yaml under assets: if not using glob
No Flutter code changes required
Repository auto-loads on next app launch
To Add a New Section to Existing Act
Open the relevant act JSON file
Add the new section object inside the correct chapter's sections array
Add any relevant case_law_ids (must match existing IDs in case_laws/)
No Flutter code changes required
To Add a New Case Law
Open the relevant category file in assets/data/case_laws/
Add the new CaseLaw object to the JSON array
Assign a unique id following the convention: cl_[short_name]
Add that id to the relevant section's or article's case_law_ids array
No Flutter code changes required
To Add a New Constitution Article
Open assets/data/constitution/constitution_of_india.json
Find the relevant part object in the root array
Add the new article object to that part's articles array
No Flutter code changes required
To Add a New Academic PDF
Place PDF file at assets/pdfs/[year]/[subject].pdf
Register in pubspec.yaml under assets:
Add subject entry to assets/data/academic/academic_years.json
No Flutter code changes required
pubspec.yaml Asset Registration


flutter:
  assets:
    - assets/data/acts/
    - assets/data/constitution/
    - assets/data/case_laws/
    - assets/data/academic/
    - assets/pdfs/y1/
    - assets/pdfs/y2/
    - assets/pdfs/y3/
    - assets/pdfs/y4/
    - assets/pdfs/y5/
    
    Content Type Reference
Type
File Location
Loaded By
Acts
assets/data/acts/*.json
_loadActs()
Constitution
assets/data/constitution/*.json
_loadConstitution()
Case Laws
assets/data/case_laws/*.json
_loadCaseLaws()
Academic Yrs
assets/data/academic/*.json
_loadAcademicYears()
PDFs
assets/pdfs/**/*.pdf
AcademicSubject.pdfPath


Future Integrations
Feature
How Content Architecture Supports It
AI Indexing
Flat case_law_ids arrays enable full-text search and RAG
Marketplace
is_premium: true flag gates content, no structural change needed
Admin CMS
JSON files updated server-side, app downloads on sync
Multi-language
Add title_hi, content_hi fields per section/article
Offline Sync
Repository compares checksums of JSON files for delta updates