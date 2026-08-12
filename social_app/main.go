package main

import (
	"log"
	"net/http"
)

func main() {
	// Point Go to the compiled Flutter web files
	fs := http.FileServer(http.Dir("./build/web"))
	http.Handle("/", fs)

	log.Println("Flutter app running on http://localhost:8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}
