package controllers

import (
	"net/http"
	"strconv"

	"Gin/internal/models"

	"github.com/gin-gonic/gin"
)

func (s *Server) GetPostsHandler(c *gin.Context) {
	page, err := strconv.Atoi(c.DefaultQuery("page", "1"))
	if err != nil || page < 1 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid page number."})
		return
	}

	size, err := strconv.Atoi(c.DefaultQuery("size", "10"))
	if err != nil || size < 1 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid size number."})
		return
	}

	var posts []models.Post
	offset := size * (page - 1)
	if err := s.db.Preload("Authors").Preload("Categories").Offset(offset).Limit(size).Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(posts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
	} else {
		c.JSON(http.StatusOK, gin.H{"result": posts})
	}
}

func (s *Server) CreatePostHandler(c *gin.Context) {
	var postData models.Post
	if err := c.BindJSON(&postData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := s.db.Create(&postData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

func (s *Server) BulkStatusUpdateHandler(c *gin.Context) {
	var req struct {
		PostIDs   []uint `json:"postIDs"`
		NewStatus string `json:"newStatus"`
	}

	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if len(req.PostIDs) < 1 || req.NewStatus == "" {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	if err := s.db.Model(&models.Post{}).Where("id IN (?)", req.PostIDs).Update("post_status", req.NewStatus).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

func (s *Server) EditPostHandler(c *gin.Context) {
	var postData models.Post
	if err := c.BindJSON(&postData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if postData.ID == 0 {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request."})
		return
	}

	if err := s.db.Model(&models.Post{}).Where("id = ?", postData.ID).Updates(postData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

func (s *Server) SearchPostsHandler(c *gin.Context) {
	search := c.Query("search")
	if search == "" {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request data."})
		return
	}

	var posts []models.Post
	if err := s.db.Where("title LIKE ? OR content LIKE ?", "%"+search+"%", "%"+search+"%").Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(posts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
	} else {
		c.JSON(http.StatusOK, gin.H{"result": posts})
	}
}

func (s *Server) SortPostsByDateHandler(c *gin.Context) {
	var posts []models.Post
	if err := s.db.Order("last_updated desc").Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(posts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
	} else {
		c.JSON(http.StatusOK, gin.H{"result": posts})
	}
}

func (s *Server) PopularPostsHandler(c *gin.Context) {
	var maxPosts []struct {
		PostID uint
		Count  int
	}

	if err := s.db.Table("comments").Select("post_id, count(*) as count").Group("post_id").Order("count desc").Limit(10).Scan(&maxPosts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(maxPosts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
		return
	}

	var postIDs []uint
	for _, maxPost := range maxPosts {
		postIDs = append(postIDs, maxPost.PostID)
	}

	var posts []models.Post
	if err := s.db.Where("id IN (?)", postIDs).Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if len(posts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
	} else {
		c.JSON(http.StatusOK, gin.H{"result": posts})
	}
}
