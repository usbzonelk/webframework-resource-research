package controllers

import (
	"net/http"
	"strconv"
	"time"

	"Gin/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type PostInputDTO struct {
	PostData struct {
		Title       string `json:"title"`
		Slug        string `json:"slug"`
		Content     string `json:"content"`
		PostStatus  string `json:"postStatus"`
		LastUpdated string `json:"lastUpdated"`
		Authors     []uint `json:"authors"`
		Categories  []uint `json:"categories"`
	} `json:"postData"`
}
type PostUpdateDTO struct {
	PostData struct {
		ID          uint   `json:"id"`
		Title       string `json:"title"`
		Slug        string `json:"slug"`
		Content     string `json:"content"`
		PostStatus  string `json:"postStatus"`
		LastUpdated string `json:"lastUpdated"`
		Authors     []uint `json:"authors"`
		Categories  []uint `json:"categories"`
	} `json:"postData"`
}

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
	var postData PostInputDTO
	if err := c.ShouldBindBodyWith(&postData, binding.JSON); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	var authors []models.Author
	if err := s.db.Where("id IN ?", postData.PostData.Authors).Find(&authors).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "failed to retrieve authors: " + err.Error()})
		return
	}
	var categories []models.Category
	if err := s.db.Where("id IN ?", postData.PostData.Categories).Find(&categories).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "failed to retrieve categories: " + err.Error()})
		return
	}
	lastUpdated, err := time.Parse("2006-01-02", postData.PostData.LastUpdated)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid date format for LastUpdated"})
		return
	}

	postNew := models.Post{
		Slug:        postData.PostData.Slug,
		Title:       postData.PostData.Title,
		Content:     postData.PostData.Content,
		LastUpdated: lastUpdated,
		PostStatus:  postData.PostData.PostStatus,
		Categories:  categories,
		Authors:     authors,
	}
	if err := s.db.Create(&postNew).Error; err != nil {
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
	var postData PostUpdateDTO
	if err := c.ShouldBindBodyWith(&postData, binding.JSON); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if postData.PostData.ID == 0 {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "Invalid request."})
		return
	}
	var lastUpdatedTime *time.Time
	if postData.PostData.LastUpdated != "" {
		parsedTime, err := time.Parse("2006-01-02 15:04:05", postData.PostData.LastUpdated)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format for LastUpdated. Expected format: YYYY-MM-DD HH:MM:SS"})
			return
		}
		lastUpdatedTime = &parsedTime
	}

	updateData := map[string]interface{}{
		"title":       postData.PostData.Title,
		"slug":        postData.PostData.Slug,
		"content":     postData.PostData.Content,
		"post_status": postData.PostData.PostStatus,
	}

	if lastUpdatedTime != nil {
		updateData["last_updated"] = *lastUpdatedTime
	}

	if err := s.db.Model(&models.Post{}).Where("id = ?", postData.PostData.ID).Updates(updateData).Error; err != nil {
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
	if err := s.db.Where("title LIKE ? OR content LIKE ?", "%"+search+"%", "%"+search+"%").Preload("Authors").Find(&posts).Error; err != nil {
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
	if err := s.db.Order("last_updated desc").Preload("Authors").Find(&posts).Error; err != nil {
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

	if err := s.db.Table("comments").Select("post_id, count(*) as count").Preload("Authors").Group("post_id").Order("count desc").Limit(10).Scan(&maxPosts).Error; err != nil {
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
	for _, postID := range postIDs {
		var post models.Post
		if err := s.db.Where("id = ?", postID).First(&post).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		posts = append(posts, post)
	}

	if len(posts) < 1 {
		c.JSON(http.StatusOK, gin.H{"result": "No posts found."})
	} else {
		c.JSON(http.StatusOK, gin.H{"result": posts})
	}
}
