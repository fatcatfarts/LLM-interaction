package api

import (
    "context"
    // "fmt"
    "log"
    "os"

    "github.com/joho/godotenv"
    "google.golang.org/genai"
)

func Gemini(user_input string) string {
    ctx := context.Background()

    if err := godotenv.Load(); err != nil {
        log.Println("No .env file found or error loading it, using environment variables where available.")
    }

    client, err := genai.NewClient(ctx, &genai.ClientConfig{
        APIKey:  os.Getenv("GEMINI_API_KEY"),
        Backend: genai.BackendGeminiAPI,
    })
    if err != nil {
        log.Printf("Failed to create client: %v", err)
        return "Failed to create Gemini client"
    }

    result, err := client.Models.GenerateContent(
        ctx,
        "gemini-2.0-flash",
        genai.Text(user_input),
        nil,
    )
    if err != nil {
        log.Printf("Failed to generate content: %v", err)
        return "Failed to generate content"
    }

    return result.Text()
}
