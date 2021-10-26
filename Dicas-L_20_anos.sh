#!/bin/bash
  
  trap "tput sgr0; tput cnorm; clear; exit" 2 3 15
  
  Lin[0]=" 0000     00    000     000     0000            00                000     000            000     00    00   000    0000  "
  Lin[1]=" 00  00        00 00    000    00  00           00               00 00   00 00           000     000   00  00 00  00  00 "
  Lin[2]=" 00   00  00  00       00 00    00     000000   00                 00    00 00          00 00    00 0  00  00 00   00    "
  Lin[3]=" 00   00  00  00       00000      00   000000   00                00     00 00          00000    00  0 00  00 00     00  "
  Lin[4]=" 00  00   00   00 00  0000000  00  00           00  00           00000   00 00         0000000   00   000  00 00  00  00 "
  Lin[5]=" 0000     00    000  00     00  0000            000000           00000    000         00     00  00    00   000    0000  "
  clear
  
  TamTela=$(tput cols)
  (( TamTela <= ${#Lin[0]} )) && {
      echo A tela precisa ter mais de ${#Lin[0]} colunas
      exit 1
      }
  
  for ((i=0; i<=5; i++))
  {
      Lin[i]=$(printf "%${TamTela}s" "${Lin[i]}" | sed 's/ /o/g')
  }
  LinIni=$(( ( $(tput lines) - 6 ) / 2 ))
  Bold=$(tput bold)
  Cinza=$(tput setaf 0)
  Norm=$(tput sgr0)
  tput civis
  while true
  do
      tput cup $LinIni 0
      for ((i=0; i<=5; i++))
      {
          echo $(sed "s/o/$Bold${Cinza}o$Norm${Cor}/g" <<< "${Lin[i]}") 
          Lin[i]=${Lin[i]:1}${Lin[i]:0:1}
      }
      ((++j%40)) || Cor=$(tput setaf $((RANDOM%4+1)))
      sleep .06
  done

