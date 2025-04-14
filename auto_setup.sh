#!/usr/bin/env bash

# ==============================================
# Automatic Environment Setup Script
# Author: @r1vs3c (Juan Rivas)
# Modified: @K4ysuh (Javier Roldán)
# Version: 2.0
# ==============================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Variables ---
USER=$(whoami)
FDIR="$HOME/.local/share/fonts"
CONFIG_DIR="$HOME/.config"
WALLPAPER_DIR="$HOME/Wallpapers"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# --- Dependencies Lists ---
CORE_DEPS=(
    kitty rofi feh xclip ranger i3lock-fancy scrot 
    scrub wmname imagemagick cmatrix htop python3-pip 
    procps tty-clock fzf lsd bat pamixer flameshot
)

BSPWM_DEPS=(
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev
    libxcb-util0-dev libxcb-icccm4-dev libyajl-dev
    libstartup-notification0-dev libxcb-randr0-dev
    libev-dev libxcb-cursor-dev libxcb-xinerama0-dev
    libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev
    autoconf libxcb-xrm-dev libxcb-shape0-dev libxcb-ewmh-dev
)

BUILD_DEPS=(
    build-essential git cmake meson ninja-build pkg-config
)

# --- Functions ---
function show_banner() {
    echo -e "\n${CYAN}              _____            ______"
    echo -e "______ ____  ___  /______      ___  /___________________      ________ ___"
    echo -e "_  __ \`/  / / /  __/  __ \     __  __ \_  ___/__  __ \_ | /| / /_  __ \`__ \\"
    echo -e "/ /_/ // /_/ // /_ / /_/ /     _  /_/ /(__  )__  /_/ /_ |/ |/ /_  / / / / /"
    echo -e "\__,_/ \__,_/ \__/ \____/      /_.___//____/ _  .___/____/|__/ /_/ /_/ /_/    ${YELLOW}(By ${PURPLE}@r1vs3c${YELLOW})${CYAN}"
    echo -e "                                             /_/${NC}"
}

function die() {
    echo -e "\n${RED}[!] Error: $1${NC}"
    exit 1
}

function install_dependencies() {
    echo -e "\n${BLUE}[*] Installing core dependencies...${NC}"
    sudo apt update || die "Failed to update packages"
    sudo apt install -y "${CORE_DEPS[@]}" "${BUILD_DEPS[@]}" || die "Failed to install core dependencies"
    
    echo -e "\n${BLUE}[*] Installing BSPWM dependencies...${NC}"
    sudo apt install -y "${BSPWM_DEPS[@]}" || die "Failed to install BSPWM dependencies"
}

function install_neofetch() {
    echo -e "\n${PURPLE}[*] Installing Neofetch from GitHub...${NC}"
    git clone https://github.com/dylanaraps/neofetch.git "$HOME/tools/neofetch" || die "Failed to clone Neofetch"
    sudo make -C "$HOME/tools/neofetch" install || die "Failed to install Neofetch"
}

function install_pywal() {
    echo -e "\n${BLUE}[*] Installing pywal...${NC}"
    sudo pip3 install pywal --break-system-packages || die "Failed to install pywal"
}

function install_bspwm() {
    echo -e "\n${PURPLE}[*] Installing bspwm...${NC}"
    git clone https://github.com/baskerville/bspwm.git "$HOME/bspwm" || die "Failed to clone bspwm"
    cd "$HOME/bspwm" || die "Could not enter bspwm directory"
    make -j$(nproc) || die "Failed to compile bspwm"
    sudo make install || sudo apt install -y bspwm || die "Failed to install bspwm"
    cd ..
}

function install_sxhkd() {
    echo -e "\n${PURPLE}[*] Installing sxhkd...${NC}"
    git clone https://github.com/baskerville/sxhkd.git "$HOME/sxhkd" || die "Failed to clone sxhkd"
    cd "$HOME/sxhkd" || die "Could not enter sxhkd directory"
    make -j$(nproc) || die "Failed to compile sxhkd"
    sudo make install || die "Failed to install sxhkd"
    cd ..
}

function install_polybar() {
    echo -e "\n${PURPLE}[*] Installing polybar...${NC}"
    git clone --recursive https://github.com/polybar/polybar.git "$HOME/polybar" || die "Failed to clone polybar"
    cd "$HOME/polybar" || die "Could not enter polybar directory"
    mkdir -p build && cd build || die "Could not create build directory"
    cmake .. || die "CMake configuration failed"
    make -j$(nproc) || die "Failed to compile polybar"
    sudo make install || die "Failed to install polybar"
    cd ../..
}

