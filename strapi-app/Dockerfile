# Use a Node.js base image (v18 is recommended for Strapi v4)
FROM node:18-alpine

# Install build dependencies required by Strapi for native modules
# Adding python3 and make are common requirements for node-gyp (native addons)
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev python3 make

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock)
# This leverages Docker's layer caching.
COPY ./package*.json ./

# Install ALL dependencies (including devDependencies)
# This is crucial because the build step might require packages from devDependencies.
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Strapi application
RUN npm run build

# Set the environment to production for the runtime stage
ENV NODE_ENV=production

# After the build, prune the devDependencies to reduce image size
RUN npm prune --production

# Expose the Strapi port
EXPOSE 1337

# Start the Strapi application
CMD ["npm", "run", "start"]

