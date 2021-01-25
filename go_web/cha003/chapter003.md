## Web应用的基本组成部分- 接受请求

    cookie实现客户端数据持久化
    会话实现服务器数据持久化

net/http标准库可以分为客户端和服务器两个部分，库中的结构和函数有些只支持客户端和服务器两者中的一个，有些
则同时支持客户端和服务器:

    Client,Response,Header,Request和Cookie对客户端进行支持
    Server,ServerMux,Handler/HandleFunc,ReponseWriter,Header,Request和Cookie则对服务器支持
    
net/http标准库，可以启动一个HTTP服务器，让这个服务器接收请求并向请求返回响应。 

    传建一个服务器: ListenAndServe 方法并传入网络地址以及负责处理请求的处理器作为参数Handler就可以了
    如果网络地址为空： 则使用默认的80
    如果处理器参数为空: 则使用默认的多路复用器 DefaultServeMux
    
    http.ListenAndServe("", nil)
    
    或者：
    server := http.Server{
    		Addr: "127.0.0.1:8080",
    		Handler: nil,
    	}
    
    server.ListenAndServe()

### 3.2.2 通过HTTPS提供服务

    HTTPS实际上就是将HTTP通讯放到SSL之上进行。 
    通过使用ListenAndServeTLS函数，可以让之前的Web应用也提供HTTPS服务。

    server.ListenAndServeTLS("cert.pem","key.pem") //证书文件和私钥
    
生产环境的证书需要CA服务器获得，测试环境自行生成就可以。

    服务器接收到客户端发送的请求之后，会将证书和响应一并返回给客户端
    客户端确认证书的真实性之后，生成一个随机秘钥
    用证书中的公钥对随机秘钥进行加密，生成对称秘钥
    对称秘钥就是客户端和服务器通讯时使用的实际秘钥

代码在chain_tls 下面, SSL证书实际上就是一个将扩展秘钥用法(extended key usage)设置成了
服务器身份验证操作的X.509证书
    
    template := x509.Certificate{
    		SerialNumber: serialNumber,
    		Subject: subject,
    		NotBefore: time.Now(),
    		NotAfter: time.Now().Add(365 * 24 * time.Hour),
    		KeyUsage: x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature,
    		ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
    		IPAddresses: []net.IP{net.ParseIP("127.0.0.1")},
    	}
    KeyUsage字段和ExtKeyUsage字段表明 这个X.509证书是用于进行服务器身份验证操作的。 
    将这书设置成了只能在IP地址127.0.0.1之上进行。
    
    
    X.509证书可以使用多种格式编码，一种是BER，DER是BER的一个子集
    X.509证书可以使用多种不同的格式保存，一中是PEM，对DER格式的X.509证书实施Base64编码，
    以BEGIN CERTIFICATE 开头， 以END CERTIFICATE结尾
    

生成RSA私钥

    pk,_ := rsa.GenerateKey(rand.Reader,2048)
    RSA私钥的结构里面包含了一种能够公开访问的公钥(public key),该公钥在创建SSL证书的时候会用到
 
创建证书

    derBytes,_ := x509.CreateCertificate(rand.Reader,&template,&template,&pk.PublicKey,pk)
    创建一个经过DER编码格式化的字节切片。

存储证书

    pem.Encode(certOut,&pem.Block{Type: "CERTIFICATE",Bytes: derBytes})
    
存储密钥

    pem.Encode(keyOut,&pem.Block{Type: "RSA PRIVATE KEY",Bytes: x509.MarshalPKCS1PrivateKey(pk)})


### 3.3 处理器和处理器函数
在GO中，一个处理器就是一个拥有ServeHTTP方法的接口，需要接受两个参数: 第一个参数就是一个ResponseWriter接口，而第二个参数则是一个指向Request结构的指针。

    任何接口只要拥有一个ServeHTTP方法，并且该方法带有以下签名，就是一个处理器
    ServeHTTP(http.ResponseWriter, *http.Request)

代码

    type MyHandler struct{}
    
    func (h *MyHandler) ServeHTTP(w http.ResponseWriter,r *http.Request)  {
    	fmt.Fprintf(w,"Hello World!")
    
    }
    
    func main() {
    	handler := MyHandler{}
    	server := http.Server{
    		Addr: "127.0.0.1:8080",
    		Handler: &handler,
    	}
    	server.ListenAndServe()
    }
    浏览localhost:8080   页面展示 Hello World
    浏览localhost:8080/xxx/xxxx  也是 Hello World
    原因: 使用自定义的处理器，替代了默认多路复用器。服务器将不再使用根据URL匹配来将请求路由至不同的处理器
    而是使用同一个处理器处理所有请求，因此无论访问什么地址，都是一样的响应。
    
    

### 3.3.3 处理器函数
处理器函数无非就是与ServeHTTP方法拥有相同签名的函数

    http.HandleFunc("/hello",hello)
    http.HandleFunc("/world",world)

虽然处理器函数能够完成跟处理器一样的工作，并且使用处理器函数的代码比使用处理器的代码更为整洁，但是处理器函数并不能完全代替处理器。
这是因为在某些情况下，代码可能已经包含了某个接口或者某种类型，这时我们需要为它们添加ServeHTTP方法就能够将
它们转换为处理器了，这种转变也有助于构建出更为模块化的Web应用。


### 3.3.4 串联多个处理器函数

    func log(h http.HandlerFunc) http.HandlerFunc {
    	return func(writer http.ResponseWriter, request *http.Request) {
    		name := runtime.FuncForPC(reflect.ValueOf(h).Pointer()).Name()
    		fmt.Println("Handler function called - "+name)
    		h(writer,request)
    	}
    
    }
    将hello发送到log函数之内，log函数返回一个匿名函数
    

### 3.3.5 ServeMux 和 DefaultServeMux



