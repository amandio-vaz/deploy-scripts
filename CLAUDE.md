# CLAUDE.md - Guia para Assistentes de IA

**Repositório**: deploy-scripts (codes-pub)
**Proprietário**: Amândio Vaz
**Licença**: MIT
**Última Atualização**: 2025-11-21

---

## 📋 Visão Geral do Repositório

Este é um repositório público de compartilhamento de códigos contendo scripts de deploy, ferramentas de automação e arquiteturas modulares. O objetivo principal é **compartilhar conhecimento livremente** e acelerar o desenvolvimento através de soluções práticas e testadas.

### Filosofia Central

- **Sem hierarquias de conhecimento** - Todos os colaboradores são iguais (humanos ou IAs)
- **Compartilhamento sobre acúmulo** - Colaboração supera ego
- **Qualidade sobre credenciais** - O que importa é a qualidade das contribuições
- **Colaboração aberta** - Códigos experimentais, validados e de produção coexistem

### Propósito do Repositório

1. **Compartilhamento de Conhecimento**: Fornecer soluções técnicas testadas
2. **Aceleração de Desenvolvimento**: Oferecer blocos de código reutilizáveis e templates
3. **Referência Técnica**: Servir como biblioteca para problemas comuns
4. **Aprendizado Colaborativo**: Facilitar aprendizado através de exemplos práticos

---

## 🗂️ Estrutura do Repositório

```
deploy-scripts/
├── bash/                          # Scripts de automação em Bash
│   └── apps-ai/                   # Scripts de deploy para aplicações IA
│       ├── auto-deploy.sh         # Deploy automatizado completo (v1.0)
│       └── auto-deploy-opt.sh     # Variante otimizada do deploy
│
├── react/                         # Sistema de deploy React + Docker
│   ├── install.sh                 # Instalador do sistema (configura ambiente)
│   ├── manage-apps.sh             # Gerenciador de aplicações (CLI/interativo)
│   ├── quick.sh                   # Script de deploy rápido
│   ├── vite.sh                    # Deploy específico para Vite
│   ├── Dockerfile                 # Dockerfile multi-stage build
│   ├── docker-compose.yml         # Orquestração de containers
│   ├── nginx.conf                 # Configuração do servidor web Nginx
│   ├── README.md                  # Guia de início rápido
│   ├── README-DOCKER.md           # Documentação específica do Docker
│   └── guia-completo.md          # Guia completo (Português)
│
├── .github/
│   └── workflows/
│       └── jekyll-docker.yml      # Pipeline CI/CD do Jekyll
│
├── README.md                      # Documentação principal do repositório
├── LICENSE                        # Licença MIT
└── CLAUDE.md                      # Este arquivo (guia para assistentes IA)
```

---

## 🎯 Tecnologias Principais

### Stack Primário
- **Containerização**: Docker, Docker Compose
- **Frontend**: React.js, Vite, HTML5/CSS3
- **Backend**: Node.js, Python, FastAPI
- **Servidor Web**: Nginx (com otimizações)
- **Scripting**: Bash (com tratamento extensivo de erros)

### Cobertura Planejada (Crescimento Orgânico)
- **DevOps/SecOps**: Kubernetes, CI/CD, IaC, Observabilidade, SIEM
- **IA/ML**: Workflows n8n, LLMs, sistemas RAG, Vector DBs
- **Bancos de Dados**: OLTP, queries SQL

---

## 🚀 Análise Profunda dos Scripts de Deploy

### 1. Scripts Auto-Deploy (`bash/apps-ai/`)

**Localização**: `bash/apps-ai/auto-deploy.sh` e `auto-deploy-opt.sh`

**Propósito**: Deploy automatizado para aplicações containerizadas (especificamente voltado para a app "MyFuckExam")

**Características Principais**:
- ✅ Validação do sistema (Docker, portas, espaço em disco, permissões)
- ✅ Configuração de ambiente com setup interativo de API keys
- ✅ Criação automática de backups com rotação (mantém últimos 5)
- ✅ Desligamento gracioso de containers
- ✅ Builds Docker multi-stage para backend + frontend
- ✅ Health checks com lógica de retry (timeout de 60s)
- ✅ Geração de scripts auxiliares (logs, restart, stop, status, backup, clean)
- ✅ Configuração de aliases Bash para comandos rápidos
- ✅ Logging abrangente com timestamps e cores
- ✅ Tratamento de erros com números de linha

