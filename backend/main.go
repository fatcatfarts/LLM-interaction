package main

import (
	"backend/config"
	"backend/controllers" 
	"backend/routes"
	"log"

	"github.com/labstack/echo/v4"
)

func main() {
	config.ConnectDB()

	controllers.InitAuthController()
	controllers.InitChatController() 

	e := echo.New()

	routes.SetupRoutes(e)

	port := config.ServerPort
	log.Printf("Server starting on port %s", port)
	if err := e.Start(":" + port); err != nil {
		log.Fatal("Error starting server: ", err)
	}
}