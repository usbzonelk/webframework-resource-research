package server

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	r.GET("/read", s.ReadHandler)

	return r
}

func (s *Server) ReadHandler(c *gin.Context) {
	currentDir, err := os.Getwd()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": fmt.Sprintf("unable to get current working directory: %v", err),
		})
		return
	}

	filePath := filepath.Join(currentDir, "textFile.txt")

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": fmt.Sprintf("file does not exist at path: %s", filePath),
		})
		return
	}

	var wg sync.WaitGroup
	wg.Add(1)

	resultChan := make(chan string, 1)

	go func(file string) {
		defer wg.Done()
		result := readFile(file)
		time.Sleep(2 * time.Second)
		resultChan <- result
	}(filePath)

	go func() {
		wg.Wait()
		close(resultChan)
	}()

	result := <-resultChan
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": result,
	})
}

func readFile(filePath string) string {
	content, err := os.ReadFile(filePath)
	if err != nil {
		return fmt.Sprintf("Error reading file %s: %s", filePath, err.Error())
	}
	return string(content)
}
