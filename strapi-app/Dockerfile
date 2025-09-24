# Dockerfile - Strapi (Node 18 LTS)
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install build deps
RUN apk add --no-cache python3 make g++ bash

# Copy package.json and package-lock.json first (cache)
COPY package*.json ./

# Install dependencies
RUN npm ci --legacy-peer-deps

# Copy rest of app
COPY . .

# Build admin UI (if using Strapi >4)
RUN npm run build

# Expose Strapi port
EXPOSE 1337

# Default environment (can be overridden via -e)
ENV NODE_ENV=production
ENV PORT=1337
# Use sqlite by default in container. For production, replace with DB envs.
ENV DATABASE_CLIENT=sqlite

# Start the app
CMD ["npm", "start"]
