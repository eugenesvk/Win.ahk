#Requires AutoHotKey 2.1-alpha.4

; ————— Iterate over elements in a string / array of chars
; bench_iter()
bench_iter() {
  t_loop_str	:= bench_loop_str()
  t_loop_arr	:= bench_loop_arr()
  t_for_arr 	:= bench_for_arr()
  dbgtxt    	:= ''                                      	; .=   no concat
  dbgtxt    	.= t_loop_arr '`t' 'loop parse array' '`n' 	;   9   9
  dbgtxt    	.= t_loop_str '`t' 'loop parse string' '`n'	; 200  53
  dbgtxt    	.= t_for_arr  '`t' "array for"             	; 417 231
  dbgMsg(0,dbgtxt,'Benchmark of iterations over string elements')
}
bench_loop_str(){
  s :='', data := 'qwertyuiop'
  perfT()
  loop 100000 {
    loop parse data {
      ; s .= A_LoopField
    }
  }
  return Round(perfT(),0)
}
bench_loop_arr(){
  s :='', data := ['q','w','e','r','t','y','u','i','o','p']
  perfT()
  loop 100000 {
    loop parse data {
      ; s .= A_LoopField
    }
  }
  return Round(perfT(),0)
}
bench_for_arr(){
  s :='', data := ['q','w','e','r','t','y','u','i','o','p']
  perfT()
  loop 100000 {
    for c in data {
      ; s .= c
    }
  }
  return Round(perfT(),0)
}
