# 🐳 Scripts Profissionais de Deploy Docker

### Suite completa e profissional para deploy, gerenciamento e validação de ambientes Docker em Ubuntu.

---

## 📦 Conteúdo do Pacote

```
docker-deploy-scripts/
├── docker-deploy-setup.sh          # Script principal de instalação
├── docker-management.sh            # Sistema de gerenciamento interativo
├── docker-validator.sh             # Validador e testes automatizados
├── GUIA-COMPLETO-DEPLOY-DOCKER.md  # Documentação completa
└── README.md                       # Este arquivo
```

---

## ⚡ Quick Start (5 minutos)

### 1️⃣ Download dos Scripts

```bash
# Fazer download de todos os scripts
cd ~
git clone [seu-repositorio] docker-scripts
cd docker-scripts

# OU se recebeu os arquivos diretamente:
cd /caminho/dos/arquivos
```

### 2️⃣ Instalação Completa do Ambiente

```bash
# Tornar executável
chmod +x docker-deploy-setup.sh

# Executar instalação (como root)
sudo ./docker-deploy-setup.sh
```

**O que será instalado:**
- ✅ Docker Engine (última versão)
- ✅ Docker Compose
- ✅ Configurações de segurança (UFW, Fail2Ban)
- ✅ Estrutura de diretórios otimizada
- ✅ Ferramentas de gerenciamento (ctop, lazydocker, dive)
- ✅ Scripts utilitários
- ✅ Configuração de rede e firewall

**Tempo estimado:** 5-10 minutos

### 3️⃣ Validar Instalação

```bash
# Validar todo o ambiente
chmod +x docker-validator.sh
sudo ./docker-validator.sh
```

### 4️⃣ Gerenciar Ambiente

```bash
# Abrir gerenciador interativo
chmod +x docker-management.sh
sudo ./docker-management.sh
```

---

## 🎯 Uso Diário

### Comandos Rápidos

```bash
# Ver status de tudo
docker ps -a

# Logs em tempo real
docker-compose logs -f

# Gerenciador visual (TUI)
lazydocker

# Monitoramento de recursos
ctop

# Dashboard completo
sudo docker-management.sh
```

### Deploy de Aplicação

```bash
# 1. Criar estrutura
cd /opt/docker
mkdir minha-app && cd minha-app

# 2. Criar docker-compose.yml
nano docker-compose.yml

# 3. Criar arquivo .env com senhas
nano .env

# 4. Validar configuração
docker-compose config

# 5. Subir aplicação
docker-compose up -d

# 6. Verificar status
docker-compose ps

# 7. Ver logs
docker-compose logs -f
```

---

## 📊 Menu do Gerenciador Interativo

Ao executar `docker-management.sh`, você terá acesso a:

1. **📊 Status e Monitoramento** - Dashboard completo em tempo real
2. **🐳 Gerenciar Containers** - Start, stop, restart, logs, shell
3. **🖼️ Gerenciar Imagens** - Pull, push, tag, remove
4. **💾 Gerenciar Volumes** - Criar, inspecionar, remover
5. **🌐 Gerenciar Redes** - Listar, criar, conectar
6. **🔄 Backup e Restore** - Manual e automático
7. **🧹 Limpeza** - Remover recursos não utilizados
8. **📈 Logs e Análise** - Análise de logs e erros
9. **🔧 Troubleshooting** - Diagnósticos e resolução
10. **🛡️ Segurança** - Auditoria e hardening
11. **⚙️ Configurações** - Ajustes avançados
12. **📝 Relatórios** - Relatórios de uso

---

## 🚀 Exemplos de Deploy

### Exemplo 1: Aplicação Node.js Simples

```yaml
version: '3.8'

services:
  app:
    image: node:20-alpine
    container_name: minha-app
    restart: unless-stopped
    working_dir: /app
    ports:
      - "3000:3000"
    volumes:
      - ./app:/app
    environment:
      - NODE_ENV=production
    command: npm start
```

```bash
# Deploy
docker-compose up -d

# Ver logs
docker-compose logs -f app

# Acessar shell
docker exec -it minha-app sh
```

### Exemplo 2: Stack Completo (Node + PostgreSQL + Redis)

```yaml
version: '3.8'

services:
  app:
    image: node:20-alpine
    restart: unless-stopped
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: db
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## 💾 Backup Automático

### Configurar Backup Diário

```bash
# Editar crontab
crontab -e

# Adicionar linha (backup às 2h da manhã)
0 2 * * * /opt/docker/scripts/backup-volumes.sh >> /var/log/docker-backup.log 2>&1

