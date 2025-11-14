#!/bin/bash

#==============================================================================
# Deploy Rápido - Aplicações React
# Autor: Amândio Vaz
# Descrição: Deploy simplificado para código já pronto
#==============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║          Deploy Rápido - Aplicações em Reazt              ║
║                 Amândio Vaz - AIOps                       ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Função de log
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    error "Este script precisa ser executado como root. Use: sudo $0"
fi

# Solicitar informações
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Por favor, forneça as seguintes informações:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

read -p "$(echo -e ${GREEN}📦 Nome da aplicação${NC} [ex: meu-app-ia: )" APP_NAME
[ -z "$APP_NAME" ] && error "Nome da aplicação é obrigatório!"

read -p "$(echo -e ${GREEN}🌐 Porta para exposição${NC} [padrão: 80]: )" PORT
PORT=${PORT:-80}

# Verificar se porta está em uso
if netstat -tuln 2>/dev/null | grep -q ":$PORT " || ss -tuln 2>/dev/null | grep -q ":$PORT "; then
    warning "Porta $PORT já está em uso!"
    read -p "Deseja usar outra porta? Digite a nova porta ou Enter para cancelar: " NEW_PORT
    [ -z "$NEW_PORT" ] && error "Deploy cancelado - porta em uso"
    PORT=$NEW_PORT
fi

read -p "$(echo -e ${GREEN}📁 Caminho COMPLETO do código fonte${NC} [ex: /home/user/meu-projeto]: )" SOURCE_PATH
[ -z "$SOURCE_PATH" ] && error "Caminho do código fonte é obrigatório!"
[ ! -d "$SOURCE_PATH" ] && error "Diretório '$SOURCE_PATH' não encontrado!"

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Confirme as informações:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "  📦 Aplicação: ${GREEN}$APP_NAME${NC}"
echo -e "  🌐 Porta: ${GREEN}$PORT${NC}"
echo -e "  📁 Código fonte: ${GREEN}$SOURCE_PATH${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

read -p "Continuar com o deploy? [S/n]: " CONFIRM
CONFIRM=${CONFIRM:-S}
[[ ! $CONFIRM =~ ^[Ss]$ ]] && error "Deploy cancelado pelo usuário"

# Diretórios
PROJECT_DIR="/opt/apps/$APP_NAME"
FRONTEND_DIR="$PROJECT_DIR/frontend"

log "Iniciando deploy da aplicação '$APP_NAME'..."

# Criar estrutura
log "Criando estrutura de diretórios..."
mkdir -p "$PROJECT_DIR"/{logs,backups}

# Copiar código fonte
log "Copiando código fonte..."
if [ -d "$FRONTEND_DIR" ]; then
    warning "Diretório de destino já existe. Criando backup..."
    tar -czf "$PROJECT_DIR/backups/backup_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$PROJECT_DIR" frontend
    rm -rf "$FRONTEND_DIR"
fi

cp -r "$SOURCE_PATH" "$FRONTEND_DIR"
success "Código fonte copiado!"

# Verificar se é um projeto válido
cd "$FRONTEND_DIR"
if [ ! -f "package.json" ]; then
    error "package.json não encontrado! Certifique-se que é um projeto React válido."
fi

# Detectar tipo de projeto
log "Detectando tipo de projeto..."
if grep -q '"vite"' package.json; then
    BUILD_CMD="npm run build"
    BUILD_DIR="dist"
    success "Projeto Vite detectado"
elif grep -q '"react-scripts"' package.json; then
    BUILD_CMD="npm run build"
    BUILD_DIR="build"
    success "Projeto Create React App detectado"
else
    warning "Tipo de projeto não detectado. Usando configuração padrão Vite."
    BUILD_CMD="npm run build"
    BUILD_DIR="dist"
fi

# Instalar dependências
log "Instalando dependências Node.js..."
npm install --production
success "Dependências instaladas!"

# Criar Dockerfile
log "Criando Dockerfile..."
cat > "$FRONTEND_DIR/Dockerfile" << DOCKERFILE
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN $BUILD_CMD

FROM nginx:alpine

RUN apk add --no-cache curl

COPY --from=builder /app/${BUILD_DIR} /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

success "Dockerfile criado!"

# Criar nginx.conf
log "Criando configuração Nginx..."
cat > "$FRONTEND_DIR/nginx.conf" << 'NGINXCONF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/javascript application/json application/javascript;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINXCONF

success "Configuração Nginx criada!"

