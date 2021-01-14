echo "Enroll Peer1"

# preparation
mkdir -p /tmp/hyperledger/org2/peer1/assets/ca 
cp /tmp/hyperledger/org2/ca/admin/msp/cacerts/0-0-0-0-7055.pem /tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem

mkdir -p /tmp/hyperledger/org2/peer1/assets/tls-ca 
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem

# for identity
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7055
sleep 5

# for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org2
sleep 5

cp /tmp/hyperledger/org2/peer1/tls-msp/keystore/*_sk /tmp/hyperledger/org2/peer1/tls-msp/keystore/key.pem

echo "Enroll Peer2"

# preparation
mkdir -p /tmp/hyperledger/org2/peer2/assets/ca 
cp /tmp/hyperledger/org2/ca/admin/msp/cacerts/0-0-0-0-7055.pem /tmp/hyperledger/org2/peer2/assets/ca/org2-ca-cert.pem

mkdir -p /tmp/hyperledger/org2/peer2/assets/tls-ca 
cp /tmp/hyperledger/tls-ca/admin/msp/cacerts/0-0-0-0-7052.pem /tmp/hyperledger/org2/peer2/assets/tls-ca/tls-ca-cert.pem

# for identity
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer2/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7055
sleep 5

# for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer2/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org2
sleep 5

cp /tmp/hyperledger/org2/peer2/tls-msp/keystore/*_sk /tmp/hyperledger/org2/peer2/tls-msp/keystore/key.pem


echo "Enroll Admin"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://admin-org2:org2AdminPW@0.0.0.0:7055

mkdir -p /tmp/hyperledger/org2/peer1/msp/admincerts
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/peer1/msp/admincerts/org2-admin-cert.pem

mkdir -p /tmp/hyperledger/org2/peer2/msp/admincerts
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/peer2/msp/admincerts/org2-admin-cert.pem

mkdir -p /tmp/hyperledger/org2/admin/msp/admincerts
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/admin/msp/admincerts/org2-admin-cert.pem

mkdir -p /tmp/hyperledger/org2/msp/admincerts
mkdir -p /tmp/hyperledger/org2/msp/cacerts
mkdir -p /tmp/hyperledger/org2/msp/tlscacerts
mkdir -p /tmp/hyperledger/org2/msp/users
cp /tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem /tmp/hyperledger/org2/msp/cacerts/
cp /tmp/hyperledger/org2/peer1/assets/tls-ca/tls-ca-cert.pem /tmp/hyperledger/org2/msp/tlscacerts/
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/msp/admincerts/admin-org2-cert.pem

echo "Org2 done"
