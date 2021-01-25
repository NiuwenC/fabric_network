package main

import (
	"html/template"
	"net/http"
)

//创建多路复用器，
func main() {
	mux := http.NewServeMux() // 构建多路复用器
	files := http.FileServer(http.Dir("/public"))
	mux.Handle("/static/", http.StripPrefix("/static/", files))
	mux.HandleFunc("/", index) //将根URL的请求重新定向到处理器，定向到名为index的处理器函数
	mux.HandleFunc("/err", err)

	mux.HandleFunc("/login", login)
	mux.HandleFunc("logout", logout)
	mux.HandleFunc("signup", signup)
	mux.HandleFunc("signup_account", signupAccount)

	mux.HandleFunc("/thread/new", newThread)
	mux.HandleFunc("/thread/create", createThread)
	mux.HandleFunc("/thread/post", postThread)
	mux.HandleFunc("/thread/read", readThread)

	server := &http.Server{
		Addr:    "0.0.0.0:8080",
		Handler: mux,
	}
	server.ListenAndServe()
}
