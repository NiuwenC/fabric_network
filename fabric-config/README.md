## configtx.yaml 配置
通过构建指定通道的初始配置的通道创建交易来创建通道。通道配置存储在账本中，并管理所有添加到通道的后续块。通道配置指定哪些组织是通道成员，可以在通道上添加新块的排序节点，以及管理通道更新的策略。可以通过通道配置更新来更新存储在通道创世块中的初始通道配置。如果足够多的组织批准通道更新，则在将新通道配置块提交到通道后，将对其进行管理。

虽然可以手动构建通道创建交易文件，但使用configtx.yaml文件和configtxgen工具可以更轻松地创建通道。configtx.yaml文件包含以易于理解和编辑的格式构建通道配置所需的信息。configtxgen工具读取configtx.yaml文件中的信息，并将其写入Fabric可以读取的protobuf格式。

configtx.yaml 文件指定新通道的通道配置。建立通道所需的信息在configtx.yaml 文件中。 

    
    Organizations: 通道成员的组织。每个组织都有用于建立通道MSP的秘钥信息地址
    Ordering service: 哪些排序节点将构成网络的排序服务，以及它们将用于同意一致交易顺序的共识方法 
    Channel policies: 定义策略，这些策略将控制组织与通道的交互方式以及哪些组织需要批准通道更新。
    Channel profiles: 每个通道配置文件都引用 configtx.yaml文件其他部分的信息来构建通道配置。 使用预设文件来创建Orderer系统通道的创始块以及将被peer组织使用的通道。
        peer组织使用的通道称为应用通道
    





Application: &ApplicationDefaults 
这种写法意味着 如下关于Application的配置可以由 ApplicationDefaults来引用


### Organization 
此部分包含组织详细信息，该组织可以是订购者或对等组织。下面是来自第一网络样本的一个例子。

正如您在下面的结构中看到的，第一个标签是“组织:”，在它下面，您可以根据需求定义任意数量的组织。

如您所见，每个组织都有名称、ID和MSPDir。这里，MSPDir是存储该组织的加密材料的位置。

它还具有锚点对等体的主机和端口详细信息。


    Organizations:

    - &OrdererOrg
        Name: OrdererOrg
        ID: OrdererMSP
        MSPDir: crypto-config/ordererOrganizations/example.com/msp

    - &Org1
        Name: Org1MSP
        ID: Org1MSP
        MSPDir: crypto-config/peerOrganizations/org1.example.com/msp

        AnchorPeers:
            - Host: peer0.org1.example.com
              Port: 7051

    - &Org2
        Name: Org2MSP
        ID: Org2MSP
        MSPDir: crypto-config/peerOrganizations/org2.example.com/msp

        AnchorPeers:
            - Host: peer0.org2.example.com
              Port: 7051


### Orderer Section in configtx.yaml file
此部分包含关于orderer的详细信息。这也有助于创建创世方块。

OrderType:它的值可以是“solo”或“kafka”。在开发过程中使用solo，在生产环境中使用kafka。

地址:这包含了orderer的主机和端口细节。

BatchTimeout:批量创建前的等待时间。订货者的工作是创建一批事务，因此这是该事务的等待时间。

最大消息数:允许批量发送的最大消息数

绝对最大字节数:在批处理中允许序列化消息的绝对最大字节数。

首选最大字节数:批量序列化消息所允许的首选最大字节数。大于首选最大字节数的消息将产生大于首选最大字节数的批处理。


    Orderer: &OrdererDefaults

    OrdererType: solo
    Addresses:
        - orderer.example.com:7050
    BatchTimeout: 2s
    BatchSize:
        MaxMessageCount: 10
        AbsoluteMaxBytes: 99 MB
        PreferredMaxBytes: 512 KB

    Kafka:
        Brokers:
            - 127.0.0.1:9092
    Organizations:

### Application section in configtx.yaml file
应用程序正在起源区块中被引用。如下图所示，组织是定义为参与者的组织列表。

    
    Application: &ApplicationDefaults

            # Organizations is the list of orgs which are defined as participants on
            # the application side of the network
            Organizations:

### Capabilities section in configtx.yaml file
功能是Hyperledger Fabric 1.1中的新特性。这样做的目的是避免在节点上运行不同版本的Fabric代码且每个人都有相同的事务视图时对网络造成任何影响。

不同类型的功能如下所述。

