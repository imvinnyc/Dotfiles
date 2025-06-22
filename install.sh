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
  cinnamon
)

echo -e "\n==> Installing pacman packages…"
sudo pacman -Sy --needed "${pac_pkgs[@]}"

###############################################################################
# 2. YAY (AUR helper) ----------------------------------------------------------
###############################################################################
if ! command -v yay &>/dev/null; then
  echo -e "\n==> YAY not found – preparing build…"

  [ -d "$HOME/yay" ] && { echo "==> Removing stale ~/yay"; rm -rf "$HOME/yay"; }

  git clone https://aur.archlinux.org/yay.git "$HOME/yay"
  pushd "$HOME/yay"
  makepkg -si --noconfirm
  popd
  rm -rf "$HOME/yay"
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
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "\n==> Installing Oh-My-Zsh…"
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
  echo "==> Oh-My-Zsh already present."
fi

[[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] \
  || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
               "$ZSH_CUSTOM/themes/powerlevel10k"

[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] \
  || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
               "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] \
  || git clone https://github.com/zsh-users/zsh-autosuggestions \
               "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

###############################################################################
# 6. Restore GNOME / Cinnamon / DConf settings --------------------------------
###############################################################################
echo -e "\n==> Importing desktop settings…"
chmod +x "$HOME/restore-gnome.sh"
"$HOME/restore-gnome.sh"

###############################################################################
# 7. Final reboot --------------------------------------------------------------
###############################################################################
echo -e "\n==> Installation complete!"
echo "System will reboot in 5 seconds so the new desktop settings load."
sleep 5
sudo systemctl reboot
