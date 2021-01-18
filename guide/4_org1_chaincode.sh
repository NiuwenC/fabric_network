peer channel create -c mychannel -f /tmp/hyperledger/org0/orderer/channel.tx -o localhost:7050 --ordererTLSHostnameOverride orderer1-org0 --outputBlock /tmp/hyperledger/org1/peer1/assets/mychannel.block --tls --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem

peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block
CORE_PEER_ADDRESS=localhost:8051 peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block



peer channel update -c mychannel -f /tmp/hyperledger/org0/orderer/org1MSPanchors.tx -o localhost:7050 --ordererTLSHostnameOverride orderer1-org0 --tls --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem




# deploy 
# // if not done before
cd fabric-samples/chaincode/abac/go/
GO111MODULE=on go mod vendor
cd fabric-samples/guide
peer lifecycle chaincode package abac.tar.gz --path /opt/hyperledger/fabric/fabricimages/fabric-samples/chaincode/abac/go/ --label abac_1


# in terminal1 and terminal 2
peer lifecycle chaincode install abac.tar.gz


# Use the package ID obtained from installation.
peer lifecycle chaincode approveformyorg --tls --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem -o localhost:7050 --ordererTLSHostnameOverride orderer1-org0 --channelID mychannel --name mycc --version 1 --sequence 1 --waitForEvent --init-required --package-id abac_1:fd3168223d23448531a02d6f52e33c5e8ea3a63cbf6e53a0093aa3a60bd70a87


# in terminal1  commit
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer1-org0 --tls --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem --peerAddresses localhost:7051 --tlsRootCertFiles /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem --peerAddresses localhost:9051 --tlsRootCertFiles /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem --channelID mychannel --name mycc --init-required --version 1 --sequence 1


# invoke
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer1-org0 --tls true --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem -C mychannel -n mycc --peerAddresses localhost:7051 --tlsRootCertFiles /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem --peerAddresses localhost:9051 --tlsRootCertFiles /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem --isInit -c '{"Args":["init","a","100","b","200"]}'