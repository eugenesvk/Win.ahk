; —————————— Locale win32 Constants ——————————
class localeInfo { ; define the "LOCALE_..." constants
  static __new() { ; get all vars and store their values in this.Varname as well ‘m’ map, and add aliases
    ; LOCALE_IDEFAULTANSICODEPAGE
    ;        IDEFAULTANSICODEPAGE
    static clsNames := ['localeNLS_SubGroups','localeOther']
     , m := Map()
     , replace := Map(
        'LOCALE_' 	,''
      , 'ENGLISH' 	,'En'
      , 'DEFAULT' 	,'Def'
      , 'CODEPAGE'	,'CPg'
      , 'NUMBER'  	,'Num'
      , 'NAME'    	,'Nm'
      , 'LANGUAGE'	,'Lng'
      , 'WINDOWS' 	,'Win'
      )
    m.CaseSense := 0 ; make key matching case insensitive
    this.m := m
    this.lng_id := this.__set_win_lang_id()

    ; some manual adjustments
    this.SUBLANG_DEFAULT    	:= 0x01
    this.SORT_DEFAULT       	:= 0x00
    this.LANG_NEUTRAL       	:= 0x00
    this.LANG_USER_DEFAULT  	:= this.SUBLANG_DEFAULT << 10 | this.LANG_NEUTRAL
    this.LOCALE_USER_DEFAULT	:= this.SORT_DEFAULT    << 16 | this.LANG_USER_DEFAULT
    _list := ['SUBLANG_DEFAULT','SORT_DEFAULT','LANG_NEUTRAL','LANG_USER_DEFAULT','LOCALE_USER_DEFAULT']
    ; msgbox(format("0x{1:X}",this.LOCALE_USER_DEFAULT),format("0x{1:X}",this.LANG_USER_DEFAULT),"T1")
    ; LOCALE_USER_DEFAULT	(MAKELCID(LANG_USER_DEFAULT, SORT_DEFAULT))
    ; LANG_USER_DEFAULT  	(MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT))
      ; LANG_NEUTRAL     	0x00
      ; SUBLANG_DEFAULT  	0x01    // user default
    ; SORT_DEFAULT       	0x0     // sorting default
    ; #define LANG_SYSTEM_DEFAULT    (MAKELANGID(LANG_NEUTRAL, SUBLANG_SYS_DEFAULT))
    ; #define LOCALE_SYSTEM_DEFAULT  (MAKELCID(LANG_SYSTEM_DEFAULT, SORT_DEFAULT))
    ; #define MAKELCID(lgid, srtid)  ((ULONG)((((ULONG)((USHORT)(srtid))) << 16) | ((ULONG)((USHORT)(lgid)))))
    ; #define MAKELANGID(p, s)       (((                (USHORT)(s))      << 10) | (USHORT)(p))
    _dbgtxt := ""
    for _v in _list {
      alias_short := _v ; alias with various substitutes
      for from,to in replace {
        alias_short := StrReplace(where:=alias_short, what:=from, repl:=to, isCase:=1,,maxrepl:=1)
      }
      if not (alias_short = _v) {
        this.%alias_short%	:= this.%_v%
        m[alias_short]    	:= this.%_v%
        ; _dbgtxt .= "pre alias_short " . alias_short . "`n"
      }
    }
    ; msgbox(_dbgtxt,"pre",'T2')
    for i,_cls in clsNames {                 	; localeNLS
      for _map in %_cls%.maps {              	; IDEFAULT
        for locVar, locVal in %_cls%.%_map% {	; LOCALE_IDEFAULTANSICODEPAGE, 0x00011004
          if type(locVal) = "String" {       	; locale variable is a string
            val := this.%locVal%             	; so refers to an already existing locale variable (hopefully it was defined earlier)
          } else {
            val := locVal
          }
          this.%locVar%	:= val
          m[locVar]    	:= this.%locVar%
          if (prefix_start := InStr(where:=locVar, what:='LOCALE_')) { ; alias without ‘locale_’ prefix
            varAlias := SubStr(where, prefix_start + StrLen(what))
            ; _dbgtxt .= "`n varAlias= " varAlias
            this.%varAlias%	:= this.%locVar%
            m[varAlias]    	:= this.%locVar%
          }

          alias_short := locVar ; alias with various substitutes
          for from,to in replace {
            alias_short := StrReplace(where:=alias_short, what:=from, repl:=to, isCase:=1,,maxrepl:=1)
          }
          if not (alias_short = locVar) {
            this.%alias_short%	:= this.%locVar%
            m[alias_short]    	:= this.%locVar%
            ; _dbgtxt .= "`n alias_short= " alias_short
          }
        }
      }
    }
    ; msgbox(_dbgtxt,"len tmap",'T1')
  }

  static __set_win_lang_id() {
    m := Map()
    m.CaseSense := 0
    m.Capacity := 500
      m['ar'               	] := 0x0001
      m['bg'               	] := 0x0002
      m['ca'               	] := 0x0003
      m['zh-Hans'          	] := 0x0004
      m['cs'               	] := 0x0005
      m['da'               	] := 0x0006
      m['de'               	] := 0x0007
      m['el'               	] := 0x0008
      m['en'               	] := 0x0009
      m['es'               	] := 0x000A
      m['fi'               	] := 0x000B
      m['fr'               	] := 0x000C
      m['he'               	] := 0x000D
      m['hu'               	] := 0x000E
      m['is'               	] := 0x000F
      m['it'               	] := 0x0010
      m['ja'               	] := 0x0011
      m['ko'               	] := 0x0012
      m['nl'               	] := 0x0013
      m['no'               	] := 0x0014
      m['pl'               	] := 0x0015
      m['pt'               	] := 0x0016
      m['rm'               	] := 0x0017
      m['ro'               	] := 0x0018
      m['ru'               	] := 0x0019
      m['hr'               	] := 0x001A
      m['sk'               	] := 0x001B
      m['sq'               	] := 0x001C
      m['sv'               	] := 0x001D
      m['th'               	] := 0x001E
      m['tr'               	] := 0x001F
      m['ur'               	] := 0x0020
      m['id'               	] := 0x0021
      m['uk'               	] := 0x0022
      m['be'               	] := 0x0023
      m['sl'               	] := 0x0024
      m['et'               	] := 0x0025
      m['lv'               	] := 0x0026
      m['lt'               	] := 0x0027
      m['tg'               	] := 0x0028
      m['fa'               	] := 0x0029
      m['vi'               	] := 0x002A
      m['hy'               	] := 0x002B
      m['az'               	] := 0x002C
      m['eu'               	] := 0x002D
      m['hsb'              	] := 0x002E
      m['mk'               	] := 0x002F
      m['st'               	] := 0x0030
      m['ts'               	] := 0x0031
      m['tn'               	] := 0x0032
      m['ve'               	] := 0x0033
      m['xh'               	] := 0x0034
      m['zu'               	] := 0x0035
      m['af'               	] := 0x0036
      m['ka'               	] := 0x0037
      m['fo'               	] := 0x0038
      m['hi'               	] := 0x0039
      m['mt'               	] := 0x003A
      m['se'               	] := 0x003B
      m['ga'               	] := 0x003C
      m['yi'               	] := 0x003D
      m['ms'               	] := 0x003E
      m['kk'               	] := 0x003F
      m['ky'               	] := 0x0040
      m['sw'               	] := 0x0041
      m['tk'               	] := 0x0042
      m['uz'               	] := 0x0043
      m['tt'               	] := 0x0044
      m['bn'               	] := 0x0045
      m['pa'               	] := 0x0046
      m['gu'               	] := 0x0047
      m['or'               	] := 0x0048
      m['ta'               	] := 0x0049
      m['te'               	] := 0x004A
      m['kn'               	] := 0x004B
      m['ml'               	] := 0x004C
      m['as'               	] := 0x004D
      m['mr'               	] := 0x004E
      m['sa'               	] := 0x004F
      m['mn'               	] := 0x0050
      m['bo'               	] := 0x0051
      m['cy'               	] := 0x0052
      m['km'               	] := 0x0053
      m['lo'               	] := 0x0054
      m['my'               	] := 0x0055
      m['gl'               	] := 0x0056
      m['kok'              	] := 0x0057
      m['mni'              	] := 0x0058
      m['sd'               	] := 0x0059
      m['syr'              	] := 0x005A
      m['si'               	] := 0x005B
      m['chr'              	] := 0x005C
      m['iu'               	] := 0x005D
      m['am'               	] := 0x005E
      m['tzm'              	] := 0x005F
      m['ks'               	] := 0x0060
      m['ne'               	] := 0x0061
      m['fy'               	] := 0x0062
      m['ps'               	] := 0x0063
      m['fil'              	] := 0x0064
      m['dv'               	] := 0x0065
      m['bin'              	] := 0x0066
      m['ff'               	] := 0x0067
      m['ha'               	] := 0x0068
      m['ibb'              	] := 0x0069
      m['yo'               	] := 0x006A
      m['quz'              	] := 0x006B
      m['nso'              	] := 0x006C
      m['ba'               	] := 0x006D
      m['lb'               	] := 0x006E
      m['kl'               	] := 0x006F
      m['ig'               	] := 0x0070
      m['kr'               	] := 0x0071
      m['om'               	] := 0x0072
      m['ti'               	] := 0x0073
      m['gn'               	] := 0x0074
      m['haw'              	] := 0x0075
      m['la'               	] := 0x0076
      m['so'               	] := 0x0077
      m['ii'               	] := 0x0078
      m['pap'              	] := 0x0079
      m['arn'              	] := 0x007A
      m['moh'              	] := 0x007C
      m['br'               	] := 0x007E
      m['ug'               	] := 0x0080
      m['mi'               	] := 0x0081
      m['oc'               	] := 0x0082
      m['co'               	] := 0x0083
      m['gsw'              	] := 0x0084
      m['sah'              	] := 0x0085
      m['qut'              	] := 0x0086
      m['rw'               	] := 0x0087
      m['wo'               	] := 0x0088
      m['prs'              	] := 0x008C
      m['gd'               	] := 0x0091
      m['ku'               	] := 0x0092
      m['quc'              	] := 0x0093
      m['ar-SA'            	] := 0x0401
      m['bg-BG'            	] := 0x0402
      m['ca-ES'            	] := 0x0403
      m['zh-TW'            	] := 0x0404
      m['cs-CZ'            	] := 0x0405
      m['da-DK'            	] := 0x0406
      m['de-DE'            	] := 0x0407
      m['el-GR'            	] := 0x0408
      m['en-US'            	] := 0x0409
      m['es-ES_tradnl'     	] := 0x040A
      m['fi-FI'            	] := 0x040B
      m['fr-FR'            	] := 0x040C
      m['he-IL'            	] := 0x040D
      m['hu-HU'            	] := 0x040E
      m['is-IS'            	] := 0x040F
      m['it-IT'            	] := 0x0410
      m['ja-JP'            	] := 0x0411
      m['ko-KR'            	] := 0x0412
      m['nl-NL'            	] := 0x0413
      m['nb-NO'            	] := 0x0414
      m['pl-PL'            	] := 0x0415
      m['pt-BR'            	] := 0x0416
      m['rm-CH'            	] := 0x0417
      m['ro-RO'            	] := 0x0418
      m['ru-RU'            	] := 0x0419
      m['hr-HR'            	] := 0x041A
      m['sk-SK'            	] := 0x041B
      m['sq-AL'            	] := 0x041C
      m['sv-SE'            	] := 0x041D
      m['th-TH'            	] := 0x041E
      m['tr-TR'            	] := 0x041F
      m['ur-PK'            	] := 0x0420
      m['id-ID'            	] := 0x0421
      m['uk-UA'            	] := 0x0422
      m['be-BY'            	] := 0x0423
      m['sl-SI'            	] := 0x0424
      m['et-EE'            	] := 0x0425
      m['lv-LV'            	] := 0x0426
      m['lt-LT'            	] := 0x0427
      m['tg-Cyrl-TJ'       	] := 0x0428
      m['fa-IR'            	] := 0x0429
      m['vi-VN'            	] := 0x042A
      m['hy-AM'            	] := 0x042B
      m['az-Latn-AZ'       	] := 0x042C
      m['eu-ES'            	] := 0x042D
      m['hsb-DE'           	] := 0x042E
      m['mk-MK'            	] := 0x042F
      m['st-ZA'            	] := 0x0430
      m['ts-ZA'            	] := 0x0431
      m['tn-ZA'            	] := 0x0432
      m['ve-ZA'            	] := 0x0433
      m['xh-ZA'            	] := 0x0434
      m['zu-ZA'            	] := 0x0435
      m['af-ZA'            	] := 0x0436
      m['ka-GE'            	] := 0x0437
      m['fo-FO'            	] := 0x0438
      m['hi-IN'            	] := 0x0439
      m['mt-MT'            	] := 0x043A
      m['se-NO'            	] := 0x043B
      m['yi-001'           	] := 0x043D
      m['ms-MY'            	] := 0x043E
      m['kk-KZ'            	] := 0x043F
      m['ky-KG'            	] := 0x0440
      m['sw-KE'            	] := 0x0441
      m['tk-TM'            	] := 0x0442
      m['uz-Latn-UZ'       	] := 0x0443
      m['tt-RU'            	] := 0x0444
      m['bn-IN'            	] := 0x0445
      m['pa-IN'            	] := 0x0446
      m['gu-IN'            	] := 0x0447
      m['or-IN'            	] := 0x0448
      m['ta-IN'            	] := 0x0449
      m['te-IN'            	] := 0x044A
      m['kn-IN'            	] := 0x044B
      m['ml-IN'            	] := 0x044C
      m['as-IN'            	] := 0x044D
      m['mr-IN'            	] := 0x044E
      m['sa-IN'            	] := 0x044F
      m['mn-MN'            	] := 0x0450
      m['bo-CN'            	] := 0x0451
      m['cy-GB'            	] := 0x0452
      m['km-KH'            	] := 0x0453
      m['lo-LA'            	] := 0x0454
      m['my-MM'            	] := 0x0455
      m['gl-ES'            	] := 0x0456
      m['kok-IN'           	] := 0x0457
      m['mni-IN'           	] := 0x0458
      m['sd-Deva-IN'       	] := 0x0459
      m['syr-SY'           	] := 0x045A
      m['si-LK'            	] := 0x045B
      m['chr-Cher-US'      	] := 0x045C
      m['iu-Cans-CA'       	] := 0x045D
      m['am-ET'            	] := 0x045E
      m['tzm-Arab-MA'      	] := 0x045F
      m['ks-Arab'          	] := 0x0460
      m['ne-NP'            	] := 0x0461
      m['fy-NL'            	] := 0x0462
      m['ps-AF'            	] := 0x0463
      m['fil-PH'           	] := 0x0464
      m['dv-MV'            	] := 0x0465
      m['bin-NG'           	] := 0x0466
      m['ff-NG, ff-Latn-NG'	] := 0x0467
      m['ha-Latn-NG'       	] := 0x0468
      m['ibb-NG'           	] := 0x0469
      m['yo-NG'            	] := 0x046A
      m['quz-BO'           	] := 0x046B
      m['nso-ZA'           	] := 0x046C
      m['ba-RU'            	] := 0x046D
      m['lb-LU'            	] := 0x046E
      m['kl-GL'            	] := 0x046F
      m['ig-NG'            	] := 0x0470
      m['kr-Latn-NG'       	] := 0x0471
      m['om-ET'            	] := 0x0472
      m['ti-ET'            	] := 0x0473
      m['gn-PY'            	] := 0x0474
      m['haw-US'           	] := 0x0475
      m['la-VA'            	] := 0x0476
      m['so-SO'            	] := 0x0477
      m['ii-CN'            	] := 0x0478
      m['pap-029'          	] := 0x0479
      m['arn-CL'           	] := 0x047A
      m['moh-CA'           	] := 0x047C
      m['br-FR'            	] := 0x047E
      m['ug-CN'            	] := 0x0480
      m['mi-NZ'            	] := 0x0481
      m['oc-FR'            	] := 0x0482
      m['co-FR'            	] := 0x0483
      m['gsw-FR'           	] := 0x0484
      m['sah-RU'           	] := 0x0485
      m['qut-GT'           	] := 0x0486
      m['rw-RW'            	] := 0x0487
      m['wo-SN'            	] := 0x0488
      m['prs-AF'           	] := 0x048C
      m['plt-MG'           	] := 0x048D
      m['zh-yue-HK'        	] := 0x048E
      m['tdd-Tale-CN'      	] := 0x048F
      m['khb-Talu-CN'      	] := 0x0490
      m['gd-GB'            	] := 0x0491
      m['ku-Arab-IQ'       	] := 0x0492
      m['quc-CO'           	] := 0x0493
      m['qps-ploc'         	] := 0x0501
      m['qps-ploca'        	] := 0x05FE
      m['ar-IQ'            	] := 0x0801
      m['ca-ES-valencia'   	] := 0x0803
      m['zh-CN'            	] := 0x0804
      m['de-CH'            	] := 0x0807
      m['en-GB'            	] := 0x0809
      m['es-MX'            	] := 0x080A
      m['fr-BE'            	] := 0x080C
      m['it-CH'            	] := 0x0810
      m['ja-Ploc-JP'       	] := 0x0811
      m['nl-BE'            	] := 0x0813
      m['nn-NO'            	] := 0x0814
      m['pt-PT'            	] := 0x0816
      m['ro-MD'            	] := 0x0818
      m['ru-MD'            	] := 0x0819
      m['sr-Latn-CS'       	] := 0x081A
      m['sv-FI'            	] := 0x081D
      m['ur-IN'            	] := 0x0820
      m['az-Cyrl-AZ'       	] := 0x082C
      m['dsb-DE'           	] := 0x082E
      m['tn-BW'            	] := 0x0832
      m['se-SE'            	] := 0x083B
      m['ga-IE'            	] := 0x083C
      m['ms-BN'            	] := 0x083E
      m['kk-Latn-KZ'       	] := 0x083F
      m['uz-Cyrl-UZ'       	] := 0x0843
      m['bn-BD'            	] := 0x0845
      m['pa-Arab-PK'       	] := 0x0846
      m['ta-LK'            	] := 0x0849
      m['mn-Mong-CN'       	] := 0x0850
      m['bo-BT'            	] := 0x0851
      m['sd-Arab-PK'       	] := 0x0859
      m['iu-Latn-CA'       	] := 0x085D
      m['tzm-Latn-DZ'      	] := 0x085F
      m['ks-Deva-IN'       	] := 0x0860
      m['ne-IN'            	] := 0x0861
      m['ff-Latn-SN'       	] := 0x0867
      m['quz-EC'           	] := 0x086B
      m['ti-ER'            	] := 0x0873
      m['qps-plocm'        	] := 0x09FF
      m['0x0C00'           	] := 0x0C00
      m['ar-EG'            	] := 0x0C01
      m['zh-HK'            	] := 0x0C04
      m['de-AT'            	] := 0x0C07
      m['en-AU'            	] := 0x0C09
      m['es-ES'            	] := 0x0C0A
      m['fr-CA'            	] := 0x0C0C
      m['sr-Cyrl-CS'       	] := 0x0C1A
      m['se-FI'            	] := 0x0C3B
      m['mn-Mong-MN'       	] := 0x0C50
      m['dz-BT'            	] := 0x0C51
      m['tmz-MA'           	] := 0x0C5F
      m['quz-PE'           	] := 0x0C6b
      m['0x1000'           	] := 0x1000
      m['ar-LY'            	] := 0x1001
      m['zh-SG'            	] := 0x1004
      m['de-LU'            	] := 0x1007
      m['en-CA'            	] := 0x1009
      m['es-GT'            	] := 0x100A
      m['fr-CH'            	] := 0x100C
      m['hr-BA'            	] := 0x101A
      m['smj-NO'           	] := 0x103B
      m['tzm-Tfng-MA'      	] := 0x105F
      m['ar-DZ'            	] := 0x1401
      m['zh-MO'            	] := 0x1404
      m['de-LI'            	] := 0x1407
      m['en-NZ'            	] := 0x1409
      m['es-CR'            	] := 0x140A
      m['fr-LU'            	] := 0x140C
      m['bs-Latn-BA'       	] := 0x141A
      m['smj-SE'           	] := 0x143B
      m['ar-MA'            	] := 0x1801
      m['en-IE'            	] := 0x1809
      m['es-PA'            	] := 0x180A
      m['fr-MC'            	] := 0x180C
      m['sr-Latn-BA'       	] := 0x181A
      m['sma-NO'           	] := 0x183B
      m['ar-TN'            	] := 0x1C01
      m['en-ZA'            	] := 0x1C09
      m['es-DO'            	] := 0x1C0A
      m['fr-029'           	] := 0x1C0C
      m['sr-Cyrl-BA'       	] := 0x1C1A
      m['sma-SE'           	] := 0x1C3B
      m['0x2000'           	] := 0x2000
      m['ar-OM'            	] := 0x2001
      m['en-JM'            	] := 0x2009
      m['es-VE'            	] := 0x200A
      m['fr-RE'            	] := 0x200C
      m['bs-Cyrl-BA'       	] := 0x201A
      m['sms-FI'           	] := 0x203B
      m['0x2400'           	] := 0x2400
      m['ar-YE'            	] := 0x2401
      m['en-029'           	] := 0x2409
      m['es-CO'            	] := 0x240A
      m['fr-CD'            	] := 0x240C
      m['sr-Latn-RS'       	] := 0x241A
      m['smn-FI'           	] := 0x243B
      m['0x2800'           	] := 0x2800
      m['ar-SY'            	] := 0x2801
      m['en-BZ'            	] := 0x2809
      m['es-PE'            	] := 0x280A
      m['fr-SN'            	] := 0x280C
      m['sr-Cyrl-RS'       	] := 0x281A
      m['0x2C00'           	] := 0x2C00
      m['ar-JO'            	] := 0x2C01
      m['en-TT'            	] := 0x2C09
      m['es-AR'            	] := 0x2C0A
      m['fr-CM'            	] := 0x2C0C
      m['sr-Latn-ME'       	] := 0x2C1A
      m['0x3000'           	] := 0x3000
      m['ar-LB'            	] := 0x3001
      m['en-ZW'            	] := 0x3009
      m['es-EC'            	] := 0x300A
      m['fr-CI'            	] := 0x300C
      m['sr-Cyrl-ME'       	] := 0x301A
      m['0x3400'           	] := 0x3400
      m['ar-KW'            	] := 0x3401
      m['en-PH'            	] := 0x3409
      m['es-CL'            	] := 0x340A
      m['fr-ML'            	] := 0x340C
      m['0x3800'           	] := 0x3800
      m['ar-AE'            	] := 0x3801
      m['en-ID'            	] := 0x3809
      m['es-UY'            	] := 0x380A
      m['fr-MA'            	] := 0x380C
      m['0x3C00'           	] := 0x3C00
      m['ar-BH'            	] := 0x3C01
      m['en-HK'            	] := 0x3C09
      m['es-PY'            	] := 0x3C0A
      m['fr-HT'            	] := 0x3C0C
      m['0x4000'           	] := 0x4000
      m['ar-QA'            	] := 0x4001
      m['en-IN'            	] := 0x4009
      m['es-BO'            	] := 0x400A
      m['0x4400'           	] := 0x4400
      m['ar-Ploc-SA'       	] := 0x4401
      m['en-MY'            	] := 0x4409
      m['es-SV'            	] := 0x440A
      m['0x4800'           	] := 0x4800
      m['ar-145'           	] := 0x4801
      m['en-SG'            	] := 0x4809
      m['es-HN'            	] := 0x480A
      m['0x4C00'           	] := 0x4C00
      m['en-AE'            	] := 0x4C09
      m['es-NI'            	] := 0x4C0A
      m['en-BH'            	] := 0x5009
      m['es-PR'            	] := 0x500A
      m['en-EG'            	] := 0x5409
      m['es-US'            	] := 0x540A
      m['en-JO'            	] := 0x5809
      m['es-419'           	] := 0x580A
      m['en-KW'            	] := 0x5C09
      m['es-CU'            	] := 0x5C0A
      m['en-TR'            	] := 0x6009
      m['en-YE'            	] := 0x6409
      m['bs-Cyrl'          	] := 0x641A
      m['bs-Latn'          	] := 0x681A
      m['sr-Cyrl'          	] := 0x6C1A
      m['sr-Latn'          	] := 0x701A
      m['smn'              	] := 0x703B
      m['az-Cyrl'          	] := 0x742C
      m['sms'              	] := 0x743B
      m['zh'               	] := 0x7804
      m['nn'               	] := 0x7814
      m['bs'               	] := 0x781A
      m['az-Latn'          	] := 0x782C
      m['sma'              	] := 0x783B
      m['kk-Cyrl'          	] := 0x783F
      m['uz-Cyrl'          	] := 0x7843
      m['mn-Cyrl'          	] := 0x7850
      m['iu-Cans'          	] := 0x785D
      m['tzm-Tfng'         	] := 0x785F
      m['zh-Hant'          	] := 0x7C04
      m['nb'               	] := 0x7C14
      m['sr'               	] := 0x7C1A
      m['tg-Cyrl'          	] := 0x7C28
      m['dsb'              	] := 0x7C2E
      m['smj'              	] := 0x7C3B
      m['kk-Latn'          	] := 0x7C3F
      m['uz-Latn'          	] := 0x7C43
      m['pa-Arab'          	] := 0x7C46
      m['mn-Mong'          	] := 0x7C50
      m['sd-Arab'          	] := 0x7C59
      m['chr-Cher'         	] := 0x7C5C
      m['iu-Latn'          	] := 0x7C5D
      m['tzm-Latn'         	] := 0x7C5F
      m['ff-Latn'          	] := 0x7C67
      m['ha-Latn'          	] := 0x7C68
      m['ku-Arab'          	] := 0x7C92
      m['fr-015'           	] := 0xE40C
    return m
  }
}

