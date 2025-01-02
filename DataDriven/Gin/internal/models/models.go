package models

import (
	"time"

	"gorm.io/gorm"
)

type Author struct {
	gorm.Model

	Name  string `json:"name" gorm:"type:varchar(150);not null"`
	Email string `json:"email" gorm:"type:varchar(255);uniqueIndex;not null"`
	ID    uint   `json:"id" gorm:"uniqueIndex;not null"`
}

type Category struct {
	gorm.Model

	Name string `json:"name" gorm:"type:varchar(150);not null"`
	ID   uint   `json:"id" gorm:"uniqueIndex;not null"`
}

type Post struct {
	gorm.Model // Includes ID, CreatedAt, UpdatedAt, DeletedAt fields

	Slug        string     `json:"slug" gorm:"type:varchar(255);uniqueIndex;not null"`                                                 // Slug, unique index, required
	Title       string     `json:"title" gorm:"type:varchar(200);not null;"`                                                           // Title, max length 200, required
	ID          uint       `json:"id" gorm:"uniqueIndex;not null"`                                                                     // Unique ID, required
	Content     string     `json:"content" gorm:"type:text;not null;default:''"`                                                       // Content, required with a default empty string
	Authors     []Author   `json:"authors" gorm:"many2many:post_authors;constraint:OnUpdate:CASCADE;"`                                 // Many-to-many relationship with Author
	Categories  []Category `json:"categories" gorm:"many2many:post_categories;constraint:OnUpdate:CASCADE;"`                           // Many-to-many relationship with Category
	LastUpdated time.Time  `json:"lastUpdated" gorm:"default:CURRENT_TIMESTAMP"`                                                       // Last updated timestamp
	PostStatus  string     `json:"postStatus" gorm:"type:varchar(50);default:'Published';check:post_status IN ('Published', 'Draft')"` // Enum-like for post status
}

type Comment struct {
	gorm.Model // Includes ID, CreatedAt, UpdatedAt, DeletedAt fields

	AuthorName  string    `json:"authorName" gorm:"type:varchar(50);not null;default:''"`    // Author name, max length 50, required
	ID          uint      `json:"id" gorm:"uniqueIndex;not null"`                            // Unique ID, required
	Content     string    `json:"content" gorm:"type:text;not null"`                         // Content of the comment, required
	LastUpdated time.Time `json:"lastUpdated" gorm:"default:CURRENT_TIMESTAMP"`              // Last updated time, defaults to current timestamp
	PostID      uint      `json:"postID" gorm:"not null"`                                    // Foreign key to Post, required
	Post        Post      `json:"post" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"` // Related Post model
}
