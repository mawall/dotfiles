#! /bin/bash

usage(){
cat <<EOF
USAGE: ./install_linux [OPTIONS]
    Marcus' system setup script - will install and configure basic software on unix-based systems.
    List of available packages for installation:
        - linux: Basic linux utilities, oh my zsh, tmux and fzf
        - mac: Homebrew, oh my zsh, tmux and fzf
        - fusuma: Multitouch gestures for Ubuntu
    If the 'specified_only' option is not given, only the linux package will be installed.
    Tested on Ubuntu 18.04 and macOS Mojave.

    After installation remember to:
        1. Check fusuma installation paht using 'which fusuma'
        2. Press alt + F2, enter 'gnome-session-properties'
        3. Add fusuma using the -d option
        4. Use 'prefix + I' when first starting tmux to install plugins

OPTIONS:
    -s|--specified_only     Install specified packages only
    -l|--linux              Install linux default package
    -m|--mac                Install mac default package
    -f|--fusuma             Install fusuma package
EOF
}

echo_red(){
    /bin/echo -e "\033[31m${*}\033[0m"
}

echo_yellow(){
    /bin/echo -e "\033[93m${*}\033[0m"
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
  # Install fusuma for multitouch gestures
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

configure_vim(){
  tic -o ~/.terminfo xterm-256color.terminfo
  export TERM=xterm-256color
  cp .vimrc ~/.vimrc

  # Install Vundle
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
}


main(){
  if [ "$specified_only" = "true" ]; then
    if [ "$linux" = "true" ]; then
      install_linux
    elif [ "$mac" = "true" ]; then
      install_mac
    elif [ "$fusuma" = "true" ]; then
      install_fusuma
    else
      echo_red "No package specified"
    fi
  else
    read -p "No operating system specified. Linux assumed. Continue? [y/n]" -n 1 -r
    echo
    if [ "$REPLY" = Y ] || [ "$REPLY" = y ]; then
      install_linux
    else
      echo_red "Exiting." && exit 1
    fi
  fi
}

specified_only="false"
linux="false"
mac="false"
fusuma="false"
while [[ $# -gt 0 ]]; do

    case $1 in
        -h|--help)
        usage
        shift 1 ;;

        -l|--linux)
        linux="true"
        shift 1 ;;

        -m|--mac)
        mac="true"
        shift 1 ;;

        -f|--fusuma)
        fusuma="true"
        shift 1 ;;

        -s|--specified_only)
        specified_only="true"
        shift 1 ;;

        *)
        echo_red "Unknown option: $1";
        usage
        exit 1 ;;
    esac

done
main
