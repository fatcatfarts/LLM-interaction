package controllers

import (
	"backend/models"
	"backend/api"
	"log"
	"net/http"

	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
	// "go.mongodb.org/mongo-driver/mongo"
)

var validateChat *validator.Validate

func InitChatController() {
	validateChat = validator.New()
	log.Println("Chat controller initialized.")
}

func ProcessPrompt(c echo.Context) error {
	var req models.PromptRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body: " + err.Error()})
	}

	if err := validateChat.Struct(req); err != nil { // Use validateChat
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Validation failed: " + err.Error()})
	}

	log.Printf("Received prompt: %s", req.Prompt)
	gemini_response := api.Gemini(req.Prompt)
	hf_response := api.HF(req.Prompt)
	responses := []models.LLMAPIResponse{
		{Source: "gemini-mock", Content: "This is a response from Gemini for: " + req.Prompt + " :is: " + gemini_response},
		{Source: "huggingface-mock", Content: "This is a response from Hugging Face for: "+ req.Prompt + " :is: "+hf_response},
	}

	return c.JSON(http.StatusOK, responses)
}