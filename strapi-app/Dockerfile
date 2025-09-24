# ---- Builder Stage ----
# This stage builds the Strapi application.
FROM node:18 AS builder

WORKDIR /app

# Install OS-level dependencies needed for some npm packages
RUN apt-get update && apt-get install -y python3 make g++ --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Use 'npm ci' which is faster and stricter for CI/CD environments.
# The --legacy-peer-deps flag is used to resolve known Strapi dependency conflicts.
RUN npm ci --legacy-peer-deps

# Copy the rest of the application source code
COPY . .

# Build the Strapi application for production
ENV NODE_ENV=production
RUN npm run build


# ---- Production Stage ----
# This is the final, small, and optimized image that will run in production.
FROM node:18-alpine AS production

WORKDIR /app

# Install OS dependencies for Alpine Linux
RUN apk add --no-cache python3 make g++

ENV NODE_ENV=production

# Copy the entire built application from the builder stage.
COPY --from=builder /app ./

# Use 'npm ci' here as well to install only production dependencies cleanly.
RUN npm ci --omit=dev --legacy-peer-deps

# Expose the port that Strapi runs on
EXPOSE 1337

# The command to start the Strapi application
CMD ["npm", "run", "start"]

