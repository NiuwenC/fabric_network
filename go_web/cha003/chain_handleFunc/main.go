package main

import (
	"fmt"
	"net/http"
)

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello")
}
func world(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "world")
}

func main() {
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/world", world)
	server := http.Server{
		Addr: "127.0.0.1:8082",
	}
	server.ListenAndServe()
}
