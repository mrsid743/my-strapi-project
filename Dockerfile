# Dockerfile for Strapi
FROM node:18-alpine

# Installing dependencies
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1

# Set working directory
WORKDIR /opt/

# Copy package.json and yarn.lock
COPY ./package.json ./yarn.lock ./

# Install dependencies
RUN yarn config set network-timeout 600000 -g && yarn install --frozen-lockfile

# Set environment
ENV NODE_ENV=production

# Copy your project files
WORKDIR /opt/app
COPY . .

# Build the Strapi app
RUN yarn build

# Expose the Strapi port and start the app
EXPOSE 1337
CMD ["yarn", "start"]
