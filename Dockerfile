# STAGE 1: Build the application
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /opt/app

# Copy package.json and package-lock.json
# FIX: Copy files from the root context, not a subdirectory
COPY package.json package-lock.json ./

# Install dependencies using npm ci for reproducible builds, ignoring peer dependency conflicts
RUN npm ci --legacy-peer-deps

# Copy the rest of the application source code
# FIX: Copy the entire context, not just a subdirectory
COPY . .

# Build the Strapi application for production
RUN npm run build

# STAGE 2: Create the production image
FROM node:18-alpine

# Set the working directory
WORKDIR /opt/app

# Copy package.json and package-lock.json from the build stage
# FIX: Copy files from the root context of the build stage
COPY package.json package-lock.json ./

# Install only production dependencies, ignoring peer dependency conflicts
RUN npm ci --omit=dev --legacy-peer-deps

# Copy the built application from the 'build' stage
COPY --from=build /opt/app/dist ./dist

# Copy the Strapi configuration and other necessary folders from the 'build' stage
COPY --from=build /opt/app/config ./config
COPY --from=build /opt/app/database ./database
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/src ./src
COPY --from=build /opt/app/.strapi ./.strapi


# Set environment variables for Strapi
# These are placeholder values. You MUST provide these via environment variables
# in the docker run command for security.
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337
ENV APP_KEYS="dummykey1,dummykey2"
ENV API_TOKEN_SALT="dummysalt"
ENV ADMIN_JWT_SECRET="dummyadminsecret"
ENV JWT_SECRET="dummyjwtsecret"

# Expose the port Strapi runs on
EXPOSE 1337

# Command to start the Strapi application
CMD ["npm", "run", "start"]

