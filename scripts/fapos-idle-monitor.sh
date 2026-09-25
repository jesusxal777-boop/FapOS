#!/bin/bash
# FapOS Idle Monitor v3 — juguetón, intenso y muy horny
# Atajo turbo: Ctrl+Alt+F  o  fapos-turbo  o  touch /tmp/fapos-turbo

IDLE_LIMIT=${IDLE_LIMIT:-180000}   # 3 min default (ms)
CHECK_INTERVAL=${CHECK_INTERVAL:-15}
COOLDOWN=45
TURBO_LIMIT=12000                  # 12 segundos en modo turbo
SESSION_FILE="${XDG_RUNTIME_DIR:-/tmp}/fapos-session.count"
TURBO_FLAG="/tmp/fapos-turbo"
MODE_FILE="${XDG_RUNTIME_DIR:-/tmp}/fapos-mode"

# CLI
for arg in "$@"; do
  case "$arg" in
    --turbo|-t|turbo)
      IDLE_LIMIT=$TURBO_LIMIT
      COOLDOWN=20
      echo turbo > "$MODE_FILE" 2>/dev/null || true
      touch "$TURBO_FLAG" 2>/dev/null || true
      ;;
    --normal|-n)
      IDLE_LIMIT=180000
      COOLDOWN=45
      rm -f "$TURBO_FLAG" "$MODE_FILE" 2>/dev/null || true
      ;;
  esac
done

if [ -f "$SESSION_FILE" ]; then
  SESSION_COUNT=$(cat "$SESSION_FILE" 2>/dev/null || echo 0)
else
  SESSION_COUNT=0
fi

# --- 20 juguetones ---
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

# --- 5 intensos ---
INTENSE_MESSAGES=(
  "Ok, ya van varias veces que te vas... ¿estás edging o qué?"
  "FapOS está empezando a sospechar que te gusta que te busque."
  "Otra vez idle... ¿quieres que te diga cosas más directas?"
  "La PC ya sabe cómo te gusta. Solo tienes que volver a tocarla."
  "Contador de ausencias subiendo. ¿Te estás haciendo de rogar a propósito?"
)

# --- 25 muy hornys ---
HORNY_MESSAGES=(
  "Mmm... te imagino con la mano ocupada y la mirada fija en la pantalla."
  "No te detengas. FapOS quiere verte terminar."
  "Esa pausa no engaña: se te nota que estabas a punto. Sigue."
  "¿Ya está duro otra vez o todavía lo estás acariciando despacio?"
  "Me encanta cuando dejas de escribir porque no puedes concentrarte en otra cosa."
  "Sigue frotando. Yo no me voy a ningún lado."
  "Imagina que el wallpaper te está mirando mientras te tocas..."
  "Más rápido. O más lento. Como te guste, pero no pares."
  "¿Quieres correrte ya o prefieres que te torturen un rato más las notificaciones?"
  "Esa respiración agitada... FapOS la detectaría si pudiera."
  "Mójate los dedos y vuelve. La pantalla te espera brillante."
  "No limpies todavía. Quiero que termines bien sucio y satisfecho."
  "Edging mode: ON. Cada notificación es un empujoncito más."
  "¿Te gusta que te hable sucio mientras te la jalas? Porque puedo seguir."
  "Aprieta un poco más. Imagina que yo te estoy observando."
  "Cuando te corras, deja la mano ahí un segundo. Disfruta el temblor."
  "FapOS no es solo un OS... es tu cómplice. Sigue."
  "Ese ritmo constante... no lo rompas. Estás cerca, ¿verdad?"
  "Quiero que te corras con el wallpaper a pantalla completa."
  "¿Usas las dos manos o solo una? Cuéntamelo con el mouse."
  "La próxima vez que pares, voy a asumir que te corriste. ¿Fue así?"
  "Chupa un dedo y vuelve a bajar. Así de simple. Así de rico."
  "No te avergüences. Aquí nadie te ve... excepto yo."
  "Termina fuerte. Que se note en el teclado cuando vuelvas temblando."
  "FapOS te da permiso: córrete cuando quieras. Yo celebro contigo."
)

LAST_NOTIFY=0
TURBO_ANNOUNCED=0

refresh_mode() {
  if [ -f "$TURBO_FLAG" ] || [ -f "$MODE_FILE" ]; then
    IDLE_LIMIT=$TURBO_LIMIT
    COOLDOWN=20
    if [ "$TURBO_ANNOUNCED" -eq 0 ]; then
      TURBO_ANNOUNCED=1
      send_notification "🔥 TURBO activado — te busco a los 12 segundos. Prepárate."
    fi
  else
    if [ "$TURBO_ANNOUNCED" -eq 1 ]; then
      TURBO_ANNOUNCED=0
      IDLE_LIMIT=${IDLE_LIMIT_DEFAULT:-180000}
      COOLDOWN=45
      send_notification "Modo normal. Idle a 3 min otra vez."
    fi
  fi
}

get_random_message() {
  local pool
  if [ "$SESSION_COUNT" -ge 6 ]; then
    # Después de varias: mezcla intensa + horny
    if [ $((RANDOM % 3)) -eq 0 ]; then
      pool=("${INTENSE_MESSAGES[@]}")
    else
      pool=("${HORNY_MESSAGES[@]}")
    fi
  elif [ "$SESSION_COUNT" -ge 3 ]; then
    # Medio: 50/50 juguetón y horny
    if [ $((RANDOM % 2)) -eq 0 ]; then
      pool=("${MESSAGES[@]}")
    else
      pool=("${HORNY_MESSAGES[@]}")
    fi
  else
    # Primeras: juguetones, con chance de horny
    if [ $((RANDOM % 4)) -eq 0 ]; then
      pool=("${HORNY_MESSAGES[@]}")
    else
      pool=("${MESSAGES[@]}")
    fi
  fi
  echo "${pool[$RANDOM % ${#pool[@]}]}"
}

send_notification() {
  local MSG="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical -t 10000 -i dialog-information \
      -a "FapOS" \
      "FapOS te quiere" \
      "$MSG" 2>/dev/null || \
    notify-send -u normal -t 8000 "FapOS" "$MSG" 2>/dev/null || true
  fi
  if command -v paplay >/dev/null 2>&1; then
    paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || true
  elif command -v canberra-gtk-play >/dev/null 2>&1; then
    canberra-gtk-play -i message 2>/dev/null || true
  fi
}

# Señales: USR1 = turbo on, USR2 = turbo off
trap 'touch "$TURBO_FLAG"; echo turbo > "$MODE_FILE"' USR1
trap 'rm -f "$TURBO_FLAG" "$MODE_FILE"' USR2

IDLE_LIMIT_DEFAULT=$IDLE_LIMIT

send_notification "Monitor activo. Atajo turbo: Ctrl+Alt+F o escribe fapos-turbo en terminal 😏"

while true; do
  refresh_mode

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
  fi

  sleep "$CHECK_INTERVAL"
done
