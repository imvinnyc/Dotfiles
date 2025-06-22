#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

###############################################################################
# 1. Core packages via pacman --------------------------------------------------
###############################################################################
pac_pkgs=(
  vim git nemo kitty
  gnome gnome-extra gnome-shell-extensions gnome-tweaks
  zsh dmenu rofi polybar feh dconf-editor plasma
  alsa-utils fastfetch
  pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
  i3 nerd-fonts
)

echo -e "\n==> Installing pacman packages…"
sudo pacman -Sy --needed "${pac_pkgs[@]}"

###############################################################################
# 2. YAY (AUR helper) ----------------------------------------------------------
###############################################################################
if ! command -v yay &>/dev/null; then
  echo -e "\n==> YAY not found – cloning and building…"
  git clone https://aur.archlinux.org/yay.git ~/yay
  pushd ~/yay
  makepkg -si --noconfirm
  popd
  rm -rf ~/yay
else
  echo "==> YAY already installed – skipping build."
fi

###############################################################################
# 3. AUR packages via yay ------------------------------------------------------
###############################################################################
aur_pkgs=(
  picom-arian8j2-git
  visual-studio-code-bin
  pokemon-colorscripts-git
)

echo -e "\n==> Installing AUR packages…"
yay -S --needed --noconfirm "${aur_pkgs[@]}"

###############################################################################
# 4. dotfiles repo local-only git settings -------------------------------------
###############################################################################
echo -e "\n==> Setting dotfiles repo to hide untracked files…"
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" \
    config --local status.showUntrackedFiles no

###############################################################################
# 5. Oh-My-Zsh, Powerlevel10k, syntax-highlighting & autosuggestions ----------
###############################################################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "\n==> Installing Oh-My-Zsh & plugins…"
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

  ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$ZSH_CUSTOM/themes/powerlevel10k"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "==> Oh-My-Zsh already present – skipping."
fi

###############################################################################
# 6. Restore GNOME / Cinnamon / DConf settings --------------------------------
###############################################################################
echo -e "\n==> Importing desktop settings…"
chmod +x "$HOME/restore-gnome.sh"
"$HOME/restore-gnome.sh"

echo -e "\nInstallation complete!  Log out and back in (or reboot) to enjoy."

