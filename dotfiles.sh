#!/bin/sh

sudo_path="$(command -v sudo 2>/dev/null)"
function sudocmd {
  if [ -n "$sudo_path" ]; then
    $sudo_path "$@"
  else
    su -c "$*"
  fi
}

if [ -e /run/ostree-booted ]; then
  echo "ostree-booted OS, skipping package installation"
else
  GENERIC_PACKAGES="bash git sudo tmux vim zsh"

  echo "Installing packages: $GENERIC_PACKAGES"
  echo "Ctrl+C to cancel..."
  sleep 2

  if command -v apt >/dev/null; then
    sudocmd apt -y update
    sudocmd apt -y install $GENERIC_PACKAGES
  elif command -v pacman >/dev/null; then
    sudocmd pacman --noconfirm -Syu
    sudocmd pacman --noconfirm -S $GENERIC_PACKAGES
  elif command -v dnf >/dev/null; then
    sudocmd dnf -y update
    sudocmd dnf -y install $GENERIC_PACKAGES
  elif command -v apk >/dev/null; then
    sudocmd apk update
    sudocmd apk add $GENERIC_PACKAGES
  fi
fi

rm -rf ~/.dotfiles && \
git clone https://github.com/reyemxela/dotfiles.git ~/.dotfiles && \
cd ~/.dotfiles && \
./setup && \
cd - >/dev/null

echo "Log out/in or \`exec bash\`"