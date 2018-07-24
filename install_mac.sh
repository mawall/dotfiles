cp .tmux.conf ~/.tmux.conf
cd ~

# Install powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

# Install Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install tmux
brew install tmux
git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack

# Install fzf - Mac
brew install fzf
$(brew --prefix)/opt/fzf/install

# Enable fzf as vim plugin
set rtp+=~/.fzf

# TODO - Further vim integration: https://github.com/junegunn/fzf.vim
