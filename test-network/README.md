## test-network
构造代码提交的环境

网络结构示意图
    
    ca-org1:
        port:7054
        ca-path:$PWD/organizations/fabric-ca/org1
        component-path:$PWD/organizations/peerOrganizations/org1.example.com/
        hostname:org1.example.com
        
        users:
            peer0
            user1
            org1admin
        
            
        
   
   
    ca-org2:
        port:8054
        path:$PWD/organizations/fabric-ca/org2
        
    
    ca-orderer:
        port:9054
        path:$PWD/organizations/fabric-ca/ordererOrg
   



运行过程:
