# 使用 Node.js 官方镜像作为基础镜像
FROM node:16-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm@8

# 复制 package.json 和 pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# 安装依赖
RUN pnpm install --frozen-lockfile

# 复制项目文件
COPY . .

# 构建参数：构建环境
ARG BUILD_ENV=production

# 构建项目
RUN if [ "$BUILD_ENV" = "test" ]; then \
        pnpm run build:test; \
    else \
        pnpm run build; \
    fi

# 使用 nginx 作为生产服务器
FROM nginx:alpine

# 复制构建产物到 nginx 目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 nginx 配置文件（如果有自定义配置）
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]

