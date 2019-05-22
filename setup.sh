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
        "1uk5AWMT7VCyK7bXFA2L5QwSyL-HDOm61"
        "1JIlM-DE28D5p39Mnu5BMjDMJq68QnEuh"
        "17ZssieU_s41ef6OhJEpviK3TRcimFWQT"
        "12-uvhbJS7qOQTE5lQn3lGWWq91pghPE_"
        "1Uvyr_fAGDBjizDKB8ErTqT5Ou1s6JuY6"
        "19L4vqJv7ZSi4isAQbrVTtwwZRdoSKOuK"
        "10AEUiAgvX2aH6hsOig16v714BOjNrlhk"
        "1orLOlmNI-_eThbnITaouUrvYTz-1FdkZ"
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
