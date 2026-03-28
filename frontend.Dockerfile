FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
ENV VITE_API_BASE_URL=/api
RUN npm run build
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
# 暴露 8000 端口
EXPOSE 8000
CMD ["nginx", "-g", "daemon off;"]
