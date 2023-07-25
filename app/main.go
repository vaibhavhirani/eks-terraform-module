package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func main() {
	// listens for request at any prefix matching "/"
	http.HandleFunc("/", getTimeStampAndIP)
	//starts the server at 8080 port
	http.ListenAndServe(":8080", nil)
}

// http handler to get timestamp and ip of the visitor
func getTimeStampAndIP(w http.ResponseWriter, req *http.Request) {
	ip := req.RemoteAddr
	timestamp := time.Now().String()
	responseMap := map[string]string{
		"timestamp": timestamp,
		"ip":        ip,
	}
	responseBytes, _ := json.Marshal(responseMap)
	fmt.Fprintf(w, "%v", string(responseBytes))
}
