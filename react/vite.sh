#!/bin/bash

#==============================================================================
# Script de Deploy Automático - React + Vite + Docker
# Autor: Vaz
# Descrição: Deploy completo de aplicações React no Docker
#==============================================================================

set -e  # Parar execução em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║     Deploy Automático - React + Vite + Docker            ║
║     GPS IT Services - Infrastructure & Observability     ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

#==============================================================================
# CONFIGURAÇÕES
#==============================================================================

# Solicitar informações do usuário
read -p "Nome da aplicação (ex: minha-app-gemini): " APP_NAME
read -p "Porta para exposição (padrão: 80): " PORT
PORT=${PORT:-80}

read -p "Caminho onde está o código fonte da aplicação React (ou deixe vazio para criar nova): " SOURCE_PATH

# Diretórios
PROJECT_DIR="/opt/apps/$APP_NAME"
FRONTEND_DIR="$PROJECT_DIR/frontend"

log_info "Aplicação: $APP_NAME"
log_info "Porta: $PORT"
log_info "Diretório: $PROJECT_DIR"

#==============================================================================
# VERIFICAÇÕES INICIAIS
#==============================================================================

log_info "Verificando pré-requisitos..."

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    log_error "Docker não encontrado! Instalando..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    log_success "Docker instalado com sucesso!"
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose não encontrado! Instalando..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    log_success "Docker Compose instalado com sucesso!"
fi

# Verificar se Node.js está instalado (para builds locais opcionais)
if ! command -v node &> /dev/null; then
    log_warning "Node.js não encontrado. Instalando..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    log_success "Node.js instalado com sucesso!"
fi

log_success "Todos os pré-requisitos verificados!"

#==============================================================================
# CRIAR ESTRUTURA DE DIRETÓRIOS
#==============================================================================

log_info "Criando estrutura de diretórios..."

# Criar diretório do projeto
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/logs"
mkdir -p "$PROJECT_DIR/backups"

cd "$PROJECT_DIR"

#==============================================================================
# PREPARAR CÓDIGO FONTE
#==============================================================================

if [ -z "$SOURCE_PATH" ]; then
    log_info "Criando nova aplicação React com Vite..."
    npm create vite@latest frontend -- --template react
    cd frontend
    npm install
else
    log_info "Copiando código fonte de: $SOURCE_PATH"
    
    if [ -d "$SOURCE_PATH" ]; then
        cp -r "$SOURCE_PATH" "$FRONTEND_DIR"
        cd "$FRONTEND_DIR"
        
        # Verificar se package.json existe
        if [ ! -f "package.json" ]; then
            log_error "package.json não encontrado! Certifique-se que é um projeto React válido."
            exit 1
        fi
        
        # Instalar dependências
        log_info "Instalando dependências..."
        npm install
    else
        log_error "Caminho $SOURCE_PATH não encontrado!"
        exit 1
    fi
fi

log_success "Código fonte preparado!"

#==============================================================================
# CRIAR ARQUIVOS DOCKER
#==============================================================================

log_info "Criando arquivos Docker..."

# Criar Dockerfile
cat > "$FRONTEND_DIR/Dockerfile" << 'DOCKERFILE'
# ============================================
# Stage 1: Build da aplicação React com Vite
# ============================================
FROM node:18-alpine AS builder

LABEL maintainer="GPS IT Services"
LABEL description="React Application built with Vite"

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production && \
    npm cache clean --force

# Copiar código fonte
COPY . .

# Build da aplicação
RUN npm run build

# ============================================
# Stage 2: Servidor Nginx
# ============================================
FROM nginx:alpine

# Instalar curl para health checks
RUN apk add --no-cache curl

