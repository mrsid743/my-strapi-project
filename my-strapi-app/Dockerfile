# Use an official Node.js runtime as a parent image
# We use 'alpine' for a smaller image size
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock)
# We copy these first to take advantage of Docker's layer caching.
# If these files don't change, Docker won't re-run 'npm install'
COPY package.json ./
COPY package-lock.json ./
# If you use yarn, uncomment the line below and comment the one above
# COPY yarn.lock ./

# Install app dependencies
RUN npm install
# If you use yarn, uncomment the line below and comment the one above
# RUN yarn install

# Bundle app source
COPY . .

# Strapi's default port
EXPOSE 1337

# This command runs your app in development mode
# It will automatically create the SQLite database inside the container
CMD ["npm", "run", "develop"]