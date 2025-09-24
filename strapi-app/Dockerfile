# ---- Production Stage ----
FROM node:18-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

# Copy only package files first
COPY --from=builder /app/package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev --legacy-peer-deps

# Copy build artifacts from builder
COPY --from=builder /app/build ./build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/.cache ./.cache

EXPOSE 1337

CMD ["npm", "run", "start"]