#! /bin/bash

install_defaults(){
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
}


main(){
  if [[ $specified_only == false ]]; then
    defaults=true
  elif [[ $defaults == true ]]; then
    install_defaults
  elif [[ $fusuma == true ]]; then
    install_fusuma
  fi
  echo "Remember to use prefix+I when first starting tmux to install plugins"
  zsh
}

specified_only=false
defaults=false
fusuma=false
while [[ $# -gt 0 ]]; do

    case $1 in
        -d|--defaults)
        defaults=true
        shift 1 ;;

        -f|--fusuma)
        fusuma=true
        shift 1 ;;

        -s|--specified_only)
        specified_only=true
        shift 1 ;;

        *)
        echo "Unknown option: $1";
        # show usage
        exit 1 ;;
    esac

done
main