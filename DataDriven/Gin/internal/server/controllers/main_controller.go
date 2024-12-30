package controllers

import (
	"gorm.io/gorm"

	"Gin/internal/database"
)

type Server struct {
	db *gorm.DB
}

func NewServer() *Server {
	return &Server{
		db: database.New().(*gorm.DB),
	}
}