function install_picom() {
    echo -e "\n${PURPLE}[*] Installing picom...${NC}"
    git clone https://github.com/ibhagwan/picom.git "$HOME/picom" || die "Failed to clone picom"
    cd "$HOME/picom" || die "Could not enter picom directory"
    git submodule update --init --recursive || die "Failed to update submodules"
    meson --buildtype=release . build || die "Meson configuration failed"
    ninja -C build || die "Failed to compile picom"
    sudo ninja -C build install || die "Failed to install picom"
    cd ..
}

function configure_fonts() {
    echo -e "\n${PURPLE}[*] Configuring fonts...${NC}"
    mkdir -p "$FDIR" || die "Could not create fonts directory"
    cp -rv "$SCRIPT_DIR/fonts/"* "$FDIR" || echo -e "${YELLOW}[!] No fonts found to copy${NC}"
}

function configure_wallpapers() {
    echo -e "\n${PURPLE}[*] Configuring wallpapers...${NC}"
    mkdir -p "$WALLPAPER_DIR" || die "Could not create wallpapers directory"
    cp -rv "$SCRIPT_DIR/wallpapers/"* "$WALLPAPER_DIR" || echo -e "${YELLOW}[!] No wallpapers found to copy${NC}"
    wal -a 90 -b '#1c1b26' -nqi "$WALLPAPER_DIR/archkali.png" || echo -e "${YELLOW}[!] Could not set wallpaper${NC}"
    sudo wal -a 90 -b '#1c1b26' -nqi "$WALLPAPER_DIR/archkali.png" || echo -e "${YELLOW}[!] Could not set root wallpaper${NC}"
}

function configure_dotfiles() {
    echo -e "\n${PURPLE}[*] Configuring dotfiles...${NC}"
    mkdir -p "$CONFIG_DIR"
    cp -rv "$SCRIPT_DIR/config/"* "$CONFIG_DIR" || echo -e "${YELLOW}[!] No config files found to copy${NC}"
    
    # ZSH configuration
    cp -v "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" || echo -e "${YELLOW}[!] No .zshrc found${NC}"
    sudo ln -sf "$HOME/.zshrc" "/root/.zshrc"
    cp -v "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh" || echo -e "${YELLOW}[!] No .p10k.zsh found${NC}"
    sudo cp -v "$SCRIPT_DIR/Root_p10k.zsh" "/root/.p10k.zsh" || echo -e "${YELLOW}[!] No Root_p10k.zsh found${NC}"
}

function install_powerlevel10k() {
    echo -e "\n${PURPLE}[*] Installing Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k" || die "Failed to install Powerlevel10k for user"
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "/root/powerlevel10k" || echo -e "${YELLOW}[!] Failed to install Powerlevel10k for root${NC}"
}

function install_fzf() {
    echo -e "\n${PURPLE}[*] Installing FZF...${NC}"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" || die "Failed to clone FZF"
    "$HOME/.fzf/install" --all || die "Failed to install FZF"
}

function install_nvchad() {
    echo -e "\n${PURPLE}[*] Installing NvChad...${NC}"
    git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" --depth 1 || die "Failed to install NvChad for user"
    sudo git clone https://github.com/NvChad/NvChad "/root/.config/nvim" --depth 1 || echo -e "${YELLOW}[!] Failed to install NvChad for root${NC}"
}

function set_permissions() {
    echo -e "\n${PURPLE}[*] Setting permissions...${NC}"
    chmod -R +x "$HOME/.config/bspwm/"
    chmod +x "$HOME/.config/polybar/launch.sh"
    chmod +x "$HOME/.config/polybar/shapes/scripts/"* || true
    sudo mkdir -p "/root/.config/polybar/shapes/scripts/"
    sudo touch "/root/.config/polybar/shapes/scripts/target"
    sudo ln -sf "$HOME/.config/polybar/shapes/scripts/target" "/root/.config/polybar/shapes/scripts/target"
}

function cleanup() {
    echo -e "\n${BLUE}[*] Cleaning up...${NC}"
    rm -rf "$HOME/tools" "$HOME/bspwm" "$HOME/sxhkd" "$HOME/polybar" "$HOME/picom" || true
}

# --- Main Execution ---
clear
show_banner

if [ "$USER" == "root" ]; then
    die "Do not run this script as root!"
fi

# Installation steps
install_dependencies
install_neofetch
install_pywal
install_bspwm
install_sxhkd
install_polybar
install_picom
install_powerlevel10k
install_fzf
install_nvchad

# Configuration steps
configure_fonts
configure_wallpapers
configure_dotfiles
set_permissions
cleanup

echo -e "\n${GREEN}[+] Environment successfully configured!${NC}"
echo -e "${YELLOW}[!] Please restart your system to apply all changes${NC}"

# Prompt for reboot
read -rp "Do you want to reboot now? [y/N] " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    sudo reboot
fi
