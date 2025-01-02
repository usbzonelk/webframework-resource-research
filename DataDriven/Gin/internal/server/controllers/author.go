package controllers

import (
	"fmt"
	"net/http"

	"Gin/internal/models"

	"github.com/gin-gonic/gin"
)

func (s *Server) GetPostsByAuthorHandler(c *gin.Context) {

	var database = s.db
	var req struct {
		Emails []string `json:"emails"`
	}
	fmt.Println("ddd")

	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var authors []models.Author
	if err := database.Where("email IN (?)", req.Emails).Find(&authors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(authors) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No authors found."})
		return
	}

	var authorIDs []uint
	for _, author := range authors {
		authorIDs = append(authorIDs, author.ID)
	}

	var posts []models.Post
	if err := database.
		Joins("JOIN post_authors pa ON pa.post_id = posts.id").
		Where("pa.author_id IN (?)", authorIDs).Preload("Authors").
		Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(posts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
	} else {
		c.JSON(http.StatusOK, gin.H{"result": posts})
	}
}
