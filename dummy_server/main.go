package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"
)

//Dummy Server
var (
	port    = flag.Int("p", 80, "Port of server")
	timeOut = flag.Int("t", 10, "Timeout settings of server")
)
var mux *http.ServeMux = http.NewServeMux()

func init() {
	//command-line
	flag.Parse()
}

func main() {

	//server object
	var srv *http.Server
	mux.HandleFunc("/", handler)
	srv = &http.Server{Addr: fmt.Sprintf(":%d", *port), Handler: mux}

	//shuutdown and timer
	// shut down gracefully, but wait no longer than 10 seconds before halting
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(*timeOut) * time.Second)
	defer func() {
		log.Println("Shutting down server...")
		srv.Shutdown(ctx)
		cancel()
		log.Println("Server gracefully stopped")
	}()

	//start server
	go func() {
		log.Printf("Server start with port %d ...", *port)
		if err := srv.ListenAndServe(); err != nil {
			log.Panicf("listen: %s\n", err)
		}
	}()

	select {
	case <-ctx.Done(): //it will be closed after timeout by context
		fmt.Println(" [timeout] done:", ctx.Err()) // done: context deadline exceeded
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Println("[healthcheck] OK")
	fmt.Fprintf(w, "OK")
}
