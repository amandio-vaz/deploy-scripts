#!/bin/bash

#==============================================================================
# Script de Gerenciamento de Aplicações
# Autor: Amandio Vaz
# Descrição: Gerenciar múltiplas aplicações React no servidor
#==============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

APPS_DIR="/opt/apps"

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║            Gerenciador de Aplicações React + Docker       ║
║                       Amândio Vaz                         ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Listar todas as aplicações
list_apps() {
    echo -e "${BLUE}📋 Aplicações Instaladas:${NC}\n"
    
    if [ ! -d "$APPS_DIR" ] || [ -z "$(ls -A $APPS_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}  Nenhuma aplicação encontrada.${NC}"
        return
    fi
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYAN}║${NC} %-20s ${CYAN}║${NC} %-15s ${CYAN}║${NC} %-15s ${CYAN}║${NC}\n" "APLICAÇÃO" "STATUS" "PORTA"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    
    for app_dir in "$APPS_DIR"/*; do
        if [ -d "$app_dir" ] && [ -f "$app_dir/docker-compose.yml" ]; then
            app_name=$(basename "$app_dir")
            
            # Verificar status
            cd "$app_dir"
            if docker-compose ps | grep -q "Up"; then
                status="${GREEN}ONLINE${NC}"
            else
                status="${RED}OFFLINE${NC}"
            fi
            
            # Extrair porta
            port=$(grep -oP 'ports:.*?\K\d+(?=:80)' docker-compose.yml | head -1)
            
            printf "${CYAN}║${NC} %-20s ${CYAN}║${NC} %-24s ${CYAN}║${NC} %-15s ${CYAN}║${NC}\n" "$app_name" "$status" "$port"
        fi
    done
    
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

# Mostrar status detalhado de uma aplicação
show_status() {
    local app_name=$1
    local app_dir="$APPS_DIR/$app_name"
    
    if [ ! -d "$app_dir" ]; then
        echo -e "${RED}❌ Aplicação '$app_name' não encontrada!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📊 Status da Aplicação: ${GREEN}$app_name${NC}\n"
    
    cd "$app_dir"
    
    echo -e "${CYAN}Containers:${NC}"
    docker-compose ps
    
    echo -e "\n${CYAN}Recursos (CPU/Memória):${NC}"
    docker stats --no-stream $(docker-compose ps -q)
    
    echo -e "\n${CYAN}Portas Expostas:${NC}"
    docker-compose port frontend 80 2>/dev/null || echo "  Nenhuma porta exposta"
    
    echo -e "\n${CYAN}Health Check:${NC}"
    local port=$(grep -oP 'ports:.*?\K\d+(?=:80)' docker-compose.yml | head -1)
    curl -s http://localhost:$port/health && echo " ✅" || echo " ❌"
}

# Iniciar aplicação
start_app() {
    local app_name=$1
    local app_dir="$APPS_DIR/$app_name"
    
    if [ ! -d "$app_dir" ]; then
        echo -e "${RED}❌ Aplicação '$app_name' não encontrada!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🚀 Iniciando: ${GREEN}$app_name${NC}"
    cd "$app_dir"
    docker-compose up -d
    echo -e "${GREEN}✅ Aplicação iniciada!${NC}"
}

# Parar aplicação
stop_app() {
    local app_name=$1
    local app_dir="$APPS_DIR/$app_name"
    
    if [ ! -d "$app_dir" ]; then
        echo -e "${RED}❌ Aplicação '$app_name' não encontrada!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🛑 Parando: ${YELLOW}$app_name${NC}"
    cd "$app_dir"
    docker-compose down
    echo -e "${GREEN}✅ Aplicação parada!${NC}"
}

# Reiniciar aplicação
restart_app() {
    local app_name=$1
    local app_dir="$APPS_DIR/$app_name"
    
    if [ ! -d "$app_dir" ]; then
        echo -e "${RED}❌ Aplicação '$app_name' não encontrada!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔄 Reiniciando: ${GREEN}$app_name${NC}"
    cd "$app_dir"
    docker-compose restart
    echo -e "${GREEN}✅ Aplicação reiniciada!${NC}"
}

# Ver logs
view_logs() {
    local app_name=$1
    local app_dir="$APPS_DIR/$app_name"
    
    if [ ! -d "$app_dir" ]; then
        echo -e "${RED}❌ Aplicação '$app_name' não encontrada!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📜 Logs de: ${GREEN}$app_name${NC}"
    echo -e "${YELLOW}(Pressione Ctrl+C para sair)${NC}\n"
    cd "$app_dir"
    docker-compose logs -f --tail=100
}

# Remover aplicação
remove_app() {
    local app_name=$1
    local app_dir="$APPS_DIR/$app_name"
    
    if [ ! -d "$app_dir" ]; then
        echo -e "${RED}❌ Aplicação '$app_name' não encontrada!${NC}"
        return 1
    fi
    
    echo -e "${RED}⚠️  ATENÇÃO: Você está prestes a REMOVER completamente a aplicação '$app_name'${NC}"
    read -p "Digite 'CONFIRMAR' para continuar: " confirmacao
    
    if [ "$confirmacao" != "CONFIRMAR" ]; then
        echo -e "${YELLOW}❌ Remoção cancelada.${NC}"
        return 0
    fi
    
    echo -e "${BLUE}🗑️  Removendo: ${RED}$app_name${NC}"
    cd "$app_dir"
    
    # Parar e remover containers
    docker-compose down -v
    
    # Criar backup antes de remover
    echo -e "${BLUE}💾 Criando backup antes de remover...${NC}"
    tar -czf "/tmp/${app_name}_backup_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$APPS_DIR" "$app_name"
    
    # Remover diretório
    cd "$APPS_DIR"
    rm -rf "$app_dir"
    
    echo -e "${GREEN}✅ Aplicação removida! Backup salvo em /tmp/${NC}"
}

# Iniciar todas as aplicações
start_all() {
    echo -e "${BLUE}🚀 Iniciando todas as aplicações...${NC}\n"
    
    for app_dir in "$APPS_DIR"/*; do
        if [ -d "$app_dir" ] && [ -f "$app_dir/docker-compose.yml" ]; then
            app_name=$(basename "$app_dir")
            start_app "$app_name"
        fi
    done
    
    echo -e "\n${GREEN}✅ Todas as aplicações foram iniciadas!${NC}"
}

# Parar todas as aplicações
stop_all() {
    echo -e "${BLUE}🛑 Parando todas as aplicações...${NC}\n"
    
    for app_dir in "$APPS_DIR"/*; do
        if [ -d "$app_dir" ] && [ -f "$app_dir/docker-compose.yml" ]; then
            app_name=$(basename "$app_dir")
            stop_app "$app_name"
        fi
    done
    
    echo -e "\n${GREEN}✅ Todas as aplicações foram paradas!${NC}"
}

# Menu interativo
show_menu() {
    show_banner
    list_apps
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${YELLOW}MENU PRINCIPAL${NC}                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}1${NC}) Listar todas as aplicações                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}2${NC}) Mostrar status de uma aplicação                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}3${NC}) Iniciar aplicação                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}4${NC}) Parar aplicação                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}5${NC}) Reiniciar aplicação                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}6${NC}) Ver logs de aplicação                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}7${NC}) Remover aplicação                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}8${NC}) Iniciar TODAS as aplicações                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}9${NC}) Parar TODAS as aplicações                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}0${NC}) Sair                                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Menu principal
main() {
    if [ "$#" -eq 0 ]; then
        # Modo interativo
        while true; do
            show_menu
            read -p "Escolha uma opção: " opcao
            
            case $opcao in
                1)
                    show_banner
                    list_apps
                    read -p "Pressione Enter para continuar..."
                    ;;
                2)
                    read -p "Nome da aplicação: " app_name
                    show_status "$app_name"
                    read -p "Pressione Enter para continuar..."
                    ;;
                3)
                    read -p "Nome da aplicação: " app_name
                    start_app "$app_name"
                    read -p "Pressione Enter para continuar..."
                    ;;
                4)
                    read -p "Nome da aplicação: " app_name
                    stop_app "$app_name"
                    read -p "Pressione Enter para continuar..."
                    ;;
                5)
                    read -p "Nome da aplicação: " app_name
                    restart_app "$app_name"
                    read -p "Pressione Enter para continuar..."
                    ;;
                6)
                    read -p "Nome da aplicação: " app_name
                    view_logs "$app_name"
                    ;;
                7)
                    read -p "Nome da aplicação: " app_name
                    remove_app "$app_name"
                    read -p "Pressione Enter para continuar..."
                    ;;
                8)
                    start_all
                    read -p "Pressione Enter para continuar..."
                    ;;
                9)
                    stop_all
                    read -p "Pressione Enter para continuar..."
                    ;;
                0)
                    echo -e "${GREEN}👋 Até logo!${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}❌ Opção inválida!${NC}"
                    sleep 2
                    ;;
            esac
        done
    else
        # Modo linha de comando
        comando=$1
        app_name=$2
        
        case $comando in
            list|ls)
                list_apps
                ;;
            status)
                show_status "$app_name"
                ;;
            start)
                start_app "$app_name"
                ;;
            stop)
                stop_app "$app_name"
                ;;
            restart)
                restart_app "$app_name"
                ;;
            logs)
                view_logs "$app_name"
                ;;
            remove)
                remove_app "$app_name"
                ;;
            start-all)
                start_all
                ;;
            stop-all)
                stop_all
                ;;
            *)
                echo -e "${RED}Comando inválido!${NC}"
                echo ""
                echo "Uso: $0 [comando] [nome-da-app]"
                echo ""
                echo "Comandos disponíveis:"
                echo "  list              - Listar todas as aplicações"
                echo "  status <app>      - Status de uma aplicação"
                echo "  start <app>       - Iniciar aplicação"
                echo "  stop <app>        - Parar aplicação"
                echo "  restart <app>     - Reiniciar aplicação"
                echo "  logs <app>        - Ver logs"
                echo "  remove <app>      - Remover aplicação"
                echo "  start-all         - Iniciar todas"
                echo "  stop-all          - Parar todas"
                echo ""
                echo "Sem argumentos: modo interativo"
                exit 1
                ;;
        esac
    fi
}

# Executar
main "$@"