# Criar .dockerignore
log "Criando .dockerignore..."
cat > "$FRONTEND_DIR/.dockerignore" << 'DOCKERIGNORE'
node_modules
dist
build
.git
.env*
npm-debug.log*
.DS_Store
DOCKERIGNORE

# Criar docker-compose.yml
log "Criando docker-compose.yml..."
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
      - ./logs:/var/log/nginx:rw
    restart: unless-stopped
    networks:
      - ${APP_NAME}-network
    labels:
      com.gps.app: "${APP_NAME}"
      com.gps.deployed: "$(date -Iseconds)"

networks:
  ${APP_NAME}-network:
    driver: bridge
COMPOSE

success "docker-compose.yml criado!"

# Criar scripts de gerenciamento
log "Criando scripts de gerenciamento..."

cat > "$PROJECT_DIR/start.sh" << 'EOF'
#!/bin/bash
docker-compose up -d
echo "✅ Aplicação iniciada!"
EOF

cat > "$PROJECT_DIR/stop.sh" << 'EOF'
#!/bin/bash
docker-compose down
echo "✅ Aplicação parada!"
EOF

cat > "$PROJECT_DIR/logs.sh" << 'EOF'
#!/bin/bash
docker-compose logs -f --tail=100
EOF

cat > "$PROJECT_DIR/restart.sh" << 'EOF'
#!/bin/bash
docker-compose restart
echo "✅ Aplicação reiniciada!"
EOF

cat > "$PROJECT_DIR/update.sh" << 'EOF'
#!/bin/bash
echo "Atualizando aplicação..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d
echo "✅ Aplicação atualizada!"
EOF

chmod +x "$PROJECT_DIR"/*.sh
success "Scripts criados!"

# Criar arquivo .env
cat > "$PROJECT_DIR/.env" << ENV
APP_NAME=${APP_NAME}
PORT=${PORT}
NODE_ENV=production
DEPLOYED_AT=$(date -Iseconds)
ENV

# Build da imagem
log "Construindo imagem Docker (isso pode levar alguns minutos)..."
cd "$PROJECT_DIR"
docker-compose build --no-cache

success "Imagem construída com sucesso!"

# Iniciar aplicação
log "Iniciando aplicação..."
docker-compose up -d

success "Aplicação iniciada!"

# Aguardar container ficar saudável
log "Verificando saúde da aplicação..."
sleep 5

# Obter IP do servidor
SERVER_IP=$(hostname -I | awk '{print $1}')

# Verificar se está rodando
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        🎉 DEPLOY CONCLUÍDO COM SUCESSO! 🎉                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} 📦 Aplicação: ${GREEN}$APP_NAME${NC}"
    echo -e "${CYAN}│${NC} 🌐 URL Local: ${GREEN}http://localhost:$PORT${NC}"
    echo -e "${CYAN}│${NC} 🌍 URL Externa: ${GREEN}http://$SERVER_IP:$PORT${NC}"
    echo -e "${CYAN}│${NC} 📂 Diretório: ${BLUE}$PROJECT_DIR${NC}"
    echo -e "${CYAN}│${NC} 🔍 Health: ${GREEN}http://localhost:$PORT/health${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${YELLOW}📋 Comandos Úteis:${NC}"
    echo -e "  ${GREEN}cd $PROJECT_DIR${NC}"
    echo -e "  ${GREEN}./start.sh${NC}    - Iniciar"
    echo -e "  ${GREEN}./stop.sh${NC}     - Parar"
    echo -e "  ${GREEN}./restart.sh${NC}  - Reiniciar"
    echo -e "  ${GREEN}./logs.sh${NC}     - Ver logs"
    echo -e "  ${GREEN}./update.sh${NC}   - Atualizar"
    echo ""
    echo -e "${YELLOW}🔧 Gerenciamento Global:${NC}"
    echo -e "  ${GREEN}manage-apps${NC}         - Menu interativo"
    echo -e "  ${GREEN}manage-apps list${NC}    - Listar todas apps"
    echo -e "  ${GREEN}manage-apps logs $APP_NAME${NC} - Ver logs"
    echo ""
    
    # Testar health check
    if curl -sf http://localhost:$PORT/health > /dev/null 2>&1; then
        success "Health check passou! ✅"
    else
        warning "Health check falhou - aguarde alguns segundos e tente novamente"
    fi
    
    echo ""
    echo -e "${BLUE}💡 Dica: Use ${GREEN}docker-compose logs -f${NC}${BLUE} para ver logs em tempo real${NC}"
    echo ""
    
else
    error "Falha ao iniciar aplicação! Verifique os logs."
    docker-compose logs
    exit 1
fi