# Remover configuração padrão
RUN rm -rf /usr/share/nginx/html/*

# Copiar build
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiar configuração customizada do Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Criar usuário não-root para Nginx
RUN addgroup -g 1001 -S nginx && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Ajustar permissões
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

log_success "Dockerfile criado!"

# Criar nginx.conf
cat > "$FRONTEND_DIR/nginx.conf" << 'NGINXCONF'
server {
    listen 80;
    server_name _;
    
    root /usr/share/nginx/html;
    index index.html;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;

    # Compressão Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

    # Cache de assets estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Fallback para SPA (Single Page Application)
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }

    # Bloquear acesso a arquivos sensíveis
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
NGINXCONF

log_success "nginx.conf criado!"

# Criar .dockerignore
cat > "$FRONTEND_DIR/.dockerignore" << 'DOCKERIGNORE'
node_modules
dist
build
.git
.gitignore
.env
.env.local
.env.development
.env.production
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.DS_Store
.vscode
.idea
*.swp
*.swo
coverage
.cache
DOCKERIGNORE

log_success ".dockerignore criado!"

#==============================================================================
# CRIAR DOCKER COMPOSE
#==============================================================================

log_info "Criando docker-compose.yml..."

cat > "$PROJECT_DIR/docker-compose.yml" << COMPOSE
version: '3.8'

services:
  frontend:
    container_name: ${APP_NAME}
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "${PORT}:80"
    environment:
      - NODE_ENV=production
      - TZ=America/Sao_Paulo
    volumes:
      - ./logs/nginx:/var/log/nginx:rw
    restart: unless-stopped
    networks:
      - ${APP_NAME}-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    labels:
      com.gps.application: "${APP_NAME}"
      com.gps.environment: "production"
      com.gps.managed-by: "docker-compose"

networks:
  ${APP_NAME}-network:
    driver: bridge
    name: ${APP_NAME}-network
COMPOSE

log_success "docker-compose.yml criado!"

#==============================================================================
# CRIAR SCRIPTS AUXILIARES
#==============================================================================

log_info "Criando scripts auxiliares..."

# Script de start
cat > "$PROJECT_DIR/start.sh" << 'STARTSCRIPT'
#!/bin/bash
echo "🚀 Iniciando aplicação..."
docker-compose up -d --build
echo "✅ Aplicação iniciada!"
docker-compose logs -f
STARTSCRIPT

# Script de stop
cat > "$PROJECT_DIR/stop.sh" << 'STOPSCRIPT'
#!/bin/bash
echo "🛑 Parando aplicação..."
docker-compose down
echo "✅ Aplicação parada!"
STOPSCRIPT

# Script de restart
cat > "$PROJECT_DIR/restart.sh" << 'RESTARTSCRIPT'
#!/bin/bash
echo "🔄 Reiniciando aplicação..."
docker-compose restart
echo "✅ Aplicação reiniciada!"
RESTARTSCRIPT

# Script de logs
cat > "$PROJECT_DIR/logs.sh" << 'LOGSSCRIPT'
#!/bin/bash
docker-compose logs -f --tail=100
LOGSSCRIPT

# Script de atualização
cat > "$PROJECT_DIR/update.sh" << 'UPDATESCRIPT'
#!/bin/bash
echo "📦 Atualizando aplicação..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d
echo "✅ Aplicação atualizada!"
UPDATESCRIPT

# Script de backup
cat > "$PROJECT_DIR/backup.sh" << 'BACKUPSCRIPT'
#!/bin/bash
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

echo "💾 Criando backup..."
tar -czf "$BACKUP_FILE" \
    --exclude='node_modules' \
    --exclude='dist' \
    --exclude='.git' \
    frontend/

echo "✅ Backup criado: $BACKUP_FILE"
BACKUPSCRIPT

# Script de limpeza
cat > "$PROJECT_DIR/cleanup.sh" << 'CLEANUPSCRIPT'
#!/bin/bash
echo "🧹 Limpando recursos Docker..."
docker system prune -af
echo "✅ Limpeza concluída!"
CLEANUPSCRIPT

# Tornar scripts executáveis
chmod +x "$PROJECT_DIR"/*.sh

log_success "Scripts auxiliares criados!"

#==============================================================================
# CRIAR ARQUIVO DE AMBIENTE
#==============================================================================

log_info "Criando arquivo .env..."

cat > "$PROJECT_DIR/.env" << ENV
# Configurações da Aplicação
APP_NAME=${APP_NAME}
PORT=${PORT}
NODE_ENV=production
TZ=America/Sao_Paulo

# Configurações do Frontend
VITE_APP_TITLE=${APP_NAME}
VITE_API_URL=http://localhost:3001/api

# GPS IT Services
MAINTAINER=GPS IT Services
ENVIRONMENT=production
ENV

log_success "Arquivo .env criado!"

#==============================================================================
# BUILD E DEPLOY
#==============================================================================

log_info "Iniciando build da aplicação..."

cd "$PROJECT_DIR"

# Build da imagem Docker
docker-compose build --no-cache

log_success "Build concluído com sucesso!"

log_info "Iniciando containers..."

# Iniciar aplicação
docker-compose up -d

log_success "Containers iniciados!"

# Aguardar health check
log_info "Aguardando aplicação ficar saudável..."
sleep 10

#==============================================================================
# VERIFICAÇÕES FINAIS
#==============================================================================

log_info "Verificando status dos containers..."

if docker-compose ps | grep -q "Up"; then
    log_success "✅ Aplicação está rodando!"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           DEPLOY CONCLUÍDO COM SUCESSO! 🎉            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📍 Aplicação:${NC} $APP_NAME"
    echo -e "${BLUE}🌐 URL:${NC} http://$(hostname -I | awk '{print $1}'):$PORT"
    echo -e "${BLUE}📂 Diretório:${NC} $PROJECT_DIR"
    echo ""
    echo -e "${YELLOW}Comandos úteis:${NC}"
    echo -e "  ${GREEN}cd $PROJECT_DIR${NC}"
    echo -e "  ${GREEN}./start.sh${NC}      - Iniciar aplicação"
    echo -e "  ${GREEN}./stop.sh${NC}       - Parar aplicação"
    echo -e "  ${GREEN}./restart.sh${NC}    - Reiniciar aplicação"
    echo -e "  ${GREEN}./logs.sh${NC}       - Ver logs em tempo real"
    echo -e "  ${GREEN}./update.sh${NC}     - Atualizar aplicação"
    echo -e "  ${GREEN}./backup.sh${NC}     - Criar backup"
    echo -e "  ${GREEN}./cleanup.sh${NC}    - Limpar recursos Docker"
    echo ""
    echo -e "${BLUE}📊 Monitoramento:${NC}"
    echo -e "  ${GREEN}docker-compose ps${NC}                    - Status dos containers"
    echo -e "  ${GREEN}docker-compose logs -f${NC}               - Logs em tempo real"
    echo -e "  ${GREEN}docker stats${NC}                         - Uso de recursos"
    echo ""
    echo -e "${BLUE}🔍 Health Check:${NC}"
    echo -e "  ${GREEN}curl http://localhost:$PORT/health${NC}"
    echo ""
    
    # Mostrar logs iniciais
    log_info "Logs da aplicação (Ctrl+C para sair):"
    docker-compose logs -f --tail=50
    
else
    log_error "❌ Erro ao iniciar aplicação!"
    docker-compose logs
    exit 1
fi
