#!/bin/bash

Sysout ()
{
  local _msg="`date "+%Y-%m-%d %H:%M:%S"` - $1";
  echo -e "$_msg"
  [ -n "$_arq_log_snx" ] && echo -e "$_msg" >> $_arq_log_snx;
  [ "$2" == "normal" -o "$2" == "critical" ] && notify-send -u "$2" "VPN" "$1"
}

snx_conectar_ajuda() {
  echo "Script para gerenciar a conexão da VPN utilizando o aplicativo SNX.";
  echo "";
  echo "Espera-se que as seguintes variáveis de ambientes estejam declaradas:";
  echo " - SNX_PATH_ARQ_CERTIFICADO";
  echo " - SNX_SENHA_PRIVADA";
  echo "";
  echo "Caso contrario será solicitado em tempo de execução.";
  echo "";
}

# Valida se existe uma pasta para os log's
if [ -z "$PATH_MEUS_LOGS" -a ! -e "$HOME/logs" ]; then
  echo "É necessário ter uma pasta para guardar os log's deste processo.";
  echo "";
  echo "Sugestão:";
  echo " - Crie a pasta '$HOME/logs' com o comando 'mkdir $HOME/logs' ou";
  echo " - Declare a variável de ambiente 'PATH_MEUS_LOGS' indicando onde gravar os logs,";
  echo "   através do comando 'export PATH_MEUS_LOGS=/path/para/meus/logs'.";
  exit 1;
fi

# Valida se existe variaveis de ambiente, caso contrario exibe ajuda
[ -z "$SNX_PATH_ARQ_CERTIFICADO" -o -z "$SNX_SENHA_PRIVADA" ] && snx_conectar_ajuda;

if [ -z "$SNX_PATH_ARQ_CERTIFICADO" ]; then
  echo -n "Informe o path do arquivo com o certificado: "; read SNX_PATH_ARQ_CERTIFICADO;
  echo ""
fi

if [ -z "$SNX_SENHA_PRIVADA" ]; then
  echo -n "Informe a senha privada: "; read -s SNX_SENHA_PRIVADA
  echo ""
fi

exit 0

#   Sysout "uso: vpn-bb PATH_CERTIFICADO"
#   exit 1
# else
#   if [ ! -e "$1" ]; then
#     Sysout "Não localizado o certificado [$1]."
#     exit 1
#   else
#     PATH_CERTIFICADO="$1"
#   fi
# fi

export _arq_log_snx="$HOME/logs/snx_`date "+%Y-%m-%d"`.log";
_ls_servidores=$SNX_SERVERS;
_qt_servidores="${#_ls_servidores[@]}"
_contador=0
_flag_conectado="NAO"

# Se existir arquivo flag, apaga
[ -e /tmp/snx.stop ] && rm /tmp/snx.stop

# OBTEM A SENHA DO CERTIFICADO VIA PROMPT
# echo -n "Informe a senha do certificado: "; read -s SENHA
# echo ""

# OBTEM A SENHA DO CERTIFICADO VIA ARQUIVO
SENHA=`cat ~/bin/vpn-bb.snh`

# Enquanto não for solicitada a desconexão, continua
while [ ! -e ~/bin/vpn-bb.stop ]; do
  # Testando se a internet está conectada
  if [ "`ip add | grep 192.168`" ]; then
    # Testando se o túnel SNX está ativo
    if [ ! "`ip link | grep tunsnx`" ]; then
      # Tunel não está ativo, então conecta à VPN-BB
      INDICE=$(( _contador % _qt_servidores ))
      SERVER="${_ls_servidores[INDICE]}"
      Sysout "Tentando conectar ao servidor [$SERVER]"
      ~/bin/monitora-snx.sh &
      snx -s $SERVER -c $PATH_ARQ_CERTIFICADO_VPN_BB -r yes <<< "$SENHA" &>> $_arq_log_snx
      _contador=$((_contador+1))
    fi
    # Testando conectividade com a rede interna do BB
    if [ "`ping -c1 intranet.bb.com.br`" ]; then
      if [ "$_flag_conectado" == "NAO" ]; then
        Sysout "VPN Conectada!!!" "normal"
        # Registrando a conexão em outro arquivo, por isso o 'echo'
        echo "`date "+%Y-%m-%d %H:%M:%S"` $SERVER" >> ~/logs/conexoes.dat
        _flag_conectado="SIM"
      fi
    else
      if [ "$_flag_conectado" == "SIM" ]; then
        Sysout "VPN Desconectada!!!" "normal"
        _flag_conectado="NAO"
      fi
    fi
  else
    Sysout "Internet desconectada, aguardando conexão!!!" "normal"
    if [ "`ip link | grep tunsnx`" ]; then
      snx -d &>> $_arq_log_snx
      _flag_conectado="NAO"
    fi
    sleep 10
  fi
  sleep 5 
done

Sysout "Solicitada a desconexão da VPN..."
rm ~/bin/vpn-bb.stop
if [ "`ip link | grep tunsnx`" ]; then
  snx -d &>> $_arq_log_snx
fi
sleep 5