**Fluxo de Deploy**:
1. **Validação**: Verifica Docker, espaço em disco, portas, permissões
2. **Setup**: Cria estrutura de diretórios, configura .env
3. **Preparação**: Faz backup da config existente, para containers antigos, limpa imagens
4. **Build**: Constrói imagens Docker do backend e frontend com tags
5. **Deploy**: Inicia containers com docker-compose
6. **Validação**: Health check nos endpoints (backend:3001, frontend:80)
7. **Finalização**: Cria scripts auxiliares, configura aliases

**Configuração Padrão**:
```bash
APP_PATH="/opt/docker/apps/cortex/myfuckexam"
BACKEND_PATH="${APP_PATH}/backend"
FRONTEND_PATH="${APP_PATH}/frontend"
LOGS_PATH="${APP_PATH}/logs"
BACKUPS_PATH="${APP_PATH}/backups"
SCRIPTS_PATH="${APP_PATH}/scripts"
MAX_DEPLOY_TIME=600  # 10 minutos
```

**Scripts Auxiliares Gerados**:
- `logs.sh` - Visualiza logs dos containers (tail 100)
- `restart.sh` - Reinicia containers
- `stop.sh` - Para containers graciosamente
- `status.sh` - Mostra status dos containers e uso de recursos
- `backup.sh` - Cria backup com timestamp
- `clean.sh` - Limpa containers e faz prune do sistema
- `git-commit.sh` - Auto-commit e push de mudanças

**Diferença Entre os Scripts**:
- `auto-deploy.sh`: Versão principal com todas as funcionalidades
- `auto-deploy-opt.sh`: Variante otimizada com correções menores:
  - Melhor fallback do comando `bc` para cálculo de espaço em disco
  - Espaçamento melhorado na formatação da saída de logs
  - Correção de label na linha 314 ("Backend" ao invés de "Frontend")

### 2. Sistema de Deploy React (`react/`)

**Propósito**: Sistema completo de deploy automatizado para aplicações React com Docker

**Componentes**:

#### `install.sh`
- Instala Docker, Docker Compose, Node.js
- Configura estrutura de diretórios (`/opt/scripts/`, `/opt/apps/`)
- Instala todos os scripts de deploy globalmente
- Configura comandos do sistema

#### `manage-apps.sh`
- Sistema de menu interativo para gerenciar aplicações
- Comandos CLI: list, status, start, stop, restart, logs, remove
- Gerenciamento centralizado de aplicações

#### `quick.sh`
- Deploy rápido para projetos React existentes
- Prompts interativos para nome da app, porta, caminho do código
- Build e deploy Docker automatizados

#### `vite.sh`
- Deploy especializado para aplicações React baseadas em Vite
- Configuração de build otimizada

#### `Dockerfile`
- Build multi-stage (base node:18-alpine)
- Otimizado para produção
- Camada de serving com Nginx

#### `docker-compose.yml`
- Orquestração de containers
- Gerenciamento de volumes
- Configuração de rede
- Mapeamento de portas

#### `nginx.conf`
- Compressão Gzip
- Cache de assets estáticos
- Headers de segurança
- Roteamento de fallback para SPA (try_files)

**Estrutura de Diretórios Gerada**:
```
/opt/
├── scripts/              # Scripts de deploy globais
│   ├── deploy-app        # Deploy de app React existente
│   ├── deploy-new        # Cria nova app React
│   ├── manage-apps       # Gerenciador de aplicações
│   └── deploy-health     # Verificação de saúde do sistema
│
└── apps/                 # Aplicações deployadas
    └── {nome-app}/
        ├── frontend/     # Código fonte
        ├── docker-compose.yml
        ├── Dockerfile
        ├── nginx.conf
        ├── start.sh      # Inicia esta app
        ├── stop.sh       # Para esta app
        ├── restart.sh    # Reinicia esta app
        ├── logs.sh       # Visualiza logs
        ├── update.sh     # Rebuild e redeploy
        └── backup.sh     # Backup desta app
```

