package main

import (
	"fmt"
	"github.com/golang/protobuf/proto"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-chaincode-go/shimtest"
	"github.com/hyperledger/fabric-protos-go/msp"
	"testing"
)

// Cert with attribute. "abac.init":"true"
const certWithAttrs = `-----BEGIN CERTIFICATE-----
MIIC2TCCAn+gAwIBAgIUQ0IZAeWJyRqPFpcFshvpVbY1RzMwCgYIKoZIzj0EAwIw
ZjELMAkGA1UEBhMCVVMxFzAVBgNVBAgTDk5vcnRoIENhcm9saW5hMRQwEgYDVQQK
EwtIeXBlcmxlZGdlcjEPMA0GA1UECxMGY2xpZW50MRcwFQYDVQQDEw5yY2Etb3Jn
MS1hZG1pbjAeFw0xODExMTMxNzQ4MDBaFw0xOTExMTMxNzUzMDBaMG8xCzAJBgNV
BAYTAlVTMRcwFQYDVQQIEw5Ob3J0aCBDYXJvbGluYTEUMBIGA1UEChMLSHlwZXJs
ZWRnZXIxHDANBgNVBAsTBmNsaWVudDALBgNVBAsTBG9yZzExEzARBgNVBAMTCmFk
bWluLW9yZzEwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAR196Xv7te+C5gkz7Ui
h8t2gl8QjjSs6iOLFTk18IEH5vLh+DovGT9q3ylvZpExtOap5zFkCva9GnChxP05
4A0eo4IBADCB/TAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAdBgNVHQ4E
FgQUXf9wjawRl/KosmHcVnYB4ay8IqswHwYDVR0jBBgwFoAUwqQ3h+jBjt2e2wC1
f1amDdCHY7QwFwYDVR0RBBAwDoIMZjExN2MxODEyYzM3MIGDBggqAwQFBgcIAQR3
eyJhdHRycyI6eyJhYmFjLmluaXQiOiJ0cnVlIiwiYWRtaW4iOiJ0cnVlIiwiaGYu
QWZmaWxpYXRpb24iOiJvcmcxIiwiaGYuRW5yb2xsbWVudElEIjoiYWRtaW4tb3Jn
MSIsImhmLlR5cGUiOiJjbGllbnQifX0wCgYIKoZIzj0EAwIDSAAwRQIhAN1v/XK0
WmZf5u9X9FG5uGxwcJ9d5K/eFAC7KahSbs65AiB/GzS2u1cYznXzTDWoBm9oflxY
w8Ou1Sh9IjeXj/SDAA==
-----END CERTIFICATE-----
`

func checkInit(t *testing.T, stub *shimtest.MockStub, args [][]byte) {
	res := stub.MockInit("1", args) // res := stub.cc.Init(stub) 里面的这句代码会调用Chaincode的Init方法 并且返回res
	if res.Status != shim.OK {
		fmt.Println("Init failed", string(res.Message))
		t.FailNow()
	}

}

func checkState(t *testing.T, stub *shimtest.MockStub, name string, value string) {
	bytes := stub.State[name]
	if bytes == nil {
		fmt.Println("State", name, "failed to get value")
		t.FailNow()
	}
	if string(bytes) != value {
		fmt.Println("State value", name, "was not", value, "as expected")
		t.FailNow()
	}
}

//测试的时候调用invoke方法,使用stub.MockInvoke
func checkInvoke(t *testing.T, stub *shimtest.MockStub, args [][]byte) {
	res := stub.MockInvoke("1", args)
	if res.Status != shim.OK {
		fmt.Println("Invoke", args, "failed", string(res.Message))
		t.FailNow()
	}
}

func checkQuery(t *testing.T, stub *shimtest.MockStub, name string, value string) {
	res := stub.MockInvoke("1", [][]byte{[]byte("query"), []byte(name)})
	if res.Status != shim.OK {
		fmt.Println("Query", name, "failed", string(res.Message))
		t.FailNow()
	}
	if res.Payload == nil {
		fmt.Println("Query", name, "failed to get value")
		t.FailNow()
	}
	if string(res.Payload) != value {
		fmt.Println("Query value", name, "was not", value, "as expected")
		t.FailNow()
	}
}

// 将mspid以及与之对应的身份证书文件序列化
func setCreator(t *testing.T, stub *shimtest.MockStub, mspId string, idbytes []byte) {
	sid := &msp.SerializedIdentity{Mspid: mspId, IdBytes: idbytes}

	b, err := proto.Marshal(sid)
	fmt.Println("b", b)
	if err != nil {
		t.FailNow()
	}

	stub.Creator = b

}

func TestDemo_Init(t *testing.T) {
	demo := new(DemoChaincode)
	stub := shimtest.NewMockStub("abac", demo)

	setCreator(t, stub, "org1MSP", []byte(certWithAttrs))

	//测试初始化,传入5个参数
	checkInit(t, stub, [][]byte{
		[]byte("init"),
		[]byte("A"),
		[]byte("123"),
		[]byte("B"),
		[]byte("234")})

	checkState(t, stub, "A", "123")
	checkState(t, stub, "B", "234")

}

func TestInvoke(t *testing.T) {
	scc := new(DemoChaincode)
	stub := shimtest.NewMockStub("demo", scc)

	//Creator参数中封装了 mspId 和 msp信息
	setCreator(t, stub, "org1MSP", []byte(certWithAttrs))

	// Init A=567 B=678
	checkInit(t, stub, [][]byte{[]byte("init"), []byte("A"), []byte("567"), []byte("B"), []byte("678")})

	// Invoke A->B for 123
	checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte("A"), []byte("B"), []byte("123")})
	checkQuery(t, stub, "A", "444")
	checkQuery(t, stub, "B", "801")

	// Invoke B->A for 234
	checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte("B"), []byte("A"), []byte("234")})
	checkQuery(t, stub, "A", "678")
	checkQuery(t, stub, "B", "567")
	checkQuery(t, stub, "A", "678")
	checkQuery(t, stub, "B", "567")

}
