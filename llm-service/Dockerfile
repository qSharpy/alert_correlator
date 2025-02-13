# Use Node.js base image
FROM node:18-slim

# Set working directory
WORKDIR /app

# Copy package files
COPY llm-service/package.json .
COPY llm-service/package-lock.json* .

# Install dependencies
RUN npm install

# Copy application files
COPY llm-service/index.html .
COPY llm-service/server.js .

# Expose port
EXPOSE 3003

# Start the server
CMD ["node", "server.js"]