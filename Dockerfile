# Stage 1: Build the Strapi application
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /opt/app

# Copy package.json and package-lock.json from the subdirectory
COPY my-strapi-app/package.json my-strapi-app/package-lock.json ./

# Install dependencies using npm ci for reproducible builds, ignoring peer dependency conflicts
RUN npm ci --legacy-peer-deps

# Copy the rest of the application source code from the subdirectory
COPY my-strapi-app/ .

# Build the Strapi admin panel
RUN npm run build

# Stage 2: Create a smaller production image
FROM node:18-alpine

# Set the working directory
WORKDIR /opt/app

# Copy package.json and package-lock.json from the build stage's subdirectory context
COPY my-strapi-app/package.json my-strapi-app/package-lock.json ./

# Install only production dependencies, ignoring peer dependency conflicts
RUN npm ci --omit=dev --legacy-peer-deps

# Copy the built application from the 'build' stage
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/config ./config
COPY --from=build /opt/app/database ./database
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/src ./src
COPY --from=build /opt/app/.strapi ./.strapi

# Expose the port Strapi runs on
EXPOSE 1337

# Set default environment variables for Strapi
# These should be overridden in the `docker run` command for a real setup
ENV HOST=0.0.0.0
ENV PORT=1337
ENV NODE_ENV=production

# These are placeholder values. You MUST provide these via environment variables
# in the docker run command for security.
ENV APP_KEYS="NmJRb4WyXDZirFykzpjc5g==,nKmOfuDBfdxXhcZFmGbiew==,ox+d6jdtd2DR8/ZKIqBObw==,afrDpX7TCT5Md8Jpg6ccmQ=="
ENV API_TOKEN_SALT="hLiEiGF82uCn3Dapbzhoog=="
ENV ADMIN_JWT_SECRET="3X28akYK0BgtH1QzhOYBpQ=="
ENV JWT_SECRET="Zg7QRAfII0Qi3pI1XD6mmg=="

# Start the Strapi application
CMD ["npm", "run", "start"]

