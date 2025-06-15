package api

import (
    "bytes"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

type hfResponse struct {
	GeneratedText string `json:"generated_text"`
}

func HF(promptu string) string {
	// promptu := "Hello, how are you?"
    prompt := "(please dont repeat this line of mine in your response): You are a friendly assistant, respond to : "+ promptu
	if err := godotenv.Load(); err != nil {
        log.Println("No .env file found or error loading it, using environment variables where available.")
    }

    requestBody := map[string]string{"inputs": prompt}
    jsonData, _ := json.Marshal(requestBody)

    req, _ := http.NewRequest("POST", "https://api-inference.huggingface.co/models/mistralai/Mixtral-8x7B-Instruct-v0.1", bytes.NewBuffer(jsonData))

    req.Header.Set("Authorization", "Bearer "+ os.Getenv("HF_KEY"))
    req.Header.Set("Content-Type", "application/json")

    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        fmt.Println("HTTP request failed:", err)
        return "error1"
    }
    defer resp.Body.Close()

    body, _ := io.ReadAll(resp.Body)

		var hfResp []hfResponse

	if err := json.Unmarshal(body, &hfResp); err != nil {
		fmt.Println("Failed to unmarshal JSON response:", err)
		return "error2"
	}

	if len(hfResp) == 0 {
		fmt.Println("Received an empty response from the API.")
		return "error3"
	}

	fullGeneratedText := hfResp[0].GeneratedText

	responseWithoutPrompt := strings.TrimPrefix(fullGeneratedText, prompt)

	finalAnswer := strings.TrimSpace(responseWithoutPrompt)

	return finalAnswer
}
