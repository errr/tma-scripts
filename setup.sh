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
        "1cS6yaBMLQM1F1lNAftGLqwiajA259mGf"
        "1TxzSWEqW6vcO-5zs8BTeEutFmR-UaanO"
        "1iUG5Be2--WKVoJDfIQS1l0471p3csEfK"
        "1VP9JHC_p09lKo9vheW1hImCUvAB3I75y"
        "1eJf_0h06QAH74s_Lrx8L3Wyq19BchEzZ"
        "1ySK1d4yo7T0lGTaQ2IXuDDSY4eZHMBdV"
        "15ka-mCefKC_DG5wSAdhQY3LhYXRLpsYJ"
        "1UOohb0UTqEWCo0Cl2bSr-L1GNjivoxtr"
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
