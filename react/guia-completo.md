# Guia Completo - Deploy Automático React + Vite + Docker

**Autor: Amândio Vaz**

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Instalação](#instalação)
4. [Uso dos Scripts](#uso-dos-scripts)
5. [Exemplos Práticos](#exemplos-práticos)
6. [Gerenciamento de Aplicações](#gerenciamento-de-aplicações)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

---

## 🎯 Visão Geral

Este conjunto de scripts automatiza completamente o deploy de aplicações React no Docker, especialmente projetado para aplicações agênticas*.

### Características:

✅ Deploy totalmente automatizado  
✅ Suporte a Vite e Create React App  
✅ Configuração Nginx otimizada  
✅ Health checks automatizados  
✅ Scripts de gerenciamento inclusos  
✅ Backup automático  
✅ Multi-aplicações no mesmo servidor  

---

## 🔧 Pré-requisitos

### Sistema Operacional
- Ubuntu 22.04+ / Debian 12+
- RHEL 7+
- Qualquer Linux com Docker

### Requisitos Mínimos
- 1 CPU
- 1 GB RAM
- 10 GB disco
- Acesso root/sudo

---

## 📥 Instalação

### Passo 1: Conectar ao Servidor

```bash
ssh root@seu-servidor.com
# ou
ssh seu-usuario@seu-servidor.com
sudo su
```

### Passo 2: Baixar os Scripts

```bash
# Criar diretório para scripts
mkdir -p /opt/scripts
cd /opt/scripts

# Baixar scripts (ajuste os comandos conforme você disponibilizar os arquivos)
# Opção 1: Se estiver em repositório Git
git clone https://github.com/seu-usuario/deploy-scripts.git
cd deploy-scripts

# Opção 2: Download direto (se você hospedar)
wget https://seu-site.com/deploy-react-vite.sh
wget https://seu-site.com/deploy-quick.sh
wget https://seu-site.com/manage-apps.sh

# Opção 3: Copiar manualmente via SCP
# No seu computador local:
scp deploy-react-vite.sh root@seu-servidor:/opt/scripts/
scp deploy-quick.sh root@seu-servidor:/opt/scripts/
scp manage-apps.sh root@seu-servidor:/opt/scripts/
```

### Passo 3: Tornar Scripts Executáveis

```bash
cd /opt/scripts
chmod +x deploy-react-vite.sh
chmod +x deploy-quick.sh
chmod +x manage-apps.sh
```

### Passo 4: Criar Links Simbólicos (Opcional - Para Acesso Global)

```bash
ln -s /opt/scripts/deploy-quick.sh /usr/local/bin/deploy-app
ln -s /opt/scripts/manage-apps.sh /usr/local/bin/manage-apps
```

Agora você pode usar os comandos de qualquer lugar:
```bash
deploy-app
manage-apps
```

---

## 🎮 Uso dos Scripts

### Script 1: deploy-quick.sh (RECOMENDADO)

**Para aplicações React já prontas (código já desenvolvidos)**

```bash
sudo /opt/scripts/deploy-quick.sh
```

**O script vai perguntar:**
1. Nome da aplicação (ex: `meu-app`)
2. Porta (padrão: 80)
3. Caminho do código fonte (ex: `/home/user/meu-projeto`)

**Exemplo de sessão:**

```
📦 Nome da aplicação [ex: meu-app]: chatbot-suporte
🌐 Porta para exposição [padrão: 80]: 8080
📁 Caminho COMPLETO do código fonte: /home/vaz/projetos/chatbot-react

Confirme as informações:
  📦 Aplicação: chatbot-suporte
  🌐 Porta: 8080
  📁 Código fonte: /home/vaz/projetos/chatbot-react

Continuar com o deploy? [S/n]: S
```

---

### Script 2: deploy-react-vite.sh

**Para criar nova aplicação do zero**

```bash
sudo /opt/scripts/deploy-react-vite.sh
```

Este script:
- Cria novo projeto Vite
- Configura Docker
- Faz deploy completo

---

### Script 3: manage-apps.sh

**Gerenciamento centralizado de todas as aplicações**

```bash
# Modo interativo (menu)
sudo /opt/scripts/manage-apps.sh

# Modo linha de comando
sudo /opt/scripts/manage-apps.sh list                    # Listar todas
sudo /opt/scripts/manage-apps.sh status chatbot-suporte  # Ver status
sudo /opt/scripts/manage-apps.sh start chatbot-suporte   # Iniciar
sudo /opt/scripts/manage-apps.sh stop chatbot-suporte    # Parar
sudo /opt/scripts/manage-apps.sh restart chatbot-suporte # Reiniciar
sudo /opt/scripts/manage-apps.sh logs chatbot-suporte    # Ver logs
sudo /opt/scripts/manage-apps.sh start-all               # Iniciar todas
sudo /opt/scripts/manage-apps.sh stop-all                # Parar todas
```

---

## 💼 Exemplos Práticos

### Exemplo 1: Deploy de Aplicação do Gemini

```bash
# 1. Transferir código do Gemini para o servidor
scp -r meu-projeto-gemini/ root@servidor:/tmp/

# 2. Conectar ao servidor
ssh root@servidor

# 3. Fazer deploy
cd /opt/scripts
./deploy-quick.sh

# Preencher:
# Nome: chatbot-ia
# Porta: 3000
# Caminho: /tmp/meu-projeto-gemini
```

**Resultado:**
- Aplicação rodando em: `http://seu-servidor:3000`
- Gerenciamento em: `/opt/apps/chatbot-ia/`

---

### Exemplo 2: Deploy de Múltiplas Aplicações

```bash
# App 1
./deploy-quick.sh
# Nome: app-vendas, Porta: 8001, Caminho: /tmp/app-vendas

# App 2
./deploy-quick.sh
# Nome: app-estoque, Porta: 8002, Caminho: /tmp/app-estoque

# App 3
./deploy-quick.sh
# Nome: app-relatorios, Porta: 8003, Caminho: /tmp/app-relatorios

# Listar todas
./manage-apps.sh list
```

---

### Exemplo 3: Atualizar Aplicação Existente

```bash
# Método 1: Via script de update da própria app
cd /opt/apps/chatbot-ia
./stop.sh
# Substituir arquivos em frontend/src/
./update.sh

# Método 2: Via gerenciador
manage-apps restart chatbot-ia

# Método 3: Rebuild completo
cd /opt/apps/chatbot-ia
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 🎛️ Gerenciamento de Aplicações

### Estrutura de Diretórios Criada

```
/opt/apps/
├── chatbot-ia/
│   ├── frontend/           # Código fonte
│   │   ├── src/
│   │   ├── public/
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   └── package.json
│   ├── logs/               # Logs Nginx
│   ├── backups/            # Backups automáticos
│   ├── docker-compose.yml
│   ├── .env
│   ├── start.sh            # Iniciar app
│   ├── stop.sh             # Parar app
│   ├── restart.sh          # Reiniciar app
│   ├── logs.sh             # Ver logs
│   ├── update.sh           # Atualizar app
│   └── backup.sh           # Criar backup
```

### Comandos Dentro de Cada Aplicação

```bash
cd /opt/apps/SUA-APLICACAO/

./start.sh      # Iniciar
./stop.sh       # Parar
./restart.sh    # Reiniciar
./logs.sh       # Logs em tempo real (Ctrl+C para sair)
./update.sh     # Rebuild e restart
./backup.sh     # Backup da aplicação
```

### Comandos Docker Úteis

```bash
# Ver containers rodando
docker ps

# Ver todas as imagens
docker images

# Ver logs de container específico
docker logs chatbot-ia -f

# Ver uso de recursos
docker stats

# Entrar no container
docker exec -it chatbot-ia sh

# Ver redes
docker network ls

# Limpar recursos não usados
docker system prune -a
```

---

## 🔍 Troubleshooting

### Problema: Porta já em uso

```bash
# Verificar o que está usando a porta
netstat -tuln | grep :80
# ou
ss -tuln | grep :80

# Parar serviço na porta
systemctl stop apache2  # ou nginx

# Ou escolher outra porta no deploy
```

---

### Problema: Container não inicia

```bash
# Ver logs detalhados
cd /opt/apps/SUA-APP
docker-compose logs

# Verificar status
docker-compose ps

# Rebuild forçado
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

### Problema: Aplicação não responde

```bash
# Verificar health check
curl http://localhost:PORTA/health

# Ver logs do Nginx
cd /opt/apps/SUA-APP
cat logs/error.log

# Reiniciar container
./restart.sh

# Entrar no container para debug
docker exec -it NOME-CONTAINER sh
```

---

### Problema: Build falha

```bash
# Verificar se package.json está correto
cd /opt/apps/SUA-APP/frontend
cat package.json

# Instalar dependências manualmente
npm install

# Build local para testar
npm run build

# Verificar logs de build
docker-compose build 2>&1 | tee build.log
```

---

### Problema: Sem espaço em disco

```bash
# Ver uso de disco
df -h

# Limpar Docker
docker system prune -a --volumes

# Remover logs antigos
find /opt/apps/*/logs -name "*.log" -mtime +30 -delete

# Ver maiores diretórios
du -h /opt/apps/ | sort -rh | head -20
```

---

## ❓ FAQ

### Como atualizar o código de uma aplicação?

```bash
# Método 1: Substituir arquivos
cd /opt/apps/SUA-APP/frontend/src
# Substituir seus arquivos
cd ../..
./update.sh

# Método 2: Deploy completo novamente
# (O script fará backup automático)
./deploy-quick.sh
```

---

### Como fazer backup de uma aplicação?

```bash
# Backup automático
cd /opt/apps/SUA-APP
./backup.sh

# Backup manual completo
tar -czf /tmp/backup-$(date +%Y%m%d).tar.gz /opt/apps/SUA-APP
```

---

### Como restaurar um backup?

```bash
# Extrair backup
cd /opt/apps
tar -xzf /tmp/backup-20250113.tar.gz

# Reiniciar aplicação
cd SUA-APP
./start.sh
```

---

### Como mudar a porta de uma aplicação?

```bash
# Editar docker-compose.yml
cd /opt/apps/SUA-APP
nano docker-compose.yml

# Mudar linha:
# ports:
#   - "NOVA_PORTA:80"

# Aplicar mudança
docker-compose down
docker-compose up -d
```

---

### Como ver todas as aplicações rodando?

```bash
# Método 1: Gerenciador
manage-apps list

# Método 2: Docker
docker ps

# Método 3: Manual
ls -la /opt/apps/
```

---

### Como remover uma aplicação completamente?

```bash
# Via gerenciador (com backup automático)
manage-apps remove NOME-DO-APP

# Manual
cd /opt/apps/NOME-DA-APP
docker-compose down -v
cd ..
rm -rf NOME-DA-APP
```

---

### Como configurar SSL/HTTPS?

```bash
# Instalar Certbot
apt-get install certbot

# Obter certificado
certbot certonly --standalone -d seu-dominio.com

# Editar nginx.conf para adicionar SSL
# (Consultar documentação específica de SSL)
```

---

### Como monitorar recursos?

```bash
# Ver uso em tempo real
docker stats

# Ver logs de acesso
tail -f /opt/apps/SUA-APP/logs/access.log

# Ver logs de erro
tail -f /opt/apps/SUA-APP/logs/error.log

# Instalar ferramentas de monitoramento
# Grafana, Prometheus, etc.
```

---

## 📝 Changelog

### v1.0.0 (2025-01-13)
- ✅ Deploy automático completo
- ✅ Suporte Vite e CRA
- ✅ Gerenciador de múltiplas apps
- ✅ Scripts de manutenção
- ✅ Health checks
- ✅ Backup automático

---

**Desenvolvido com ❤️ por Vaz - GPS IT Services**
