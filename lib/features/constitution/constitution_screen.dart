// lib/features/constitution/constitution_screen.dart
// Law Briefly — Constitution of India Screen
// iOS 18 Liquid Glass | Accordion Parts & Articles | GoRouter Navigation

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../app/app_router.dart' show AppNavigation, ConstitutionReaderArgs;

// ─────────────────────────────────────────────
// MARK: — CONSTITUTION ARTICLE MODEL (JSON-ready)
// ─────────────────────────────────────────────

class ConstitutionArticle {
  final String id;
  final String number;   // "1", "21A", "Preamble", "243ZT"
  final String title;
  final bool isPreamble;
  final bool isRepealed;
  final bool isOmitted;

  const ConstitutionArticle({
    required this.id,
    required this.number,
    required this.title,
    this.isPreamble = false,
    this.isRepealed = false,
    this.isOmitted  = false,
  });

  String get displayNumber => isPreamble ? 'Preamble' : number;
  bool   get isSpecial     => isRepealed || isOmitted;

  factory ConstitutionArticle.fromJson(Map<String, dynamic> json) =>
      ConstitutionArticle(
        id:         json['id']          as String,
        number:     json['number']      as String,
        title:      json['title']       as String,
        isPreamble: json['is_preamble'] as bool? ?? false,
        isRepealed: json['is_repealed'] as bool? ?? false,
        isOmitted:  json['is_omitted']  as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'number':      number,
        'title':       title,
        'is_preamble': isPreamble,
        'is_repealed': isRepealed,
        'is_omitted':  isOmitted,
      };
}

// ─────────────────────────────────────────────
// MARK: — CONSTITUTION PART MODEL (JSON-ready)
// ─────────────────────────────────────────────

class ConstitutionPart {
  final String id;
  final String number;   // "I", "IVA", "XIVA"
  final String name;
  final List<ConstitutionArticle> articles;

  const ConstitutionPart({
    required this.id,
    required this.number,
    required this.name,
    required this.articles,
  });

  String get displayTitle => 'Part $number \u2013 $name';

  String get articleRange {
    final active     = articles.where((a) => !a.isPreamble).toList();
    final hasPreamble = articles.any((a) => a.isPreamble);
    final pre = hasPreamble ? 'Preamble\u2002' : '';
    if (active.isEmpty) return hasPreamble ? 'Preamble' : '\u2014';
    if (active.length == 1) return '${pre}Art.\u00A0${active.first.number}';
    return '${pre}Arts.\u00A0${active.first.number}\u2013${active.last.number}';
  }

  factory ConstitutionPart.fromJson(Map<String, dynamic> json) =>
      ConstitutionPart(
        id:       json['id']     as String,
        number:   json['number'] as String,
        name:     json['name']   as String,
        articles: (json['articles'] as List<dynamic>)
            .map((a) => ConstitutionArticle.fromJson(
                  a as Map<String, dynamic>,
                ))
            .toList(),
      );
}

// ─────────────────────────────────────────────
// MARK: — MOCK CONSTITUTION DATA
// ─────────────────────────────────────────────

