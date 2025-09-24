# Use a Node.js base image
FROM node:18-alpine

# Set the environment to production
ENV NODE_ENV=production

# Install build dependencies required by Strapi for native modules
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock)
COPY ./package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Build the Strapi application
RUN npm run build

# Expose the Strapi port
EXPOSE 1337

# Start the Strapi application
CMD ["npm", "run", "start"]
