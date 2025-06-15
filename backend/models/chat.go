package models

type PromptRequest struct {
	Prompt string `json:"prompt" validate:"required"`
}

type LLMAPIResponse struct {
	Source  string `json:"source"` 
	Content string `json:"content"`
}

// type SavedLLMResponse struct {
// 	ID            primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
// 	UserID        primitive.ObjectID `json:"userId" bson:"userId"`
// 	Prompt        string             `json:"prompt" bson:"prompt"`
// 	Source        string             `json:"source" bson:"source"`
// 	Content       string             `json:"content" bson:"content"`
// 	SavedAt       time.Time          `json:"savedAt" bson:"savedAt"`
// }