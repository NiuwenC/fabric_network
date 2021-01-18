peer channel create -c mychannel -f /tmp/hyperledger/org1/peer1/assets/channel.tx -o orderer1-org0:7050 --outputBlock /tmp/hyperledger/org1/peer1/assets/mychannel.block --tls --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem


CORE_PEER_ADDRESS=peer2-org1:8052 peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block