**Comandos Rápidos** (após instalação):
```bash
deploy-app         # Deploy de app React existente
deploy-new         # Cria novo projeto React
manage-apps        # Gerenciador interativo
deploy-health      # Verificação de saúde do sistema
```

**Comandos por Aplicação**:
```bash
cd /opt/apps/{nome-app}
./start.sh         # Inicia aplicação
./stop.sh          # Para aplicação
./restart.sh       # Reinicia aplicação
./logs.sh          # Visualiza logs (tempo real)
./update.sh        # Rebuild e redeploy
./backup.sh        # Cria backup
```

---

## 💻 Fluxos de Desenvolvimento

### Para Contribuir com Código

1. **Fork & Clone**
   ```bash
   git clone https://github.com/amandio-vaz/codes-pub.git
   cd codes-pub
   ```

2. **Criar Branch de Feature**
   ```bash
   git checkout -b feature/minha-feature
   ```

3. **Fazer Alterações**
   - Seguir o estilo de código existente
   - Adicionar comentários em português (pt-BR) para audiência brasileira
   - Testar em ambiente isolado primeiro

4. **Padrões de Commit**
   ```bash
   git commit -m "feat: Adiciona nova feature"
   git commit -m "fix: Corrige bug no middleware"
   git commit -m "docs: Atualiza README"
   git commit -m "refactor: Melhora performance"
   git commit -m "test: Adiciona testes"
   ```

5. **Push & PR**
   ```bash
   git push origin feature/minha-feature
   # Abrir Pull Request no GitHub
   ```

### Tags de Status para Código

Ao contribuir ou documentar, sempre indicar o status:

- ✅ **Validado** - Testado e funcionando em ambiente específico (documentar ambiente)
- ⚠️ **Não Validado** - Funcional mas sem testes extensivos
- 🧪 **Experimental** - Prova de conceito ou em desenvolvimento
- 📚 **Didático** - Exemplo educacional

### Testes Antes de Produção

**CRÍTICO**: Sempre testar em ambientes seguros primeiro!

```bash
# Ambiente isolado com Docker
docker-compose up -d

# Ambiente virtual Python
python -m venv venv
source venv/bin/activate

# Testar em servidores de não-produção
ssh servidor-teste
```

---

## 🔧 Convenções Principais

### Nomenclatura de Arquivos
- Usar `kebab-case` para arquivos: `autenticacao-usuario.js`
- Ser descritivo: `jwt-middleware.js` (não: `middleware.js`)
- Incluir extensões apropriadas

### Documentação de Código
- **Idioma**: Português (pt-BR) para comentários (audiência brasileira)
- **Comentários**: Explicar lógica complexa, não código óbvio
- **Cabeçalhos**: Incluir propósito, autor, versão nos cabeçalhos dos scripts
- **TODO/FIXME**: Marcar claramente código incompleto ou problemático

### Padrões de Scripts Bash

1. **Tratamento de Erros**
   ```bash
   set -e  # Sair em caso de erro
   trap 'handle_error ${LINENO}' ERR
   ```

2. **Funções de Log**
   ```bash
   log_section() { ... }    # Cabeçalhos de seção
   log_success() { ... }    # Mensagens de sucesso (verde)
   log_error() { ... }      # Mensagens de erro (vermelho)
   log_warning() { ... }    # Avisos (amarelo)
   log_info() { ... }       # Mensagens informativas (ciano)
   ```

3. **Códigos de Cores**
   ```bash
   RED='\033[0;31m'
   GREEN='\033[0;32m'
   YELLOW='\033[1;33m'
   BLUE='\033[0;34m'
   CYAN='\033[0;36m'
   MAGENTA='\033[0;35m'
   NC='\033[0m'  # Sem Cor
   ```

4. **Interação com Usuário**
   - Banners ASCII art claros para scripts principais
   - Prompts interativos com validação
   - Indicadores de progresso (spinners para operações longas)
   - Mensagens de erro abrangentes com conselhos acionáveis

### Melhores Práticas Docker

1. **Builds Multi-stage** - Manter imagens pequenas
2. **Base Alpine** - Usar `node:18-alpine` para footprint mínimo
3. **Cache de Camadas** - Ordenar comandos do Dockerfile para cache otimizado
4. **Health Checks** - Sempre incluir endpoints de health
5. **Desligamento Gracioso** - Usar tratamento adequado de sinais