abstract final class MockConstitutionData {
  static const List<ConstitutionPart> parts = [

    // ── Part I ──────────────────────────────
    ConstitutionPart(
      id: 'part_1', number: 'I',
      name: 'The Union and its Territory',
      articles: [
        ConstitutionArticle(id: 'pre',   number: 'Preamble', title: 'Preamble of the Constitution of India', isPreamble: true),
        ConstitutionArticle(id: 'a1',    number: '1',  title: 'Name and territory of the Union'),
        ConstitutionArticle(id: 'a2',    number: '2',  title: 'Admission or establishment of new States'),
        ConstitutionArticle(id: 'a3',    number: '3',  title: 'Formation of new States and alteration of areas, boundaries or names of existing States'),
        ConstitutionArticle(id: 'a4',    number: '4',  title: 'Laws made under articles 2 and 3 to provide for amendment of Schedules'),
      ],
    ),

    // ── Part II ─────────────────────────────
    ConstitutionPart(
      id: 'part_2', number: 'II',
      name: 'Citizenship',
      articles: [
        ConstitutionArticle(id: 'a5',   number: '5',  title: 'Citizenship at the commencement of the Constitution'),
        ConstitutionArticle(id: 'a6',   number: '6',  title: 'Rights of citizenship of certain persons who have migrated to India from Pakistan'),
        ConstitutionArticle(id: 'a7',   number: '7',  title: 'Rights of citizenship of certain migrants to Pakistan'),
        ConstitutionArticle(id: 'a8',   number: '8',  title: 'Rights of citizenship of certain persons of Indian origin residing outside India'),
        ConstitutionArticle(id: 'a9',   number: '9',  title: 'Persons voluntarily acquiring citizenship of a foreign State not to be citizens'),
        ConstitutionArticle(id: 'a10',  number: '10', title: 'Continuance of the rights of citizenship'),
        ConstitutionArticle(id: 'a11',  number: '11', title: 'Parliament to regulate the right of citizenship by law'),
      ],
    ),

    // ── Part III ────────────────────────────
    ConstitutionPart(
      id: 'part_3', number: 'III',
      name: 'Fundamental Rights',
      articles: [
        ConstitutionArticle(id: 'a12',   number: '12',  title: 'Definition'),
        ConstitutionArticle(id: 'a13',   number: '13',  title: 'Laws inconsistent with or in derogation of the fundamental rights'),
        ConstitutionArticle(id: 'a14',   number: '14',  title: 'Equality before law'),
        ConstitutionArticle(id: 'a15',   number: '15',  title: 'Prohibition of discrimination on grounds of religion, race, caste, sex or place of birth'),
        ConstitutionArticle(id: 'a16',   number: '16',  title: 'Equality of opportunity in matters of public employment'),
        ConstitutionArticle(id: 'a17',   number: '17',  title: 'Abolition of Untouchability'),
        ConstitutionArticle(id: 'a18',   number: '18',  title: 'Abolition of titles'),
        ConstitutionArticle(id: 'a19',   number: '19',  title: 'Protection of certain rights regarding freedom of speech, etc.'),
        ConstitutionArticle(id: 'a20',   number: '20',  title: 'Protection in respect of conviction for offences'),
        ConstitutionArticle(id: 'a21',   number: '21',  title: 'Protection of life and personal liberty'),
        ConstitutionArticle(id: 'a21a',  number: '21A', title: 'Right to education'),
        ConstitutionArticle(id: 'a22',   number: '22',  title: 'Protection against arrest and detention in certain cases'),
        ConstitutionArticle(id: 'a23',   number: '23',  title: 'Prohibition of traffic in human beings and forced labour'),
        ConstitutionArticle(id: 'a24',   number: '24',  title: 'Prohibition of employment of children in factories, etc.'),
        ConstitutionArticle(id: 'a25',   number: '25',  title: 'Freedom of conscience and free profession, practice and propagation of religion'),
        ConstitutionArticle(id: 'a26',   number: '26',  title: 'Freedom to manage religious affairs'),
        ConstitutionArticle(id: 'a27',   number: '27',  title: 'Freedom as to payment of taxes for promotion of any particular religion'),
        ConstitutionArticle(id: 'a28',   number: '28',  title: 'Freedom as to attendance at religious instruction or worship in certain educational institutions'),
        ConstitutionArticle(id: 'a29',   number: '29',  title: 'Protection of interests of minorities'),
        ConstitutionArticle(id: 'a30',   number: '30',  title: 'Right of minorities to establish and administer educational institutions'),
        ConstitutionArticle(id: 'a31',   number: '31',  title: 'Compulsory acquisition of property', isOmitted: true),
        ConstitutionArticle(id: 'a31a',  number: '31A', title: 'Saving of laws providing for acquisition of estates, etc.'),
        ConstitutionArticle(id: 'a31b',  number: '31B', title: 'Validation of certain Acts and Regulations'),
        ConstitutionArticle(id: 'a31c',  number: '31C', title: 'Saving of laws giving effect to certain directive principles'),
        ConstitutionArticle(id: 'a32',   number: '32',  title: 'Remedies for enforcement of rights conferred by this Part'),
        ConstitutionArticle(id: 'a32a',  number: '32A', title: 'Constitutional validity of State laws not to be considered in proceedings', isOmitted: true),
        ConstitutionArticle(id: 'a33',   number: '33',  title: 'Power of Parliament to modify rights in their application to Forces, etc.'),
        ConstitutionArticle(id: 'a34',   number: '34',  title: 'Restriction on rights conferred by this Part while martial law is in force'),
        ConstitutionArticle(id: 'a35',   number: '35',  title: 'Legislation to give effect to the provisions of this Part'),
      ],
    ),

    // ── Part IV ─────────────────────────────
    ConstitutionPart(
      id: 'part_4', number: 'IV',
      name: 'Directive Principles of State Policy',
      articles: [
        ConstitutionArticle(id: 'a36',   number: '36',  title: 'Definition'),
        ConstitutionArticle(id: 'a37',   number: '37',  title: 'Application of the principles contained in this Part'),
        ConstitutionArticle(id: 'a38',   number: '38',  title: 'State to secure a social order for the promotion of welfare of the people'),
        ConstitutionArticle(id: 'a39',   number: '39',  title: 'Certain principles of policy to be followed by the State'),
        ConstitutionArticle(id: 'a39a',  number: '39A', title: 'Equal justice and free legal aid'),
        ConstitutionArticle(id: 'a40',   number: '40',  title: 'Organisation of village panchayats'),
        ConstitutionArticle(id: 'a41',   number: '41',  title: 'Right to work, to education and to public assistance in certain cases'),
        ConstitutionArticle(id: 'a42',   number: '42',  title: 'Provision for just and humane conditions of work and maternity relief'),
        ConstitutionArticle(id: 'a43',   number: '43',  title: 'Living wage, etc., for workers'),
        ConstitutionArticle(id: 'a43a',  number: '43A', title: 'Participation of workers in management of industries'),
        ConstitutionArticle(id: 'a43b',  number: '43B', title: 'Promotion of co-operative societies'),
        ConstitutionArticle(id: 'a44',   number: '44',  title: 'Uniform civil code for the citizens'),
        ConstitutionArticle(id: 'a45',   number: '45',  title: 'Provision for early childhood care and education to children below the age of six years'),
        ConstitutionArticle(id: 'a46',   number: '46',  title: 'Promotion of educational and economic interests of Scheduled Castes, Scheduled Tribes and other weaker sections'),
        ConstitutionArticle(id: 'a47',   number: '47',  title: 'Duty of the State to raise the level of nutrition and the standard of living and to improve public health'),
        ConstitutionArticle(id: 'a48',   number: '48',  title: 'Organisation of agriculture and animal husbandry'),
        ConstitutionArticle(id: 'a48a',  number: '48A', title: 'Protection and improvement of environment and safeguarding of forests and wild life'),
        ConstitutionArticle(id: 'a49',   number: '49',  title: 'Protection of monuments and places and objects of national importance'),
        ConstitutionArticle(id: 'a50',   number: '50',  title: 'Separation of judiciary from executive'),
        ConstitutionArticle(id: 'a51',   number: '51',  title: 'Promotion of international peace and security'),
      ],
    ),

    // ── Part IVA ────────────────────────────
    ConstitutionPart(
      id: 'part_4a', number: 'IVA',
      name: 'Fundamental Duties',
      articles: [
        ConstitutionArticle(id: 'a51a', number: '51A', title: 'Fundamental duties'),
      ],
    ),

    // ── Part V ──────────────────────────────
    ConstitutionPart(
      id: 'part_5', number: 'V',
      name: 'The Union',
      articles: [
        ConstitutionArticle(id: 'a52',   number: '52',  title: 'The President of India'),
        ConstitutionArticle(id: 'a53',   number: '53',  title: 'Executive power of the Union'),
        ConstitutionArticle(id: 'a54',   number: '54',  title: 'Election of President'),
        ConstitutionArticle(id: 'a55',   number: '55',  title: 'Manner of election of President'),
        ConstitutionArticle(id: 'a56',   number: '56',  title: 'Term of office of President'),
        ConstitutionArticle(id: 'a57',   number: '57',  title: 'Eligibility for re-election'),
        ConstitutionArticle(id: 'a58',   number: '58',  title: 'Qualifications for election as President'),
        ConstitutionArticle(id: 'a60',   number: '60',  title: 'Oath or affirmation by the President'),
        ConstitutionArticle(id: 'a61',   number: '61',  title: 'Procedure for impeachment of the President'),
        ConstitutionArticle(id: 'a63',   number: '63',  title: 'The Vice-President of India'),
        ConstitutionArticle(id: 'a72',   number: '72',  title: 'Power of President to grant pardons, etc., and to suspend, remit or commute sentences in certain cases'),
        ConstitutionArticle(id: 'a74',   number: '74',  title: 'Council of Ministers to aid and advise President'),
        ConstitutionArticle(id: 'a75',   number: '75',  title: 'Other provisions as to Ministers'),
        ConstitutionArticle(id: 'a76',   number: '76',  title: 'Attorney-General for India'),
        ConstitutionArticle(id: 'a79',   number: '79',  title: 'Constitution of Parliament'),
        ConstitutionArticle(id: 'a80',   number: '80',  title: 'Composition of the Council of States'),
        ConstitutionArticle(id: 'a81',   number: '81',  title: 'Composition of the House of the People'),
        ConstitutionArticle(id: 'a100',  number: '100', title: 'Voting in Houses, power of Houses to act notwithstanding vacancies and quorum'),
        ConstitutionArticle(id: 'a108',  number: '108', title: 'Joint sitting of both Houses in certain cases'),
        ConstitutionArticle(id: 'a110',  number: '110', title: 'Definition of \u201CMoney Bills\u201D'),
        ConstitutionArticle(id: 'a111',  number: '111', title: 'Assent to Bills'),
        ConstitutionArticle(id: 'a112',  number: '112', title: 'Annual financial statement'),
        ConstitutionArticle(id: 'a123',  number: '123', title: 'Power of President to promulgate Ordinances during recess of Parliament'),
        ConstitutionArticle(id: 'a124',  number: '124', title: 'Establishment and constitution of Supreme Court'),
        ConstitutionArticle(id: 'a131',  number: '131', title: 'Original jurisdiction of the Supreme Court'),
        ConstitutionArticle(id: 'a136',  number: '136', title: 'Special leave to appeal by the Supreme Court'),
        ConstitutionArticle(id: 'a137',  number: '137', title: 'Review of judgments or orders by the Supreme Court'),
        ConstitutionArticle(id: 'a141',  number: '141', title: 'Law declared by Supreme Court to be binding on all courts'),
        ConstitutionArticle(id: 'a142',  number: '142', title: 'Enforcement of decrees and orders of Supreme Court'),
        ConstitutionArticle(id: 'a143',  number: '143', title: 'Power of President to consult Supreme Court'),
        ConstitutionArticle(id: 'a148',  number: '148', title: 'Comptroller and Auditor-General of India'),
      ],
    ),

    // ── Part VI ─────────────────────────────
    ConstitutionPart(
      id: 'part_6', number: 'VI',
      name: 'The States',
      articles: [
        ConstitutionArticle(id: 'a152',  number: '152', title: 'Definition'),
        ConstitutionArticle(id: 'a153',  number: '153', title: 'Governors of States'),
        ConstitutionArticle(id: 'a154',  number: '154', title: 'Executive power of State'),
        ConstitutionArticle(id: 'a155',  number: '155', title: 'Appointment of Governor'),
        ConstitutionArticle(id: 'a156',  number: '156', title: 'Term of office of Governor'),
        ConstitutionArticle(id: 'a161',  number: '161', title: 'Power of Governor to grant pardons, etc.'),
        ConstitutionArticle(id: 'a163',  number: '163', title: 'Council of Ministers to aid and advise Governor'),
        ConstitutionArticle(id: 'a164',  number: '164', title: 'Other provisions as to Ministers'),
        ConstitutionArticle(id: 'a165',  number: '165', title: 'Advocate-General for the State'),
        ConstitutionArticle(id: 'a168',  number: '168', title: 'Constitution of Legislatures in States'),
        ConstitutionArticle(id: 'a200',  number: '200', title: 'Assent to Bills'),
        ConstitutionArticle(id: 'a213',  number: '213', title: 'Power of Governor to promulgate Ordinances during recess of Legislature'),
        ConstitutionArticle(id: 'a214',  number: '214', title: 'High Courts for States'),
        ConstitutionArticle(id: 'a215',  number: '215', title: 'High Courts to be courts of record'),
        ConstitutionArticle(id: 'a216',  number: '216', title: 'Constitution of High Courts'),
        ConstitutionArticle(id: 'a226',  number: '226', title: 'Power of High Courts to issue certain writs'),
        ConstitutionArticle(id: 'a227',  number: '227', title: 'Power of superintendence over all courts by the High Court'),
        ConstitutionArticle(id: 'a233',  number: '233', title: 'Appointment of district judges'),
        ConstitutionArticle(id: 'a235',  number: '235', title: 'Control over subordinate courts'),
      ],
    ),

    // ── Part VII ────────────────────────────
    ConstitutionPart(
      id: 'part_7', number: 'VII',
      name: 'The States in Part B of the First Schedule',
      articles: [
        ConstitutionArticle(id: 'a238', number: '238', title: 'Application of provisions of Part VI to States in Part B of the First Schedule', isRepealed: true),
      ],
    ),

    // ── Part VIII ───────────────────────────
    ConstitutionPart(
      id: 'part_8', number: 'VIII',
      name: 'The Union Territories',
      articles: [
        ConstitutionArticle(id: 'a239',    number: '239',   title: 'Administration of Union territories'),
        ConstitutionArticle(id: 'a239a',   number: '239A',  title: 'Creation of local Legislatures or Council of Ministers or both for certain Union territories'),
        ConstitutionArticle(id: 'a239aa',  number: '239AA', title: 'Special provisions with respect to Delhi'),
        ConstitutionArticle(id: 'a239b',   number: '239B',  title: 'Power of administrator to promulgate Ordinances during recess of Legislature'),
        ConstitutionArticle(id: 'a240',    number: '240',   title: 'Power of President to make regulations for certain Union territories'),
        ConstitutionArticle(id: 'a241',    number: '241',   title: 'High Courts for Union territories'),
        ConstitutionArticle(id: 'a242',    number: '242',   title: 'Coorg', isRepealed: true),
      ],
    ),

    // ── Part IX ─────────────────────────────
    ConstitutionPart(
      id: 'part_9', number: 'IX',
      name: 'The Panchayats',
      articles: [
        ConstitutionArticle(id: 'a243',    number: '243',   title: 'Definitions'),
        ConstitutionArticle(id: 'a243a',   number: '243A',  title: 'Gram Sabha'),
        ConstitutionArticle(id: 'a243b',   number: '243B',  title: 'Constitution of Panchayats'),
        ConstitutionArticle(id: 'a243c',   number: '243C',  title: 'Composition of Panchayats'),
        ConstitutionArticle(id: 'a243d',   number: '243D',  title: 'Reservation of seats'),
        ConstitutionArticle(id: 'a243e',   number: '243E',  title: 'Duration of Panchayats, etc.'),
        ConstitutionArticle(id: 'a243f',   number: '243F',  title: 'Disqualifications for membership'),
        ConstitutionArticle(id: 'a243g',   number: '243G',  title: 'Powers, authority and responsibilities of Panchayats'),
        ConstitutionArticle(id: 'a243h',   number: '243H',  title: 'Powers to impose taxes by, and funds of, the Panchayats'),
        ConstitutionArticle(id: 'a243i',   number: '243I',  title: 'Constitution of Finance Commission to review financial position'),
        ConstitutionArticle(id: 'a243k',   number: '243K',  title: 'Elections to the Panchayats'),
        ConstitutionArticle(id: 'a243l',   number: '243L',  title: 'Application to Union territories'),
        ConstitutionArticle(id: 'a243m',   number: '243M',  title: 'Part not to apply to certain areas'),
        ConstitutionArticle(id: 'a243n',   number: '243N',  title: 'Continuance of existing laws and Panchayats'),
        ConstitutionArticle(id: 'a243o',   number: '243O',  title: 'Bar to interference by courts in electoral matters'),
      ],
    ),

    // ── Part IXA ────────────────────────────
    ConstitutionPart(
      id: 'part_9a', number: 'IXA',
      name: 'The Municipalities',
      articles: [
        ConstitutionArticle(id: 'a243p',   number: '243P',  title: 'Definitions'),
        ConstitutionArticle(id: 'a243q',   number: '243Q',  title: 'Constitution of Municipalities'),
        ConstitutionArticle(id: 'a243r',   number: '243R',  title: 'Composition of Municipalities'),
        ConstitutionArticle(id: 'a243s',   number: '243S',  title: 'Constitution and composition of Wards Committees, etc.'),
        ConstitutionArticle(id: 'a243t',   number: '243T',  title: 'Reservation of seats'),
        ConstitutionArticle(id: 'a243u',   number: '243U',  title: 'Duration of Municipalities, etc.'),
        ConstitutionArticle(id: 'a243w',   number: '243W',  title: 'Powers, authority and responsibilities of Municipalities, etc.'),
        ConstitutionArticle(id: 'a243x',   number: '243X',  title: 'Power to impose taxes by, and funds of, the Municipalities'),
        ConstitutionArticle(id: 'a243y',   number: '243Y',  title: 'Finance Commission'),
        ConstitutionArticle(id: 'a243z',   number: '243Z',  title: 'Audit of accounts of Municipalities'),
        ConstitutionArticle(id: 'a243za',  number: '243ZA', title: 'Elections to the Municipalities'),
        ConstitutionArticle(id: 'a243zd',  number: '243ZD', title: 'Committee for district planning'),
        ConstitutionArticle(id: 'a243ze',  number: '243ZE', title: 'Committee for Metropolitan planning'),
        ConstitutionArticle(id: 'a243zg',  number: '243ZG', title: 'Bar to interference by courts in electoral matters'),
      ],
    ),

    // ── Part IXB ────────────────────────────
    ConstitutionPart(
      id: 'part_9b', number: 'IXB',
      name: 'The Co-operative Societies',
      articles: [
        ConstitutionArticle(id: 'a243zh',  number: '243ZH', title: 'Definitions'),
        ConstitutionArticle(id: 'a243zi',  number: '243ZI', title: 'Incorporation of co-operative societies'),
        ConstitutionArticle(id: 'a243zj',  number: '243ZJ', title: 'Number and term of members of board and its office bearers'),
        ConstitutionArticle(id: 'a243zk',  number: '243ZK', title: 'Election of members of board'),
        ConstitutionArticle(id: 'a243zl',  number: '243ZL', title: 'Supersession and suspension of board and interim management'),
        ConstitutionArticle(id: 'a243zm',  number: '243ZM', title: 'Audit of accounts of co-operative societies'),
        ConstitutionArticle(id: 'a243zn',  number: '243ZN', title: 'Convening of general meetings'),
        ConstitutionArticle(id: 'a243zo',  number: '243ZO', title: 'Right of a member to get information'),
        ConstitutionArticle(id: 'a243zp',  number: '243ZP', title: 'Returns'),
        ConstitutionArticle(id: 'a243zq',  number: '243ZQ', title: 'Offences and penalties'),
        ConstitutionArticle(id: 'a243zr',  number: '243ZR', title: 'Application to multi-State co-operative societies'),
        ConstitutionArticle(id: 'a243zt',  number: '243ZT', title: 'Continuance of existing laws'),
      ],
    ),

    // ── Part X ──────────────────────────────
    ConstitutionPart(
      id: 'part_10', number: 'X',
      name: 'The Scheduled and Tribal Areas',
      articles: [
        ConstitutionArticle(id: 'a244',   number: '244',  title: 'Administration of Scheduled Areas and Tribal Areas'),
        ConstitutionArticle(id: 'a244a',  number: '244A', title: 'Formation of an autonomous State comprising certain tribal areas in Assam'),
      ],
    ),

    // ── Part XI ─────────────────────────────
    ConstitutionPart(
      id: 'part_11', number: 'XI',
      name: 'Relations between the Union and the States',
      articles: [
        ConstitutionArticle(id: 'a245',   number: '245',  title: 'Extent of laws made by Parliament and by the Legislatures of States'),
        ConstitutionArticle(id: 'a246',   number: '246',  title: 'Subject-matter of laws made by Parliament and by the Legislatures of States'),
        ConstitutionArticle(id: 'a246a',  number: '246A', title: 'Special provision with respect to goods and services tax'),
        ConstitutionArticle(id: 'a248',   number: '248',  title: 'Residuary powers of legislation'),
        ConstitutionArticle(id: 'a249',   number: '249',  title: 'Power of Parliament to legislate with respect to a matter in the State List'),
        ConstitutionArticle(id: 'a250',   number: '250',  title: 'Power of Parliament to legislate with respect to any matter in the State List if a Proclamation of Emergency is in operation'),
        ConstitutionArticle(id: 'a252',   number: '252',  title: 'Power of Parliament to legislate for two or more States by consent'),
        ConstitutionArticle(id: 'a253',   number: '253',  title: 'Legislation for giving effect to international agreements'),
        ConstitutionArticle(id: 'a254',   number: '254',  title: 'Inconsistency between laws made by Parliament and laws made by the Legislatures of States'),
        ConstitutionArticle(id: 'a256',   number: '256',  title: 'Obligation of States and the Union'),
        ConstitutionArticle(id: 'a257',   number: '257',  title: 'Control of the Union over States in certain cases'),
        ConstitutionArticle(id: 'a261',   number: '261',  title: 'Public acts, records and judicial proceedings'),
        ConstitutionArticle(id: 'a262',   number: '262',  title: 'Adjudication of disputes relating to waters of inter-State rivers or river valleys'),
        ConstitutionArticle(id: 'a263',   number: '263',  title: 'Provisions with respect to an inter-State Council'),
      ],
    ),

    // ── Part XII ────────────────────────────
    ConstitutionPart(
      id: 'part_12', number: 'XII',
      name: 'Finance, Property, Contracts and Suits',
      articles: [
        ConstitutionArticle(id: 'a265',   number: '265',  title: 'Taxes not to be imposed save by authority of law'),
        ConstitutionArticle(id: 'a266',   number: '266',  title: 'Consolidated Funds and public accounts of India and of the States'),
        ConstitutionArticle(id: 'a267',   number: '267',  title: 'Contingency Fund'),
        ConstitutionArticle(id: 'a268',   number: '268',  title: 'Duties levied by the Union but collected and appropriated by the States'),
        ConstitutionArticle(id: 'a270',   number: '270',  title: 'Taxes levied and distributed between the Union and the States'),
        ConstitutionArticle(id: 'a280',   number: '280',  title: 'Finance Commission'),
        ConstitutionArticle(id: 'a282',   number: '282',  title: 'Expenditure defrayable by the Union or a State out of its revenues'),
        ConstitutionArticle(id: 'a300',   number: '300',  title: 'Suits and proceedings'),
        ConstitutionArticle(id: 'a300a',  number: '300A', title: 'Persons not to be deprived of property save by authority of law'),
      ],
    ),

    // ── Part XIII ───────────────────────────
    ConstitutionPart(
      id: 'part_13', number: 'XIII',
      name: 'Trade, Commerce and Intercourse within the Territory of India',
      articles: [
        ConstitutionArticle(id: 'a301', number: '301', title: 'Freedom of trade, commerce and intercourse'),
        ConstitutionArticle(id: 'a302', number: '302', title: 'Power of Parliament to impose restrictions on trade, commerce and intercourse'),
        ConstitutionArticle(id: 'a303', number: '303', title: 'Restrictions on the legislative powers of Parliament and of the States with regard to trade and commerce'),
        ConstitutionArticle(id: 'a304', number: '304', title: 'Restrictions on trade, commerce and intercourse among States'),
        ConstitutionArticle(id: 'a305', number: '305', title: 'Saving of existing laws and laws providing for State monopolies'),
        ConstitutionArticle(id: 'a306', number: '306', title: 'Power of certain States in Part B of the First Schedule to impose restrictions', isRepealed: true),
        ConstitutionArticle(id: 'a307', number: '307', title: 'Appointment of authority for carrying out the purposes of articles 301 to 304'),
      ],
    ),

    // ── Part XIV ────────────────────────────
    ConstitutionPart(
      id: 'part_14', number: 'XIV',
      name: 'Services under the Union and the States',
      articles: [
        ConstitutionArticle(id: 'a308', number: '308', title: 'Interpretation'),
        ConstitutionArticle(id: 'a309', number: '309', title: 'Recruitment and conditions of service of persons serving the Union or a State'),
        ConstitutionArticle(id: 'a310', number: '310', title: 'Tenure of office of persons serving the Union or a State'),
        ConstitutionArticle(id: 'a311', number: '311', title: 'Dismissal, removal or reduction in rank of persons employed in civil capacities under the Union or a State'),
        ConstitutionArticle(id: 'a312', number: '312', title: 'All-India services'),
        ConstitutionArticle(id: 'a315', number: '315', title: 'Public Service Commissions for the Union and for the States'),
        ConstitutionArticle(id: 'a316', number: '316', title: 'Appointment and term of office of members'),
        ConstitutionArticle(id: 'a317', number: '317', title: 'Removal and suspension of a member of a Public Service Commission'),
        ConstitutionArticle(id: 'a320', number: '320', title: 'Functions of Public Service Commissions'),
        ConstitutionArticle(id: 'a323', number: '323', title: 'Reports of Public Service Commissions'),
      ],
    ),

    // ── Part XIVA ───────────────────────────
    ConstitutionPart(
      id: 'part_14a', number: 'XIVA',
      name: 'Tribunals',
      articles: [
        ConstitutionArticle(id: 'a323a', number: '323A', title: 'Administrative tribunals'),
        ConstitutionArticle(id: 'a323b', number: '323B', title: 'Tribunals for other matters'),
      ],
    ),

    // ── Part XV ─────────────────────────────
    ConstitutionPart(
      id: 'part_15', number: 'XV',
      name: 'Elections',
      articles: [
        ConstitutionArticle(id: 'a324',  number: '324',  title: 'Superintendence, direction and control of elections to be vested in an Election Commission'),
        ConstitutionArticle(id: 'a325',  number: '325',  title: 'No person to be ineligible for inclusion in, or to claim to be included in a special, electoral roll on grounds of religion, race, caste or sex'),
        ConstitutionArticle(id: 'a326',  number: '326',  title: 'Elections to the House of the People and to the Legislative Assemblies of States to be on the basis of adult suffrage'),
        ConstitutionArticle(id: 'a327',  number: '327',  title: 'Power of Parliament to make provision with respect to elections to Legislatures'),
        ConstitutionArticle(id: 'a328',  number: '328',  title: 'Power of Legislature of a State to make provision with respect to elections to such Legislature'),
        ConstitutionArticle(id: 'a329',  number: '329',  title: 'Bar to interference by courts in electoral matters'),
        ConstitutionArticle(id: 'a329a', number: '329A', title: 'Special provision as to elections to Parliament in the case of Prime Minister and Speaker', isRepealed: true),
      ],
    ),

    // ── Part XVI ────────────────────────────
    ConstitutionPart(
      id: 'part_16', number: 'XVI',
      name: 'Special Provisions Relating to Certain Classes',
      articles: [
        ConstitutionArticle(id: 'a330',   number: '330',  title: 'Reservation of seats for Scheduled Castes and Scheduled Tribes in the House of the People'),
        ConstitutionArticle(id: 'a332',   number: '332',  title: 'Reservation of seats for Scheduled Castes and Scheduled Tribes in the Legislative Assemblies of the States'),
        ConstitutionArticle(id: 'a334',   number: '334',  title: 'Reservation of seats and special representation to cease after certain period'),
        ConstitutionArticle(id: 'a335',   number: '335',  title: 'Claims of Scheduled Castes and Scheduled Tribes to services and posts'),
        ConstitutionArticle(id: 'a338',   number: '338',  title: 'National Commission for Scheduled Castes'),
        ConstitutionArticle(id: 'a338a',  number: '338A', title: 'National Commission for Scheduled Tribes'),
        ConstitutionArticle(id: 'a338b',  number: '338B', title: 'National Commission for Backward Classes'),
        ConstitutionArticle(id: 'a340',   number: '340',  title: 'Appointment of a Commission to investigate the conditions of backward classes'),
        ConstitutionArticle(id: 'a341',   number: '341',  title: 'Scheduled Castes'),
        ConstitutionArticle(id: 'a342',   number: '342',  title: 'Scheduled Tribes'),
        ConstitutionArticle(id: 'a342a',  number: '342A', title: 'Socially and educationally backward classes'),
      ],
    ),

    // ── Part XVII ───────────────────────────
    ConstitutionPart(
      id: 'part_17', number: 'XVII',
      name: 'Official Language',
      articles: [
        ConstitutionArticle(id: 'a343',   number: '343',  title: 'Official language of the Union'),
        ConstitutionArticle(id: 'a344',   number: '344',  title: 'Commission and Committee of Parliament on official language'),
        ConstitutionArticle(id: 'a345',   number: '345',  title: 'Official languages of a State'),
        ConstitutionArticle(id: 'a346',   number: '346',  title: 'Official language for communication between one State and another or between a State and the Union'),
        ConstitutionArticle(id: 'a347',   number: '347',  title: 'Special provision relating to language spoken by a section of the population of a State'),
        ConstitutionArticle(id: 'a348',   number: '348',  title: 'Language to be used in the Supreme Court and in the High Courts and for Acts, Bills, etc.'),
        ConstitutionArticle(id: 'a349',   number: '349',  title: 'Special procedure for enactment of certain laws relating to language'),
        ConstitutionArticle(id: 'a350a',  number: '350A', title: 'Facilities for instruction in mother-tongue at primary stage'),
        ConstitutionArticle(id: 'a350b',  number: '350B', title: 'Special Officer for linguistic minorities'),
        ConstitutionArticle(id: 'a351',   number: '351',  title: 'Directive for development of the Hindi language'),
      ],
    ),

    // ── Part XVIII ──────────────────────────
    ConstitutionPart(
      id: 'part_18', number: 'XVIII',
      name: 'Emergency Provisions',
      articles: [
        ConstitutionArticle(id: 'a352', number: '352', title: 'Proclamation of Emergency'),
        ConstitutionArticle(id: 'a353', number: '353', title: 'Effect of Proclamation of Emergency'),
        ConstitutionArticle(id: 'a354', number: '354', title: 'Application of provisions relating to distribution of revenues while a Proclamation of Emergency is in operation'),
        ConstitutionArticle(id: 'a355', number: '355', title: 'Duty of the Union to protect States against external aggression and internal disturbance'),
        ConstitutionArticle(id: 'a356', number: '356', title: 'Provisions in case of failure of constitutional machinery in States'),
        ConstitutionArticle(id: 'a357', number: '357', title: 'Exercise of legislative powers under Proclamation issued under article 356'),
        ConstitutionArticle(id: 'a358', number: '358', title: 'Suspension of provisions of article 19 during emergencies'),
        ConstitutionArticle(id: 'a359', number: '359', title: 'Suspension of the enforcement of the rights conferred by Part III during emergencies'),
        ConstitutionArticle(id: 'a360', number: '360', title: 'Provisions as to financial emergency'),
      ],
    ),

    // ── Part XIX ────────────────────────────
    ConstitutionPart(
      id: 'part_19', number: 'XIX',
      name: 'Miscellaneous',
      articles: [
        ConstitutionArticle(id: 'a361',   number: '361',  title: 'Protection of President and Governors and Rajpramukhs'),
        ConstitutionArticle(id: 'a361a',  number: '361A', title: 'Protection of publication of proceedings of Parliament and State Legislatures'),
        ConstitutionArticle(id: 'a362',   number: '362',  title: 'Rights and privileges of Rulers of Indian States', isOmitted: true),
        ConstitutionArticle(id: 'a363',   number: '363',  title: 'Bar to interference by courts in disputes arising out of certain treaties, agreements, etc.'),
        ConstitutionArticle(id: 'a363a',  number: '363A', title: 'Recognition granted to Rulers of Indian States to cease and privy purses to be abolished'),
        ConstitutionArticle(id: 'a365',   number: '365',  title: 'Effect of failure to comply with, or to give effect to, directions given by the Union'),
        ConstitutionArticle(id: 'a366',   number: '366',  title: 'Definitions'),
        ConstitutionArticle(id: 'a367',   number: '367',  title: 'Interpretation'),
      ],
    ),

    // ── Part XX ─────────────────────────────
    ConstitutionPart(
      id: 'part_20', number: 'XX',
      name: 'Amendment of the Constitution',
      articles: [
        ConstitutionArticle(id: 'a368', number: '368', title: 'Power of Parliament to amend the Constitution and procedure therefor'),
      ],
    ),

    // ── Part XXI ────────────────────────────
    ConstitutionPart(
      id: 'part_21', number: 'XXI',
      name: 'Temporary, Transitional and Special Provisions',
      articles: [
        ConstitutionArticle(id: 'a369',   number: '369',  title: 'Temporary power to Parliament to make laws with respect to certain matters in the State List'),
        ConstitutionArticle(id: 'a370',   number: '370',  title: 'Temporary provisions with respect to the State of Jammu and Kashmir'),
        ConstitutionArticle(id: 'a371',   number: '371',  title: 'Special provision with respect to the States of Maharashtra and Gujarat'),
        ConstitutionArticle(id: 'a371a',  number: '371A', title: 'Special provision with respect to the State of Nagaland'),
        ConstitutionArticle(id: 'a371b',  number: '371B', title: 'Special provision with respect to the State of Assam'),
        ConstitutionArticle(id: 'a371c',  number: '371C', title: 'Special provision with respect to the State of Manipur'),
        ConstitutionArticle(id: 'a371d',  number: '371D', title: 'Special provisions with respect to the State of Andhra Pradesh or the State of Telangana'),
        ConstitutionArticle(id: 'a371f',  number: '371F', title: 'Special provisions with respect to the State of Sikkim'),
        ConstitutionArticle(id: 'a371g',  number: '371G', title: 'Special provision with respect to the State of Mizoram'),
        ConstitutionArticle(id: 'a371h',  number: '371H', title: 'Special provision with respect to the State of Arunachal Pradesh'),
        ConstitutionArticle(id: 'a371i',  number: '371I', title: 'Special provision with respect to the State of Goa'),
        ConstitutionArticle(id: 'a371j',  number: '371J', title: 'Special provisions with respect to the State of Karnataka'),
        ConstitutionArticle(id: 'a372',   number: '372',  title: 'Continuance in force of existing laws and their adaptation'),
        ConstitutionArticle(id: 'a373',   number: '373',  title: 'Power of President to make order in respect of persons under preventive detention in certain cases'),
        ConstitutionArticle(id: 'a392',   number: '392',  title: 'Power of the President to remove difficulties'),
      ],
    ),

    // ── Part XXII ───────────────────────────
    ConstitutionPart(
      id: 'part_22', number: 'XXII',
      name: 'Short Title, Commencement, Authoritative Text in Hindi and Repeals',
      articles: [
        ConstitutionArticle(id: 'a393',  number: '393',  title: 'Short title'),
        ConstitutionArticle(id: 'a394',  number: '394',  title: 'Commencement'),
        ConstitutionArticle(id: 'a394a', number: '394A', title: 'Authoritative text in the Hindi language'),
        ConstitutionArticle(id: 'a395',  number: '395',  title: 'Repeals'),
      ],
    ),
  ];
}

