#! /bin/bash

usage(){
cat <<EOF
USAGE: ./setup [OPTIONS]
    Marcus' system setup script - will install and configure basic software on unix-based systems.
    List of available packages for installation:
        - linux: Basic linux utilities, oh my zsh, tmux and fzf
        - mac: Homebrew, oh my zsh, tmux and fzf
        - fusuma: Multitouch gestures for Ubuntu
        - docker: Latest stable release for distribution
        - nvidia drivers: Latest stable Nvidia drivers for Ubuntu
        - nvidia cuda: Installs kernel headers and latest cuda packages
        - nvidia-docker: Nvidia container toolkit to build and run GPU accelerated Docker containers
    Tested on Ubuntu 18.04 and macOS Mojave.

    After the installation remember to:
        - Use 'prefix + I' when first starting tmux to install plugins
    If you installed fusuma:
        1. Check fusuma installation path using 'which fusuma'
        2. Press alt + F2, enter 'gnome-session-properties'
        3. Add fusuma using the -d option

OPTIONS:
    -l|--linux              Install linux default package
    -m|--mac                Install mac default package
    -f|--fusuma             Install fusuma package
    -d|--docker             Install or uninstall and reinstall docker
       --nvidia_drivers     Install or uninstall and reinstall nvidia drivers
       --nvidia_cuda        Install or uninstall and reinstall nvidia cuda
       --nvidia_docker      Install nvidia-docker package

       --uninstall_nvidia   Uninstalls all nvidia software. If specified, the script will exit afterwards
       --uninstall_docker   Uninstalls docker. If specified, the script will exit afterwards
EOF
}

echo_red(){
    /bin/echo -e "\033[31m${*}\033[0m"
}

echo_yellow(){
    /bin/echo -e "\033[93m${*}\033[0m"
}

check_if_linux(){
  if [ -z "$OS" ]; then
    read -p "Are you on linux [y/n]? " -n 1 -r
    echo
    if [ "$REPLY" = Y ] || [ "$REPLY" = y ]; then
      OS="linux"
    else
      OS="not_linux"
    fi
  fi
}

install_linux(){
  echo_yellow "Installing linux defaults"
  cd ~

  echo_yellow "Installing packages"
  sudo apt update && sudo apt install -y \
    vim-gnome \
    zsh \
    git \
    curl \
    htop \
    bmon \
    ncdu

  echo_yellow "Installing powerline fonts"
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts

  echo_yellow "Installing Oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  echo_yellow "Installing tmux"
  cp .tmux.conf ~/.tmux.conf
  sudo apt-get update
  sudo apt-get install tmux
  git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo_yellow "Installing fzf"
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install

  echo_yellow "Setting up global gitignore"
  cp .gitignore_global ~/.gitignore_global
  git config --global core.excludesfile ~/.gitignore_global

  echo_yellow "Successfully installed linux defaults"
}

install_mac(){
  echo_yellow "Installing mac defaults"
  cd ~

  echo_yellow "Installing homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  echo_yellow "Installing powerline fonts"
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts

  echo_yellow "Installing Oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  echo_yellow "Installing tmux"
  cp .tmux.conf ~/.tmux.conf
  brew install tmux
  git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack

  echo_yellow "Installing fzf"
  brew install fzf
  "$(brew --prefix)"/opt/fzf/install

  echo_yellow "Setting up global gitignore"
  cp .gitignore-global ~/.gitignore_global
  git config --global core.excludesfile ~/.gitignore_global

  echo_yellow "Successfully installed mac defaults"
}

install_fusuma(){
  check_if_linux && if [ ! "$OS" = "linux" ]; then
    echo_red "fusuma can only be installed on linux" && return 1
  fi

  # Install fusuma for trackpad multitouch gestures
  # https://github.com/iberianpig/fusuma/
  echo_yellow "Installing fusuma"
  sudo gpasswd -a $USER input
  sudo apt-get install libinput-tools
  sudo apt-get install ruby
  sudo gem install fusuma
  sudo apt-get install xdotool
  gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
  sudo gem update fusuma
  # create config file
  mkdir -p ~/.config/fusuma
  cp ~/dotfiles/config.yml ~/.config/fusuma/config.yml
}

