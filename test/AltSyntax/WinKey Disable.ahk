#Requires AutoHotKey 2.0.10
disable_WinKey()
disable_WinKey() {
  bl := '{Blind}#{'
  ;$#1::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖1​  vk31 ⟶ #1
  $#1::    	aTabSameApp("+","", "LWin","vk31")                 	;❖1​  vk31 ⟶ Switch between windows of the same app (ignore minimized)
  $#2::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖2​  vk32 ⟶ #2
  $#3::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖3​  vk33 ⟶ #3
  $#4::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖4​  vk34 ⟶ #4
  $#5::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖5​  vk35 ⟶ #5
  $#6::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖6​  vk36 ⟶ #6
  $#7::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖7​  vk37 ⟶ #7
  $#8::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖8​  vk38 ⟶ #8
  $#9::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖9​  vk39 ⟶ #9
  ;$#0::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖0​  vk30 ⟶ #0
  ;$#vkBD::	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖-​  vkBD ⟶ #-
  ;$#vkBB::	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖=​  vkBB ⟶ #=
  $#a::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖a​  vk41 ⟶ #a
  ;$#c::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖c​  vk43 ⟶ #c
  ;$#d::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖d​  vk44 ⟶ #d
  ;$#e::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖e​  vk45 ⟶ #e
  ;$#f::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖f​  vk46 ⟶ #f
  ;$#g::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖g​  vk47 ⟶ #g
  ;$#h::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖h​  vk48 ⟶ #h
  ;$#i::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖i​  vk49 ⟶ #i
  ;$#k::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖k​  vk4B ⟶ #k
  ;$#l::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖l​  vk4C ⟶ #l
  ;$#m::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖m​  vk4D ⟶ #m
  ;$#p::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖p​  vk50 ⟶ #p
  $#r::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖r​  vk52 ⟶ #r
  $#s::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖s​  vk53 ⟶ #s
  $#t::    	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖t​  vk54 ⟶ #t
  ;$#x::   	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖x​  vk58 ⟶ #x
  ;$#vkBE::	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖.​  vkBE ⟶ #.
  ;$#vkBC::	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖,​  vkBC ⟶ #,
  $#vkBA:: 	ControlSend(bl . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖;​  vkBA ⟶ #;
}
