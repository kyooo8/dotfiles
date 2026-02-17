#Include ".\getIme.ahk"
; パススルー用ホットキー（代表的キーをスルー）

*~a:: Return

*~b:: Return

*~c:: Return

*~d:: Return

*~e:: Return

*~f:: Return

*~g:: Return

*~h:: Return

*~i:: Return

*~j:: Return

*~k:: Return

*~l:: Return

*~m:: Return

*~n:: Return

*~o:: Return

*~p:: Return

*~q:: Return

*~r:: Return

*~s:: Return

*~t:: Return

*~u:: Return

*~v:: Return

*~w:: Return

*~x:: Return

*~y:: Return

*~z:: Return

*~1:: Return

*~2:: Return

*~3:: Return

*~4:: Return

*~5:: Return

*~6:: Return

*~7:: Return

*~8:: Return

*~9:: Return

*~0:: Return

*~F1:: Return

*~F2:: Return

*~F3:: Return

*~F4:: Return

*~F5:: Return

*~F6:: Return

*~F7:: Return

*~F8:: Return

*~F9:: Return

*~F10:: Return

*~F11:: Return

*~F12:: Return

*~`:: Return

*~~:: Return

*~!:: Return

*~@:: Return

*~#:: Return

*~$:: Return

*~%:: Return

*~^:: Return

*~&:: Return

*~*:: Return

*~(:: Return

*~):: Return

*~-:: Return

*~_:: Return

*~=:: Return

*~+:: Return

*~[:: Return

*~{:: Return

*~]:: Return

*~}:: Return

*~\:: Return

*~|:: Return

*~;:: Return

*~':: Return

*~":: Return

*~,:: Return

*~<:: Return

*~.:: Return

*~>:: Return

*~/:: Return

*~?:: Return

*~Esc:: Return

*~Tab:: Return

*~Space:: Return

*~Left:: Return

*~Right:: Return

*~Up:: Return

*~Down:: Return

*~Enter:: Return

*~PrintScreen:: Return

*~Delete:: Return

*~Home:: Return

*~End:: Return

*~PgUp:: Return

*~PgDn:: Return



; 上部メニューが勝手にアクティブ化されるのを抑制

*~LAlt:: {

    Send "{Blind}{vk07}"

}

*~RCtrl:: {

    Send "{Blind}{vk07}"

}



; 左 Alt 空打ち → IME OFF

LAlt up:: {

    if (A_PriorHotkey = "*~LAlt") {

        IME_SET(0)

    }

}



; 右 Alt 空打ち → IME ON

RCtrl up:: {

    if (A_PriorHotkey = "*~RCtrl") {

        IME_SET(1)

    }

}

