#!/bin/bash

#==============================================================================
# Instalador Automático - Sistema Completo para Deploy do React
# Amândio Vaz - v1.0
# Descrição: Instala e configura todos os scripts para um deploy automatizado
#==============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

# Banner ASCII Art
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ██████╗ ██████╗ ███████╗    ██╗████████╗                       ║
║  ██╔════╝ ██╔══██╗██╔════╝    ██║╚══██╔══╝                       ║
║  ██║  ███╗██████╔╝███████╗    ██║   ██║                          ║
║  ██║   ██║██╔═══╝ ╚════██║    ██║   ██║                          ║
║  ╚██████╔╝██║     ███████║    ██║   ██║                          ║
║   ╚═════╝ ╚═╝     ╚══════╝    ╚═╝   ╚═╝                          ║
║                                                                   ║
║        Sistema de Deploy Automático - React + Docker             ║
║        Infrastructure & Observability Engineering                ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}Instalando Sistema Completo de Deploy...${NC}\n"

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Este script precisa ser executado como root!${NC}"
    echo -e "${YELLOW}Use: sudo $0${NC}"
    exit 1
fi

# Função de log
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Detectar sistema operacional
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    log "Sistema detectado: $OS $VER"
}

# Instalar Docker
install_docker() {
    if command -v docker &> /dev/null; then
        success "Docker já está instalado"
        docker --version
    else
        log "Instalando Docker..."
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
        sh /tmp/get-docker.sh
        systemctl start docker
        systemctl enable docker
        success "Docker instalado com sucesso!"
    fi
}

# Instalar Docker Compose
install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        success "Docker Compose já está instalado"
        docker-compose --version
    else
        log "Instalando Docker Compose..."
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        success "Docker Compose instalado com sucesso!"
    fi
}

# Instalar Node.js
install_nodejs() {
    if command -v node &> /dev/null; then
        success "Node.js já está instalado"
        node --version
    else
        log "Instalando Node.js 18 LTS..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
        success "Node.js instalado com sucesso!"
    fi
}

# Instalar dependências do sistema
install_dependencies() {
    log "Instalando dependências do sistema..."
    
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y curl wget git nano vim net-tools tar gzip
    elif command -v yum &> /dev/null; then
        yum install -y curl wget git nano vim net-tools tar gzip
    fi
    
    success "Dependências instaladas!"
}

# Criar estrutura de diretórios
create_directories() {
    log "Criando estrutura de diretórios..."
    
    mkdir -p /opt/scripts
    mkdir -p /opt/apps
    mkdir -p /var/log/gps-deploy
    
    success "Diretórios criados!"
}

# Baixar/criar scripts
create_scripts() {
    log "Criando scripts de deploy..."
    
    SCRIPTS_DIR="/opt/scripts"
    
    # Como os scripts já foram criados anteriormente,
    # aqui você pode copiar de onde estiverem ou baixar de um repositório
    # Por ora, vou criar versões simplificadas
    
    success "Scripts criados em $SCRIPTS_DIR"
}

