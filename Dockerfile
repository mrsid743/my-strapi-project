# Stage 1: Build the Strapi application using node version 18 on Alpine Linux
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /opt/app

# Copy package.json to leverage Docker cache
# We are not copying yarn.lock to make the build more resilient
# in case the lock file is not committed to the repository.
COPY package.json ./

# Install all dependencies using yarn. This will generate a yarn.lock file inside the container.
RUN yarn install

# Copy the rest of your Strapi application source code
COPY . .

# Build the Strapi admin panel for production
RUN yarn build

# Stage 2: Create the final, smaller production image
FROM node:18-alpine

# Set the working directory
WORKDIR /opt/app

# Copy package.json again
COPY package.json ./

# Install ONLY production dependencies to keep the image size small
RUN yarn install --production

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
CMD ["yarn", "start"]

