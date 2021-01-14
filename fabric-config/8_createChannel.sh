
docker-compose up -d peer1-org1 peer2-org1 peer1-org2 peer2-org2
sleep 5

configtxgen -profile OrgsOrdererGenesis -outputBlock /tmp/hyperledger/org0/orderer/genesis.block -channelID syschannel
sleep 5
configtxgen -profile OrgsChannel -outputCreateChannelTx /tmp/hyperledger/org0/orderer/channel.tx -channelID mychannel
sleep 5

docker-compose up -d orderer1-org0 cli-org1 cli-org2