; get from ‘win32 const Locale.xlsx’, so don't edit here (except for manual localias)
class localeNLS_SubGroups { ; define the "LOCALE_..." constants
  static maps := ['IDEFAULT','INEG','IPOS','RRETURN','SABBREV','SDAYNAME','SENG','SENGLISH','SISO','SLOCALIZED','SMON','SMONTHNAME','SNATIVE','SSORT','STIME','localias']
  ; , mapAlias := Map('Misc1','Misc')
  , IDEFAULT := Map(
    "LOCALE_IDEFAULTANSICODEPAGE",0x00001004,  	; default ansi code page (use of Unicode is recommended instead)
    "LOCALE_IDEFAULTCODEPAGE",0x0000000B,      	; default oem code page (use of Unicode is recommended instead)
    "LOCALE_IDEFAULTCOUNTRY",0x0000000A,       	; default country code, deprecated
    "LOCALE_IDEFAULTEBCDICCODEPAGE",0x00001012,	; default ebcdic code page (use of Unicode is recommended instead)
    "LOCALE_IDEFAULTLANGUAGE",0x00000009,      	; default language id, deprecated
    "LOCALE_IDEFAULTMACCODEPAGE",0x00001011,   	; default mac code page (use of Unicode is recommended instead)
  )
  , INEG := Map(
    "LOCALE_INEGCURR",0x0000001C,       	; negative currency mode, 0-15, see documentation
    "LOCALE_INEGSYMPRECEDES",0x00000056,	; mon sym precedes neg amt (derived from INEGCURR)
  )
  , IPOS := Map(
    "LOCALE_IPOSSEPBYSPACE",0x00000055, 	; mon sym sep by space from pos amt (derived from ICURRENCY)
    "LOCALE_IPOSSIGNPOSN",0x00000052,   	; positive sign position (derived from INEGCURR)
    "LOCALE_IPOSSYMPRECEDES",0x00000054,	; mon sym precedes pos amt (derived from ICURRENCY)
  )
  , RRETURN := Map(
    "LOCALE_RETURN_GENITIVE_NAMES",0x10000000,	; Windows 7 and later: Retrieve the genitive names of months, which are the names used when the month names are combined with other items. For example, in Ukrainian the equivalent of January is written "Січень" when the month is named alone. However, when the month name is used in combination, for example, in a date such as January 5th, 2003, the genitive form of the name is used. For the Ukrainian example, the genitive month name is displayed as "5 січня 2003". The list of genitive month names begins with January and is semicolon-delimited. If there is no 13th month, use a semicolon in its place at the end of the list. Note: Genitive month names do not exist in all languages.
    "LOCALE_RETURN_NUMBER",0x20000000,        	; Windows Me/98, Windows NT 4.0 and later: Retrieve a number. This constant causes GetLocaleInfo or GetLocaleInfoEx to retrieve a value as a number instead of as a string. The buffer that receives the value must be at least the length of a DWORD value. This constant can be combined with any other constant having a name that begins with "LOCALE_I".
  )
  , SABBREV := Map(
    "LOCALE_SABBREVCTRYNAME",0x00000007,   	; Abbreviated name of the country/region, mostly based on the ISO Standard 3166. The maximum number of characters allowed for this string is nine, including a terminating null character.
    "LOCALE_SABBREVDAYNAME1",0x00000031,   	; Native abbreviated name for Monday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVDAYNAME2",0x00000032,   	; Native abbreviated name for Tuesday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVDAYNAME3",0x00000033,   	; Native abbreviated name for Wednesday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVDAYNAME4",0x00000034,   	; Native abbreviated name for Thursday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVDAYNAME5",0x00000035,   	; Native abbreviated name for Friday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVDAYNAME6",0x00000036,   	; Native abbreviated name for Saturday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVDAYNAME7",0x00000037,   	; Native abbreviated name for Sunday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVLANGNAME",0x00000003,   	; Abbreviated name of the language. In most cases, the name is created by taking the two-letter language abbreviation from ISO Standard 639 and adding a third letter, as appropriate, to indicate the sublanguage. For example, the abbreviated name for the language corresponding to the English (United States) locale is ENU.
    "LOCALE_SABBREVMONTHNAME1",0x00000044, 	; Native abbreviated name for January. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME10",0x0000004D,	; Native abbreviated name for October. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME11",0x0000004E,	; Native abbreviated name for November. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME12",0x0000004F,	; Native abbreviated name for December. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME13",0x0000100F,	; Native abbreviated name for a 13th month, if it exists. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME2",0x00000045, 	; Native abbreviated name for February. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME3",0x00000046, 	; Native abbreviated name for March. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME4",0x00000047, 	; Native abbreviated name for April. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME5",0x00000048, 	; Native abbreviated name for May. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME6",0x00000049, 	; Native abbreviated name for June. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME7",0x0000004A, 	; Native abbreviated name for July. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME8",0x0000004B, 	; Native abbreviated name for August. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SABBREVMONTHNAME9",0x0000004C, 	; Native abbreviated name for September. The maximum number of characters allowed for this string is 80, including a terminating null character.
  )
  , SDAYNAME := Map(
    "LOCALE_SDAYNAME1",0x0000002A,	; Native long name for Monday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SDAYNAME2",0x0000002B,	; Native long name for Tuesday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SDAYNAME3",0x0000002C,	; Native long name for Wednesday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SDAYNAME4",0x0000002D,	; Native long name for Thursday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SDAYNAME5",0x0000002E,	; Native long name for Friday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SDAYNAME6",0x0000002F,	; Native long name for Saturday. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SDAYNAME7",0x00000030,	; Native long name for Sunday. The maximum number of characters allowed for this string is 80, including a terminating null character.
  )
  , SENG := Map(
    "LOCALE_SENGLISHCOUNTRYNAME",0x00001002, 	; Windows 7 and later: English name of the country/region, for example, Germany for Deutschland. This name is always restricted to characters that can be mapped into the ASCII 127-character subset.
    "LOCALE_SENGLISHDISPLAYNAME",0x00000072, 	; Windows 7 and later: Display name of the locale in English. Usually the display name consists of the language and the country/region, for example, German (Germany) for Deutsch (Deutschland).
    "LOCALE_SENGLISHLANGUAGENAME",0x00001001,	; Windows 7 and later: English name of the language in English, for example, German for Deutsch, from International ISO Standard 639. This name is always restricted to characters that can be mapped into the ASCII 127-character subset.
  )
  , SENGLISH := Map(
    "LOCALE_SENGCOUNTRY",0x00001002, 	; Deprecated for Windows 7 and later. Full English name of the country/region. See LOCALE_SENGLISHCOUNTRYNAME.
    "LOCALE_SENGCURRNAME",0x00001007,	; Windows Me/98, Windows 2000: The full English name of the currency associated with the locale. There is no limit on the number of characters allowed for this string.
    "LOCALE_SENGLANGUAGE",0x00001001,	; Deprecated for Windows 7 and later. Full English name of the language from ISO Standard 639. See LOCALE_SENGLISHLANGUAGENAME.
  )
  , SISO := Map(
    "LOCALE_SISO3166CTRYNAME",0x0000005A, 	; Windows Me/98, Windows NT 4.0: Country/region name, based on ISO Standard 3166, such as "US" for the United States. This can also return a number, such as "029" for Caribbean. The maximum number of characters allowed for this string is nine, including a terminating null character.
    "LOCALE_SISO3166CTRYNAME2",0x00000068,	; Windows Vista and later: Three-letter ISO region name (ISO 3166 three-letter code for the country/region), such as "USA" for the United States. This can also return a number, such as "029" for Caribbean. The maximum number of characters allowed for this string is nine, including a terminating null character.
    "LOCALE_SISO639LANGNAME",0x00000059,  	; Windows Me/98, Windows NT 4.0: The abbreviated name of the language based entirely on the ISO Standard 639 values, in lowercase form, such as "en" for English. This can be a 3-letter code for languages that don't have a 2-letter code, such as "haw" for Hawaiian. The maximum number of characters allowed for this string is nine, including a terminating null character.
    "LOCALE_SISO639LANGNAME2",0x00000067, 	; Windows Vista and later: Three-letter ISO language name, in lowercase form (ISO 639-2 three-letter code for the language), such as "eng" for English. The maximum number of characters allowed for this string is nine, including a terminating null character.
  )
  , SLOCALIZED := Map(
    "LOCALE_SLOCALIZEDCOUNTRYNAME",0x00000006, 	; Windows 7 and later: Full localized name of the country/region, for example, Deutschland for Germany. The maximum number of characters allowed for this string is 80, including a terminating null character. Since this name is based on the localization of the product, it changes for each localized version.
    "LOCALE_SLOCALIZEDDISPLAYNAME",0x00000002, 	; Windows 7 and later: Full localized name of the locale for the user interface language, for example, Deutsch (Deutschland) for German (Germany)" There is no limit on the number of characters allowed for this string. Since this name is based on the localization of the product, it changes for each localized version.
    "LOCALE_SLOCALIZEDLANGUAGENAME",0x0000006f,	; Windows Vista: Full localized primary name of the user interface language included in a localized display name, for example, Deutsch representing German. Since this name is based on the localization of the product, it changes for each localized version.
  )
  , SMON := Map(
    "LOCALE_SMONDECIMALSEP",0x00000016, 	; Character(s) used as the monetary decimal separator. The maximum number of characters allowed for this string is four, including a terminating null character. For example, if a monetary amount is displayed as "$3.40", just as "three dollars and forty cents" is displayed in the United States, then the monetary decimal separator is ".".
    "LOCALE_SMONGROUPING",0x00000018,   	; Sizes for each group of monetary digits to the left of the decimal. The maximum number of characters allowed for this string is ten, including a terminating null character. An explicit size is needed for each group, and sizes are separated by semicolons. If the last value is 0, the preceding value is repeated. For example, to group thousands, specify 3;0. Indic languages group the first thousand and then group by hundreds. For example 12,34,56,789 is represented by 3;2;0.
    "LOCALE_SMONTHOUSANDSEP",0x00000017,	; Character(s) used as the monetary separator between groups of digits to the left of the decimal. The maximum number of characters allowed for this string is four, including a terminating null character. Typically, the groups represent thousands. However, depending on the value specified for LOCALE_SMONGROUPING, they can represent something else.
  )
  , SMONTHNAME := Map(
    "LOCALE_SMONTHNAME1",0x00000038, 	; Native long name for January. The maximum number of characters allowed for this string is 80, including a terminating null character. Note: Calling the GetLocaleInfo or GetLocaleInfoEx function with a LOCALE_SMONTHNAME* constant returns the standalone, or nominative, form of the month name. To get the genitive form of the month name, the application calls GetDateFormat or GetDateFormatEx with a date picture of ddMMMM and removes the two digits from the beginning of the retrieved string.
    "LOCALE_SMONTHNAME10",0x00000041,	; Native long name for October. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME11",0x00000042,	; Native long name for November. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME12",0x00000043,	; Native long name for December. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME13",0x0000100E,	; Native name for a 13th month, if it exists. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME2",0x00000039, 	; Native long name for February. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME3",0x0000003A, 	; Native long name for March. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME4",0x0000003B, 	; Native long name for April. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME5",0x0000003C, 	; Native long name for May. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME6",0x0000003D, 	; Native long name for June. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME7",0x0000003E, 	; Native long name for July. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME8",0x0000003F, 	; Native long name for August. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
    "LOCALE_SMONTHNAME9",0x00000040, 	; Native long name for September. The maximum number of characters allowed for this string is 80, including a terminating null character. See note for LOCALE_SMONTHNAME1.
  )
  , SNATIVE := Map(
    "LOCALE_SNATIVECOUNTRYNAME",0x00000008, 	; Windows 7 and later: Native name of the country/region, for example, España for Spain. The maximum number of characters allowed for this string is 80, including a terminating null character.
    "LOCALE_SNATIVECTRYNAME",0x00000008,    	; Deprecated for Windows 7 and later. Native name of the country/region. See LOCALE_SNATIVECOUNTRYNAME.
    "LOCALE_SNATIVECURRNAME",0x00001008,    	; Windows Me/98, Windows 2000: The native name of the currency associated with the locale, in the native language of the locale. There is no limit on the number of characters allowed for this string.
    "LOCALE_SNATIVEDIGITS",0x00000013,      	; Native equivalents of ASCII 0 through 9. The maximum number of characters allowed for this string is eleven, including a terminating null character. For example, Arabic uses "٠١٢٣٤٥ ٦٧٨٩". See also LOCALE_IDIGITSUBSTITUTION.
    "LOCALE_SNATIVEDISPLAYNAME",0x00000073, 	; Windows 7 and later: Display name of the locale in its native language, for example, Deutsch (Deutschland) for the locale German (Germany).
    "LOCALE_SNATIVELANGNAME",0x00000004,    	; Deprecated for Windows 7 and later. Native name of the language. See LOCALE_SNATIVELANGUAGENAME.
    "LOCALE_SNATIVELANGUAGENAME",0x00000004,	; Windows 7 and later: Native name of the language, for example, Հայերեն for Armenian (Armenia). The maximum number of characters allowed for this string is 80, including a terminating null character.
  )
  , SSORT := Map(
    "LOCALE_SSORTLOCALE",0x0000007b,	; Windows 7 and later: Name of the locale to use for sorting or casing behavior.
    "LOCALE_SSORTNAME",0x00001013,  	; Windows Me/98, Windows 2000: The full localized name of the sort for the specified locale identifier, dependent on the language of the shell. This constant is used to determine casing and sorting behavior
  )
  , STIME := Map(
    "LOCALE_STIME",0x0000001E,      	; Character(s) for the time separator. The maximum number of characters allowed for this string is four, including a terminating null character. Windows Vista and later: This constant is deprecated. Use LOCALE_STIMEFORMAT instead. A custom locale might not have a single, uniform separator character. For example, a format such as "03:56'23" is valid.
    "LOCALE_STIMEFORMAT",0x00001003,	; Time formatting strings for the locale. The maximum number of characters allowed for this string is 80, including a terminating null character. The string can consist of a combination of hour, minute, and second format pictures.
  )

