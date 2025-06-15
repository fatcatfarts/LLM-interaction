package utils

import (
	"backend/config"
	"time"

	"github.com/dgrijalva/jwt-go"
)

func GenerateToken(userID, email, username string) (string, error) {
	claims := jwt.MapClaims{}
	claims["authorized"] = true
	claims["user_id"] = userID
	claims["email"] = email
	if username != "" {
		claims["username"] = username
	}
	claims["exp"] = time.Now().Add(time.Hour * 72).Unix() 

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(config.JWTSecret))
}

// token validation