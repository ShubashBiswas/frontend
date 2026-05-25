# syntax=docker/dockerfile:1

FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app
ARG VENDURE_SHOP_API_URL
ENV VENDURE_SHOP_API_URL=${VENDURE_SHOP_API_URL}
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ARG VENDURE_SHOP_API_URL
ENV NODE_ENV=production
ENV PORT=3000
ENV VENDURE_SHOP_API_URL=${VENDURE_SHOP_API_URL}
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./next.config.ts
EXPOSE 3000
CMD ["npm", "start"]
