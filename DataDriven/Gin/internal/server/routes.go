package server

import (
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"Gin/internal/server/controllers"
)

func (s *Server) RegisterRoutes() http.Handler {
	var allControllers = controllers.NewServer()

	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"},
		AllowHeaders:     []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: true, // Enable cookies/auth
	}))

	r.GET("/posts", allControllers.GetPostsHandler)
	r.GET("/posts/popular", allControllers.PopularPostsHandler)
	r.GET("/posts/search", allControllers.SearchPostsHandler)
	r.GET("/posts/sort-by-date", allControllers.SortPostsByDateHandler)
	r.POST("/posts/create", allControllers.CreatePostHandler)
	r.PUT("/posts/status-update", allControllers.BulkStatusUpdateHandler)
	r.PUT("/posts/edit", allControllers.EditPostHandler)

	r.POST("/authors/get-posts", allControllers.GetPostsByAuthorHandler)

	r.POST("/comments/create-bulk", allControllers.CreateBulkCommentsHandler)
	r.POST("/comments/delete-bulk", allControllers.DeleteBulkCommentsHandler)

	return r
}
