#!/usr/bin/env bash
set -euo pipefail

die()  { printf "\e[31m%s\e[0m\n" "$*" >&2; exit 1; }
need() { command -v "$1" &>/dev/null; }

_expand_group() { pacman -Sgq "$1" 2>/dev/null || echo "$1"; }

install_pac() {
  local missing=() packages arg
  for arg; do
    packages=($(_expand_group "$arg"))
    for pkg in "${packages[@]}"; do
      pacman -Qq "$pkg" &>/dev/null || missing+=("$pkg")
    done
  done
  (( ${#missing[@]} )) && sudo pacman -Sy --needed "${missing[@]}"
  return 0
}

install_aur() {
  local missing=()
  for pkg; do
    yay -Qq "$pkg" &>/dev/null || missing+=("$pkg")
  done
  (( ${#missing[@]} )) && yay -S --needed "${missing[@]}"
  return 0
}

ensure_yay() {
  if ! need yay; then
    [[ -d $HOME/yay ]] && rm -rf "$HOME/yay"
    git clone https://aur.archlinux.org/yay.git "$HOME/yay"
    (cd "$HOME/yay" && makepkg -si --noconfirm)
  fi
}

bak_and_checkout() {
  git --git-dir="$HOME/.dotfiles" ls-tree -r --name-only main -- "$@" |
  while IFS= read -r f; do
    if [[ -e $HOME/$f ]]; then
      mkdir -p "$HOME/$(dirname "$f")"
      mv    "$HOME/$f" "$HOME/${f}.bak"
    fi
  done
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout main -- "$@"
}

bak_and_checkout_full() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" ls-files -z \
    | xargs -0 rm -f --

  rm -rf "$HOME/.dotfiles"
  git clone --bare https://github.com/imvinnyc/Dotfiles.git "$HOME/.dotfiles"

  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout 2>&1 \
    | awk '/^\t/ {print substr($0,2)}' \
    | xargs -I{} bash -c '
        mkdir -p "$HOME/$(dirname "{}")"
        mv "$HOME/{}" "$HOME/{}.bak"
      ' || true

  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout
}

clone_if_missing() { [[ -d $2 ]] || git clone "$1" "$2"; }

# -- Package sets --
PAC_KITTY=(kitty zsh nerd-fonts base-devel)
AUR_KITTY=(pokemon-colorscripts-git)

PAC_I3=(i3 nemo kitty nerd-fonts alsa-utils pipewire pipewire-alsa \
        pipewire-pulse pipewire-jack wireplumber zsh dmenu rofi polybar \
        feh fastfetch base-devel)
AUR_I3=(picom-arian8j2-git pokemon-colorscripts-git)

PAC_GNOME=(gnome gnome-extra gnome-shell-extensions gnome-tweaks nemo \
           dconf-editor nerd-fonts cinnamon plasma)
AUR_GNOME=()

PAC_VIM=(vim)                       ; AUR_VIM=()
PAC_FASTFETCH=(fastfetch nerd-fonts); AUR_FASTFETCH=()
PAC_VSCODE=(base-devel)             ; AUR_VSCODE=(visual-studio-code-bin)

PAC_ALL=(vim git nemo kitty gnome gnome-extra gnome-shell-extensions \
         gnome-tweaks zsh dmenu rofi polybar feh dconf-editor plasma \
         alsa-utils fastfetch pipewire pipewire-alsa pipewire-pulse \
         pipewire-jack wireplumber i3 nerd-fonts cinnamon base-devel)
AUR_ALL=(picom-arian8j2-git visual-studio-code-bin pokemon-colorscripts-git)

# -- Installation menu --
cat <<EOF
Choose dot-files profile to install:
 1) Full Kitty terminal setup
 2) i3 + Kitty + Fastfetch setup
 3) GNOME / Cinnamon desktop import
 4) Vim config
 5) Fastfetch config
 6) VS Code extensions
 7) EVERYTHING!! :D
 q) Quit
EOF
read -rp "Selection: " sel

case $sel in
 1)
    install_pac "${PAC_KITTY[@]}"
    ensure_yay; install_aur "${AUR_KITTY[@]}"
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git \
                     "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    bak_and_checkout .config/kitty .p10k.zsh .p10k1.zsh \
                     .bashrc .zshrc .xinitrc .bash_profile
    ;;
 2)
    install_pac "${PAC_I3[@]}"
    ensure_yay; install_aur "${AUR_I3[@]}"
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git \
                     "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    bak_and_checkout .config/i3 .config/fastfetch .config/kitty .config/rofi \
                     .config/picom .config/polybar .p10k.zsh .p10k1.zsh \
                     .bashrc .zshrc .xinitrc .bash_profile wallpapers .fehbg
    ;;
 3)
    install_pac "${PAC_GNOME[@]}"
    bak_and_checkout gnome wallpapers .local/share/cinnamon/extensions \
                     .config/cinnamon .icons restore-gnome.sh .gtkrc-2.0 \
                     .config/kdedefaults .config/xsettingsd .config/gtkrc \
                     .config/gtkrc-2.0 .config/kdeglobals .config/mimeapps.list \
                     .config/gtk-3.0
    ./restore-gnome.sh || true
    echo -e "\e[32mRebooting in 5 s…\e[0m"; sleep 5; systemctl reboot
    ;;
 4) install_pac "${PAC_VIM[@]}";       bak_and_checkout .vimrc ;;
 5) install_pac "${PAC_FASTFETCH[@]}"; bak_and_checkout .config/fastfetch ;;
 6)
    install_pac "${PAC_VSCODE[@]}"
    ensure_yay; install_aur "${AUR_VSCODE[@]}"
    bak_and_checkout .vscode
    ;;
 7)
    install_pac "${PAC_ALL[@]}"
    ensure_yay; install_aur "${AUR_ALL[@]}"

    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git \
                     "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
                     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    bak_and_checkout_full
    ./restore-gnome.sh || true
    echo -e "\e[32mRebooting in 5 s…\e[0m"; sleep 5; systemctl reboot
    ;;
  q|Q) exit 0 ;;
  *)   die "Unknown selection" ;;
esac