# Verificar cron
crontab -l
```

### Backup Manual

```bash
# Backup de todos os volumes
/opt/docker/scripts/backup-volumes.sh

# Backup de volume específico
docker run --rm \
  -v nome_do_volume:/data:ro \
  -v /opt/backups/docker:/backup \
  alpine tar czf /backup/volume_$(date +%Y%m%d).tar.gz -C /data .

# Listar backups
ls -lh /opt/backups/docker/
```

---

## 🔧 Troubleshooting Rápido

### Container não inicia

```bash
# Ver logs detalhados
docker logs container_name

# Inspecionar
docker inspect container_name

# Verificar porta
netstat -tlnp | grep porta
```

### Sem conectividade

```bash
# Testar internet
docker run --rm alpine ping -c 3 8.8.8.8

# Testar DNS
docker run --rm alpine nslookup google.com

# Ver redes
docker network ls
docker network inspect bridge
```

### Alto uso de disco

```bash
# Ver uso
docker system df

# Limpeza completa
docker system prune -a --volumes

# Limpeza seletiva
/opt/docker/scripts/cleanup.sh
```

---

## 📈 Monitoramento

### Ferramentas Instaladas

```bash
# ctop - Monitor visual de containers
ctop

# lazydocker - Interface TUI completa
lazydocker

# dive - Análise de imagens
dive nome_da_imagem

# htop - Monitor do sistema
htop
```

### Logs Centralizados

```bash
# Ver logs de todos os containers
docker-compose logs -f

# Filtrar por serviço
docker-compose logs -f service_name

# Últimas 100 linhas
docker logs --tail 100 container_name

# Seguir logs
docker logs -f container_name
```

---

## 🛡️ Segurança

### Checklist de Segurança

- ✅ UFW (Firewall) ativo
- ✅ Fail2Ban configurado
- ✅ Senhas fortes em .env
- ✅ .env no .gitignore
- ✅ Healthchecks configurados
- ✅ Restart policies definidas
- ✅ Limites de recursos
- ✅ Usuários não-root nos containers
- ✅ Redes isoladas para backend
- ✅ Volumes com permissões corretas

### Verificar Segurança

```bash
# Executar validador
sudo ./docker-validator.sh

# Status do firewall
sudo ufw status

# Status do Fail2Ban
sudo fail2ban-client status

# Auditoria de containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 📖 Documentação Completa

Para guia completo com exemplos avançados, consulte:
- **GUIA-COMPLETO-DEPLOY-DOCKER.md**

---

## 🆘 Suporte

### Recursos Úteis

- [Docker Docs](https://docs.docker.com)
- [Docker Compose](https://docs.docker.com/compose)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices)

---

## ⚙️ Requisitos do Sistema

### Mínimo

- Ubuntu 20.04+ (ou derivados)
- 2GB RAM
- 20GB espaço em disco
- 2 CPU cores

### Recomendado

- Ubuntu 24.04+ LTS
- 4GB+ RAM
- 50GB+ espaço em disco 
- 4+ CPU cores

---

## 📝 Changelog

### v2.0 (2025-11-14)

- ✨ Nova versão completa e profissional
- 🎨 Interface interativa melhorada
- 🔒 Segurança aprimorada
- 📊 Monitoramento avançado
- 🐛 Correções e melhorias
- 📚 Documentação completa

---

## 📄 Licença

**Propriedade: Todos(as)**

Scripts desenvolvidos para uso público.

---

## ✨ Features

- ✅ **Instalação Automatizada** - Deploy completo em 5 minutos
- ✅ **Validação Automatizada** - 40+ testes automatizados
- ✅ **Gerenciamento Visual** - Interface TUI interativa
- ✅ **Monitoramento Integrado** - Dashboard em tempo real
- ✅ **Backup Automático** - Rotinas de backup configuráveis
- ✅ **Segurança Hardened** - Firewall, Fail2Ban, best practices
- ✅ **Troubleshooting** - Diagnósticos automatizados
- ✅ **Logs Centralizados** - Análise e busca de erros
- ✅ **Performance** - Otimizações e tuning
- ✅ **Documentação Completa** - Guias e exemplos

---

## 🎓 Próximos Passos

1. Execute o instalador: `sudo ./docker-deploy-setup.sh`
2. Valide a instalação: `sudo ./docker-validator.sh`
3. Explore o gerenciador: `sudo ./docker-management.sh`
4. Leia o guia completo: `GUIA-COMPLETO-DEPLOY-DOCKER.md`
5. Deploy sua primeira aplicação!

---

**Desenvolvido com ❤️ pela equipe GPS IT - BU Engenharia**

*Versão 2.0 | 2025-11-14*
