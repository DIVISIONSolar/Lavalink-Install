#!/bin/bash
set -e
echo -e "\e[32m
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#              Lavalink Installation Script             #
#       This Script only works on Ubuntu & Debian       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #\e[0m"

# Check if user is sudo
if [[ $EUITD -ne 0 ]]; then
    echo -e "\e{32m* This script must be executed via sudo user. \e[0m" 1>&2
    exit 1
fi

# Proceed?
while true; do
RESET="\e[0m"
GREEN="\e[32m"
read -p "$(echo -e $GREEN"\n* Do you want to proceed? (Y/N)"$RESET)" yn
case $yn in
[yY] ) echo -e "\e[32m* Confirmed. Continuing..\e[0m";
break;;
[nN] ) echo -e "\e[32m* Confirmed. Exiting Installation..\e[0m";
exit;;
* ) echo -e "\3[32m* Invalid Response.\3[0m";;
esac
done
echo -e "\e[32m* Installing dependencies..\3[0m"
sudo apt update > /dev/null 2>&1

# Install Curl
if ! [ -x "$(command -v curl)" ]; then
echo -e "\e[32m* Installing curl.\e[0m"
sudo apt install -y curl > /dev/null 2>&1
fi

# Install NodeJS
if ! [ -x "$(command -v node)" ]; then
echo -e "\e[32m* Installing NodeJS\e[0m"
echo -e "\e[32m* Which NodeJS version would you like to install? [17, 18.]\e[0m"
read NodeJSVer
if [[ -n "NodeJSVer" ]]
then
in=$NodeJSVer
fi
echo -e "\e[32m* Installing NodeJS: $in \e[0m"
curl -sL https://deb.nodesource.com/setup_$in.x | sudo -E bash - > /dev/null 2>&1 && sudo apt install -y nodejs > /dev/null 2>&1
fi

# Install NPM 
if ! [ -x "$(command -v npm)" ]; then
echo -e "\e[32m* Installing NPM.\e[0m"
sudo apt install -y npm > /dev/null 2>&1
fi

# Install Wget
if ! [ -x "$(command -v wget)" ]; then
echo -e "\e[32m* Installing wget.\e[0m"
sudo apt install -y wget > /dev/null 2>&1
fi

# Install Java
if ! [ -x "$(command -v javac)" ]; then
echo -e "\e[32m* Installing java.\e[0m"
sudo apt install -y default-jdk > /dev/null 2>&1
fi

# Install Pm2
if ! [ -x "$(command -v pm2)" ]; then
echo -e "\e[32m* Installing pm2.\e[0m"
sudo npm install pm2 -g > /dev/null 2>&1
fi

# Install Lavalink
echo -e "\e[32m* Starting Lavalink Installation\e[0m"
mkdir ~/Lavalink && cd ~/Lavalink
wget https://cdn.joshsevero.dev/u/VfWVMa.jar > /dev/null 2>&1
echo "What port do you want your Lavalink to run on?"
read Lava_Port
echo "What password do you want to set for your Lavalink?"
read Lava_Pass
echo "server: # REST and WS server
  port: $Lava_Port
  address: 0.0.0.0

lavalink:
  server:
    password: \"$Lava_Pass\"
    playerUpdateInterval: 5 # How frequently to send player updates to clients, in seconds
    statsTaskInterval: 60 # How frequently to send the node stats to clients, in seconds
    koe:
      useEpoll: true
      highPacketPriority: true
      bufferDurationMs: 400
      byteBufAllocator: "default"
    sources:
      # Remote sources
      bandcamp: true
      getyarn: true
      http: true
      odysee: true
      reddit: true
      soundcloud: true
      tiktok: true
      twitch: true
      vimeo: true
      yandex: true
      youtube: true

      # Local source
      local: false
    lavaplayer:
      nonAllocating: false # Whether to use the non-allocating frame buffer.
      frameBufferDuration: 5000 # The frame buffer duration, in milliseconds
      youtubePlaylistLoadLimit: 6 # Number of pages at 100 each
      gc-warnings: true
      youtubeSearchEnabled: true
      odyseeSearchEnabled: true
      soundcloudSearchEnabled: true
      yandexMusicSearchEnabled: true
      #youtubeConfig: (Youtube account credentials, needed to play age restricted tracks)
        #email: ""
        #password: ""
      # You can get your yandex oauth token here https://music-yandex-bot.ru/ used to remove the 30s limit on some tracks
      #yandexOAuthToken:
      #ratelimit:
        #ipBlocks: ["1.0.0.0/8", "..."] # list of ip blocks
        #excludedIps: ["...", "..."] # ips which should be explicit excluded from usage by lavalink
        #strategy: "RotateOnBan" # RotateOnBan | LoadBalance | NanoSwitch | RotatingNanoSwitch
        #searchTriggersFail: true # Whether a search 429 should trigger marking the ip as failing
        #retryLimit: -1 # -1 = use default lavaplayer value | 0 = infinity | >0 = retry will happen this numbers times

metrics:
  prometheus:
    enabled: true
    endpoint: /metrics

sentry:
  dsn: ""
  environment: ""
#  tags:
#    some_key: some_value
#    another_key: another_value

logging:
  file:
    path: ./logs/
  logback:
    rollingpolicy:
      max-file-size: 1GB
      max-history: 30

  level:
    root: INFO
    lavalink: INFO
" > application.yml

echo -e "\e[32m* Lavalink Installation Completed\e[0m"

# Start Lavalink
sudo pm2 start Lavalink.jar --name "Lavalink"
sudo pm2 startup
sudo pm2 save