通道:这些功能同时应用于对等体和订购者，并且位于根通道组中。
订购者:仅适用于订购者，并位于订购者组。
Application:仅应用于对等体，位于应用程序组中。

    Capabilities:
    Global: &ChannelCapabilities
        V1_1: true
    Orderer: &OrdererCapabilities
        V1_1: true
    Application: &ApplicationCapabilities
        V1_1: true



### Profile section in configtx.yaml file
configtx.yaml 中最后一个重要的部分文件是配置文件部分。它主要由两部分组成，一是生成模块细节，二是通道细节。让我们用例子来理解它。

TwoOrgsOrdererGenesis指的是genesis块，在它下面有需要的细节。它包含块、订购者详细信息(组织和功能)、联盟详细信息(对等组织)的功能。

twoorgchannel指的是帮助创建所需通道的通道。

    Profiles:

    TwoOrgsOrdererGenesis:
        Capabilities:
            <<: *ChannelCapabilities
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *OrdererOrg
            Capabilities:
                <<: *OrdererCapabilities
        Consortiums:
            SampleConsortium:
                Organizations:
                    - *Org1
                    - *Org2
    TwoOrgsChannel:
        Consortium: SampleConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - *Org1
                - *Org2
            Capabilities:
                <<: *ApplicationCapabilities




## 2 来自于官网的描述信息
###  2.1 Organizations
通道配置中包含的最重要信息是作为通道成员的组织。每个组织都由MSP ID和通道MSP标识。通道MSP存储在通道配置中，并包含用于标识组织的节点，应用程序和管理员的证书。configtx.yaml文件的Organizations部分用于为通道的每个成员创建通道MSP和随附的MSP ID。

测试网络使用的configtx.yaml文件包含三个组织。可以添加到应用程序通道的两个组织是Peer组织Org1和Org2。OrdererOrg是一个Orderer组织，是排序服务的管理员。因为最佳做法是使用不同的证书颁发机构来部署Peer节点和Orderer节点，所以即使组织实际上是由同一公司运营，也通常将其称为Peer组织或Orderer组织。


    - &Org1
    # DefaultOrg defines the organization which is used in the sampleconfig
    # of the fabric.git development environment
    Name: Org1MSP

    # ID to load the MSP definition as
    ID: Org1MSP

    MSPDir: ../organizations/peerOrganizations/org1.example.com/msp

    # Policies defines the set of policies at this level of the config tree
    # For organization policies, their canonical path is usually
    #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
    Policies:
        Readers:
            Type: Signature
            Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
        Writers:
            Type: Signature
            Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
        Admins:
            Type: Signature
            Rule: "OR('Org1MSP.admin')"
        Endorsement:
            Type: Signature
            Rule: "OR('Org1MSP.peer')"

    # leave this flag set to true.
    AnchorPeers:
        # AnchorPeers defines the location of peers which can be used
        # for cross org gossip communication.  Note, this value is only
        # encoded in the genesis block in the Application section context
        - Host: peer0.org1.example.com
          Port: 7051

MSPDir 是组织创建的MSP文件夹路径。 configtxgen工具将使用此MSP文件夹来创建通道MSP。该MSP文件夹包含以下信息，这些信息将被传输到通道MSP并存储在通道配置中:

    * 一个CA根证书，为组织建立信任根。 CA根证书用于验证应用程序，节点或者管理员是否属于通道成员。
    * 来自TLS CA的根证书，该证书颁发了Peer节点或者Orderer节点的TLS证书。 TLS证书用于通过Gossip协议标识组织。
    * 如果启用了Node OU，该MSP文件夹需要包含一个config.yaml文件，该文件根据x509证书的OU标识管理员，节点和客户端
    * 如果未启用Node OU,该MSP需要包含一个admincerts文件夹，其中包含组织管理员身份的签名证书。 (org-admin)  cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem /tmp/hyperledger/org0/msp/admincerts/admin-org0-cert.pem

用于创建通道MSP得MSP文件夹进包含公共证书，这样可以在本地生成MSP文件夹，然后将MSP发送到创建通道的组织。

    Policies部分用于定义一组引用通道成员的签名策略。
    AnchorPeers: 列出了组织的锚节点。 为了利用诸如私有数据和服务发现之类的功能，锚节点是必需的。建议组织至少选择一个锚节点。 虽然组织可以使用configtxgen工具首次选择通道上的锚节点，但建议每个组织都使用configtxlator工具来设置锚节点更新通道配置。 因此，该字段不是必须的。

