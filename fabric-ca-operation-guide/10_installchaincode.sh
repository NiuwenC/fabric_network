# in terminal 1
go mod verdor # download dependency

peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/abac/go


CORE_PEER_ADDRESS=peer2-org1:8052 peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/abac/go


# in terminal 2
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/abac/go

CORE_PEER_ADDRESS=peer2-org2:9052 peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/abac/go
