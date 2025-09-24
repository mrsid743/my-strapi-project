# Stage 1: Build the Strapi application using node version 18 on Alpine Linux
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /opt/app

# Copy package.json and yarn.lock to leverage Docker cache
COPY package.json ./
COPY yarn.lock ./

# Install all dependencies using yarn
RUN yarn install --frozen-lockfile

# Copy the rest of your Strapi application source code
COPY . .

# Build the Strapi admin panel for production
RUN yarn build

# Stage 2: Create the final, smaller production image
FROM node:18-alpine

# Set the working directory
WORKDIR /opt/app

# Copy package.json and yarn.lock again
COPY package.json ./
COPY yarn.lock ./

# Install ONLY production dependencies to keep the image size small
RUN yarn install --production --frozen-lockfile

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

