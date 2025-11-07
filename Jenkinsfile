pipeline {
    agent any
    
    // 环境变量配置
    environment {
        // Node.js 版本（根据项目需要调整）
        NODE_VERSION = '16'
        // pnpm 版本
        PNPM_VERSION = '8'
        // 构建产物目录
        BUILD_DIR = 'dist'
        // Docker 镜像仓库地址（如果需要容器化部署）
        DOCKER_REGISTRY = 'your-registry.com'
        // Docker 镜像名称
        DOCKER_IMAGE_NAME = 'vite-vue3-h5-template'
    }
    
    // 参数化构建
    parameters {
        choice(
            name: 'BUILD_ENV',
            choices: ['development', 'test', 'production'],
            description: '选择构建环境'
        )
        choice(
            name: 'DEPLOY_TARGET',
            choices: ['none', 'test-server', 'production-server'],
            description: '选择部署目标（none表示只构建不部署）'
        )
        booleanParam(
            name: 'SKIP_LINT',
            defaultValue: false,
            description: '跳过代码检查'
        )
        booleanParam(
            name: 'SKIP_TYPECHECK',
            defaultValue: false,
            description: '跳过类型检查'
        )
    }
    
    stages {
        // 阶段1: 代码检出
        stage('Checkout') {
            steps {
                script {
                    echo "开始检出代码..."
                    checkout scm
                    // 显示当前分支和提交信息
                    sh '''
                        echo "当前分支: $(git branch --show-current)"
                        echo "最新提交: $(git log -1 --pretty=format:'%h - %an, %ar : %s')"
                    '''
                }
            }
        }
        
        // 阶段2: 环境准备
        stage('Setup Environment') {
            steps {
                script {
                    echo "准备构建环境..."
                    // 检查并设置 Node.js 环境
                    sh '''
                        # 检查 Node.js 是否已全局安装
                        if command -v node &> /dev/null; then
                            echo "Node.js 已全局安装"
                            node -v
                            npm -v
                        else
                            echo "Node.js 未全局安装，尝试使用 nvm..."
                            export NVM_DIR="$HOME/.nvm"
                            
                            # 如果 nvm 存在，使用 nvm 安装 Node.js
                            if [ -s "$NVM_DIR/nvm.sh" ]; then
                                echo "找到 nvm，使用 nvm 安装 Node.js ${NODE_VERSION}..."
                                # 使用 bash -c 确保所有命令在同一个 shell 中执行
                                bash -c "
                                    export NVM_DIR=\\$HOME/.nvm
                                    [ -s \\$NVM_DIR/nvm.sh ] && source \\$NVM_DIR/nvm.sh
                                    nvm install ${NODE_VERSION}
                                    nvm use ${NODE_VERSION}
                                    node -v
                                    npm -v
                                "
                            else
                                echo "错误: Node.js 未安装且 nvm 未找到"
                                echo "请执行以下操作之一："
                                echo "1. 在 Jenkins 系统配置中安装 Node.js 插件并配置 Node.js ${NODE_VERSION}"
                                echo "2. 在服务器上全局安装 Node.js ${NODE_VERSION}"
                                echo "3. 安装 nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
                                exit 1
                            fi
                        fi
                        
                        # 安装 pnpm（如果未安装）
                        if ! command -v pnpm &> /dev/null; then
                            echo "安装 pnpm..."
                            npm install -g pnpm@${PNPM_VERSION}
                        fi
                        
                        # 显示 pnpm 版本
                        pnpm -v || (echo "pnpm 安装失败" && exit 1)
                    '''
                }
            }
        }
        
        // 阶段3: 安装依赖
        stage('Install Dependencies') {
            steps {
                script {
                    echo "安装项目依赖..."
                    sh '''
                        # 加载 Node.js 环境（如果使用 nvm）
                        export NVM_DIR="$HOME/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || true
                        
                        # 使用 pnpm 安装依赖
                        pnpm install --frozen-lockfile
                        
                        # 验证依赖安装
                        echo "依赖安装完成"
                    '''
                }
            }
        }
        
        // 阶段4: 代码检查
        stage('Lint') {
            when {
                expression { !params.SKIP_LINT }
            }
            steps {
                script {
                    echo "执行代码检查..."
                    sh '''
                        # 加载 Node.js 环境（如果使用 nvm）
                        export NVM_DIR="$HOME/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || true
                        
                        pnpm run lint || {
                            echo "代码检查失败，请修复后重试"
                            exit 1
                        }
                    '''
                }
            }
        }
        
        // 阶段5: 类型检查
        stage('Type Check') {
            when {
                expression { !params.SKIP_TYPECHECK }
            }
            steps {
                script {
                    echo "执行 TypeScript 类型检查..."
                    sh '''
                        # 加载 Node.js 环境（如果使用 nvm）
                        export NVM_DIR="$HOME/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || true
                        
                        pnpm run typecheck || {
                            echo "类型检查失败，请修复后重试"
                            exit 1
                        }
                    '''
                }
            }
        }
        
        // 阶段6: 构建项目
        stage('Build') {
            steps {
                script {
                    echo "开始构建项目，环境: ${params.BUILD_ENV}"
                    sh '''
                        # 加载 Node.js 环境（如果使用 nvm）
                        export NVM_DIR="$HOME/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || true
                        
                        # 根据环境选择构建命令
                        if [ "${BUILD_ENV}" == "test" ]; then
                            echo "构建测试环境..."
                            pnpm run build:test
                        elif [ "${BUILD_ENV}" == "production" ]; then
                            echo "构建生产环境..."
                            pnpm run build
                        else
                            echo "构建开发环境..."
                            pnpm run build
                        fi
                        
                        # 检查构建产物
                        if [ ! -d "${BUILD_DIR}" ]; then
                            echo "构建失败：未找到构建产物目录 ${BUILD_DIR}"
                            exit 1
                        fi
                        
                        # 显示构建产物大小
                        du -sh ${BUILD_DIR}
                        echo "构建完成"
                    '''
                }
            }
        }
        
        // 阶段7: 构建产物归档
        stage('Archive Artifacts') {
            steps {
                script {
                    echo "归档构建产物..."
                    archiveArtifacts artifacts: "${BUILD_DIR}/**/*", fingerprint: true, allowEmptyArchive: false
                }
            }
        }
        
        // 阶段8: Docker 构建（可选）
        stage('Docker Build') {
            when {
                expression { 
                    params.DEPLOY_TARGET != 'none' && 
                    fileExists('Dockerfile') 
                }
            }
            steps {
                script {
                    echo "构建 Docker 镜像..."
                    def imageTag = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${BUILD_ENV}-${BUILD_NUMBER}"
                    def latestTag = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${BUILD_ENV}-latest"
                    
                    sh """
                        docker build -t ${imageTag} -t ${latestTag} .
                        docker push ${imageTag}
                        docker push ${latestTag}
                    """
                    
                    // 保存镜像标签供后续使用
                    env.DOCKER_IMAGE_TAG = imageTag
                }
            }
        }
        
        // 阶段9: 部署
        stage('Deploy') {
            when {
                expression { params.DEPLOY_TARGET != 'none' }
            }
            steps {
                script {
                    echo "部署到: ${params.DEPLOY_TARGET}"
                    
                    if (params.DEPLOY_TARGET == 'test-server') {
                        // 部署到测试服务器
                        sh '''
                            echo "部署到测试服务器..."
                            # 示例：使用 rsync 部署
                            # rsync -avz --delete ${BUILD_DIR}/ user@test-server:/var/www/html/
                            
                            # 或使用 scp
                            # scp -r ${BUILD_DIR}/* user@test-server:/var/www/html/
                            
                            # 或使用 SSH 执行部署脚本
                            # ssh user@test-server 'bash /path/to/deploy.sh'
                            
                            echo "测试环境部署完成"
                        '''
                    } else if (params.DEPLOY_TARGET == 'production-server') {
                        // 部署到生产服务器（需要确认）
                        input message: "确认部署到生产环境？", ok: "确认部署"
                        
                        sh '''
                            echo "部署到生产服务器..."
                            # 示例：使用 rsync 部署
                            # rsync -avz --delete ${BUILD_DIR}/ user@prod-server:/var/www/html/
                            
                            # 或使用 scp
                            # scp -r ${BUILD_DIR}/* user@prod-server:/var/www/html/
                            
                            # 或使用 SSH 执行部署脚本
                            # ssh user@prod-server 'bash /path/to/deploy.sh'
                            
                            echo "生产环境部署完成"
                        '''
                    }
                }
            }
        }
    }
    
    // 构建后操作
    post {
        // 构建成功
        success {
            script {
                echo "构建成功！"
                // 可以在这里添加通知，如发送邮件、企业微信、钉钉等
                // emailext (
                //     subject: "构建成功: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                //     body: "构建环境: ${params.BUILD_ENV}\n构建编号: ${env.BUILD_NUMBER}\n构建分支: ${env.BRANCH_NAME}",
                //     to: "your-email@example.com"
                // )
            }
        }
        
        // 构建失败
        failure {
            script {
                echo "构建失败！"
                // 失败通知
                // emailext (
                //     subject: "构建失败: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                //     body: "构建环境: ${params.BUILD_ENV}\n构建编号: ${env.BUILD_NUMBER}\n请查看构建日志",
                //     to: "your-email@example.com"
                // )
            }
        }
        
        // 总是执行（清理工作）
        always {
            script {
                echo "清理临时文件..."
                // 清理 node_modules（可选，节省空间）
                // sh 'rm -rf node_modules'
            }
        }
    }
}

