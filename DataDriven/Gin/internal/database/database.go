package database

import (
	"Gin/internal/models"
	"fmt"
	"log"
    "os"
	_ "github.com/joho/godotenv/autoload"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// Service represents a service that interacts with a database.
type Service interface {
}

type service struct {
	db *gorm.DB
}


var (
	database   = "DataDriven"
	password   = "123456"
	username   = "root"
	port       = "61015"
	host       = os.Getenv("DBSERVER")
	schema     = "public"
	dbInstance *service
)

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

func New() Service {
	if dbInstance != nil {
		return dbInstance.db
	}
	connStr := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable&search_path=%s", username, password, host, port, database, schema)

	db, err := gorm.Open(postgres.Open(connStr), &gorm.Config{})
	if err != nil {
		panic("failed to connect to the database")
	}
	if err != nil {
		log.Fatal(err)
	}
	dbInstance = &service{
		db: db,
	}
	runMigrations()
	return dbInstance.db

}

func runMigrations() {
	err := dbInstance.db.AutoMigrate(&models.Author{}, &models.Category{}, &models.Post{}, &models.Comment{})
	if err != nil {
		log.Fatal("failed to migrate database")
	}
}
