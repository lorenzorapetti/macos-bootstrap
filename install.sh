#!/bin/sh

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

xcode-select --install
sudo xcodebuild -license

mkdir -p "$HOME/code/github"

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install RVM (Ruby Version Manager)
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable -- --ignore-dotfiles

# Install Volta (Node version manager)
curl https://get.volta.sh | bash

# Install packages for the brew bundle to work
brew install mas openssl

# Check if the user is logged in to the App Store
mas account 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
  read -p "You need to be logged in to the App Store for some scripts to work. Press enter when you are ready." 0</dev/tty
fi

# Install all the things
brew bundle --file="$DOTFILES_PATH/mac/Brewfile"

# Clone my dotfiles in the home directory
git clone https://github.com/lorenzorapetti/dotfiles.git ~

###############################################################################
# App config                                                                  #
###############################################################################

### iTerm2
curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
mkdir -p "$HOME/.iterm"
cp ./iterm2/com.googlecode.iterm2.plist "$HOME/.iterm/com.googlecode.iterm2.plist"
cp ./iterm2/profiles.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/profiles.json"

# Install Node with Volta (current LTS)
volta install node@16

$(brew --prefix)/opt/fzf/install --no-update-rc --bin --key-bindings --completion

# Git global config
./load-git-config.sh

# Update npm
npm i -g npm

# Install global packages
npm i -g npm-check-updates

# Install powerline fonts
POWERLINE_FONTS_PATH=$HOME/powerline-fonts
git clone https://github.com/powerline/fonts.git $POWERLINE_FONTS_PATH --depth=1
$POWERLINE_FONTS_PATH/install.sh
rm -rf $POWERLINE_FONTS_PATH
unset POWERLINE_FONTS_PATH

sudo echo "$(which zsh)" >/etc/shells
chsh -s $(which zsh)

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Dock" \
	"Finder" \
	"Google Chrome Canary" \
	"Google Chrome" \
	"Mail" \
	"Messages" \
	"Opera" \
	"Photos" \
	"Safari" \
	"SizeUp" \
	"Spectacle" \
	"SystemUIServer" \
	"Terminal" \
	"Transmission" \
	"Tweetbot" \
	"Twitter" \
	"iCal"; do
	killall "${app}" &> /dev/null
done

echo -e "\\n\\n\033[1m\033[1mFinished!\\nNow all you have to do is restart for the changes to take effect \033[0m✨"
