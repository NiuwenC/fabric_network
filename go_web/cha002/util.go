package main

import (
	"errors"
	"fmt"
	"html/template"
	"net/http"
)

// 用户会话
func session(w http.ResponseWriter, r *http.Request) (sess data.Session, err error) {
	cookie, err := r.Cookie("_cookie") // 从请求中取出cookie
	if err == nil {
		sess = data.Session{Uuid: cookie.Value} // 访问数据库并核实会话的唯一ID是否存在
		if ok, _ := sess.Check(); !ok {
			err = errors.New("Invalid session")
		}

	}
	return
}

// HTML生成, 对于给定的模板文件进行语法分析。 data参数的类型为空接口类型(empty interface type)
// 这意味着该参数可以接受任何类型的值作为输入。 GO语言中每一个接口就是一种类型。一个空接口就是一个空集合，任何类型都可以成为一个空接口
func generateHTML(w http.ResponseWriter, data interface{}, fn ...string) {
	var files []string
	for _, file := range fn {
		files = append(files, fmt.Sprintf("templates/%s.html", file))
	}
	templates := template.Must(template.ParseFiles(files...))
	_ = templates.ExecuteTemplate(w, "layout", data)

}
