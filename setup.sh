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

install_linux(){
  echo "Installing linux defaults"
  cd ~

  # Basics
  sudo apt install vim
  sudo apt install zsh
  sudo apt install git
  sudo apt install curl
  sudo apt install htop
  sudo apt install bmon
  sudo apt install ncdu

  # Install powerline fonts
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts

  # Install Oh my zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  # Install tmux
  cp .tmux.conf ~/.tmux.conf
  sudo apt-get update
  sudo apt-get install tmux
  git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepak
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  # Install fzf - Linux
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install

  # Enable fzf as vim plugin
  set rtp+=~/.fzf
  # TODO - Further vim integration: https://github.com/junegunn/fzf.vim
}

install_mac(){
  echo "Installing mac defaults"
  cd ~

  # Install homebrew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  # Install powerline fonts
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts

  # Install Oh my zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  # Install tmux
  cp .tmux.conf ~/.tmux.conf
  brew install tmux
  git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack

  # Install fzf - Mac
  brew install fzf
  $(brew --prefix)/opt/fzf/install

  # Enable fzf as vim plugin
  set rtp+=~/.fzf
}

install_fusuma(){
  # Install fusuma for multitouch gestures
  # https://github.com/iberianpig/fusuma/
  echo "Installing fusuma"
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


main(){
  if [[ $specified_only == false ]]; then
    linux=true
  elif [[ $linux == true ]]; then
    install_linux
  elif [[ $mac == true ]]; then
    install_mac
  elif [[ $fusuma == true ]]; then
    install_fusuma
  else
    echo "No package specified"
  fi
  zsh
}

specified_only=false
linux=false
mac=false
fusuma=false
while [[ $# -gt 0 ]]; do

    case $1 in
        -h|--help)
        usage
        shift 1 ;;

        -l|--linux)
        linux=true
        shift 1 ;;

        -m|--mac)
        mac=true
        shift 1 ;;

        -f|--fusuma)
        fusuma=true
        shift 1 ;;

        -s|--specified_only)
        specified_only=true
        shift 1 ;;

        *)
        echo "Unknown option: $1";
        usage
        exit 1 ;;
    esac

done
main