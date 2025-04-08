FROM node:18-alpine

WORKDIR /app
COPY . .
RUN apk add --no-cache curl && npm install
CMD ["node", "server.js"]

