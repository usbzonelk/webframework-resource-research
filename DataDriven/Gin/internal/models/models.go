package models

import (
	"time"

	"gorm.io/gorm"
)

type Author struct {
	gorm.Model

	Name  string `gorm:"type:varchar(150);not null"`
	Email string `gorm:"type:varchar(255);uniqueIndex;not null"`
	ID    uint   `gorm:"uniqueIndex;not null"`
}

type Category struct {
	gorm.Model

	Name string `gorm:"type:varchar(150);not null"`
	ID   uint   `gorm:"uniqueIndex;not null"`
}

type Post struct {
	gorm.Model // Includes ID, CreatedAt, UpdatedAt, DeletedAt fields

	Title       string     `gorm:"type:varchar(200);not null;default:''"`                                            // Title, max length 200, required
	Slug        string     `gorm:"type:varchar(255);uniqueIndex;not null"`                                           // Slug, unique index, required
	ID          uint       `gorm:"uniqueIndex;not null"`                                                             // Unique ID, required
	Content     string     `gorm:"type:text;not null;default:''"`                                                    // Content, required with a default empty string
	Authors     []Author   `gorm:"many2many:post_authors;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`             // Many-to-many relationship with Author
	Categories  []Category `gorm:"many2many:post_categories;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`          // Many-to-many relationship with Category
	LastUpdated time.Time  `gorm:"default:CURRENT_TIMESTAMP"`                                                        // Last updated timestamp
	PostStatus  string     `gorm:"type:varchar(50);default:'Published';check:post_status IN ('Published', 'Draft')"` // Enum-like for post status
}

type Comment struct {
	gorm.Model // Includes ID, CreatedAt, UpdatedAt, DeletedAt fields

	AuthorName  string    `gorm:"type:varchar(50);not null;default:''"`          // Author name, max length 50, required
	ID          uint      `gorm:"uniqueIndex;not null"`                          // Unique ID, required
	Content     string    `gorm:"type:text;not null"`                            // Content of the comment, required
	LastUpdated time.Time `gorm:"default:CURRENT_TIMESTAMP"`                     // Last updated time, defaults to current timestamp
	PostID      uint      `gorm:"not null"`                                      // Foreign key to Post, required
	Post        Post      `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"` // Related Post model
}
