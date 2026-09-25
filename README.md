# FapOS 1.0 — Liquid Glass Edition

**FapOS** es un sistema basado en Ubuntu 24.04 con look inspirado en **macOS / PearOS** y el estilo **Liquid Glass** (transparencias, cristal fluido, paneles suaves).

Incluye:
- Notificaciones de inactividad **muy interactivas y provocativas**
- Dock estilo macOS (Plank)
- Tema listo para WhiteSur / look glass
- Carpeta dedicada a wallpapers R34
- Pensado para correr en **QEMU**, **Limbo** (Android) y **UTM**

> **Disclaimer**: Proyecto personal / de diversión. Contenido adulto (R34) por diseño. Úsalo con responsabilidad.

---

## Estilo Liquid Glass / PearOS

Inspirado en:
- **PearOS** (Linux con look macOS + Liquid Gel)
- **macOS 26/27 Liquid Glass** (transparencias fluidas, refracción, paneles de cristal)

En FapOS se traduce a:
- WhiteSur GTK theme (oscuro o claro) + iconos WhiteSur
- Plank dock semitransparente
- Notificaciones con estilo glass (bordes suaves, blur cuando el DE lo permite)
- Fondos R34 con el escritorio como marco “de cristal”

---

## Características

| Feature | Descripción |
|---------|-------------|
| **Idle Monitor v2** | Detecta inactividad a los 3 min y te manda mensajes cada vez más intensos |
| **Interacciones** | Notificaciones críticas, sonido, contador de “sesiones” |
| **UI** | XFCE + Plank + WhiteSur (macOS-like / Liquid Glass) |
| **Wallpapers** | `/usr/share/backgrounds/fapos/` listo para R34 |
| **Live ISO** | Buildable con GitHub Actions |

---

## Contraseña (Live ISO)

- **Usuario:** `usuario`
- **Contraseña:** ninguna (solo Enter / vacío)

En el live system el usuario tiene sudo sin password para que sea fácil de usar en emuladores.

---

## Instalación rápida (sistema ya instalado)

```bash
git clone https://github.com/jesusxal777-boop/FapOS.git
cd FapOS
sudo bash install.sh
```

Luego:
1. Cierra sesión y vuelve a entrar (o reinicia)
2. Aplica tema WhiteSur en Apariencia
3. Pon tus wallpapers R34 en `/usr/share/backgrounds/fapos/`
4. El monitor de inactividad arranca solo

---

## Idle Monitor — cómo se siente

Después de **3 minutos** sin tocar teclado/mouse:

- Te manda notificaciones cada vez más directas y juguetonas
- A partir de la 4ª ausencia, los mensajes se ponen más intensos
- Incluye sonido de notificación
- Te “extraña” y te invita a volver

Puedes cambiar el tiempo editando `IDLE_LIMIT` (en milisegundos) en el script o en el servicio.

---

## Construir la Live ISO

1. Ve a **Actions** → **Build FapOS Live ISO**
2. Click en **Run workflow**
3. Espera (puede tardar mucho; usa XFCE para que sea más ligero)
4. Si tiene éxito, descarga el artifact `FapOS-Live-ISO`

> Nota: los builds de ISO en GitHub Actions son pesados. Si falla por espacio/tiempo, el log se sube igual para diagnosticar.

---

## Correr en emuladores

### QEMU
```bash
qemu-system-x86_64 -m 4096 -smp 4 -cdrom FapOS-1.0-LiquidGlass-amd64.iso -boot d -enable-kvm
```

### Limbo / UTM
Carga la ISO como medio de arranque (x86_64).

---

## Estructura del proyecto

```
FapOS/
├── README.md
├── install.sh
├── scripts/
│   └── fapos-idle-monitor.sh   # v2 — más interactivo y tentador
├── configs/
│   └── autostart/
├── branding/
│   ├── os-release
│   └── lsb-release
├── wallpapers/                 # Pon aquí tus R34 (no van en el repo)
└── .github/workflows/
    └── build-iso.yml
```

---

## License

MIT — haz lo que quieras, solo no seas un cabrón.

---

Hecho para divertirse. Liquid Glass. Más interacciones. Más ganas de volver a tocarla.