  , localias := Map(
     'en'                     	, 'LOCALE_SISO639LANGNAME'       	;
    ,'eng'                    	, 'LOCALE_SISO639LANGNAME2'      	;
    ,'English'                	, 'LOCALE_SENGLISHLANGUAGENAME'  	;
    ,'United States'          	, 'LOCALE_SENGLISHCOUNTRYNAME'   	;
    ,'English (United States)'	, 'LOCALE_SENGLISHDISPLAYNAME'   	;
    ,'Deutsch'                	, 'LOCALE_SLOCALIZEDLANGUAGENAME'	;
    ,'Deutschland'            	, 'LOCALE_SLOCALIZEDCOUNTRYNAME' 	;
    ,'Deutsch (Deutschland)'  	, 'LOCALE_SLOCALIZEDDISPLAYNAME' 	;
  )
  }

class localeOther { ; define the "LOCALE_..." constants
  static maps := ['Combining','Locale_Def','NLS','LCType_Get','LCType_GetSet']
  , Combining := Map(
    "LOCALE_NOUSEROVERRIDE",0x80000000,	;
    "LOCALE_USE_CP_ACP",0x40000000,    	;
  )
  , NLS := Map(
    "LOCALE_ALLOW_NEUTRAL_NAMES",0x08000000,                  	;
    "LOCALE_INEUTRAL",0x00000071,                             	;
    "LOCALE_IUSEUTF8LEGACYACP",0x00000666,                    	;
    "LOCALE_IUSEUTF8LEGACYOEMCP",0x00000999,                  	;
    "LOCALE_NEUTRALDATA",0x00000010,                          	;
    "LOCALE_SCOUNTRY",0x00000006,                             	; localized name of country     Germany in UI language
    "LOCALE_SLANGDISPLAYNAME","LOCALE_SLOCALIZEDLANGUAGENAME",	;
    "LOCALE_SLANGUAGE","LOCALE_SLOCALIZEDDISPLAYNAME",        	; localized name of locale      German (Germany) in UI language
    "LOCALE_SMONTHDAY",0x00000078,                            	;
    "LOCALE_SOPENTYPELANGUAGETAG",0x0000007a,                 	;
    "LOCALE_SPECIFICDATA",0x00000020,                         	;
    "LOCALE_SPERMILLE",0x00000077,                            	;
  )
  , LCType_Get := Map(
    "LOCALE_FONTSIGNATURE",0x00000058,	;
    "LOCALE_ICENTURY",0x00000024,	; century format specifier (short date, SSHORTDATE is preferred)
    "LOCALE_ICONSTRUCTEDLOCALE",0x0000007d,	;
    "LOCALE_ICOUNTRY",0x00000005,	; country code            1, SISO3166CTRYNAME may be more useful.
    "LOCALE_IDATE",0x00000021,	; short date format ordering (derived from SSHORTDATE, use that instead)
    "LOCALE_IDAYLZERO",0x00000026,	; leading zeros in day field (short date, SSHORTDATE is preferred)
    "LOCALE_IDIALINGCODE",0x00000005,	;
    "LOCALE_IGEOID",0x0000005B,	; geographical location id 244
    "LOCALE_IINTLCURRDIGITS",0x0000001A,	; # intl monetary digits   2 for $1.00
    "LOCALE_ILANGUAGE",0x00000001,	; language id, SNAME preferred
    "LOCALE_ILDATE",0x00000022,	; long date format ordering (derived from SLONGDATE, use that instead)
    "LOCALE_IMONLZERO",0x00000027,	; leading zeros in month field (short date, SSHORTDATE is preferred)
    "LOCALE_INEGATIVEPERCENT",0x00000074,	;
    "LOCALE_INEGSEPBYSPACE",0x00000057,	; mon sym sep by space from neg amt (derived from INEGCURR)
    "LOCALE_INEGSIGNPOSN",0x00000053,	; negative sign position (derived from INEGCURR)
    "LOCALE_IOPTIONALCALENDAR",0x0000100B,	; additional calendar types specifier CAL_GREGORIAN_US
    "LOCALE_IPOSITIVEPERCENT",0x00000075,	;
    "LOCALE_ITIMEMARKPOSN",0x00001005,	; time marker position (derived from STIMEFORMAT, use that instead)
    "LOCALE_ITLZERO",0x00000025,	; leading zeros in time field (derived from STIMEFORMAT, use that instead)
    "LOCALE_SCONSOLEFALLBACKNAME",0x0000006e,	;
    "LOCALE_SDURATION",0x0000005d,	;
    "LOCALE_SINTLSYMBOL",0x00000015,	; intl monetary symbol          USD
    "LOCALE_SKEYBOARDSTOINSTALL",0x0000005e,	;
    "LOCALE_SNAME",0x0000005c,	;
    "LOCALE_SNAN",0x00000069,	;
    "LOCALE_SNEGINFINITY",0x0000006b,	;
    "LOCALE_SPARENT",0x0000006d,	;
    "LOCALE_SPERCENT",0x00000076,	;
    "LOCALE_SPOSINFINITY",0x0000006a,	;
    "LOCALE_SSCRIPTS",0x0000006c,	;
    "LOCALE_SSHORTESTAM",0x0000007e,	;
    "LOCALE_SSHORTESTDAYNAME1",0x00000060,	;
    "LOCALE_SSHORTESTDAYNAME2",0x00000061,	;
    "LOCALE_SSHORTESTDAYNAME3",0x00000062,	;
    "LOCALE_SSHORTESTDAYNAME4",0x00000063,	;
    "LOCALE_SSHORTESTDAYNAME5",0x00000064,	;
    "LOCALE_SSHORTESTDAYNAME6",0x00000065,	;
    "LOCALE_SSHORTESTDAYNAME7",0x00000066,	;
    "LOCALE_SSHORTESTPM",0x0000007f,	;
  )
  , LCType_GetSet := Map(
    "LOCALE_ICALENDARTYPE",0x00001009,	; type of calendar specifier CAL_GREGORIAN
    "LOCALE_ICURRDIGITS",0x00000019,	; # local monetary digits 2 for $1.00
    "LOCALE_ICURRENCY",0x0000001B,	; positive currency mode, 0-3, see documenation
    "LOCALE_IDIGITS",0x00000011,	; number of fractional digits eg 2 for 1.00
    "LOCALE_IDIGITSUBSTITUTION",0x00001014,	; 0=context, 1=none, 2=national
    "LOCALE_IFIRSTDAYOFWEEK",0x0000100C,	; first day of week specifier, 0-6, 0=Monday, 6=Sunday
    "LOCALE_IFIRSTWEEKOFYEAR",0x0000100D,	; first week of year specifier, 0-2, see documentation
    "LOCALE_ILZERO",0x00000012,	; leading zeros for decimal, 0 for .97, 1 for 0.97
    "LOCALE_IMEASURE",0x0000000D,	; 0=metric, 1=US measurement system
    "LOCALE_INEGNUMBER",0x00001010,	; negative number mode, 0-4, see documentation
    "LOCALE_IPAPERSIZE",0x0000100A,	; 1=letter, 5=legal, 8=a3, 9=a4
    "LOCALE_IREADINGLAYOUT",0x00000070,	;
    "LOCALE_ITIME",0x00000023,	; time format specifier (derived from STIMEFORMAT, use that instead)
    "LOCALE_S1159",0x00000028,	; AM designator, eg "AM"
    "LOCALE_S2359",0x00000029,	; PM designator, eg "PM"
    "LOCALE_SAM",0x00000028,	;
    "LOCALE_SCURRENCY",0x00000014,	; local monetary symbol         $
    "LOCALE_SDATE",0x0000001D,	; date separator                (derived from SSHORTDATE, use that instead)
    "LOCALE_SDECIMAL",0x0000000E,	; decimal separator             . for 1,234.00
    "LOCALE_SGROUPING",0x00000010,	; digit grouping                3;0 for 1,000,000
    "LOCALE_SLIST",0x0000000C,	; list item separator           , for "1,2,3,4"
    "LOCALE_SLONGDATE",0x00000020,	; long date format string       dddd, MMMM dd, yyyy
    "LOCALE_SNEGATIVESIGN",0x00000051,	; negative sign                 -
    "LOCALE_SPM",0x00000029,	;
    "LOCALE_SPOSITIVESIGN",0x00000050,	; positive sign
    "LOCALE_SSHORTDATE",0x0000001F,	; short date format string      MM/dd/yyyy
    "LOCALE_SSHORTTIME",0x00000079,	;
    "LOCALE_STHOUSAND",0x0000000F,	; thousand separator            , for 1,234.00
    "LOCALE_SYEARMONTH",0x00001006,	; year month format string      MM/yyyy
  )
  , Locale_Def := Map(
    "LOCALE_ALTERNATE_SORTS",0x00000004,	;
    "LOCALE_REPLACEMENT",0x00000008,    	;
    "LOCALE_SUPPLEMENTAL",0x00000002,   	;
    "LOCALE_WINDOWS",0x00000001,        	;
  )
  }
