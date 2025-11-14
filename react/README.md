# 🚀 Deploy Automático React + Docker 

Sistema completo de deploy automatizado para aplicações React com Docker**.

**Desenvolvido por: Amândio Vaz - AIOps**

---

## ⚡ Início Rápido (3 Passos)

### 1️⃣ Instalar Sistema

```bash
# Conectar ao servidor
ssh root@seu-servidor

# Baixar instalador
wget https://raw.githubusercontent.com/SEU-REPO/install.sh
# OU copiar via SCP
scp install.sh root@seu-servidor:/tmp/

# Executar instalação
chmod +x install.sh
./install.sh
```

### 2️⃣ Transferir Código da Aplicação

```bash
# Do seu computador local:
scp -r meu-projeto-react/ root@seu-servidor:/tmp/
```

### 3️⃣ Fazer Deploy

```bash
# No servidor:
deploy-app

# Preencher informações:
# - Nome da aplicação: minha-app
# - Porta: 80 (ou outra)
# - Caminho do código: /tmp/meu-projeto-react
```

**Pronto! Sua aplicação está no ar! 🎉**

---

## 📦 O que Foi Instalado?

✅ **Docker & Docker Compose** - Containerização  
✅ **Node.js 18+ LTS** - Runtime JavaScript  
✅ **Scripts de Deploy** - Automação completa  
✅ **Nginx** - Servidor web otimizado  
✅ **Gerenciador de Apps** - Controle centralizado  

---

## 🎮 Comandos Principais

```bash
# Deploy de aplicação React existente
deploy-app

# Criar novo projeto do zero
deploy-new

# Gerenciar aplicações (menu interativo)
manage-apps

# Verificar saúde do sistema
deploy-health

# Gerenciar aplicações via CLI
manage-apps list                # Listar todas
manage-apps status minha-app    # Ver status
manage-apps start minha-app     # Iniciar
manage-apps stop minha-app      # Parar
manage-apps logs minha-app      # Ver logs
```

---

## 📂 Estrutura Criada

```
/opt/
├── scripts/              # Scripts de deploy
│   ├── deploy-app        # Deploy rápido
│   ├── deploy-new        # Novo projeto
│   ├── manage-apps       # Gerenciador
│   └── deploy-health     # Health check
│
└── apps/                 # Suas aplicações
    └── minha-app/
        ├── frontend/     # Código fonte
        ├── start.sh      # Iniciar app
        ├── stop.sh       # Parar app
        ├── restart.sh    # Reiniciar app
        └── logs.sh       # Ver logs
```

---

## 💡 Exemplos de Uso

### Exemplo 1: Deploy Simples

```bash
# 1. Transferir código
scp -r chatbot/ root@servidor:/tmp/

# 2. Conectar e fazer deploy
ssh root@servidor
deploy-app

# Nome: chatbot
# Porta: 3000
# Caminho: /tmp/chatbot

# 3. Acessar
http://seu-servidor:3000
```

### Exemplo 2: Múltiplas Aplicações

```bash
# App 1 - Vendas
deploy-app  # Porta 8001

# App 2 - Estoque  
deploy-app  # Porta 8002

# App 3 - Dashboard
deploy-app  # Porta 8003

# Listar todas
manage-apps list
```

### Exemplo 3: Gerenciar Aplicação

```bash
# Ver status
manage-apps status chatbot

# Ver logs em tempo real
manage-apps logs chatbot

# Reiniciar
manage-apps restart chatbot

# Parar
manage-apps stop chatbot

# Iniciar
manage-apps start chatbot
```

---

## 🔧 Gerenciamento por Aplicação

Cada aplicação tem seus próprios scripts:

```bash
cd /opt/apps/NOME-DO-APP/

./start.sh      # Iniciar
./stop.sh       # Parar  
./restart.sh    # Reiniciar
./logs.sh       # Logs em tempo real
./update.sh     # Atualizar (rebuild)
./backup.sh     # Criar backup
```

---

## 🌐 URLs das Aplicações

Após o deploy, acesse via:

```
Local:    http://localhost:PORTA
Rede:     http://IP-DO-SERVIDOR:PORTA
Domínio:  http://seu-dominio.com:PORTA

Health:   http://localhost:PORTA/health
```

---

## 🐛 Troubleshooting Rápido

### Porta já em uso?
```bash
# Ver o que está usando
netstat -tuln | grep :80

# Ou escolher outra porta no deploy
```

### Container não inicia?
```bash
cd /opt/apps/NOME-APP
docker-compose logs
./restart.sh
```

### Ver uso de recursos?
```bash
docker stats
```

### Limpar espaço?
```bash
docker system prune -a
```

---

## 📊 Monitoramento

```bash
# Status de todas as apps
manage-apps list

# Logs em tempo real
manage-apps logs NOME-APP

# Recursos do sistema
docker stats

# Health check
curl http://localhost:PORTA/health
```

---

## 🔄 Atualização de Código

### Método 1: Via Script
```bash
cd /opt/apps/NOME-APP/frontend/src
# Substituir seus arquivos aqui
cd ../..
./update.sh
```

### Método 2: Novo Deploy
```bash
# Fazer backup automático e deploy novo
deploy-app
# Usar mesmo nome e porta
```

---

## 💾 Backup

```bash
# Backup de uma app
cd /opt/apps/NOME-APP
./backup.sh

# Backup manual
tar -czf /tmp/backup.tar.gz /opt/apps/NOME-APP

# Backups automáticos ficam em:
/opt/apps/NOME-APP/backups/
```

---

## 📋 Checklist de Deploy

- [ ] Sistema instalado (`./install.sh`)
- [ ] Código transferido para o servidor
- [ ] Deploy executado (`deploy-app`)
- [ ] Aplicação testada (abrir no navegador)
- [ ] Health check ok (`curl localhost:PORTA/health`)
- [ ] Logs verificados (`manage-apps logs APP`)

---

## 🎯 Requisitos Mínimos

- **OS:** Ubuntu 20.04+ / Debian 10+
- **CPU:** 1 core
- **RAM:** 1 GB
- **Disco:** 10 GB
- **Acesso:** Root/Sudo

---

## 🚀 Performance

- ⚡ Build otimizado multi-stage
- 🗜️ Compressão Gzip automática
- 💾 Cache de assets estáticos
- 🔒 Headers de segurança
- 🏥 Health checks integrados
- 🔄 Hot reload em desenvolvimento

---

## 📜 Licença Pública

Desenvolvido por **Amândio Vaz** para meus amigos e colaboradores da **GPS IT**  
© 2025 - VAZ

---

## 🎓 Aprenda Mais

```bash
# Ver documentação completa
cat /opt/scripts/GUIA_COMPLETO.md

# Ver exemplos práticos
cat /opt/scripts/EXEMPLOS.md

# Ver troubleshooting detalhado
cat /opt/scripts/TROUBLESHOOTING.md
```

---

**🚀 Comece agora mesmo!**

```bash
# Instalar
./install.sh

# Deploy
deploy-app

# Gerenciar
manage-apps
```

**Simples, rápido e profissional! 🎉**

---

*Desenvolvido com ❤️ por Vaz - GPS IT Services*  
*Infrastructure & Observability Engineering*