### 2.2 Capabilitles
Fabric通道可以由运行不同版本的Hyperledger Fabric的Orderer节点和Peer节点加入。 通道功能通过仅启用某些功能，允许运行不同Fabric二进制文件的组织参与同一个通道。 例如，只要通道功能级别设为V1_4_X或者更低，则运行Fabric v1.4的组织和运行Fabric v2.x的组织可以加入同一通道。所有通道成员都无法使用Fabric v2.0中引入的功能。

在configtx.yaml 文件中，将看到三个功能组：
* Application功能可控制Peer节点使用的功能，例如Fabric链码生命周期，并设置可以由加入通道的Peer运行的Fabric二进制文件的最低版本。
* Orderer功能可以控制Orderer节点使用的功能，例如Raft共识，并设置可以通过Orderer属于通道共识者集合的节点运行的Fabric二进制文件的最低版本。
* Channel功能可以设置Peer节点和Orderer节点运行的Fabric的最低版本。 由于Fabric的测试网络的所有Peer和Orderer节点都运行版本v2.x,因此每个功能组均设置为V2_0。因此运行Fabric版本低于v2.0的节点不能加入测试网络。

如下为配置

    Capabilities:
        Channel: &ChannelCapabilities
            V2_0: true

        Orderer: &OrdererCapabilities
            V2_0: true

        Application: &ApplicationCapabilities
            V2_0: true


### 2.3 Application
Application部分定义了Peer组织如何与应用程序通道交互的策略。 

测试网络使用Hyperledger Fabric提供的默认Application策略。 如果您使用默认策略，则所有Peer组织都能够读取数据并将数据写入账本。 默认策略还要求大多数通道成员给通道配置更新签名，并且大多数通道成员需要批准链码定义，然后才能将链码部署到通道。 

### 2.4 Orderer
每个通道配置的通道共识集合中都包含orderer节点。 共识集合是排序节点的组合，能够创建新的区块，将区块分发到加入通道的peer。 每个orderer节点的端口信息是共识集合的成员。

    OrdererType: etcdraft

    EtcdRaft:
        Consenters:
        - Host: orderer.example.com
          Port: 7050
          ClientTLSCert: ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
          ServerTLSCert: ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt

共识者列表中的每个Orderer节点均由其端点地址以及其客户端地址和服务器TLS证书标识。 如果要部署多节点排序服务，则需要提供主机名，端口和每个节点使用的TLS证书的路径地址。 还需要将每个排序节点的端口地址添加到Address列表中。

Policies部分创建用于管理通道共识者集合的策略。 测试网络使用Fabric提供的默认策略，该策略要求大多数Orderer管理员批准添加或删除Orderer节点，组织或对分块切割参数进行更新。


### 2.5 Channel
通道部分定义了用于管理最高层级通道配置的策略。 

    对于应用程序通道，这些策略控制哈希算法，用于创建新块的数据哈希结构以及通道功能级别。
    在系统通道中，这些策略还控制Peer组织的联盟的创建或删除。

### 2.6 Profiles
configtxgen 工具读取Profiles部分中的配置文件以构建通道配置。每个配置文件都使用YAML语法从文件的其他部分收集数据。 

测试网络使用的configtx.yaml包含两个通道配置文件  TwoOrdererGenesis和 TwoOrgsChannel:

    TwoOrgsOrdererGenesis:
    <<: *ChannelDefaults
    Orderer:
        <<: *OrdererDefaults
        Organizations:
            - *OrdererOrg
        Capabilities:
            <<: *OrdererCapabilities
    Consortiums:
        SampleConsortium:
            Organizations:
                - *Org1
                - *Org2

创建系统通道和创始块。Organizations部分的OrdererOrg称为排序服务的唯一管理员。 

TwoOrgsChannel

    TwoOrgsChannel:
    Consortium: SampleConsortium
    <<: *ChannelDefaults
    Application:
        <<: *ApplicationDefaults
        Organizations:
            - *Org1
            - *Org2
        Capabilities:
            <<: *ApplicationCapabilities

排序服务将系统通道用作创建应用程序通道的模板。在系统通道中定义的排序服务的节点成为新通道的默认共识者集合，而排序服务的管理员则成为该通道的Orderer管理员。







## 3 通道策略
通道是组织之间进行通讯的一种私有方法。因此，通道配置的大多数更改都需要该通道的其他成员同意。 如果一个组织可以在未经其他组织批准的情况下加入该通道并读取账上的数据，则通道将没有作用。 通道组织结构的任何更改都必须由一组能够满足通道策略的组织批准。

