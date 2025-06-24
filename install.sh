#!/usr/bin/env bash
set -euo pipefail

# ---------- helpers -----------------------------------------------------------
die() { printf "\e[31m%s\e[0m\n" "$*" >&2; exit 1; }
need() { command -v "$1" &>/dev/null; }

install_pac() {
  local wanted=("$@") missing=()
  for p in "${wanted[@]}"; do
    pacman -Qq "$p" &>/dev/null || missing+=("$p")
  done
  [[ ${#missing[@]} -gt 0 ]] && sudo pacman -Sy --needed --noconfirm "${missing[@]}"
}

install_aur() {
  local wanted=("$@") missing=()
  for p in "${wanted[@]}"; do
    yay -Qq "$p" &>/dev/null || missing+=("$p")
  done
  [[ ${#missing[@]} -gt 0 ]] && yay -S --noconfirm "${missing[@]}"
}

ensure_yay() {
  if ! need yay; then
    [[ -d $HOME/yay ]] && rm -rf "$HOME/yay"
    git clone https://aur.archlinux.org/yay.git "$HOME/yay"
    (cd "$HOME/yay" && makepkg -si --noconfirm)
  fi
}

bak_and_checkout() {
  git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -- "$@" 2>&1 \
    | awk '/^\t/ {print substr($0,2)}' \
    | xargs -I{} bash -c 'mkdir -p "$HOME/$(dirname "{}")"; mv "$HOME/{}" "$HOME/{}.bak"' || true
  git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -- "$@"
}

clone_if_missing() {
  local repo=$1 dest=$2
  [[ -d $dest ]] || git clone "$repo" "$dest"
}

# ---------- package sets ------------------------------------------------------
PAC_KITTY=(kitty zsh nerd-fonts base-devel)
AUR_KITTY=(pokemon-colorscripts-git)

PAC_I3=(i3 nemo kitty nerd-fonts alsa-utils pipewire pipewire-alsa pipewire-pulse \
        pipewire-jack wireplumber zsh dmenu rofi polybar feh fastfetch base-devel)
AUR_I3=(picom-arian8j2-git pokemon-colorscripts-git)

PAC_GNOME=(gnome gnome-extra gnome-shell-extensions gnome-tweaks nemo dconf-editor nerd-fonts cinnamon)
AUR_GNOME=()

PAC_VIM=(vim)
AUR_VIM=()

PAC_FASTFETCH=(fastfetch nerd-fonts)
AUR_FASTFETCH=()

PAC_VSCODE=(base-devel)
AUR_VSCODE=(visual-studio-code-bin)

PAC_ALL=(vim git nemo kitty gnome gnome-extra gnome-shell-extensions gnome-tweaks zsh dmenu rofi polybar feh dconf-editor plasma alsa-utils fastfetch \
         pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber i3 nerd-fonts cinnamon base-devel)
AUR_ALL=(picom-arian8j2-git visual-studio-code-bin pokemon-colorscripts-git)

# ---------- menu --------------------------------------------------------------
cat <<EOF
Choose dot‑files profile to install:
 1) Full Kitty terminal setup (doesn't include Fastfetch)
 2) Full i3 + Kitty + Fastfetch setup (with smooth animations)
 3) GNOME/Cinnamon desktop import
 4) Vim only
 5) Fastfetch only
 6) VS Code extensions/config
 7) Everything (full repo)
 q) Quit
EOF
read -rp "Selection: " sel

case $sel in
 1)
    install_pac "${PAC_KITTY[@]}"
    ensure_yay; install_aur "${AUR_KITTY[@]}"
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    bak_and_checkout .config/kitty .p10k.zsh .p10k1.zsh .bashrc .zshrc .xinitrc .bash_profile
    ;;
  2)
    install_pac "${PAC_I3[@]}"
    ensure_yay; install_aur "${AUR_I3[@]}"
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    bak_and_checkout .config/i3 .config/fastfetch .config/kitty .config/rofi .config/picom \
                     .config/polybar .p10k.zsh .p10k1.zsh .bashrc .zshrc .xinitrc .bash_profile \
                     wallpapers .fehbg
    ;;
  3)
    install_pac "${PAC_GNOME[@]}"
    ensure_yay; install_aur "${AUR_GNOME[@]}"
    bak_and_checkout gnome wallpapers .local/share/cinnamon/extensions .config/cinnamon .icons
    ./restore-gnome.sh || true
    echo -e "\e[32mRebooting in 5 seconds to complete setup...\e[0m"; sleep 5; systemctl reboot
    ;;
  4)
    install_pac "${PAC_VIM[@]}"; bak_and_checkout .vimrc
    ;;
  5)
    install_pac "${PAC_FASTFETCH[@]}"; bak_and_checkout .config/fastfetch
    ;;
  6)
    install_pac "${PAC_VSCODE[@]}"; ensure_yay; install_aur "${AUR_VSCODE[@]}"; bak_and_checkout .vscode
    ;;
  7)
    install_pac "${PAC_ALL[@]}"; ensure_yay; install_aur "${AUR_ALL[@]}"
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    bak_and_checkout
    ;;
  q|Q) exit 0;;
  *) die "Unknown selection";;
esac

