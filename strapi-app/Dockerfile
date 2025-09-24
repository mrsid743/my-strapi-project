# ---- Builder Stage ----
# This stage builds the Strapi application.
FROM node:18 AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y python3 make g++ --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

# Use --legacy-peer-deps to resolve dependency conflicts between Strapi plugins
RUN npm install --legacy-peer-deps

COPY . .

ENV NODE_ENV=production
RUN npm run build


# ---- Production Stage ----
# This is the final, small, and optimized image.
FROM node:18-alpine AS production

WORKDIR /app

RUN apk add --no-cache python3 make g++

ENV NODE_ENV=production

# Copy the entire built application from the builder stage.
COPY --from=builder /app ./

# Use --legacy-peer-deps here as well for consistency
RUN npm ci --omit=dev --legacy-peer-deps

EXPOSE 1337

CMD ["npm", "run", "start"]

