const express = require("express");
const http = require("http");
const WebSocket = require("ws");
const _ = require("lodash");

const app = express();
const port = 54301;

const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: "/webapp/websocket" });

const rooms = {};

wss.on("connection", (ws) => {
  let currentRoom = null;
  let userId = _.uniqueId("user_");

  console.log(`New connection: ${userId}`);

  ws.on("message", (message) => {
    try {
      const data = JSON.parse(message);

      switch (data.event) {
        case "join_room": {
          const { topic, payload } = data;
          const user_id = payload.user_id;
          if (!rooms[topic]) {
            rooms[topic] = [];
          }
          rooms[topic].push(ws);
          currentRoom = topic;

          broadcastToRoom(topic, {
            type: "presence_state",
            users: [{ user_id }],
          });

          console.log(`${user_id} joined room: ${topic}`);
          break;
        }

        case "new_msg": {
          const { payload } = data;
          const user_id = payload.user_id;
          const body = payload.body;
          if (currentRoom) {
            broadcastToRoom(currentRoom, {
              type: "new_msg",
              body,
              user_id,
            });
            console.log(`${user_id} sent a message: ${body}`);
          }
          break;
        }

        case "typing": {
          const { payload } = data;
          const user_id = payload.user_id;
          if (currentRoom) {
            broadcastToRoom(currentRoom, {
              type: "typing",
              user_id,
            });
            console.log(`${user_id} is typing...`);
          }
          break;
        }

        case "time_now": {
          const time = new Date().toISOString();
          ws.send(JSON.stringify({ type: "time_now", time }));
          console.log(`Time broadcasted: ${time}`);
          break;
        }

        default:
          console.log("Unknown message type:", data.type);
      }
    } catch (error) {
      console.error("Error parsing message:", error);
    }
  });

  ws.on("close", () => {
    console.log(`User disconnected: ${userId}`);
    if (currentRoom && rooms[currentRoom]) {
      _.pull(rooms[currentRoom], ws);
    }
  });
});

function broadcastToRoom(room, message) {
  if (rooms[room]) {
    rooms[room].forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(message));
      }
    });
  }
}

function broadcastToAll(message) {
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(message));
    }
  });
}

server.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
