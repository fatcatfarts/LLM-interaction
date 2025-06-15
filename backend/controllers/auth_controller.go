package controllers

import (
	"context"
	"backend/config"
	"backend/models"
	"backend/utils"
	"net/http"
	"time"

	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var authUserCollection *mongo.Collection 
var validateAuth *validator.Validate   

func InitAuthController() {
	authUserCollection = config.GetCollection("users")
	validateAuth = validator.New()
}

func Signup(c echo.Context) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var req models.SignupRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body: " + err.Error()})
	}

	if err := validateAuth.Struct(req); err != nil { // Use validateAuth
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Validation failed: " + err.Error()})
	}

	var existingUser models.User
	err := authUserCollection.FindOne(ctx, bson.M{"email": req.Email}).Decode(&existingUser)
	if err == nil {
		return c.JSON(http.StatusConflict, map[string]string{"error": "User with this email already exists"})
	}
	if err != mongo.ErrNoDocuments {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Database error: " + err.Error()})
	}

	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to hash password"})
	}

	newUser := models.User{
		ID:       primitive.NewObjectID(),
		Username: req.Username,
		Email:    req.Email,
		Password: hashedPassword,
	}

	_, err = authUserCollection.InsertOne(ctx, newUser) // Use authUserCollection
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to create user: " + err.Error()})
	}

	token, err := utils.GenerateToken(newUser.ID.Hex(), newUser.Email, newUser.Username)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to generate token"})
	}

	return c.JSON(http.StatusCreated, newUser.ToAuthResponse(token))
}

func Login(c echo.Context) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var req models.LoginRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body: " + err.Error()})
	}

	if err := validateAuth.Struct(req); err != nil { // Use validateAuth
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Validation failed: " + err.Error()})
	}

	var user models.User
	err := authUserCollection.FindOne(ctx, bson.M{"email": req.Email}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Invalid email or password"})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Database error: " + err.Error()})
	}

	if !utils.CheckPasswordHash(req.Password, user.Password) {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Invalid email or password"})
	}

	token, err := utils.GenerateToken(user.ID.Hex(), user.Email, user.Username)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to generate token"})
	}

	return c.JSON(http.StatusOK, user.ToAuthResponse(token))
}