echo "Create Org1 Identities"

mkdir -p  $PWD/organizations/peerOrganizations/org1.example.com/

export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/tls-cert.pem
fabric-ca-client enroll -d -u https://admin:adminpw@localhost:7054 --caname ca-org1


echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml


echo "register network component: peer"
fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer

echo "register user"
fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client

echo "register admin"
fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin

mkdir -p organizations/peerOrganizations/org1.example.com/peers
# 身份文件存储地址
mkdir -p organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com

export FABRIC_CA_CLIENT_MSPDIR=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp

echo "enroll peer"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 --csr.hosts peer0.org1.example.com
cp ${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/config.yaml

echo "Generate the peer0-tls certificates"
export FABRIC_CA_CLIENT_MSPDIR=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 --enrollment.profile tls --csr.hosts peer0.org1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem

# 将tls文件夹下面的内容先复制到org1的peer下面
cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
# 再复制到org1下面的msp
mkdir -p ${PWD}/organizations/peerOrganizations/org1.example.com/msp/tlscacerts
cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/msp/tlscacerts/ca.crt

mkdir -p ${PWD}/organizations/peerOrganizations/org1.example.com/tlsca
cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem

mkdir -p ${PWD}/organizations/peerOrganizations/org1.example.com/ca
cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem

mkdir -p organizations/peerOrganizations/org1.example.com/users
mkdir -p organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com


echo  "Generate user msp identity"
fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem

cp ${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/config.yaml

mkdir -p organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com

fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem

cp ${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/config.yaml