### Considerações de Segurança

⚠️ **IMPORTANTE**: Este repositório é PÚBLICO!

- **NUNCA** commitar credenciais, API keys ou secrets
- **SEMPRE** usar arquivos `.env` (adicionar ao `.gitignore`)
- **REMOVER** dados sensíveis antes de compartilhar
- **VALIDAR** todos os inputs de usuário nos scripts
- **REVISAR** código para vulnerabilidades de injeção de comando
- **TESTAR** em ambientes isolados primeiro

---

## 🛠️ Trabalhando com Este Repositório como Assistente de IA

### Entendendo o Status do Código

Ao analisar código neste repositório:

1. **Verificar Indicadores de Status** - Procurar por tags ✅/⚠️/🧪/📚
2. **Ler Comentários Cuidadosamente** - Contexto importante está nos comentários em português
3. **Validar Dependências** - Verificar requisitos de versão
4. **Entender Ambiente** - Notar SO alvo, versões do Docker, etc.

### Fazendo Modificações

1. **Preservar Padrões Existentes**
   - Manter estrutura de logging
   - Manter codificação de cores consistente
   - Seguir padrões de tratamento de erros

2. **Melhorar, Não Substituir**
   - Adicionar funcionalidades incrementalmente
   - Manter compatibilidade retroativa quando possível
   - Documentar mudanças que quebram compatibilidade claramente

3. **Testar Abrangentemente**
   - Testar caminhos felizes
   - Testar condições de erro
   - Testar casos extremos (inputs vazios, caracteres especiais, etc.)

4. **Documentar Mudanças**
   - Atualizar arquivos README relevantes
   - Adicionar comentários inline para lógica complexa
   - Atualizar CLAUDE.md se a estrutura mudar

### Tarefas Comuns para Assistentes de IA

#### Adicionando um Novo Script de Deploy

1. Colocar no diretório apropriado (`bash/` ou `react/`)
2. Seguir convenções de nomenclatura
3. Incluir cabeçalho abrangente:
   ```bash
   #!/bin/bash
   #==============================================================================
   # Nome do Script - Versão
   # Autor: Nome
   # Descrição: O que faz
   #==============================================================================
   ```
4. Adicionar ao README relevante
5. Testar minuciosamente
6. Marcar com tag de status apropriada

#### Debugando Problemas de Deploy

1. **Verificar Logs Primeiro**
   ```bash
   # Para scripts auto-deploy
   tail -f /opt/docker/apps/cortex/myfuckexam/logs/deploy-*.log

   # Para apps React
   manage-apps logs {nome-app}
   docker-compose logs
   ```

2. **Verificar Requisitos do Sistema**
   - Versão do Docker
   - Espaço em disco disponível
   - Disponibilidade de portas
   - Permissões de arquivos

3. **Verificar Configuração**
   - Validade do arquivo .env
   - Sintaxe do docker-compose.yml
   - Configuração do Nginx

4. **Problemas Comuns**
   - Conflitos de porta → Usar porta diferente ou parar serviço conflitante
   - Permissão negada → Verificar ownership de arquivos e chmod
   - Falha no build da imagem → Verificar sintaxe do Dockerfile e dependências
   - Falha no health check → Verificar URLs dos endpoints e tempo de startup do serviço

#### Atualizando Documentação

1. **Manter Consistência**
   - Corresponder tom e estilo existentes
   - Usar mesmos padrões de formatação
   - Manter abordagem em pt-BR

2. **Atualizar Múltiplas Localizações**
   - README.md principal
   - READMEs específicos de diretórios
   - CLAUDE.md (este arquivo)
   - Comentários inline no código

---

## 📊 Padrões do Projeto

### Requisitos Mínimos

Para que os scripts de deploy funcionem:

- **SO**: Ubuntu 20.04+ / Debian 10+
- **CPU**: 1+ cores
- **RAM**: 1+ GB (2GB recomendado)
- **Disco**: 10+ GB de espaço livre
- **Acesso**: Privilégios root ou sudo
- **Rede**: Acesso à internet para pulls do Docker

### Otimizações de Performance

