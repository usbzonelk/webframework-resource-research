package server

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var rooms = make(map[string][]*websocket.Conn)
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type Message struct {
	Event   string `json:"event"`
	Topic   string `json:"topic,omitempty"`
	Payload struct {
		UserID string `json:"user_id"`
		Body   string `json:"body,omitempty"`
	} `json:"payload"`
}

func broadcastToRoom(room string, msg interface{}) {
	if clients, ok := rooms[room]; ok {
		for _, client := range clients {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Println("Error broadcasting message:", err)
			}
		}
	}
}

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()
	r.GET("/webapp/websocket", s.handleConnection)
	return r
}

func (s *Server) handleConnection(c *gin.Context) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("Upgrade error:", err)
		return
	}
	defer conn.Close()

	var currentRoom string
	userID := fmt.Sprintf("user_%d", time.Now().UnixNano())

	log.Printf("New connection: %s", userID)

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			log.Println("Read error:", err)
			break
		}

		var data Message
		if err := json.Unmarshal(msg, &data); err != nil {
			log.Println("Error parsing message:", err)
			continue
		}

		switch data.Event {
		case "join_room":
			if _, exists := rooms[data.Topic]; !exists {
				rooms[data.Topic] = []*websocket.Conn{}
			}
			rooms[data.Topic] = append(rooms[data.Topic], conn)
			currentRoom = data.Topic

			broadcastToRoom(data.Topic, map[string]interface{}{
				"type":  "presence_state",
				"users": []map[string]string{{"user_id": data.Payload.UserID}},
			})
			log.Printf("%s joined room: %s", data.Payload.UserID, data.Topic)

		case "new_msg":
			if currentRoom != "" {
				broadcastToRoom(currentRoom, map[string]interface{}{
					"type":    "new_msg",
					"body":    data.Payload.Body,
					"user_id": data.Payload.UserID,
				})
				log.Printf("%s sent a message: %s", data.Payload.UserID, data.Payload.Body)
			}

		case "typing":
			if currentRoom != "" {
				broadcastToRoom(currentRoom, map[string]interface{}{
					"type":    "typing",
					"user_id": data.Payload.UserID,
				})
				log.Printf("%s is typing...", data.Payload.UserID)
			}

		case "time_now":
			timeNow := time.Now().Format(time.RFC3339)
			conn.WriteJSON(map[string]interface{}{
				"type": "time_now",
				"time": timeNow,
			})
			log.Printf("Time broadcasted: %s", timeNow)

		default:
			log.Println("Unknown message type:", data.Event)
		}
	}

	log.Printf("User disconnected: %s", userID)
	if currentRoom != "" {
		clients := rooms[currentRoom]
		for i, client := range clients {
			if client == conn {
				rooms[currentRoom] = append(clients[:i], clients[i+1:]...)
				break
			}
		}
	}
}
