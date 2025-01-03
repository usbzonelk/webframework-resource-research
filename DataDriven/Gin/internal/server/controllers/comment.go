package controllers

import (
	"net/http"
	"time"

	"Gin/internal/models"

	"github.com/gin-gonic/gin"
)

type commentInput struct {
	AuthorName  string `json:"authorName"`  // Author name, max length 50, required
	Content     string `json:"content"`     // Content of the comment, required
	LastUpdated string `json:"lastUpdated"` // Last updated time, defaults to current timestamp
	Post        uint   `json:"post"`        // Related Post model
}

func (s *Server) CreateBulkCommentsHandler(c *gin.Context) {
	var req struct {
		CommentsData []commentInput `json:"commentsData"`
	}

	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	if len(req.CommentsData) < 1 {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	var comments []models.Comment

	for _, commentData := range req.CommentsData {
		lastUpdated, err := time.Parse("2006-01-02", commentData.LastUpdated)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid date format for LastUpdated"})
			return
		}

		comment := models.Comment{
			AuthorName:  commentData.AuthorName,
			Content:     commentData.Content,
			LastUpdated: lastUpdated,
			PostID:      commentData.Post,
		}

		comments = append(comments, comment)
	}

	if err := s.db.Create(&comments).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

func (s *Server) DeleteBulkCommentsHandler(c *gin.Context) {
	var req struct {
		PostIDs []uint `json:"postIDs"`
	}

	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	if len(req.PostIDs) < 1 {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	var posts []models.Post
	if err := s.db.Where("id IN (?)", req.PostIDs).Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(posts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
		return
	}

	var postIDs []uint
	for _, post := range posts {
		postIDs = append(postIDs, post.ID)
	}

	if err := s.db.Unscoped().Where("post_id IN (?)", postIDs).Delete(&models.Comment{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}
