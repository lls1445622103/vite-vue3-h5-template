#!/bin/bash

# 部署脚本示例
# 使用方法: ./deploy.sh [environment] [target]
# 例如: ./deploy.sh production /var/www/html

set -e

ENVIRONMENT=${1:-production}
DEPLOY_TARGET=${2:-/var/www/html}
BUILD_DIR="dist"

echo "=========================================="
echo "开始部署"
echo "环境: $ENVIRONMENT"
echo "目标目录: $DEPLOY_TARGET"
echo "=========================================="

# 检查构建产物是否存在
if [ ! -d "$BUILD_DIR" ]; then
    echo "错误: 构建产物目录 $BUILD_DIR 不存在"
    echo "请先执行构建: pnpm run build"
    exit 1
fi

# 备份现有部署（如果存在）
if [ -d "$DEPLOY_TARGET" ]; then
    echo "备份现有部署..."
    BACKUP_DIR="${DEPLOY_TARGET}_backup_$(date +%Y%m%d_%H%M%S)"
    cp -r "$DEPLOY_TARGET" "$BACKUP_DIR"
    echo "备份完成: $BACKUP_DIR"
fi

# 部署文件
echo "部署文件到 $DEPLOY_TARGET..."
mkdir -p "$DEPLOY_TARGET"
rsync -avz --delete "$BUILD_DIR/" "$DEPLOY_TARGET/"

# 设置权限（根据实际情况调整）
# chown -R www-data:www-data "$DEPLOY_TARGET"
# chmod -R 755 "$DEPLOY_TARGET"

echo "=========================================="
echo "部署完成！"
echo "=========================================="

# 可选：重启服务
# systemctl reload nginx

