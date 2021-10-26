# Define arquivo de log
ARQ_LOG=~/logs/snx_`date "+%Y-%m-%d"`.log

# Aguarda um tempo
sleep 15

# Obtem dados do SNX
PID_SNX=`ps -C snx -o pid=`
LNK_SNX=`ip link | grep tunsnx`

# echo "PID_SNX=[$PID_SNX]"
# echo "LNK_SNX=[$LNK_SNX]"

# Verifica status da situação
if [ -n "$PID_SNX" ]; then
  if [ -z "$LNK_SNX" ]; then
    echo "`date "+%Y-%m-%d %H:%M:%S"` - SNX em execução sem link ativo, matando processo do SNX..." >> "$ARQ_LOG"
    kill -9 "$PID_SNX"
  fi
else
  if [ -n "$LNK_SNX" ]; then
    echo "`date "+%Y-%m-%d %H:%M:%S"` - SNX não está em execução mas existe um link ativo, desconectando o link..." >> "$ARQ_LOG"
    snx -d
  fi
fi

