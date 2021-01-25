package main

import (
	"fmt"
	"net/http"
	"reflect"
	"runtime"
)

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Println("调用hello函数")
	fmt.Fprintf(w, "Hello World")
}

func log(h http.HandlerFunc) http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		name := runtime.FuncForPC(reflect.ValueOf(h).Pointer()).Name()
		fmt.Println("Handler function called - " + name)
		h(writer, request)
	}

}

func main() {
	server := http.Server{
		Addr: "127.0.0.1:8083",
	}
	http.HandleFunc("/hello", log(hello))
	server.ListenAndServe()
}
