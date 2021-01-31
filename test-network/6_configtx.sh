echo "Generating Orderer Genesis block"


configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block  -configPath $PWD/configtx

