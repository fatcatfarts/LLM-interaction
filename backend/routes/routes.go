// llm_go_backend/routes/routes.go
package routes

import (
	"backend/controllers" // Adjust import path
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func SetupRoutes(e *echo.Echo) {
	// Middleware
	e.Use(middleware.Logger())  // Log HTTP requests
	e.Use(middleware.Recover()) // Recover from panics

	// Basic CORS for development (adjust for production)
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"}, // Or specify your Flutter app's origin
		AllowMethods: []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodOptions},
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization},
	}))

	e.GET("/", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]string{
			"message": "LLM Interaction API (Go) is running!",
		})
	})

	api := e.Group("/api") 

	auth := api.Group("/auth")
	auth.POST("/signup", controllers.Signup)
	auth.POST("/login", controllers.Login)

	chat := api.Group("/chat")
	//jwt for protection(Baad m)
	chat.POST("/prompt", controllers.ProcessPrompt)
//history(get,post)
}