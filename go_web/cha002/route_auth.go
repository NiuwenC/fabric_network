package main

import "net/http"

// 认证
func authenticate(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	user, _ := data.UserByEmail(r.PostFormValue("email"))           // 通过给定的邮件地址获取与之对应的User结构
	if user.Password == data.Encrypt(r.PostFormValue("password")) { // 加密给定的字符串
		session := user.CreateSession()
		cookie := http.Cookie{
			Name:     "_cookie", //名字随意设置 没有设置过期时间，所以是一个会话cookie，将在浏览器关闭之后自动移除
			Value:    session.Uuid,
			HttpOnly: true, //只能通过http或者https访问，无法通过JavaScript等非HTTP API进行访问
		}
		http.SetCookie(w, &cookie) // 添加到响应的头部中
		http.Redirect(w, r, "/", 302)
	} else {
		http.Redirect(w, r, "/login", 302)
	}

}