uninstall_nvidia_all(){
  check_if_linux && if [ ! "$OS" = "linux" ]; then
    echo_red "uninstalling nvidia software is currently only implemented for linux" && return 1
  fi

  read -p "Do you really want to uninstall all nvidia software [y/n]? " -n 1 -r
  echo
  if [ ! "$REPLY" = Y ] && [ ! "$REPLY" = y ]; then
    echo_red "Exiting." && exit 1
  else
    sudo apt-get -y purge '^nvidia-.*'
    sudo apt-get -y purge '^libnvidia-.*'
    sudo apt-get -y autoremove
  fi
}

uninstall_docker(){
  check_if_linux && if [ ! "$OS" = "linux" ]; then
    echo_red "uninstalling docker is currently only implemented for linux" && return 1
  fi

  read -p "Do you really want to uninstall docker [y/n]? " -n 1 -r
  echo
  if [ ! "$REPLY" = Y ] && [ ! "$REPLY" = y ]; then
    echo_red "Exiting." && exit 1
  else
    sudo apt-get -y purge '^docker-.*'
    sudo apt-get -y purge containerd runc
    sudo apt-get -y autoremove
  fi
}

install_nvidia_drivers(){
  check_if_linux && if [ ! "$OS" = "linux" ]; then
    echo_red "nvidia driver installation is currently only implemented for linux" && return 1
  fi

  echo_yellow "Installing nvidia drivers"
  sudo apt-get purge nvidia-*
  sudo apt-get -y install ubuntu-drivers-common && sudo ubuntu-drivers autoinstall
  echo_yellow "Reboot machine now!"
}

install_nvidia_cuda(){
  check_if_linux && if [ ! "$OS" = "linux" ]; then
    echo_red "cuda installation is currently only implemented for linux" && return 1
  fi

  echo_yellow "Installing nvidia cuda"
  cd ~
  sudo apt-get -y install linux-headers-"$(uname -r)"
  sudo apt-get -y purge nvidia-cuda*
#  wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run
#  sudo sh cuda_10.2.89_440.33.01_linux.run --override
  sudo apt-get -y install nvidia-cuda-toolkit
  sudo apt-get -y install nvidia-container-runtime
  sudo systemctl restart docker
}

install_docker(){
  check_if_linux && if [ ! "$OS" = "linux" ]; then
    echo_red "docker installation is currently only implemented for linux" && return 1
  fi

  echo_yellow "Installing latest stable docker release"
  sudo apt -y update
  sudo apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  sudo apt -y remove docker docker-ce docker-ce-cli docker-engine docker.io containerd runc
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt -y install docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER
  newgrp docker
}

install_nvidia_docker(){
  check_if_linux && if [ ! "$OS" = "linux" ]; then
    echo_red "nvidia-docker installation is currently only implemented for linux" && return 1
  fi

  echo_yellow "Installing nvidia-docker"
  cd ~
  # From https://github.com/NVIDIA/nvidia-docker
  # Add the package repositories
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

  sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
  sudo systemctl restart docker
}

configure_vim(){
  tic -o ~/.terminfo xterm-256color.terminfo
  export TERM=xterm-256color
  cp .vimrc ~/.vimrc

  # Install Vundle
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
}


main(){
  if [ -n "$OS" ]; then
    install_"$OS"
  elif [ -z "$PACKAGES_TO_INSTALL" ]; then
    echo_red "No operating system specified."
    usage
  else
    read -p "No operating system specified. Continue to install specified software packages [y/n]? " -n 1 -r
    echo
    if [ ! "$REPLY" = Y ] && [ ! "$REPLY" = y ]; then
      echo_red "Exiting." && exit 1
    fi
  fi

  for PACKAGE in $PACKAGES_TO_INSTALL; do
    install_"$PACKAGE"
  done
}

OS=""
PACKAGES_TO_INSTALL=""
while [[ $# -gt 0 ]]; do

  case $1 in
    -h|--help)
    usage
    exit 0 ;;

    -l|--linux)
    OS="linux"
    shift 1 ;;

    -m|--mac)
    OS="mac"
    shift 1 ;;

    -f|--fusuma)
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} fusuma"
    shift 1 ;;

    -d|--docker)
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} docker"
    shift 1 ;;

    --nvidia_drivers)
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} nvidia_drivers"
    shift 1 ;;

    --nvidia_cuda)
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} nvidia_cuda"
    shift 1 ;;

    --nvidia_docker)
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} nvidia_docker"
    shift 1 ;;

    --uninstall_nvidia)
    uninstall_nvidia_all
    exit 0 ;;

    --uninstall_docker)
    uninstall_docker
    exit 0 ;;

    *)
    echo_red "Unknown option: $1";
    usage
    exit 1 ;;
  esac

done
main
