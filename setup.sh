#!/bin/bash

echo ""
echo "|''||''| '||    ||'     |    "
echo "   ||     |||  |||     |||   "
echo "   ||     |'|..'||    |  ||  "
echo "   ||     | '|' ||   .''''|. "
echo "  .||.   .|. | .||. .|.  .||."
echo ""

shardingPower=3
lastShard=7

bootstrap=(
        "1VaX56Hopo5o8ydWHepRpkhpA5FDYueIY"
        "1DlsCjVTBGle1oAXkYuJJRSV-9Gvs5zu4"
        "1QhF77sov35DrRjejGc1l0A20Eoafuo4g"
        "11yVJWwAbaO_Xk_pGMQ_bDFD_08lV-eN4"
        "1lHmF9WNgvzB1j2iq5l7NnuiFSml5dgoS"
        "1IJb-VYF_O79o29wqhyFPf-n-S5JXnboe"
        "14MicxjgnX0AWe8J3q0fzmA0XPyWlBmdu"
        "1rFpDbAJqpPpGbLjvnWVpF_NlTNk0LNfQ"
)

read -p "Shard ID (0-$lastShard, leave empty for random): " shardID
read -p "Port (leave empty for 4000): " port

if [ -z "$shardID" ]; then
        shardID=$(shuf -n 1 -i 0-$lastShard)
fi

if [ -z "$port" ]; then
        port="4000"
fi

sudo apt-get update
sudo apt-get install -y openjdk-11-jdk haveged git unzip wget
wget https://raw.githubusercontent.com/circulosmeos/gdown.pl/15557edc15ad507de3cb849975897e6eec799dc0/gdown.pl
chmod +x gdown.pl

git clone https://github.com/tmacoin/tma
cd tma

echo "Downloading bootstrap..."
../gdown.pl "https://drive.google.com/uc?id=${bootstrap[$shardID]}" data$shardID.zip
unzip data$shardID.zip && rm data$shardID.zip gdown*

chmod +x tma.sh addnewkey.sh exportkeys.sh
sed -i "s/4000/$port/" tma.sh
sed -i "s/<power>/$shardingPower/" addnewkey.sh
sed -i "s/<shard id>/$shardID/" addnewkey.sh

echo "Adding new key..."
./addnewkey.sh

echo "Exporting keys..."
./exportkeys.sh

echo "Done"
