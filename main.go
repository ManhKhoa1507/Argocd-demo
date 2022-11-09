package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type Card struct {
	Color string `json:"Color"`
}

var Cards []Card

func returnSuccess(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Cards)
}

func handleRequest() {
	http.HandleFunc("/", returnSuccess)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func main() {

	Cards = []Card{
		Card{Color: "Red"},
	}

	handleRequest()
}
