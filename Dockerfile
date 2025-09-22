# Use an appropriate Node.js base image
FROM node:18-alpine

# Set the working directory *inside* the container
WORKDIR /usr/src/app

# --- This is the key change ---
# 1. Copy package files *from* the 'strapi-app' subfolder
COPY strapi-app/package.json strapi-app/package-lock.json ./

# 2. Install dependencies INSIDE the container
RUN npm install

# 3. Copy the rest of your app code *from* the 'strapi-app' subfolder
# This will respect your .dockerignore file
COPY strapi-app/ .
# -----------------------------

# If your Strapi app needs to be built (Strapi usually does)
RUN npm run build

# Expose the Strapi port
EXPOSE 1337

# Command to run your app
CMD ["npm", "run", "start"]