# Dockerfile for Strapi (Optimized Multi-stage Build)

# 1. Build Stage: Where we build the Strapi admin panel.
FROM node:18 AS build

WORKDIR /opt/app

# Copy package.json and yarn.lock to leverage Docker cache.
COPY package.json yarn.lock ./

# Install all dependencies, including devDependencies needed for the build.
RUN yarn install --frozen-lockfile

# Copy the rest of your Strapi application source code.
COPY . .

# Build the admin panel.
ENV NODE_ENV=production
RUN yarn build

# Remove devDependencies to prepare for the production stage.
RUN yarn install --production --frozen-lockfile


# 2. Production Stage: A smaller, secure image for running the app.
FROM node:18-alpine

WORKDIR /opt/app

# Install runtime-only native dependencies for 'sharp' (image processing).
RUN apk add --no-cache vips-dev

# Copy the built application, including pruned node_modules, from the build stage.
COPY --from=build /opt/app ./

# Expose the Strapi port and start the application.
EXPOSE 1337
CMD ["yarn", "start"]
