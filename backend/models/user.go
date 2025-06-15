package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type User struct {
	ID       primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Username string             `json:"username,omitempty" bson:"username,omitempty"` // Optional
	Email    string             `json:"email" bson:"email"`
	Password string             `json:"-" bson:"password"` // Don't send password in JSON response
}

type SignupRequest struct {
	Username string `json:"username,omitempty"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type AuthResponse struct {
	ID       string `json:"id"`
	Username string `json:"username,omitempty"`
	Email    string `json:"email"`
	Token    string `json:"token"`
}

func (u *User) ToAuthResponse(token string) AuthResponse {
	return AuthResponse{
		ID:       u.ID.Hex(),
		Username: u.Username,
		Email:    u.Email,
		Token:    token,
	}
}