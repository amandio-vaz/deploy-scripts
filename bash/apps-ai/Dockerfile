FROM node:20-alpine

WORKDIR /app

# Instalar dependências do sistema
RUN apk add --no-cache dumb-init curl

# Copiar package.json
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código
COPY src ./src
COPY tsconfig.json ./

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3001/health || exit 1

# Usar dumb-init
ENTRYPOINT ["dumb-init", "--"]

# Comando
CMD ["node", "src/server.ts"]

LABEL maintainer="cortex@myfuckexam.com"
LABEL version="1.0"
LABEL description="Cortex MyFuckExam Backend"
```

`/opt/docker/apps/cortex/myfuckexam/backend/.dockerignore`:
```
node_modules
npm-debug.log
.git
.env
.env.local
dist
build
.DS_Store
*.log
.vscode
.idea