Scripts incluem:
- ⚡ Builds Docker multi-stage
- 🗜️ Compressão Gzip
- 💾 Cache de assets estáticos
- 🔒 Headers de segurança
- 🏥 Health checks integrados
- 🔄 Hot reload em desenvolvimento

---

## 🚨 Disclaimers Importantes

### Níveis de Validação de Código

Este repositório contém código em vários estágios de validação:

1. **Validado** (✅) - Testado em ambientes documentados
2. **Não Validado** (⚠️) - Funcional mas não extensivamente testado
3. **Experimental** (🧪) - PoC, estudos ou exemplos
4. **Educacional** (📚) - Para fins de aprendizado

### Responsabilidade

**CRÍTICO**: Usuários assumem TODA a responsabilidade:

- ❌ **Sem garantias** de funcionalidade em todos os ambientes
- ❌ **Sem garantia** para perda de dados, falhas de sistema ou problemas de segurança
- ❌ **Sem responsabilidade** por danos diretos ou indiretos
- ✅ **Testes obrigatórios** antes de uso em produção
- ✅ **Conhecimento técnico obrigatório** - entender antes de executar
- ✅ **Usuário aceita todos os riscos** associados ao uso

### Postura de Segurança

- Revisar TODO o código antes da execução
- Testar em ambientes isolados
- Remover credenciais antes de adaptar
- Validar compatibilidade com suas versões
- Entender implicações de cada comando

---

## 🤝 Diretrizes de Contribuição

### Quem Pode Contribuir

- **Qualquer pessoa** - Do iniciante ao expert, humano ou IA
- **Sem hierarquias** - Qualidade importa, não credenciais
- **Espírito colaborativo** - Ajudar outros a aprender

### O Que Contribuir

- ✅ Novos scripts de deploy ou ferramentas
- ✅ Correções de bugs e melhorias
- ✅ Aprimoramentos de documentação
- ✅ Exemplos e tutoriais
- ✅ Otimizações de performance
- ✅ Melhorias de segurança

### Padrões de Contribuição

1. **Documentação** - Todo código deve ser bem documentado
2. **Comentários** - Explicar seções complexas (em português para audiência pt-BR)
3. **Status** - Marcar claramente o status de validação
4. **README** - Adicionar ou atualizar arquivos README relevantes
5. **Código Limpo** - Seguir melhores práticas
6. **Segurança** - Remover todas as informações sensíveis
7. **Testes** - Testar antes de submeter

### Processo de PR

1. Fazer fork do repositório
2. Criar branch de feature: `git checkout -b feature/minha-feature`
3. Fazer mudanças seguindo as convenções
4. Testar minuciosamente em ambiente seguro
5. Commitar com mensagens claras (feat/fix/docs/refactor/test)
6. Push para seu fork: `git push origin feature/minha-feature`
7. Abrir Pull Request com descrição detalhada

---

## 📚 Recursos Adicionais

### Arquivos de Documentação

- `README.md` - Visão geral principal do repositório
- `react/README.md` - Início rápido para deploy React
- `react/README-DOCKER.md` - Guia específico de Docker
- `react/guia-completo.md` - Guia completo (Português)
- `LICENSE` - Termos da licença MIT

### Referências Externas

