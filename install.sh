#!/usr/bin/env bash
# ---------------------------------------------------------------
#  Hyprland-Rice installer (Arch Linux)
#  Repo:   https://github.com/yolacodium/Hyprland-Rice
#  Branch: Hyrpland
# ---------------------------------------------------------------
set -euo pipefail

REPO_URL="https://github.com/yolacodium/Hyprland-Rice.git"
BRANCH="Hyrpland"
CLONE_DIR="$HOME/.local/share/Hyprland-Rice"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Alle Ordner aus .config/ im Repo werden automatisch nach ~/.config verlinkt.
# Hier Ordner eintragen, die NICHT verlinkt werden sollen (leer = alles verlinken).
EXCLUDE_FOLDERS=(Claud discord go dconf mozilla mpv obs-studio pulse session spotify systemd VSCodium yay)

# ---- Pakete ----------------------------------------------------
PACMAN_PKGS=(
  git base-devel
  hyprland xdg-desktop-portal-hyprland hyprpolkitagent
  kitty rofi
  cava
  pipewire pipewire-pulse wireplumber playerctl
  brightnessctl grim slurp wl-clipboard cliphist
  networkmanager bluez bluez-utils
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
  qt5-wayland qt6-wayland
  swww
  btop
)

AUR_PKGS=(
  aylurs-gtk-shell-git   # ags
  libastal-meta          # Astal Libraries (notifd, mpris, battery, ...)
  matugen-bin            # Farben aus dem Wallpaper
)

# ---- Helfer ----------------------------------------------------
c_info()  { printf '\e[1;34m[*]\e[0m %s\n' "$*"; }
c_ok()    { printf '\e[1;32m[+]\e[0m %s\n' "$*"; }
c_warn()  { printf '\e[1;33m[!]\e[0m %s\n' "$*"; }
c_err()   { printf '\e[1;31m[x]\e[0m %s\n' "$*" >&2; }

if [[ $EUID -eq 0 ]]; then
  c_err "Bitte nicht als root ausfuehren."
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  c_err "Dieses Script ist fuer Arch Linux (pacman) gedacht."
  exit 1
fi

# ---- 1. Pakete installieren ------------------------------------
c_info "Installiere Pakete aus den offiziellen Repos ..."
sudo pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"

if ! command -v yay >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
  c_info "Kein AUR-Helper gefunden, installiere yay ..."
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

AUR_HELPER="$(command -v yay || command -v paru)"
c_info "Installiere AUR-Pakete mit $(basename "$AUR_HELPER") ..."
"$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}"

# ---- 2. Repo klonen / aktualisieren ----------------------------
if [[ -d "$CLONE_DIR/.git" ]]; then
  c_info "Repo existiert schon, aktualisiere ..."
  git -C "$CLONE_DIR" fetch origin "$BRANCH"
  git -C "$CLONE_DIR" checkout "$BRANCH"
  git -C "$CLONE_DIR" pull --ff-only origin "$BRANCH"
else
  c_info "Klone $REPO_URL (Branch: $BRANCH) ..."
  mkdir -p "$(dirname "$CLONE_DIR")"
  git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$CLONE_DIR"
fi

SRC_DIR="$CLONE_DIR/.config"
if [[ ! -d "$SRC_DIR" ]]; then
  c_err "Im Repo wurde kein .config/-Ordner gefunden ($SRC_DIR)."
  exit 1
fi

# ---- 3. Configs verlinken (mit Backup) -------------------------
mkdir -p "$CONFIG_DIR"
shopt -s nullglob
for src in "$SRC_DIR"/*/; do
  src="${src%/}"
  folder="$(basename "$src")"
  dest="$CONFIG_DIR/$folder"

  # Ausgeschlossene Ordner ueberspringen
  skip=0
  for ex in "${EXCLUDE_FOLDERS[@]}"; do
    [[ "$folder" == "$ex" ]] && skip=1
  done
  if (( skip )); then
    c_warn "'$folder' ist ausgeschlossen, ueberspringe."
    continue
  fi

  # Schon korrekt verlinkt?
  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    c_ok "$folder ist bereits verlinkt."
    continue
  fi

  # Bestehende Config sichern
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    c_warn "Backup: $dest -> $BACKUP_DIR/"
  fi

  ln -s "$src" "$dest"
  c_ok "Verlinkt: $dest -> $src"
done

# ---- 4. Wallpaper-Ordner & matugen -----------------------------
mkdir -p "$WALLPAPER_DIR"
if [[ -d "$CLONE_DIR/wallpapers" ]]; then
  cp -n "$CLONE_DIR"/wallpapers/* "$WALLPAPER_DIR"/ 2>/dev/null || true
  c_ok "Wallpaper nach $WALLPAPER_DIR kopiert."
fi

# Erste Farbpalette erzeugen, damit colors.css / colors.rasi / colors.lua existieren
first_wp="$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | head -n1 || true)"
if [[ -n "${first_wp:-}" ]] && command -v matugen >/dev/null 2>&1; then
  c_info "Erzeuge Farben aus $(basename "$first_wp") ..."
  matugen image "$first_wp" || c_warn "matugen ist fehlgeschlagen, spaeter manuell ausfuehren."
else
  c_warn "Kein Wallpaper gefunden. Lege Bilder in $WALLPAPER_DIR ab und fuehre 'matugen image <bild>' aus."
fi

# ---- 5. Services -----------------------------------------------
c_info "Aktiviere Dienste ..."
sudo systemctl enable --now NetworkManager.service || true
sudo systemctl enable --now bluetooth.service || true
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service || true

# ---- Fertig ----------------------------------------------------
echo
c_ok "Installation abgeschlossen!"
[[ -d "$BACKUP_DIR" ]] && c_info "Alte Configs liegen in: $BACKUP_DIR"
c_info "Melde dich ab und starte Hyprland neu (oder 'Hyprland' in einer TTY)."
