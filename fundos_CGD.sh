#!/bin/bash

# VARIABLES

#Directory for html files
updatedPage=/home/user/scriptProjeto/fundos_CGD_$(date +%Y%m%d).html

# FUNCTIONS

#I checked this website to understand better bash functions and its syntax
#https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php

#Function that will help us to compare data
echoFirstValueComparison() {

  local firstValue="$(cat $updatedPage | grep -A1 "$1" \
  | tail -n 1 | tr -d ' ' | tr -d '€' | tr ',' '.' | tr -d '\n\r\t' )"

  echo "$(date +%d-%m-%Y):$firstValue" 

}


#Function that will get the first value and echo it to the file
#This function will write the date as well
echoFirstValueFile() {

  local firstValue="$(cat $updatedPage | grep -A1 "$1" \
  | tail -n 1 | tr -d ' ' | tr -d '€' | tr ',' '.' | tr -d '\n\r\t' )"

  echo "$(date +%d-%m-%Y):$firstValue" >> "$2.dat" 

}

#Function that prints values from the page
printValuesFromPage() {

  local firstValue="$(cat $updatedPage | grep -A1 "$1" \
  | tail -n 1 | tr -d ' ' | tr -d '€' | tr ',' '.' | tr -d '\n\r\t' )"
  local secondValue="$(cat $updatedPage | grep -A3 "$1" | tail -n 1 \
  | tr -d ' ' | tr -d '€' | tr ',' '.' | tr -d '\n\r\t')"
  local thirdValue="$(cat $updatedPage | grep -A5 "$1" | tail -n 1 \
  | tr -d ' ' | tr ',' '.' | tr -d '\n\r\t' | cut -d "[" -f1)"
  local fourthValue="$(cat $updatedPage | grep -A7 "$1" | tail -n 1 \
  | tr -d ' ' | tr ',' '.' | tr -d '\n\r\t' | cut -d "[" -f1)"

  local array_Values=( $firstValue $secondValue $thirdValue $fourthValue )

  echo "$2|${array_Values[0]}|${array_Values[1]}|${array_Values[2]}|${array_Values[3]}"

}

#Function that downloads the website
download() {

  wget -O ~/scriptProjeto/fundos_CGD_$(date +%Y%m%d).html \
  https://www.cgd.pt/Particulares/Poupanca-Investimento/Fundos-de-Investimento/Pages/CotacoeseRendibilidades.aspx &&
  echo "O download da página foi realizado!" || echo "[ERRO]: O download não foi efetuado!" 

}
#Function that displays the script's manual
manual() {

  echo ""
  echo ""
  echo -e "\033[1m		Informação sucinta da script\033[0m"
  echo -e "\033[1mNOME\033[0m:fundos_CGD.sh"
  echo -e "\033[1mSINOPSE\033[0m:fundos_CGD.sh [\e[4moptions\e[0m]"
  echo -e "\033[1mDESCRIÇÃO\033[0m:"
  echo "Esta script tem como função generalizada mostrar as cotações\
 dos fundos disponibilizados pela CGD."
  echo -e "\033[1mOPÇÕES\033[0m:"
  echo "'-h' - Mostrar o manual da script."
  echo "'-i' - Realizar o download da página da CGD."
  echo ""
  echo ""

#While I was coding this function, I checked these websites for support
#https://stackoverflow.com/questions/2924697/how-does-one-output-bold-text-in-bash
#https://www.unix.com/shell-programming-and-scripting/91021-how-can-i-bold-text.html

}

#Function that will run if you do not send any arguments
runScriptWithoutArgs() {

  if [ !  -f "$updatedPage" ]; then

    echo "[ERRO]: ficheiro 'fundos_CGD_$(date +%Y%m%d).html' não \
    encontrado no dirétorio local."
  else
# The script will run this, if the file exists
    echo ""
    echo "data|$(date +%d-%m-%Y)"
    echo "Fundo|data|data-1|12meses|24meses"
    printValuesFromPage "Cx Ações Europa Soc Resp" "EU"
    printValuesFromPage "Cx Ações EUA" "EUA"
    printValuesFromPage "Cx Ações Portugal Espanha" "PT"
    printValuesFromPage "Cx Ações Oriente" "ORI"
    printValuesFromPage "Cxg Ações Emergentes" "EMER"
    printValuesFromPage "Cx Ações Líderes Globais" "GLOB"
    printValuesFromPage "Caixa Reforma Activa" "Reforma"
    echo ""

#I checked these website to find a better way to do this loop since I need to 
#loop through two arrays, so I couldn't use "for i in "${arr[@]}" instead.
#https://www.cyberciti.biz/faq/bash-for-loop/
#https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash

    local array_fileName=( "EU" "EUA" "PT" "ORI" "EMER" "GLOB" "Reforma" )
    local array_name=( "Cx Ações Europa Soc Resp" "Cx Ações EUA" "Cx Ações Portugal Espanha"\
 "Cx Ações Oriente" "Cxg Ações Emergentes" "Cx Ações Líderes Globais" "Caixa Reforma Activa" )
 
    for (( i=0; i<7; i++ ))
    do
      if [ ! -f /home/user/ARQUIVO/${array_fileName[i]}.dat ]; then

        cd /home/user/ARQUIVO
        touch "${array_fileName[i]}.dat"
        echo "# Dados para o fundo ${array_fileName[i]}" >> ${array_fileName[i]}.dat
        echo "# Rodrigo Pintassilgo/2191190_IPLeiria" >> ${array_fileName[i]}.dat 
        echo "# Criado: $(date +%Y.%m.%d_%Hh:%M:%S)" >> ${array_fileName[i]}.dat
        echoFirstValueFile "${array_name[i]}" "${array_fileName[i]}"
        echo "Os ficheiro '${array_fileName[i]}.dat' foi criado com sucesso!"
       else
         cd /home/user/ARQUIVO
         #Here, I'm comparing the last string that was written in the file with the new one that may be added
         #to the file if they're different
         local stringFile="$(cat ${array_fileName[i]}.dat |tail -n 1 | tr -d '\n\r\t' | tr -d ' ')"
         local stringNOW="$(echoFirstValueComparison "${array_name[i]}" | tr -d '\n\r\t' | tr -d ' ')"
         if [[ "$stringFile" == "$stringNOW" ]]; then
           echo "[Ficheiro '${array_fileName[i]}.dat']: Nenhuns dados foram guardados. Dados iguais!"
          else            
           echoFirstValueFile "${array_name[i]}" "${array_fileName[i]}"
           echo "[Ficheiro '${array_fileName[i]}.dat']: Dados gravados com sucesso"
         fi
      
      fi
    done 
  
  fi

}

#Main function to simplify/understand better the code
main() {

# If the directories don't exist, then they're going to be created

 if  [ !  -d /home/user/scriptProjeto ]; then  
   mkdir /home/user/scriptProjeto
   echo "O diretório 'scriptProjeto' foi criado com sucesso!"  
 fi
 if  [ ! -d /home/user/ARQUIVO ]; then  
   mkdir /home/user/ARQUIVO
   echo "O diretório 'ARQUIVO' foi criado com sucesso!"
 fi

#Here, I'm checking if the user is sending more than one argument
 if (( $# < 2 ));then

#options with case
  case "$1" in

#if I run the script without any arguments (**Warning**: Not to confuse, an option is just an argument started with -)
   "") runScriptWithoutArgs
       ;;
#the cgd page will be downloaded
   -i) download
       ;;
#the script will show you a manual
   -h) manual
       ;;
#Check for invalid option
    *) echo "[ERRO]: opcao invalida!"
       echo "Verifica a opcao '-h' para verificar as opcoes disponiveis!"
       ;;

  esac

 else
  echo "[ERRO]: Quantidade inválida de parâmetros!"
 fi

}


#Calling the main/primary function! 
main "$@"