// ─────────────────────────────────────────────
// MARK: — CONSTITUTION SCREEN
// ─────────────────────────────────────────────

class ConstitutionScreen extends StatefulWidget {
  final ValueChanged<ConstitutionArticle>? onArticleTap;
  final String? initialPartId;

  const ConstitutionScreen({
    super.key,
    this.onArticleTap,
    this.initialPartId,
  });

  @override
  State<ConstitutionScreen> createState() => _ConstitutionScreenState();
}

class _ConstitutionScreenState extends State<ConstitutionScreen>
    with TickerProviderStateMixin {

  // ── Controllers ───────────────────────────────
  late final List<AnimationController> _partControllers;
  late final AnimationController _entranceController;
  final ScrollController _scrollController = ScrollController();

  // ── Accordion state ───────────────────────────
  int?  _expandedIndex;
  bool  _entranceDone = false;

  // ── Entrance animations ───────────────────────
  late final Animation<double> _appBarFade;
  late final Animation<double> _infoFade;
  late final Animation<Offset>  _infoSlide;
  late final List<Animation<double>> _partFades;
  late final List<Animation<Offset>>  _partSlides;

  static const int _maxStagger = 10;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initControllers();
    _setupEntranceAnimations();
    _startEntrance();
    _applyInitialPart();
  }

  void _applyInitialPart() {
    if (widget.initialPartId == null) return;
    final index = MockConstitutionData.parts
        .indexWhere((p) => p.id == widget.initialPartId);
    if (index >= 0) {
      _expandedIndex = index;
    }
  }

  void _initControllers() {
    _partControllers = List.generate(
      MockConstitutionData.parts.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 340),
      ),
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _setupEntranceAnimations() {
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.38, curve: Curves.easeOut),
      ),
    );
    _infoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.48, curve: Curves.easeOut),
      ),
    );
    _infoSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.52, curve: Curves.easeOutCubic),
      ),
    );

    final n = MockConstitutionData.parts.length;
    _partFades = List.generate(n, (i) {
      final si = i.clamp(0, _maxStagger - 1);
      final s  = (0.22 + si * 0.07).clamp(0.0, 0.88);
      final e  = (s + 0.25).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });

    _partSlides = List.generate(n, (i) {
      final si = i.clamp(0, _maxStagger - 1);
      final s  = (0.22 + si * 0.07).clamp(0.0, 0.88);
      final e  = (s + 0.32).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  void _startEntrance() {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _entranceController.forward().then((_) {
        if (mounted) setState(() => _entranceDone = true);
      });
      if (_expandedIndex != null) {
        _partControllers[_expandedIndex!].forward();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _partControllers) c.dispose();
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACCORDION
  // ─────────────────────────────────────────────

  void _togglePart(int index) {
    HapticFeedback.lightImpact();
    if (_expandedIndex == index) {
      _partControllers[index].reverse();
      setState(() => _expandedIndex = null);
    } else {
      if (_expandedIndex != null) {
        _partControllers[_expandedIndex!].reverse();
      }
      _partControllers[index].forward();
      setState(() => _expandedIndex = index);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — HELPERS
  // ─────────────────────────────────────────────

  Animation<double> _fadeAt(int i) {
    if (_entranceDone) return const AlwaysStoppedAnimation<double>(1.0);
    return _partFades[i];
  }

  Animation<Offset> _slideAt(int i) {
    if (_entranceDone) return const AlwaysStoppedAnimation<Offset>(Offset.zero);
    return _partSlides[i];
  }

  // ─────────────────────────────────────────────
  // MARK: — ARTICLE TAP → READER SCREEN
  // ─────────────────────────────────────────────

  void _handleArticleTap(ConstitutionPart part, ConstitutionArticle article) {
    HapticFeedback.lightImpact();

    // Notify external listener if provided (e.g. analytics)
    widget.onArticleTap?.call(article);

    // Navigate to ReaderScreen via GoRouter, passing partId + articleId
    context.goConstitutionReader(
      partId:    part.id,
      articleId: article.id,
      args: ConstitutionReaderArgs(
        partId:       part.id,
        partName:     part.name,
        articleId:    article.id,
        articleTitle: article.title,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(dark),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _ConstitutionBackground(isDark: dark),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),

              // Info strip
              FadeTransition(
                opacity: _infoFade,
                child: SlideTransition(
                  position: _infoSlide,
                  child: _ConstitutionInfoStrip(isDark: dark),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Parts list
              Expanded(child: _buildPartsList(dark)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool dark) => GlassAppBar(
        titleWidget: FadeTransition(
          opacity: _appBarFade,
          child: Text(
            'Constitution of India',
            style: AppTypography.titleLarge.copyWith(
              color: dark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leading: FadeTransition(
          opacity: _appBarFade,
          child: _GlassBackButton(isDark: dark),
        ),
        actions: [
          FadeTransition(
            opacity: _appBarFade,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.base),
              child: Center(child: _GlassSearchButton(isDark: dark)),
            ),
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // MARK: — PARTS LIST
  // ─────────────────────────────────────────────

  Widget _buildPartsList(bool dark) {
    final parts = MockConstitutionData.parts;
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, AppSpacing.max,
      ),
      itemCount: parts.length,
      itemBuilder: (context, i) {
        final part = parts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: FadeTransition(
            opacity: _fadeAt(i),
            child: SlideTransition(
              position: _slideAt(i),
              child: _PartCard(
                part: part,
                isExpanded: _expandedIndex == i,
                expansionAnim: _partControllers[i],
                isDark: dark,
                onHeaderTap: () => _togglePart(i),
                onArticleTap: (article) => _handleArticleTap(part, article),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — CONSTITUTION INFO STRIP
// ─────────────────────────────────────────────

class _ConstitutionInfoStrip extends StatelessWidget {
  final bool isDark;
  const _ConstitutionInfoStrip({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, 0,
        ),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _InfoPill(label: 'Adopted 26 Nov 1949',  icon: Icons.history_edu_outlined, isDark: isDark),
            _InfoPill(label: 'In Force 26 Jan 1950', icon: Icons.flag_outlined,         isDark: isDark),
            _InfoPill(label: '22+ Parts · 395 Articles', icon: Icons.article_outlined,  isDark: isDark),
          ],
        ),
      );
}

class _InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _InfoPill({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0x14FFFFFF)
              : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isDark
                ? const Color(0x18FFFFFF)
                : const Color(0x0D000000),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
            const SizedBox(width: 4),
            Text(label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10.5,
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — PART CARD
// ─────────────────────────────────────────────

class _PartCard extends StatelessWidget {
  final ConstitutionPart part;
  final bool isExpanded;
  final AnimationController expansionAnim;
  final bool isDark;
  final VoidCallback onHeaderTap;
  final ValueChanged<ConstitutionArticle> onArticleTap;

  const _PartCard({
    required this.part,
    required this.isExpanded,
    required this.expansionAnim,
    required this.isDark,
    required this.onHeaderTap,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    final expandCurve = CurvedAnimation(
      parent: expansionAnim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppBlur.md, sigmaY: AppBlur.md,
          tileMode: TileMode.mirror,
        ),
        child: AnimatedBuilder(
          animation: expansionAnim,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Color.lerp(const Color(0x991C1C1E), const Color(0xBF222222), expansionAnim.value)
                  : Color.lerp(const Color(0xCCFFFFFF), const Color(0xE8FFFFFF), expansionAnim.value),
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark
                    ? Color.lerp(const Color(0x1AFFFFFF), const Color(0x2EFFFFFF), expansionAnim.value)!
                    : Color.lerp(const Color(0x33FFFFFF), const Color(0x4DFFFFFF), expansionAnim.value)!,
                width: 0.5,
              ),
              boxShadow: isDark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top highlight
              Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(isDark ? 0.12 : 0.60),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Header
              GestureDetector(
                onTap: onHeaderTap,
                behavior: HitTestBehavior.opaque,
                child: _PartHeader(
                  part: part,
                  expansionAnim: expansionAnim,
                  expandCurve: expandCurve,
                  isDark: isDark,
                ),
              ),

              // Expandable article list
              ClipRect(
                child: SizeTransition(
                  sizeFactor: expandCurve,
                  axisAlignment: -1.0,
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: expansionAnim,
                      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
                    ),
                    child: _ArticleList(
                      articles: part.articles,
                      isDark: isDark,
                      onArticleTap: onArticleTap,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — PART HEADER
// ─────────────────────────────────────────────

class _PartHeader extends StatelessWidget {
  final ConstitutionPart part;
  final AnimationController expansionAnim;
  final Animation<double> expandCurve;
  final bool isDark;

  const _PartHeader({
    required this.part,
    required this.expansionAnim,
    required this.expandCurve,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final baseArrowColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accentColor = isDark ? AppColors.accentLight : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Arrow
          RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 0.25).animate(expandCurve),
            child: AnimatedBuilder(
              animation: expansionAnim,
              builder: (_, __) => Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color.lerp(baseArrowColor, accentColor, expansionAnim.value),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Part title
          Expanded(
            child: AnimatedBuilder(
              animation: expansionAnim,
              builder: (_, child) => Text(
                part.displayTitle,
                style: AppTypography.titleMedium.copyWith(
                  color: Color.lerp(
                    isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    accentColor,
                    expansionAnim.value * 0.35,
                  ),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.15,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Article range chip
          _ArticleRangeChip(range: part.articleRange, isDark: isDark),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — ARTICLE LIST
// ─────────────────────────────────────────────

class _ArticleList extends StatelessWidget {
  final List<ConstitutionArticle> articles;
  final bool isDark;
  final ValueChanged<ConstitutionArticle> onArticleTap;

  const _ArticleList({
    required this.articles,
    required this.isDark,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.darkSeparator : AppColors.lightSeparator,
          ),
          ...articles.map(
            (a) => _ArticleItem(
              article: a,
              isDark: isDark,
              onTap: () => onArticleTap(a),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — ARTICLE ITEM
// ─────────────────────────────────────────────

class _ArticleItem extends StatefulWidget {
  final ConstitutionArticle article;
  final bool isDark;
  final VoidCallback? onTap;

  const _ArticleItem({
    required this.article,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<_ArticleItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark    = widget.isDark;
    final article = widget.article;

    final numberColor = article.isPreamble
        ? AppColors.gold
        : article.isSpecial
            ? (dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText)
            : (dark ? AppColors.accentLight : AppColors.accent);

    final titleColor = article.isSpecial
        ? (dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText)
        : (dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText);

    final statusSuffix = article.isRepealed
        ? ' (Repealed)'
        : article.isOmitted
            ? ' (Omitted)'
            : '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        color: _pressed
            ? numberColor.withOpacity(dark ? 0.10 : 0.06)
            : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indent
            const SizedBox(width: 40),

            // Number column
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: SizedBox(
                width: 48,
                child: Text(
                  article.displayNumber,
                  style: AppTypography.labelMedium.copyWith(
                    color: numberColor,
                    fontWeight: article.isPreamble
                        ? FontWeight.w700
                        : FontWeight.w700,
                    fontSize: article.isPreamble ? 10 : 11.5,
                    letterSpacing: article.isPreamble ? 0.3 : 0.1,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  article.title + statusSuffix,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: null,
                    color: titleColor,
                    height: 1.45,
                    fontSize: 13.5,
                    fontStyle: article.isSpecial ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Chevron
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.md, AppSpacing.base, 0,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: _pressed
                    ? numberColor.withOpacity(0.65)
                    : (dark
                        ? AppColors.darkTertiaryText
                        : AppColors.lightTertiaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — ARTICLE RANGE CHIP
// ─────────────────────────────────────────────

class _ArticleRangeChip extends StatelessWidget {
  final String range;
  final bool isDark;

  const _ArticleRangeChip({required this.range, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? const Color(0x20FFFFFF) : const Color(0x14000000),
            width: 0.5,
          ),
        ),
        child: Text(
          range,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 9.5,
            letterSpacing: 0.05,
            color: isDark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — GLASS BACK BUTTON
// ─────────────────────────────────────────────

class _GlassBackButton extends StatefulWidget {
  final bool isDark;
  const _GlassBackButton({required this.isDark});

  @override
  State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) {
            _press.reverse();
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x1A000000),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 15,
              color: widget.isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — GLASS SEARCH BUTTON (Placeholder)
// ─────────────────────────────────────────────

class _GlassSearchButton extends StatefulWidget {
  final bool isDark;
  const _GlassSearchButton({required this.isDark});

  @override
  State<_GlassSearchButton> createState() => _GlassSearchButtonState();
}

class _GlassSearchButtonState extends State<_GlassSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp:   (_) { _press.reverse(); HapticFeedback.lightImpact(); },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x1A000000),
            ),
            child: Icon(Icons.search_rounded, size: 17,
              color: widget.isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — BACKGROUND
// ─────────────────────────────────────────────

class _ConstitutionBackground extends StatelessWidget {
  final bool isDark;
  const _ConstitutionBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF121212), const Color(0xFF0C0F1A)]
                : [const Color(0xFFF8F5FF), const Color(0xFFFFFFFF), const Color(0xFFFFF8F0)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90, left: -60,
              child: _Orb(size: 280,
                color: AppColors.gold.withOpacity(isDark ? 0.07 : 0.04)),
            ),
            Positioned(
              bottom: -100, right: -50,
              child: _Orb(size: 250,
                color: AppColors.accent.withOpacity(isDark ? 0.07 : 0.04)),
            ),
          ],
        ),
      );
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        ),
      );
}