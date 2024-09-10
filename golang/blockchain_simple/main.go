package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"
)

type (
	// Transaction stores information about the sender
	// and receiver including the amount transacted.
	Transaction struct {
		Sender    string `json:"sender"`
		Recipient string `json:"recipient"`
		Amount    int64  `json:"amount"`
	}

	// Block stores
	Block struct {
		Index        int64          `json:"index"`
		Transactions []*Transaction `json:"transactions"`
		Proof        int64          `json:"proof"`
		Timestamp    int64          `json:"timestamp"`
		PreviousHash string         `json:"previousHash"`
	}

	// Blockchain stores the chain of related blocks.
	Blockchain struct {
		Chain               []*Block
		CurrentTransactions []*Transaction
	}
)

// NewBlock creates a new block in the blockchain.
func (c *Blockchain) NewBlock(proof int64, previousHash string) {
	block := &Block{
		Index:        int64(len(c.Chain) + 1),
		Transactions: c.CurrentTransactions,
		Proof:        proof,
		PreviousHash: previousHash,
		CreatedAt:    time.Now().UTC().UnixNano(),
	}

	// Reset the current list of transactions.
	c.CurrentTransactions = nil

	// Throw the newly created block in the chain.
	c.Chain = append(c.Chain, block)
}

// NewTransaction creates new transaction to go into the next mined block.
func (c *Blockchain) NewTransaction(sender, recipient string, amount int64) {
	c.CurrentTransactions = append(c.CurrentTransactions, &Transaction{
		Sender:    sender,
		Recipient: recipient,
		Amount:    amount,
	})
}

// LastBlock returns the last element of the chain.
func (c *Blockchain) LastBlock() *Block {
	return c.Chain[len(c.Chain)-1]
}

// Hash creates a SHA-256 hash of a block.
func (c *Blockchain) Hash(block *Block) (string, error) {
	data, err := json.Marshal(block)
	encodedData := string(data)

	hash := sha256.New()
	_, err = hash.Write([]byte(encodedData))
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(hash.Sum(nil)), nil
}

func main() {
	port := flag.String("port", "8080", "listening port number")
	flag.Parse()

	fmt.Printf("Running blockchain server on port %s\n", *port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", *port), chainHandler()))
}

func chainHandler() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("/mine", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusOK)

		fmt.Fprintf(w, "hello, world")
	})

	mux.HandleFunc("/transaction/new", func(w http.ResponseWriter, r *http.Request) {
		t := new(Transaction)
		d := json.NewDecoder(r.Body)
		err := d.Decode(&t)
		if err != nil {
			panic(err)
		}
		defer func() {
			err = r.Body.Close()
			if err != nil {
				panic(err)
			}
		}()

		fmt.Fprintf(w, "hello, world")
	})

	mux.HandleFunc("/chain", func(w http.ResponseWriter, r *http.Request) {
		// response := make(map[string]interface{})
		// response["r"]

		fmt.Fprintf(w, "response")
	})

	return mux
}
