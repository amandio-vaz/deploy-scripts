#!/bin/bash

################################################################################
#                                                                              #
#                  🚀 CORTEX MyFuckExam - AUTO DEPLOY v1.0                   #
#                                                                              #
#  Deploy automático completo com validação,  backup,  build e inicialização   #
#                                                                              #
################################################################################

set -e

# ============ CONFIGURAÇÕES ============
APP_NAME="MyFuckExam"
APP_PATH="/opt/docker/apps/cortex/myfuckexam"
BACKEND_PATH="${APP_PATH}/backend"
FRONTEND_PATH="${APP_PATH}/frontend"
SCRIPTS_PATH="${APP_PATH}/scripts"
LOGS_PATH="${APP_PATH}/logs"
BACKUPS_PATH="${APP_PATH}/backups"
ENV_FILE="${APP_PATH}/.env"
LOG_FILE="${LOGS_PATH}/deploy-$(date +%Y%m%d-%H%M%S).log"
DOCKER_COMPOSE="docker-compose"
MAX_DEPLOY_TIME=600  # 10 minutos

# ============ CORES ============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ============ INÍCIO ============

clear

# ASCII Art
cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║           🚀 CORTEX MyFuckExam - AUTO DEPLOY AUTOMATION 🚀                 ║
║                                                                              ║
║                    Deploy Completo em Um Único Comando                       ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

sleep 1

# ============ FUNÇÕES DE LOG ============

init_logging() {
    mkdir -p "$LOGS_PATH"
    exec 1> >(tee -a "$LOG_FILE")
    exec 2>&1
}

log_section() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n${MAGENTA}[${timestamp}]${NC} ${BLUE}▶ $1${NC}"
    echo "═══════════════════════════════════════════════════════════════"
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

log_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

