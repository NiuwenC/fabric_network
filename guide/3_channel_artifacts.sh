configtxgen -profile OrgsOrdererGenesis -outputBlock /tmp/hyperledger/org0/orderer/genesis.block -channelID syschannel
configtxgen -profile OrgsChannel -outputCreateChannelTx /tmp/hyperledger/org0/orderer/channel.tx -channelID mychannel
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate /tmp/hyperledger/org0/orderer/org1MSPanchors.tx -channelID mychannel -asOrg org1MSP