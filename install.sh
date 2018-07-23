cd ~

# Install powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

# Install Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install fzf - Linux
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install fzf - Mac
#brew install fzf
#$(brew --prefix)/opt/fzf/install

# Enable fzf as vim plugin
set rtp+=~/.fzf

# TODO - Further vim integration: https://github.com/junegunn/fzf.vim
