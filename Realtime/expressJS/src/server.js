const express = require("express");
const http = require("http");
const WebSocket = require("ws");
const _ = require("lodash");

const app = express();
const port = 54301;

const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: "/webapp" });

const rooms = {};

wss.on("connection", (ws) => {
  let currentRoom = null;
  let userId = _.uniqueId("user_");

  console.log(`New connection: ${userId}`);

  ws.on("message", (message) => {
    try {
      const data = JSON.parse(message);

      switch (data.type) {
        case "join_room": {
          const { room, user_id, username } = data;
          if (!rooms[room]) {
            rooms[room] = [];
          }
          rooms[room].push(ws);
          currentRoom = room;

          broadcastToRoom(room, {
            type: "presence_state",
            users: [{ user_id, username }],
          });

          console.log(`${username} joined room: ${room}`);
          break;
        }

        case "new_msg": {
          const { body, user_id, username } = data;

          if (currentRoom) {
            broadcastToRoom(currentRoom, {
              type: "new_msg",
              body,
              user_id,
              username,
            });
            console.log(`${username} sent a message: ${body}`);
          }
          break;
        }

        case "presence_state": {
          const { users } = data;

          if (currentRoom) {
            broadcastToRoom(currentRoom, {
              type: "presence_state",
              users,
            });
            console.log("Presence updated");
          }
          break;
        }

        case "typing": {
          const { user_id, username } = data;

          if (currentRoom) {
            broadcastToRoom(currentRoom, {
              type: "typing",
              user_id,
              username,
            });
            console.log(`${username} is typing...`);
          }
          break;
        }

        case "time_now": {
          const time = new Date().toISOString();
          broadcastToAll({ type: "time_now", time });
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
