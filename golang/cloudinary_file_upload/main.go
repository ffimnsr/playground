package main

import (
	"bytes"
	"crypto/sha1"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"strconv"
	"time"
)

type ErrorResp struct {
	Message string `json:"message"`
}

type Upload struct {
	PublicId         string    `json:"public_id"`
	Version          int       `json:"version"`
	Signature        string    `json:"signature"`
	Width            int       `json:"width"`
	Height           int       `json:"height"`
	Format           string    `json:"format"`
	ResourceType     string    `json:"resource_type"`
	CreatedAt        string    `json:"created_at"`
	Tags             []string  `json:"tags,omitempty"`
	Bytes            int       `json:"bytes"`
	Type             string    `json:"type"`
	Etag             string    `json:"etag"`
	Url              string    `json:"url"`
	SecureURL        string    `json:"secure_url"`
	OriginalFilename string    `json:"original_filename"`
	Error            ErrorResp `json:"error,omitempty"`
}

func uploadFile(data io.Reader) error {
	uploadURI := "https://api.cloudinary.com/v1_1/fizzafruit/image/upload"
	timestamp := strconv.FormatInt(time.Now().Unix(), 10)

	params := fmt.Sprintf("timestamp=%s", timestamp)
	hash := sha1.New()
	hash.Write([]byte(params + "peIfAN1L1x4USnJGk2P8Ld7PIFY"))
	signature := hex.EncodeToString(hash.Sum(nil))

	buf := new(bytes.Buffer)
	w := multipart.NewWriter(buf)

	i, err := w.CreateFormField("api_key")
	if err != nil {
		return err
	}
	i.Write([]byte("585154911658289"))

	i, err = w.CreateFormField("timestamp")
	if err != nil {
		return err
	}
	i.Write([]byte(timestamp))

	i, err = w.CreateFormField("signature")
	if err != nil {
		return err
	}
	i.Write([]byte(signature))

	i, err = w.CreateFormFile("file", "gopher.png")
	if err != nil {
		return err
	}
	if data != nil {
		tmp, err := ioutil.ReadAll(data)
		if err != nil {
			return err
		}
		i.Write(tmp)
	}
	w.Close()

	req, err := http.NewRequest("POST", uploadURI, buf)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", w.FormDataContentType())
	rsp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer rsp.Body.Close()

	if rsp.StatusCode == http.StatusOK {
		log.Print("OK")
		data := json.NewDecoder(rsp.Body)
		info := new(Upload)
		if err := data.Decode(info); err != nil {
			return err
		}
		log.Print(info.SecureURL)
	} else {
		log.Printf("Not OK: %s", rsp.Status)
		bb, err := ioutil.ReadAll(rsp.Body)
		if err != nil {
			return err
		}
		log.Print(string(bb))
	}

	return nil
}

func main() {
	file, err := os.Open("gopher.png")
	if err != nil {
		log.Fatal(err)
	}

	if err := uploadFile(file); err != nil {
		log.Fatal(err)
	}
}
