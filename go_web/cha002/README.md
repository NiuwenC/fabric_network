## ChitChat 论坛
用户注册账号
登录之前发表新帖子或者回复已有的帖子
未注册用户可以查看帖子，但是无法发表帖子或者回复帖子


    多路复用器：
        (1) 将请求重定向到相应的处理器
        (2) 需要为静态文件提供服务
            FileServer创建一个能够为指定目录中的静态文件服务的处理器
                mux.Handle("/static",xxxxx) 就是寻找对应的xxxx静态文件
        
### 2.4.4 使用cookie进行访问控制

    当用户登录成功以后，服务器必须在后续的请求中标示出这事一个已经登录的用户。
    为了做到这一点，服务器会在响应的首部写入一个cookie，而客户端在接收到这个cookie之后则会把
    它存储到浏览器里面。
    
##2.5 使用模板生成HTML响应
index处理器函数里面的大部分代码都是为客户端生成HTML页面的。 需要的模板文件放到Go切片中

    切片指定的模板文件都包含了特定的嵌入命令，这些命令被称为动作，动作在HTML文件里面会被
    {{ 符号和}} 符号包围
    ParseFiles函数进行语法解析，创建相应的模板。 
    


## 2.7 连接数据库
Thread结构应该与创建关系数据库表threads时使用的数据定义语言保持一致。 
