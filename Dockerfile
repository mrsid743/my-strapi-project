# Stage 1: Build the Strapi application using node version 18 on Alpine Linux
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /opt/app

# Copy package.json and package-lock.json to leverage Docker cache
COPY package.json ./
COPY package-lock.json ./

# Install all dependencies (including devDependencies needed for the build)
RUN npm install

# Copy the rest of your Strapi application source code
COPY . .

# Build the Strapi admin panel for production
RUN npm run build

# Stage 2: Create the final, smaller production image
FROM node:18-alpine

# Set the working directory
WORKDIR /opt/app

# Copy package.json and package-lock.json again
COPY package.json ./
COPY package-lock.json ./

# Install ONLY production dependencies to keep the image size small
RUN npm install --production

# Copy the built application artifacts from the 'build' stage
COPY --from=build /opt/app/dist ./dist

# Copy the production-necessary folders from the 'build' stage
COPY --from=build /opt/app/config ./config
COPY --from=build /opt/app/database ./database
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/src ./src
COPY --from=build /opt/app/.strapi ./.strapi

# Expose the port that Strapi runs on
EXPOSE 1337

# The command to start the Strapi application in production mode
CMD ["npm", "run", "start"]

