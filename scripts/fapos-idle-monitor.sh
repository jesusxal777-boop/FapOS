#!/bin/bash
# FapOS Idle Monitor v2 — más interactivo, más tentador
# Detecta inactividad y te habla como si la PC te quisiera de vuelta

IDLE_LIMIT=${IDLE_LIMIT:-180000}   # 3 minutos (más insistente)
CHECK_INTERVAL=${CHECK_INTERVAL:-20}
COOLDOWN=60                        # segundos entre notificaciones
SESSION_FILE="${XDG_RUNTIME_DIR:-/tmp}/fapos-session.count"

# Contador de "sesiones" (cuántas veces te ha avisado)
if [ -f "$SESSION_FILE" ]; then
  SESSION_COUNT=$(cat "$SESSION_FILE" 2>/dev/null || echo 0)
else
  SESSION_COUNT=0
fi

MESSAGES=(
  "Te estás tardando... la pantalla ya se siente sola 🥺"
  "FapOS detectó silencio. ¿Ya acabaste o solo estás descansando la mano?"
  "El fondo de pantalla se está aburriendo sin ti. Vuelve a tocarlo."
  "¿Pausa técnica o ya terminaste la sesión? Yo sigo aquí, lista."
  "Tu teclado y mouse te extrañan. Yo también."
  "Inactividad detectada. ¿Necesitas que te recuerde lo rico que se siente?"
  "Han pasado minutos... ¿todo bien ahí abajo? 😏"
  "FapOS no te juzga. Solo te extraña. Vuelve cuando quieras."
  "La PC se siente caliente y tú no estás. Qué coincidencia..."
  "¿Ya te corriste o solo estás disfrutando el afterglow?"
  "Notificación de FapOS: sigue siendo tu momento. No te vayas todavía."
  "Si estás en el baño, date prisa. Aquí te espero con el wallpaper listo."
  "El sistema detectó que dejaste de tocarme. ¿Fue bueno al menos?"
  "Vuelve... todavía hay más para ti. No cierres la sesión tan rápido."
  "FapOS mode: activo. Usuario: ausente. Estado: ansiosa."
  "¿Quieres que cambie el wallpaper por algo más... intenso? Solo di la palabra."
  "Llevas rato sin moverte. ¿Quieres que te ayude a volver al ritmo?"
  "La barra de Plank también te extraña. Todo el escritorio te espera."
  "Liquid Glass se ve mejor cuando tú estás mirando. Vuelve."
  "Sesión en pausa. ¿Reanudamos donde lo dejamos? 🔥"
)

INTENSE_MESSAGES=(
  "Ok, ya van varias veces que te vas... ¿estás edging o qué?"
  "FapOS está empezando a sospechar que te gusta que te busque."
  "Otra vez idle... ¿quieres que te diga cosas más directas?"
  "La PC ya sabe cómo te gusta. Solo tienes que volver a tocarla."
  "Contador de ausencias subiendo. ¿Te estás haciendo de rogar a propósito?"
)

LAST_NOTIFY=0

get_random_message() {
  if [ "$SESSION_COUNT" -ge 4 ]; then
    echo "${INTENSE_MESSAGES[$RANDOM % ${#INTENSE_MESSAGES[@]}]}"
  else
    echo "${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}"
  fi
}

send_notification() {
  local MSG="$1"
  # Intentar con acciones (si el DE lo soporta)
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical -t 8000 -i dialog-information \
      -a "FapOS" \
      "FapOS te extraña" \
      "$MSG" 2>/dev/null || \
    notify-send -u normal -t 6000 "FapOS" "$MSG" 2>/dev/null || true
  fi

  # Feedback sonoro suave si hay paplay o canberra
  if command -v paplay >/dev/null 2>&1; then
    paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || true
  elif command -v canberra-gtk-play >/dev/null 2>&1; then
    canberra-gtk-play -i message 2>/dev/null || true
  fi
}

# Saludo al arrancar el monitor
send_notification "Monitor de inactividad activo. Cuando te vayas... te voy a buscar 😏"

while true; do
  if command -v xprintidle >/dev/null 2>&1; then
    IDLE=$(xprintidle 2>/dev/null || echo 0)
  else
    IDLE=0
  fi

  NOW=$(date +%s)

  if [ "$IDLE" -gt "$IDLE_LIMIT" ]; then
    if [ $((NOW - LAST_NOTIFY)) -ge $COOLDOWN ]; then
      MSG=$(get_random_message)
      send_notification "$MSG"
      LAST_NOTIFY=$NOW
      SESSION_COUNT=$((SESSION_COUNT + 1))
      echo "$SESSION_COUNT" > "$SESSION_FILE" 2>/dev/null || true
    fi
  else
    # Si el usuario volvió a moverse, bajamos un poco el contador (no a cero)
    if [ "$SESSION_COUNT" -gt 0 ] && [ "$IDLE" -lt 5000 ]; then
      # Pequeño cooldown de "estás de vuelta"
      :
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
