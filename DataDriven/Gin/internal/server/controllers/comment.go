package controllers

import (
	"net/http"

	"Gin/internal/models"

	"github.com/gin-gonic/gin"
)

func (s *Server) CreateBulkCommentsHandler(c *gin.Context) {
	var req struct {
		CommentsData []models.Comment `json:"commentsData"`
	}

	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	if len(req.CommentsData) < 1 {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	if err := s.db.Create(&req.CommentsData).Error; err != nil {
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

	if err := s.db.Where("post_id IN (?)", postIDs).Delete(&models.Comment{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}