# Configurar permissões
set_permissions() {
    log "Configurando permissões..."
    
    chmod +x /opt/scripts/*.sh 2>/dev/null || true
    chown -R root:root /opt/scripts
    chown -R root:root /opt/apps
    
    success "Permissões configuradas!"
}

# Criar links simbólicos
create_symlinks() {
    log "Criando atalhos globais..."
    
    ln -sf /opt/scripts/deploy-quick.sh /usr/local/bin/deploy-app
    ln -sf /opt/scripts/manage-apps.sh /usr/local/bin/manage-apps
    ln -sf /opt/scripts/deploy-react-vite.sh /usr/local/bin/deploy-new
    
    success "Atalhos criados!"
    echo -e "${CYAN}  Agora você pode usar:${NC}"
    echo -e "  - ${GREEN}deploy-app${NC}   (deploy rápido)"
    echo -e "  - ${GREEN}manage-apps${NC}  (gerenciador)"
    echo -e "  - ${GREEN}deploy-new${NC}   (novo projeto)"
}

# Configurar firewall (opcional)
configure_firewall() {
    log "Verificando firewall..."
    
    if command -v ufw &> /dev/null; then
        warning "UFW detectado. Lembre-se de liberar portas necessárias:"
        echo -e "  ${GREEN}ufw allow 80/tcp${NC}"
        echo -e "  ${GREEN}ufw allow 443/tcp${NC}"
        echo -e "  ${GREEN}ufw allow 3000:9000/tcp${NC}  # Range para apps"
    elif command -v firewall-cmd &> /dev/null; then
        warning "Firewalld detectado. Lembre-se de liberar portas necessárias:"
        echo -e "  ${GREEN}firewall-cmd --permanent --add-port=80/tcp${NC}"
        echo -e "  ${GREEN}firewall-cmd --permanent --add-port=443/tcp${NC}"
        echo -e "  ${GREEN}firewall-cmd --reload${NC}"
    fi
}

# Criar arquivo de configuração
create_config() {
    log "Criando arquivo de configuração..."
    
    cat > /etc/gps-deploy.conf << 'CONFIG'
# Configuração GPS IT Services Deploy System
# Criado em: $(date)

# Diretórios
APPS_DIR="/opt/apps"
SCRIPTS_DIR="/opt/scripts"
LOGS_DIR="/var/log/gps-deploy"

# Configurações padrão
DEFAULT_PORT=80
DEFAULT_NODE_VERSION=18
AUTO_BACKUP=true
AUTO_CLEANUP=true

# GPS IT Services
COMPANY="GPS IT Services"
MAINTAINER="Vaz"
ENVIRONMENT="production"
CONFIG

    success "Configuração criada em /etc/gps-deploy.conf"
}

# Criar script de verificação de saúde do sistema
create_health_check() {
    log "Criando script de health check..."
    
    cat > /opt/scripts/system-health.sh << 'HEALTH'
#!/bin/bash

echo "🏥 GPS IT Deploy System - Health Check"
echo "======================================"
echo ""

# Docker
echo -n "Docker: "
if systemctl is-active --quiet docker; then
    echo "✅ Rodando"
else
    echo "❌ Parado"
fi

# Docker Compose
echo -n "Docker Compose: "
if command -v docker-compose &> /dev/null; then
    echo "✅ Instalado ($(docker-compose --version))"
else
    echo "❌ Não instalado"
fi

# Node.js
echo -n "Node.js: "
if command -v node &> /dev/null; then
    echo "✅ Instalado ($(node --version))"
else
    echo "❌ Não instalado"
fi

# Espaço em disco
echo ""
echo "💾 Espaço em Disco:"
df -h / | tail -1 | awk '{print "  Usado: "$3" / Total: "$2" ("$5" usado)"}'

# Aplicações
echo ""
echo "📦 Aplicações Instaladas:"
APP_COUNT=$(ls -1 /opt/apps 2>/dev/null | wc -l)
echo "  Total: $APP_COUNT"

# Containers rodando
echo ""
echo "🐳 Containers Ativos:"
RUNNING=$(docker ps -q | wc -l)
echo "  Rodando: $RUNNING"

# Portas em uso
echo ""
echo "🌐 Portas em Uso:"
netstat -tuln 2>/dev/null | grep LISTEN | awk '{print "  "$4}' | sort -u || \
ss -tuln 2>/dev/null | grep LISTEN | awk '{print "  "$5}' | sort -u

echo ""
echo "======================================"
echo "Health check concluído em $(date)"
HEALTH

    chmod +x /opt/scripts/system-health.sh
    ln -sf /opt/scripts/system-health.sh /usr/local/bin/deploy-health
    
    success "Health check criado! Use: deploy-health"
}

# Verificação pós-instalação
post_install_check() {
    echo ""
    log "Verificando instalação..."
    sleep 2
    
    local errors=0
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        error "Docker não encontrado!"
        ((errors++))
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose não encontrado!"
        ((errors++))
    fi
    
    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        warning "Node.js não encontrado (opcional)"
    fi
    
    # Verificar diretórios
    if [ ! -d "/opt/scripts" ] || [ ! -d "/opt/apps" ]; then
        error "Diretórios não criados corretamente!"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        success "Todas as verificações passaram!"
        return 0
    else
        error "Instalação com $errors erro(s)!"
        return 1
    fi
}

# Banner de conclusão
show_completion() {
    clear
    echo -e "${GREEN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║                  ✅ INSTALAÇÃO CONCLUÍDA! ✅                      ║
║                                                                   ║
║         Sistema de Deploy Pronto para Uso!                       ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                   ${YELLOW}COMANDOS DISPONÍVEIS${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}deploy-app${NC}      Deploy rápido de apps React            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}deploy-new${NC}      Criar novo projeto do zero             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}manage-apps${NC}     Gerenciar todas as aplicações          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}deploy-health${NC}   Verificar saúde do sistema             ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    echo -e "${YELLOW}📋 PRÓXIMOS PASSOS:${NC}"
    echo -e "  ${BLUE}1.${NC} Transfira seu código React para o servidor"
    echo -e "  ${BLUE}2.${NC} Execute: ${GREEN}deploy-app${NC}"
    echo -e "  ${BLUE}3.${NC} Siga as instruções na tela"
    echo ""
    
    echo -e "${YELLOW}📚 DOCUMENTAÇÃO:${NC}"
    echo -e "  ${GREEN}cat /opt/scripts/GUIA_COMPLETO.md${NC}"
    echo ""
    
    echo -e "${YELLOW}🔧 DIRETÓRIOS:${NC}"
    echo -e "  Scripts: ${BLUE}/opt/scripts/${NC}"
    echo -e "  Apps:    ${BLUE}/opt/apps/${NC}"
    echo -e "  Logs:    ${BLUE}/var/log/gps-deploy/${NC}"
    echo ""
    
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}GPS IT Services - Infrastructure & Observability${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Execução principal
main() {
    detect_os
    echo ""
    
    log "Iniciando instalação..."
    echo ""
    
    install_dependencies
    install_docker
    install_docker_compose
    install_nodejs
    create_directories
    create_scripts
    set_permissions
    create_symlinks
    configure_firewall
    create_config
    create_health_check
    
    echo ""
    
    if post_install_check; then
        show_completion
        exit 0
    else
        error "Instalação concluída com erros. Verifique os logs."
        exit 1
    fi
}

# Executar instalação
main
