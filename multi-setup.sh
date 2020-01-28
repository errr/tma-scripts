#!/bin/bash

c0="\033[0m"
c1="\033[00;33m"
c2="\033[01;36m"

echo -e "${c1}"
echo "|''||''| '||    ||'     |    "
echo "   ||     |||  |||     |||   "
echo "   ||     |'|..'||    |  ||  "
echo "   ||     | '|' ||   .''''|. "
echo "  .||.   .|. | .||. .|.  .||."
echo ""
echo "   Multi-node setup script   "
echo ""
echo "NOTE: Setting up 8 nodes + proof file will require at least ~77 GB of free disk space!"
echo -e "${c0}"


minSpaceKB=77000000
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

echo -e "${c2}"

freeSpaceKB=$(df -Pk . | sed 1d | grep -v used | awk '{ print $4 "\t" }')
if [ "$freeSpaceKB" -lt $minSpaceKB ]; then
	read -p "Not enough disk space, are you sure you want to continue? (y/n): " continue
	if [ "$continue" != "y" ]; then
		exit
	fi
	echo ""
fi

read -p "Base directory (default: tma): " baseDir
read -p "Install libraries + gdown (y/n) (default: n): " installLibs
read -p "Ports (x = shard ID) (default: 400x): " ports
read -p "Download bootstraps? (y/n) (default: y): " useBootstrap
read -p "Proof file (absolute path) (default: $(pwd)/proof): " pfPath

echo -e "${c0}"

if [ -z "$baseDir" ]; then
	baseDir="tma"
fi

if [ -z "$installLibs" ]; then
        exportAll="n"
fi

if [ -z "$ports" ]; then
        ports="400x"
fi

if [ -z "$useBootstrap" ]; then
        useBootstrap="y"
fi

if [ -z "$exportAll" ]; then
        exportAll="n"
fi

if [ -z "$pfPath" ]; then
	pfPath="$(pwd)/proof"
fi

setup () {
	echo -e "${c1}"
        echo "Installing libraries..."
	echo -n -e "${c0}"
        sudo apt-get update
        sudo apt-get install -y openjdk-11-jdk haveged git unzip wget

	echo -e "${c1}"
        echo "Downloading gdown..."
	echo -n -e "${c0}"
        wget https://raw.githubusercontent.com/circulosmeos/gdown.pl/15557edc15ad507de3cb849975897e6eec799dc0/gdown.pl
        chmod +x gdown.pl
}

setupNode () {
        local ID=$1
        local port=$2

	if [ -d "tma$ID" ]; then
		echo -n -e "${c1}"
		echo "Directory tma$ID already exists, skipping..."
		echo -n -e "${c0}"
		return
	fi

	echo -e "${c1}"
        echo "Setting up TMA node on shard $1"
	echo -e "${c0}"

        git clone https://github.com/tmacoin/tma tma$ID
        cd tma$ID

        if [ "$useBootstrap" = "y" ]; then
		echo -e "${c1}"
                echo "(#$ID) Downloading bootstrap..."
		echo -n -e "${c0}"

                ../gdown.pl "https://drive.google.com/uc?id=${bootstrap[$ID]}" data$ID.zip
                unzip data$ID.zip && rm data$ID.zip gdown*
        fi

	echo -e "${c1}"
        echo "Setting up scripts..."
	echo -n -e "${c0}"

        chmod +x tma.sh addnewkey.sh exportkeys.sh
        sed -i "s/4000/$port/" tma.sh
	sed -i "s/config\/proof\"//" tma.sh
	echo "${pfPath}/proof\"" >> tma.sh
        sed -i "s/<power>/$shardingPower/" addnewkey.sh
        sed -i "s/<shard id>/$ID/" addnewkey.sh

	echo -e "${c1}"
        echo "Adding new key..."
	echo -n -e "${c0}"
        ./addnewkey.sh

	echo -e "${c1}"
        echo "Exporting keys..."
	echo -n -e "${c0}"
        ./exportkeys.sh

	echo -e "${c1}"
	echo "Done!"
	echo -e "${c0}"

	cd ..
}

run() {
        if [ "$installLibs" = "y" ]; then
		echo -e "${c1}"
                echo "Running setup..."
		echo -e "${c0}"
                setup
	fi


	if [ ! -d "$baseDir" ]; then
		mkdir $baseDir
	fi
	cd $baseDir

	echo -e "${c1}"
        echo "Setting up nodes on shards 0-$lastShard"
	echo -e "${c0}"
        for i in {0..7}; do
                setupNode $i $(echo "$ports" | sed "s/x/$i/")
        done

	echo -e "${c1}"
	echo "All done!"
	echo -e "${c0}"
}

run
