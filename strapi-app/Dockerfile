# ---- Builder Stage ----
# This stage builds the Strapi application. Using a full Node image is robust.
FROM node:18 AS builder

# Set the working directory
WORKDIR /app

# Install dependencies needed for native modules, just in case
RUN apt-get update && apt-get install -y python3 make g++ --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json first to leverage Docker's layer caching.
# This is the key to speeding up subsequent builds.
COPY package*.json ./

# Install all dependencies (including devDependencies needed for the build)
RUN npm install

# Copy the rest of the application's source code
COPY . .

# Build the Strapi application for production
ENV NODE_ENV=production
RUN npm run build


# ---- Production Stage ----
# This is the final, small, and optimized image that will be deployed.
FROM node:18-alpine AS production

# Set the working directory
WORKDIR /app

# Install OS dependencies required for running Strapi on Alpine Linux
# These are needed for some npm packages to work correctly.
RUN apk add --no-cache python3 make g++

# Set environment to production
ENV NODE_ENV=production

# Copy the entire built application from the builder stage.
# This is more robust than copying individual folders.
COPY --from=builder /app ./

# Install ONLY production dependencies using npm ci for speed and consistency.
# This will remove any devDependencies that were copied from the builder stage.
RUN npm ci --omit=dev

# Expose the port Strapi runs on
EXPOSE 1337

# The command to start the Strapi application in production
CMD ["npm", "run", "start"]

