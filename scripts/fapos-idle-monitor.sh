#!/bin/bash
# FapOS Idle Monitor
# Detects prolonged inactivity and sends playful notifications

IDLE_LIMIT=${IDLE_LIMIT:-300000}   # 5 minutes in milliseconds
CHECK_INTERVAL=${CHECK_INTERVAL:-30}
COOLDOWN=90                        # seconds between notifications

MESSAGES=(
  "¿Ya te cansaste? El sistema te está esperando..."
  "FapOS detectó inactividad. ¿Todo bien por ahí?"
  "El fondo de pantalla se aburre sin ti."
  "Vuelve cuando quieras, aquí no se juzga."
  "¿Sesión terminada o solo pausa técnica?"
  "Tu teclado y mouse te extrañan."
  "Notificación de FapOS: sigue siendo tu momento."
  "Inactividad detectada. ¿Necesitas un break o ya acabaste?"
)

LAST_NOTIFY=0

get_random_message() {
  echo "${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}"
}

while true; do
  if command -v xprintidle >/dev/null 2>&1; then
    IDLE=$(xprintidle 2>/dev/null || echo 0)
  else
    # Fallback: very basic, assumes always "active" if tool missing
    IDLE=0
  fi

  NOW=$(date +%s)

  if [ "$IDLE" -gt "$IDLE_LIMIT" ]; then
    if [ $((NOW - LAST_NOTIFY)) -ge $COOLDOWN ]; then
      MSG=$(get_random_message)
      notify-send -u normal -i dialog-information "FapOS" "$MSG" 2>/dev/null || \
      notify-send "FapOS" "$MSG" 2>/dev/null || true
      LAST_NOTIFY=$NOW
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
