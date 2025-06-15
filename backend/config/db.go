// llm_go_backend/config/config.go
package config

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv" 
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var DB *mongo.Database
var JWTSecret string
var ServerPort string

func ConnectDB() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found or error loading it, using environment variables where available.")
	}

	mongoURI := os.Getenv("MONGODB_URI")
	if mongoURI == "" {
		mongoURI = "mongodb://localhost:27017" 
		log.Println("MONGODB_URI not set, using default:", mongoURI)
	}

	databaseName := os.Getenv("DATABASE_NAME")
	if databaseName == "" {
		databaseName = "llm_chat_app" 
		log.Println("DATABASE_NAME not set, using default:", databaseName)
	}

	JWTSecret = os.Getenv("JWT_SECRET")
	if JWTSecret == "" {
		JWTSecret = "a_very_secure_default_secret_key_!@#$%" 
		log.Println("JWT_SECRET not set, using default (INSECURE FOR PRODUCTION).")
	}

	ServerPort = os.Getenv("PORT")
	if ServerPort == "" {
		ServerPort = "8080" 
	}

	clientOptions := options.Client().ApplyURI(mongoURI)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Fatal("Failed to connect to MongoDB:", err)
	}

	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatal("Failed to ping MongoDB:", err)
	}

	DB = client.Database(databaseName)
	log.Printf("Connected to MongoDB! Database: %s\n", databaseName)
}

func GetCollection(collectionName string) *mongo.Collection {
	if DB == nil {
		log.Fatal("Database not initialized. Call ConnectDB first.")
	}
	return DB.Collection(collectionName)
}