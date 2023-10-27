#Requires AutoHotKey 2.0.10
RemoveLetterAccents(text) { ; autohotkey.com/boards/viewtopic.php?t=8089&p=285091
  static diaM := Map(
      "a" , "áàâǎăãảạäåāąấầẫẩậắằẵẳặǻ"
    , "c" , "ćĉčċç"
    , "d" , "ďđð"
    , "e" , "éèêěĕẽẻėëēęếềễểẹệ"
    , "g" , "ğĝġģ"
    , "h" , "ĥħ"
    , "i" , "íìĭîǐïĩįīỉị"
    , "j" , "ĵ"
    , "k" , "ķ"
    , "l" , "ĺľļłŀ"
    , "n" , "ńňñņ"
    , "o" , "óòŏôốồỗổǒöőõøǿōỏơớờỡởợọộ"
    , "p" , "ṕṗ"
    , "r" , "ŕřŗ"
    , "s" , "śŝšş"
    , "t" , "ťţŧ"
    , "u" , "úùŭûǔůüǘǜǚǖűũųūủưứừữửựụ"
    , "w" , "ẃẁŵẅ"
    , "y" , "ýỳŷÿỹỷỵ"
    , "z" , "źžż" )

  for k, v in diaM {
     VU := StrUpper(v)
     KU := StrUpper(k)
     text:=RegExReplace(text,"[" v  "]", k)  ; lower case
     text:=RegExReplace(text,"[" VU "]", KU) ; upper case
    }
  Return text
  }