通道还控制用户如何与通道交互的过程，例如在将链码部署到通道之前需要一些组织批准或者需要由通道管理员完成一些操作。

通道策略非常重要，因此需要在单独的主题中讨论。 与通道配置的其他部分不同，控制通道的策略由 configtx.yaml文件的不同部分组合起来才能确定。 尽管可以在几乎没有任何约束的情况下为任何场景配置通道策略，但本主题将重点介绍如何使用Fabric提供的默认策略。 

### 3.1 签名策略
默认情况，每个成员都定义了一组引用其组织的签名策略。 当有提案提交给peer或交易提交给Orderer节点时，节点将读取附加到交易上的签名，并根据通道配置中定义的签名策略对它们进行评估。 每个签名策略都有一个规则，该规则指定了一组签名可以满足该策略的组织和身份。 

    -&org1
        ....

        Policies:
            Readers:
                Type: Signature
                Rule: "OR('Org1MSP.admin','Org1MSP.peer','Org1MSP.client')"
            
            Writers:
                Type: Signature
                Rule: "OR('Org1MSP.admin','Org1MSP.client')"
            Admins:
                Type: Signature
                Rule: "OR('Org1MSP.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('Org1MSP.peer')"

上面的所有策略都可以通过Org1的签名来满足。 但是每个策略列出了组织内部能够满足该策略的一组不同的角色。

Admins策略只能由具有管理员橘色的身份提交的交易满足，而只具有peer的身份才能满足Endorsement策略。 附加到单笔交易上的一组签名可以满足多个签名策略。 例如，如果交易附加的背书由Org1和Org2共同提供，则此签名集将满足Org1和Org2的Endorsement策略。

#### ImplicitMeta策略
如果通道使用默认策略，则每个组织的签名策略将由通道配置中更高层级的ImplicitMeta策略评估。ImplicitMeta策略不是直接评估提交给通道的签名，而是使用规则在通道配置中指定可以满足该组策略的一组其他策略。如果交易可以满足该策略引用的下层签名策略集合，则它可以满足ImplicitMeta策略。


在Application部分中看到定义的ImplicitMeta策略

    Policies:
        Reader: 
            Type:ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        
    
Application部分中的ImplicitMeta策略控制Peer组织如何与通道进行交互。每个策略引用与每个通道成员关联的签名策略:

![](https://hyperledger-fabric.readthedocs.io/zh_CN/release-2.2/_images/application-policies.png)

每个策略均在通道配置中引用其路径。 由于Application部分中的策略位于通道组内部的应用程序组中，因此它们被称为 Channel/Application策略。 由于Fabric文档中的大多数位置都是通过策略路径来引用策略的，因此后续将通过策略路径来引用策略。

每个ImplicitMeta中的Rule均引用可以满足该策略的签名策略的名称。 例如， Channel/Application/Admins ImplicitMeta策略引用每个组织的Admins签名策略。 每个Rule包含满足ImplicitMeta策略所需的签名策略的数量，例如 Channel/Application/Admins 策略要求满足大多数Admins签名策略。

![](https://hyperledger-fabric.readthedocs.io/zh_CN/release-2.2/_images/application-admins.png)

图2：提交给该通道的通道更新请求包含来自Org1，Org2和Org3的签名，满足每个组织的签名策略。因此，该请求满足Channel/Application/Admins策略。Org3检查呈浅绿色，因为不需要签名个数达到大多数。


再举一个例子，大多数组织的Endorsement策略都可以满足 Channel/Application/Endorsement策略，这需要每个组织的Peer签名。 Fabric链码生命周期将此策略用作默认链码背书策略。 除非您提交链码定义时使用不同的背书策略，否则调用链码的交易必须得到大多数通道成员的认可。

![](https://hyperledger-fabric.readthedocs.io/zh_CN/release-2.2/_images/application-endorsement.png)

图3：来自客户端应用程序的交易调用了Org1和Org2的Peer上的链码。链码调用成功，并且该应用程序收到了两个组织的Peer背书。由于此交易满足Channel/Application/Endorsement策略，因此该交易符合默认的背书策略，可以添加到通道的账本中。


同时使用ImplicitMeta策略和签名策略的优点是，您可以在通道级别设置治理规则，同时运行每个通道成员选择对其组织进行签名所需的身份。 例如，通道可以指定要求大多数组织管理员给通道配置更新签名。 但是，每个组织可以使用其签名策略来选择组织中的哪些身份是管理员，甚至要求组织中的多个身份签名才能批准通道更新。







### 主题： 策略概念