log_spinner() {
    local pid=$1
    local task=$2
    local spinner=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )
    local i=0
    
    echo -ne "${CYAN}${task}${NC}"
    
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\b${spinner[$i]}"
        ((i++))
        ((i %= ${#spinner[@]}))
        sleep 0.1
    done
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -ne "\b${GREEN}✓${NC}\n"
    else
        echo -ne "\b${RED}✗${NC}\n"
    fi
    
    return $exit_code
}

# ============ PRÉ-VALIDAÇÕES ============

validate_system() {
    log_section "🔍 VALIDANDO SISTEMA"

    # Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker não instalado"
        exit 1
    fi
    DOCKER_VERSION=$(docker --version | awk '{print $NF}')
    log_success "Docker: $DOCKER_VERSION"

    # Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose não instalado"
        exit 1
    fi
    DC_VERSION=$(docker-compose --version | awk '{print $NF}')
    log_success "Docker Compose: $DC_VERSION"

    # Git
    if command -v git &> /dev/null; then
        log_success "Git: $(git --version | awk '{print $NF}')"
    else
        log_warning "Git não encontrado (opcional)"
    fi

    # Diretórios
    if [ ! -d "$APP_PATH" ]; then
        log_error "Diretório não encontrado: $APP_PATH"
        exit 1
    fi
    log_success "Diretório: $APP_PATH"

    # Permissões
    if [ ! -w "$APP_PATH" ]; then
        log_error "Sem permissão de escrita em: $APP_PATH"
        exit 1
    fi
    log_success "Permissões: OK"

    # Espaço em disco
    AVAILABLE=$(df "$APP_PATH" | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE" -lt 524288 ]; then  # < 512MB
        log_warning "Espaço em disco baixo: ${AVAILABLE}KB"
    else
        if command -v bc &> /dev/null; then
            AVAILABLE_GB=$(echo "scale=2; $AVAILABLE / 1048576" | bc)
        else
            AVAILABLE_GB=$(awk "BEGIN {printf \"%.2f\", $AVAILABLE/1048576}")
        fi
        log_success "Espaço em disco: ${AVAILABLE_GB}GB"
    fi

    # Portas
    if netstat -tuln 2>/dev/null | grep -q ':80 '; then
        log_warning "Porta 80 já em uso"
    else
        log_success "Porta 80: Disponível"
    fi

    if netstat -tuln 2>/dev/null | grep -q ':3001 '; then
        log_warning "Porta 3001 já em uso"
    else
        log_success "Porta 3001: Disponível"
    fi
}

# ============ SETUP ============

setup_directories() {
    log_section "📁 CRIANDO ESTRUTURA DE DIRETÓRIOS"

    mkdir -p "$LOGS_PATH"
    log_success "Logs: $LOGS_PATH"

    mkdir -p "$BACKUPS_PATH"
    log_success "Backups: $BACKUPS_PATH"

    mkdir -p "$SCRIPTS_PATH"
    log_success "Scripts: $SCRIPTS_PATH"

    mkdir -p "${BACKEND_PATH}/src"
    log_success "Backend: $BACKEND_PATH"

    mkdir -p "${FRONTEND_PATH}/src"
    log_success "Frontend: $FRONTEND_PATH"
}

setup_environment() {
    log_section "🔧 CONFIGURANDO AMBIENTE"

    if [ ! -f "$ENV_FILE" ]; then
        if [ -f "${APP_PATH}/.env.example" ]; then
            cp "${APP_PATH}/.env.example" "$ENV_FILE"
            log_success ".env criado"
        else
            log_error ".env.example não encontrado"
            exit 1
        fi
    else
        log_info ".env já existe"
    fi

    # Verificar se GEMINI_API_KEY está preenchida
    if grep -q "GEMINI_API_KEY=sua_chave_aqui" "$ENV_FILE"; then
        log_warning "GEMINI_API_KEY ainda com valor placeholder"
        log_info "Digite sua chave API do Gemini: "
        read -p "GEMINI_API_KEY: " api_key
        
        if [ -z "$api_key" ]; then
            log_error "Chave API não pode estar vazia"
            exit 1
        fi
        
        # Backup do .env antigo
        cp "$ENV_FILE" "${ENV_FILE}.bak"
        
        # Atualizar .env
        sed -i "s|GEMINI_API_KEY=sua_chave_aqui|GEMINI_API_KEY=$api_key|g" "$ENV_FILE"
        log_success "GEMINI_API_KEY configurada"
    else
        log_success "GEMINI_API_KEY já configurada"
    fi

    # Carregar variáveis
    source "$ENV_FILE"
    log_success "Variáveis carregadas"
}

# ============ BACKUP ============

create_backup() {
    log_section "💾 CRIANDO BACKUP"

    local backup_file="$BACKUPS_PATH/myfuckexam-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    # Arquivos para backup
    tar -czf "$backup_file" \
        -C "$APP_PATH" \
        docker-compose.yml \
        .env \
        .env.bak \
        2>/dev/null || true

    if [ -f "$backup_file" ]; then
        local size=$(du -h "$backup_file" | awk '{print $1}')
        log_success "Backup: $backup_file ($size)"
        
        # Limpar backups antigos (manter últimos 5)
        cd "$BACKUPS_PATH"
        ls -t myfuckexam-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f
        log_info "Limpeza de backups antigos concluída"
    else
        log_warning "Falha ao criar backup (não crítico)"
    fi
}

# ============ PARAR CONTAINERS ANTIGOS ============

stop_containers() {
    log_section "🛑 PARANDO CONTAINERS ANTIGOS"

    cd "$APP_PATH"

    if docker-compose ps 2>/dev/null | grep -q "Up"; then
        log_info "Containers rodando detectados..."
        
        # Graceful shutdown
        docker-compose down --remove-orphans 2>/dev/null &
        local pid=$!
        log_spinner $pid "  Encerrando containers..."
        
        if [ $? -eq 0 ]; then
            log_success "Containers parados"
            sleep 2
        else
            log_warning "Erro ao parar containers (continuando)"
        fi
    else
        log_info "Nenhum container rodando"
    fi
}

# ============ CLEANUP DE IMAGENS ============

cleanup_images() {
    log_section "🧹 LIMPANDO IMAGENS ANTIGAS"

    # Remover images dangling
    docker image prune -f --filter "dangling=true" > /dev/null 2>&1 || true
    log_success "Imagens dangling removidas"

    # Remover volumes não utilizados (opcional)
    if [ "$1" == "aggressive" ]; then
        docker volume prune -f > /dev/null 2>&1 || true
        log_success "Volumes não utilizados removidos"
    fi
}

# ============ BUILD DE IMAGENS ============

build_backend() {
    log_section "🏗️ BUILDANDO BACKEND"

    cd "$BACKEND_PATH"

    log_info "Backend..."
    docker build -t cortex/myfuckexam-backend:latest . > /tmp/backend-build.log 2>&1 &
    local pid=$!
    log_spinner $pid "  Buildando backend..."

    if [ $? -eq 0 ]; then
        log_success "Backend buildado com sucesso"
        
        # Tag com timestamp
        local tag=$(date +%Y%m%d-%H%M%S)
        docker tag cortex/myfuckexam-backend:latest "cortex/myfuckexam-backend:${tag}" 2>/dev/null || true
        log_info "  Tag: ${tag}"
    else
        log_error "Erro ao buildar backend"
        cat /tmp/backend-build.log
        exit 1
    fi
}

build_frontend() {
    log_section "🏗️ BUILDANDO FRONTEND"

    cd "$FRONTEND_PATH"

    log_info "Frontend..."
    docker build -t cortex/myfuckexam-frontend:latest . > /tmp/frontend-build.log 2>&1 &
    local pid=$!
    log_spinner $pid "  Buildando frontend..."

    if [ $? -eq 0 ]; then
        log_success "Frontend buildado com sucesso"
        
        # Tag com timestamp
        local tag=$(date +%Y%m%d-%H%M%S)
        docker tag cortex/myfuckexam-frontend:latest "cortex/myfuckexam-frontend:${tag}" 2>/dev/null || true
        log_info "  Tag: ${tag}"
    else
        log_error "Erro ao buildar frontend"
        cat /tmp/frontend-build.log
        exit 1
    fi
}

# ============ INICIAR CONTAINERS ============

start_containers() {
    log_section "🚀 INICIANDO CONTAINERS"

    cd "$APP_PATH"

    docker-compose up -d 2>&1 &
    local pid=$!
    log_spinner $pid "  Iniciando containers..."

    if [ $? -eq 0 ]; then
        log_success "Containers iniciados"
        sleep 5
    else
        log_error "Erro ao iniciar containers"
        exit 1
    fi
}

# ============ HEALTH CHECK ============

health_check() {
    log_section "💚 VERIFICANDO SAÚDE DOS SERVIÇOS"

    local max_attempts=60
    local attempt=0
    local backend_ok=false
    local frontend_ok=false

    # Backend
    log_info "Aguardando Backend..."
    while [ $attempt -lt $max_attempts ]; do
        if curl -sf http://localhost:3001/health > /dev/null 2>&1; then
            log_success "Backend respondendo"
            backend_ok=true
            break
        fi
        echo -ne "."
        attempt=$((attempt + 1))
        sleep 1
    done
    echo ""

    if [ "$backend_ok" = false ]; then
        log_error "Backend não respondeu após ${max_attempts}s"
        log_info "Logs do Backend: "
        docker-compose logs backend | tail -20
        exit 1
    fi

    # Frontend
    attempt=0
    log_info "Aguardando Frontend..."
    while [ $attempt -lt $max_attempts ]; do
        if curl -sf http://localhost/health > /dev/null 2>&1; then
            log_success "Frontend respondendo"
            frontend_ok=true
            break
        fi
        echo -ne "."
        attempt=$((attempt + 1))
        sleep 1
    done
    echo ""

    if [ "$frontend_ok" = false ]; then
        log_error "Frontend não respondeu após ${max_attempts}s"
        log_info "Logs do Frontend: "
        docker-compose logs frontend | tail -20
        exit 1
    fi

    log_success "Todos os serviços estão saudáveis! ✓"
}

# ============ TESTES BÁSICOS ============

run_tests() {
    log_section "🧪 EXECUTANDO TESTES BÁSICOS"

    # API endpoint
    log_info "Testando API..."
    if curl -sf http://localhost/api > /dev/null 2>&1; then
        log_success "API respondendo"
    else
        log_warning "API não respondendo (não crítico)"
    fi

    # Frontend assets
    log_info "Testando assets..."
    if curl -sf http://localhost/index.html > /dev/null 2>&1; then
        log_success "Assets carregando"
    else
        log_warning "Assets não carregando (não crítico)"
    fi

    # Docker stats
    log_info "Recursos em uso: "
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || true
}

# ============ CRIAR SCRIPTS AUXILIARES ============

create_helper_scripts() {
    log_section "📝 CRIANDO SCRIPTS AUXILIARES"

    # Script logs
    cat > "$SCRIPTS_PATH/logs.sh" << 'SCRIPT_EOF'
#!/bin/bash
cd /opt/docker/apps/cortex/myfuckexam
docker-compose logs -f --tail=100 "$@"
SCRIPT_EOF
    chmod +x "$SCRIPTS_PATH/logs.sh"
    log_success "logs.sh criado"

    # Script restart
    cat > "$SCRIPTS_PATH/restart.sh" << 'SCRIPT_EOF'
#!/bin/bash
cd /opt/docker/apps/cortex/myfuckexam
echo "Reiniciando..."
docker-compose restart "$@"
echo "✓ Reiniciado"
SCRIPT_EOF
    chmod +x "$SCRIPTS_PATH/restart.sh"
    log_success "restart.sh criado"

    # Script stop
    cat > "$SCRIPTS_PATH/stop.sh" << 'SCRIPT_EOF'
#!/bin/bash
cd /opt/docker/apps/cortex/myfuckexam
echo "Parando..."
docker-compose down "$@"
echo "✓ Parado"
SCRIPT_EOF
    chmod +x "$SCRIPTS_PATH/stop.sh"
    log_success "stop.sh criado"

    # Script status
    cat > "$SCRIPTS_PATH/status.sh" << 'SCRIPT_EOF'
#!/bin/bash
cd /opt/docker/apps/cortex/myfuckexam
echo "Status dos Containers: "
docker-compose ps
echo ""
echo "Recursos: "
docker stats --no-stream 2>/dev/null || echo "Docker stats não disponível"
SCRIPT_EOF
    chmod +x "$SCRIPTS_PATH/status.sh"
    log_success "status.sh criado"

    # Script backup
    cat > "$SCRIPTS_PATH/backup.sh" << 'SCRIPT_EOF'
#!/bin/bash
cd /opt/docker/apps/cortex/myfuckexam
mkdir -p backups
BACKUP="backups/myfuckexam-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$BACKUP" docker-compose.yml .env 2>/dev/null
echo "✓ Backup: $BACKUP"
du -h "$BACKUP"
SCRIPT_EOF
    chmod +x "$SCRIPTS_PATH/backup.sh"
    log_success "backup.sh criado"

    # Script clean
    cat > "$SCRIPTS_PATH/clean.sh" << 'SCRIPT_EOF'
#!/bin/bash
cd /opt/docker/apps/cortex/myfuckexam
echo "Limpando..."
docker-compose down -v
docker system prune -f
echo "✓ Sistema limpo"
SCRIPT_EOF
    chmod +x "$SCRIPTS_PATH/clean.sh"
    log_success "clean.sh criado"

    # Script git commit
    cat > "$SCRIPTS_PATH/git-commit.sh" << 'SCRIPT_EOF'
#!/bin/bash
cd /opt/docker/apps/cortex/myfuckexam
git add -A
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S')" || true
git push || true
echo "✓ Git sincronizado"
SCRIPT_EOF
    chmod +x "$SCRIPTS_PATH/git-commit.sh"
    log_success "git-commit.sh criado"
}

# ============ CRIAR ALIASES ============

setup_aliases() {
    log_section "🔗 CONFIGURANDO ALIASES"

    local bashrc="$HOME/.bashrc"
    local aliases_marker="# Cortex MyFuckExam Aliases"

    if grep -q "$aliases_marker" "$bashrc"; then
        log_info "Aliases já configurados"
        return
    fi

    cat >> "$bashrc" << 'ALIAS_EOF'

# Cortex MyFuckExam Aliases
alias myfuckexam='cd /opt/docker/apps/cortex/myfuckexam'
alias myfuckexam-deploy='/opt/docker/apps/cortex/myfuckexam/auto-deploy.sh'
alias myfuckexam-logs='/opt/docker/apps/cortex/myfuckexam/scripts/logs.sh'
alias myfuckexam-status='/opt/docker/apps/cortex/myfuckexam/scripts/status.sh'
alias myfuckexam-restart='/opt/docker/apps/cortex/myfuckexam/scripts/restart.sh'
alias myfuckexam-stop='/opt/docker/apps/cortex/myfuckexam/scripts/stop.sh'
alias myfuckexam-backup='/opt/docker/apps/cortex/myfuckexam/scripts/backup.sh'
alias myfuckexam-clean='/opt/docker/apps/cortex/myfuckexam/scripts/clean.sh'
ALIAS_EOF

    log_success "Aliases adicionados a ~/.bashrc"
    log_info "Execute: source ~/.bashrc"
}

# ============ INFORMAÇÕES FINAIS ============

show_summary() {
    log_section "✨ DEPLOY CONCLUÍDO COM SUCESSO!"

    echo -e "\n${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  STATUS: ONLINE ✓${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}\n"

    # Status dos containers
    log_info "Status dos Containers: "
    cd "$APP_PATH"
    docker-compose ps | tail -n +3 | sed 's/^/  /'

    echo ""
    log_info "Acessar Serviços: "
    echo -e "  Frontend:       ${CYAN}http://localhost${NC}"
    echo -e "  Backend:        ${CYAN}http://localhost:3001${NC}"
    echo -e "  API:            ${CYAN}http://localhost/api${NC}"

    echo ""
    log_info "Arquivos Importantes: "
    echo -e "  Logs Deploy:    ${CYAN}$LOG_FILE${NC}"
    echo -e "  Env File:       ${CYAN}$ENV_FILE${NC}"
    echo -e "  Backups:        ${CYAN}$BACKUPS_PATH${NC}"
    echo -e "  Scripts:        ${CYAN}$SCRIPTS_PATH${NC}"

    echo ""
    log_info "Comandos Rápidos: "
    echo -e "  Ver logs:       ${CYAN}myfuckexam-logs${NC}"
    echo -e "  Status:         ${CYAN}myfuckexam-status${NC}"
    echo -e "  Restart:        ${CYAN}myfuckexam-restart${NC}"
    echo -e "  Stop:           ${CYAN}myfuckexam-stop${NC}"
    echo -e "  Deploy novo:    ${CYAN}./auto-deploy.sh${NC}"

    echo ""
    log_info "Próximas Ações Recomendadas: "
    echo -e "  1. ${CYAN}Testar${NC} aplicação em http://localhost"
    echo -e "  2. ${CYAN}Verificar${NC} logs: ${YELLOW}myfuckexam-logs backend${NC}"
    echo -e "  3. ${CYAN}Monitorar${NC} recursos: ${YELLOW}myfuckexam-status${NC}"
    echo -e "  4. ${CYAN}Configurar${NC} domínio/SSL em produção"
    echo -e "  5. ${CYAN}Ativar${NC} sistema de backup automático"

    echo ""
    log_success "Tempo total: $((SECONDS / 60))m $((SECONDS % 60))s"
    echo -e "\n${GREEN}════════════════════════════════════════════════════════════════${NC}\n"
}

# ============ ERROR HANDLING ============

handle_error() {
    local line_number=$1
    log_error "Erro na linha $line_number"
    log_error "Deploy falhou!"
    echo -e "\n${RED}Verifique o log: ${NC} $LOG_FILE"
    exit 1
}

trap 'handle_error ${LINENO}' ERR

# ============ MAIN FLOW ============

main() {
    local start_time=$SECONDS

    init_logging

    log_section "🎯 INICIANDO DEPLOY AUTOMÁTICO"

    # 1. Validações
    validate_system

    # 2. Setup
    setup_directories
    setup_environment

    # 3. Preparação
    create_backup
    stop_containers
    cleanup_images

    # 4. Build
    build_backend
    build_frontend

    # 5. Deploy
    start_containers

    # 6. Validação
    health_check
    run_tests

    # 7. Finalização
    create_helper_scripts
    setup_aliases

    show_summary
}

# ============ EXECUTAR ============

main "$@"

exit 0
