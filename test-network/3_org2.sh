echo "Enroll the CA admin"
mkdir -p organizations/peerOrganizations/org2.example.com/

export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.example.com/
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org2/tls-cert.pem

fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml

echo "Register peer0"
fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem

echo "Register user"
fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem

echo "Register the org admin"
fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem

mkdir -p organizations/peerOrganizations/org2.example.com/peers
mkdir -p organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com

echo "Generate the peer0 msp"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp --csr.hosts peer0.org2.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
cp ${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/config.yaml

echo "Generate the peer0-tls certificates"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls --enrollment.profile tls --csr.hosts peer0.org2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem


cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key

mkdir -p ${PWD}/organizations/peerOrganizations/org2.example.com/msp/tlscacerts
cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/msp/tlscacerts/ca.crt

mkdir -p ${PWD}/organizations/peerOrganizations/org2.example.com/tlsca
cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem

mkdir -p ${PWD}/organizations/peerOrganizations/org2.example.com/ca
cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem

mkdir -p organizations/peerOrganizations/org2.example.com/users
mkdir -p organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com

echo "Generate the user msp"

fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem

cp ${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/config.yaml

mkdir -p organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com

echo "Generate the org admin msp"
fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem


cp ${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/config.yaml

