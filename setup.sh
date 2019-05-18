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
        "1yvhvPsDhxlcHv_QsmZ_V-HSVKoqe3Gzg"
        "1aLMVGZNBe5KdxGEU4w9b7oZjsrk5bsz_"
        "1RKo2z_87TDy5RLfr0HFjIeZFVPHxcHvA"
        "1JijDFxW76xNLlw-CQ_qHhFWvw6gfCHO0"
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
sudo apt-get install -y openjdk-11-jdk haveged git unzip python python-pip
python -m pip install gdown

git clone https://github.com/tmacoin/tma
cd tma

echo "Downloading bootstrap..."
gdown "https://drive.google.com/uc?id=${bootstrap[$shardID]}"
unzip data*.zip && rm data*zip

chmod +x tma.sh addnewkey.sh
sed -i "s/4000/$port/" tma.sh
sed -i "s/<power>/$shardingPower/" addnewkey.sh
sed -i "s/<shard id>/$shardID/" addnewkey.sh

echo "Adding new key, input password when prompted --"
./addnewkey.sh

echo "Done"
