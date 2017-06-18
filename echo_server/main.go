package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

//Echo Server
var (
	port = flag.Int("p", 80, "Port of server")
)

func init() {
	//command-line
	flag.Parse()
}

func main() {
	//router
	http.HandleFunc("/", handler)

	//
	log.Printf("Server start with port %d ...", *port)
	http.ListenAndServe(fmt.Sprintf(":%d", *port), nil)
}

func handler(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()

	//fmt.Println("path", r.URL.Path)      //path /
	//fmt.Println("scheme", r.URL.Scheme)  //scheme

	fmt.Printf("[echo] message=%s: code=%s\n", r.Form["msg"], r.Form["code"])

	fmt.Fprintf(w, "OK")
}
