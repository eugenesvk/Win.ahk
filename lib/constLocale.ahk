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