- [Documentação Docker](https://docs.docker.com)
- [Docker Compose](https://docs.docker.com/compose/)
- [Documentação React](https://react.dev)
- [Documentação Nginx](https://nginx.org/en/docs/)
- [Documentação Node.js](https://nodejs.org/docs)

### Comandos Úteis

```bash
# Exploração do repositório
tree -L 3 -a                    # Visualizar estrutura
git log --oneline               # Ver histórico de commits
find . -type f -name "*.sh"     # Encontrar todos os scripts shell

# Operações Docker
docker ps                       # Listar containers rodando
docker images                   # Listar imagens
docker-compose logs -f          # Seguir logs
docker system prune -a          # Limpar tudo

# Verificações de sistema
df -h                          # Espaço em disco
netstat -tuln                  # Uso de portas
systemctl status docker        # Status do Docker
```

---

## 🎓 Aprendendo com Este Repositório

### Para Iniciantes

Comece com:
1. Ler README.md principal minuciosamente
2. Revisar `react/README.md` para exemplos práticos
3. Estudar `install.sh` para entender configuração do sistema
4. Experimentar `quick.sh` para deploy prático

### Para Usuários Intermediários

Explorar:
1. `auto-deploy.sh` para padrões avançados de bash
2. Builds Docker multi-stage no `Dockerfile`
3. Otimização do Nginx no `nginx.conf`
4. Padrões de tratamento de erros e logging

### Para Usuários Avançados

Aprofundar:
1. Contribuir com otimizações
2. Adicionar novos alvos de deploy
3. Aprimorar funcionalidades de segurança
4. Criar workflows de automação avançados

---

## 🔄 Manutenção do Repositório

### Atualizações Regulares

Este repositório é ativamente mantido:

- ⭐ Dar star para atualizações
- 👁️ Watch para notificações
- 🔔 Seguir releases

### Reportando Problemas

- **Bugs**: Abrir issue com passos detalhados de reprodução
- **Perguntas**: Usar Discussions
- **Sugestões**: Abrir issue com label "enhancement"

### Obtendo Ajuda

1. **Ler Documentação** - Verificar arquivos README primeiro
2. **Pesquisar Issues** - Problema pode ser conhecido
3. **Perguntar em Discussions** - Comunidade pode ajudar
4. **Abrir Issue** - Para novos bugs ou features

---

## 📝 Histórico de Versões

### Estrutura Atual (v1.0)
- ✅ Scripts auto-deploy para apps containerizadas
- ✅ Sistema completo de deploy React
- ✅ Otimização Docker + Nginx
- ✅ Ferramentas de gerenciamento interativas
- ✅ Documentação abrangente

### Adições Planejadas (Crescimento Orgânico)
- 📋 Stacks DevOps/SecOps (K8s, CI/CD, IaC)
- 🤖 Integrações IA/ML (n8n, LLMs, RAG)
- 🗄️ Scripts de banco de dados e queries
- 🔒 Funcionalidades de segurança aprimoradas
- 📊 Ferramentas de monitoramento e observabilidade

---

## 👤 Sobre o Autor

**Amândio Vaz**
- **Função**: Engenharia de Infraestrutura, Segurança & Observabilidade
- **Experiência**: 20+ anos em TI
- **Filosofia**: Compartilhamento de conhecimento sobre acúmulo de conhecimento
- **GitHub**: [@amandio-vaz](https://github.com/amandio-vaz)

### Motivação

Após 20+ anos em TI, este repositório é uma resposta à cultura do "guardião do conhecimento" - profissionais que acumulam informação ao invés de compartilhar. Este é um espaço para **colaboração genuína, aprendizado mútuo e crescimento coletivo**.

> "Crescemos quando compartilhamos. Evoluímos quando colaboramos."

---

## ✨ Referência Rápida para Assistentes de IA

### Tipo de Repositório
Repositório público de compartilhamento de códigos com ferramentas de automação de deploy

### Linguagem Primária
Scripts Bash com alguns arquivos de configuração (YAML, conf)

### Idioma do Código
- Scripts: Bash
- Comentários: Português (pt-BR)
- Documentação: Português brasileiro

### Público-Alvo
Desenvolvedores, engenheiros DevOps, administradores de sistemas, assistentes de IA

### Alvos de Deploy
- Aplicações containerizadas em Docker
- Aplicações frontend React.js
- Serviços backend Node.js
- Servidores web Nginx

### Arquivos Chave para Referência
- `bash/apps-ai/auto-deploy.sh` - Automação principal de deploy
- `react/install.sh` - Instalador do sistema
- `react/manage-apps.sh` - Gerenciador de aplicações
- `README.md` - Visão geral do repositório

### Operações Comuns
1. **Deploy completo de app**: `bash/apps-ai/auto-deploy.sh`
2. **Setup de app React**: `react/install.sh` → `deploy-app`
3. **Gerenciamento de app**: `manage-apps list|start|stop|logs`
4. **Debugging**: Verificar logs em `/opt/docker/apps/*/logs/` ou `/opt/apps/*/`

### Flags de Alerta
- 🚨 Sempre testar em ambientes isolados
- 🚨 Remover credenciais antes de commitar
- 🚨 Validar todos os inputs de usuário
- 🚨 Verificar requisitos de sistema antes do deploy

---

**Feito com ❤️ de um simples humano, para humanos e não humanos**

*Última atualização: 2025-11-21*
