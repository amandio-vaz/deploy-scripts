# CLAUDE.md - AI Assistant Guide

**Repository**: deploy-scripts (codes-pub)
**Owner**: Amândio Vaz
**License**: MIT
**Last Updated**: 2025-11-21

---

## 📋 Repository Overview

This is a public code-sharing repository containing deployment scripts, automation tools, and modular architectures. The primary goal is to **share knowledge freely** and accelerate development through practical, tested solutions.

### Core Philosophy

- **No knowledge hierarchies** - All contributors are equal (human or AI)
- **Knowledge sharing over hoarding** - Collaboration trumps ego
- **Quality over credentials** - What matters is the quality of contributions
- **Open collaboration** - Experimental, validated, and production code coexist

### Repository Purpose

1. **Knowledge Sharing**: Provide tested technical solutions
2. **Development Acceleration**: Offer reusable code blocks and templates
3. **Technical Reference**: Serve as a library for common problems
4. **Collaborative Learning**: Facilitate learning through practical examples

---

## 🗂️ Repository Structure

```
deploy-scripts/
├── bash/                          # Bash automation scripts
│   └── apps-ai/                   # AI application deployment scripts
│       ├── auto-deploy.sh         # Full automated deployment (v1.0)
│       └── auto-deploy-opt.sh     # Optimized deployment variant
│
├── react/                         # React + Docker deployment system
│   ├── install.sh                 # System installer (sets up environment)
│   ├── manage-apps.sh             # Application manager (CLI/interactive)
│   ├── quick.sh                   # Quick deployment script
│   ├── vite.sh                    # Vite-specific deployment
│   ├── Dockerfile                 # Multi-stage build Dockerfile
│   ├── docker-compose.yml         # Container orchestration
│   ├── nginx.conf                 # Nginx web server config
│   ├── README.md                  # Quick start guide
│   ├── README-DOCKER.md           # Docker-specific docs
│   └── guia-completo.md          # Complete guide (Portuguese)
│
├── .github/
│   └── workflows/
│       └── jekyll-docker.yml      # Jekyll CI/CD pipeline
│
├── README.md                      # Main repository documentation
├── LICENSE                        # MIT License
└── CLAUDE.md                      # This file (AI assistant guide)
```

---

## 🎯 Key Technologies

### Primary Stack
- **Containerization**: Docker, Docker Compose
- **Frontend**: React.js, Vite, HTML5/CSS3
- **Backend**: Node.js, Python, FastAPI
- **Web Server**: Nginx (with optimization)
- **Scripting**: Bash (with extensive error handling)

### Planned Coverage (Organic Growth)
- **DevOps/SecOps**: Kubernetes, CI/CD, IaC, Observability, SIEM
- **AI/ML**: n8n workflows, LLMs, RAG systems, Vector DBs
- **Databases**: OLTP, SQL queries

---

## 🚀 Deployment Scripts Deep Dive

### 1. Auto-Deploy Scripts (`bash/apps-ai/`)

**Location**: `bash/apps-ai/auto-deploy.sh` and `auto-deploy-opt.sh`

**Purpose**: Automated deployment for containerized applications (specifically targeting "MyFuckExam" app)

**Key Features**:
- ✅ System validation (Docker, ports, disk space, permissions)
- ✅ Environment configuration with interactive API key setup
- ✅ Automated backup creation and rotation (keeps last 5)
- ✅ Graceful container shutdown
- ✅ Multi-stage Docker builds for backend + frontend
- ✅ Health checks with retry logic (60s timeout)
- ✅ Helper script generation (logs, restart, stop, status, backup, clean)
- ✅ Bash alias configuration for quick commands
- ✅ Comprehensive logging with timestamps and colors
- ✅ Error handling with line numbers

**Deployment Flow**:
1. **Validation**: Check Docker, disk space, ports, permissions
2. **Setup**: Create directory structure, configure .env
3. **Preparation**: Backup existing config, stop old containers, clean images
4. **Build**: Build backend and frontend Docker images with tags
5. **Deploy**: Start containers with docker-compose
6. **Validation**: Health check endpoints (backend:3001, frontend:80)
7. **Finalization**: Create helper scripts, configure aliases

**Default Configuration**:
```bash
APP_PATH="/opt/docker/apps/cortex/myfuckexam"
BACKEND_PATH="${APP_PATH}/backend"
FRONTEND_PATH="${APP_PATH}/frontend"
LOGS_PATH="${APP_PATH}/logs"
BACKUPS_PATH="${APP_PATH}/backups"
SCRIPTS_PATH="${APP_PATH}/scripts"
MAX_DEPLOY_TIME=600  # 10 minutes
```

**Generated Helper Scripts**:
- `logs.sh` - View container logs (tail 100)
- `restart.sh` - Restart containers
- `stop.sh` - Stop containers gracefully
- `status.sh` - Show container status and resource usage
- `backup.sh` - Create timestamped backup
- `clean.sh` - Clean containers and prune system
- `git-commit.sh` - Auto-commit and push changes

**Difference Between Scripts**:
- `auto-deploy.sh`: Main version with full features
- `auto-deploy-opt.sh`: Optimized variant with minor fixes:
  - Better `bc` command fallback for disk space calculation
  - Improved spacing in log output formatting
  - Fixed label on line 314 ("Backend" instead of "Frontend")

### 2. React Deployment System (`react/`)

**Purpose**: Complete automated deployment system for React applications with Docker

**Components**:

#### `install.sh`
- Installs Docker, Docker Compose, Node.js
- Sets up directory structure (`/opt/scripts/`, `/opt/apps/`)
- Installs all deployment scripts globally
- Configures system-wide commands

#### `manage-apps.sh`
- Interactive menu system for managing applications
- CLI commands: list, status, start, stop, restart, logs, remove
- Centralized application management

#### `quick.sh`
- Rapid deployment for existing React projects
- Interactive prompts for app name, port, source path
- Automated Docker build and deployment

#### `vite.sh`
- Specialized deployment for Vite-based React apps
- Optimized build configuration

#### `Dockerfile`
- Multi-stage build (node:18-alpine base)
- Optimized for production
- Nginx serving layer

#### `docker-compose.yml`
- Container orchestration
- Volume management
- Network configuration
- Port mapping

#### `nginx.conf`
- Gzip compression
- Static asset caching
- Security headers
- SPA fallback routing (try_files)

**Generated Directory Structure**:
```
/opt/
├── scripts/              # Global deployment scripts
│   ├── deploy-app        # Deploy existing React app
│   ├── deploy-new        # Create new React app
│   ├── manage-apps       # Application manager
│   └── deploy-health     # System health check
│
└── apps/                 # Deployed applications
    └── {app-name}/
        ├── frontend/     # Source code
        ├── docker-compose.yml
        ├── Dockerfile
        ├── nginx.conf
        ├── start.sh      # Start this app
        ├── stop.sh       # Stop this app
        ├── restart.sh    # Restart this app
        ├── logs.sh       # View logs
        ├── update.sh     # Rebuild and redeploy
        └── backup.sh     # Backup this app
```

**Quick Commands** (after installation):
```bash
deploy-app         # Deploy existing React app
deploy-new         # Create new React project
manage-apps        # Interactive manager
deploy-health      # System health check
```

**Per-Application Commands**:
```bash
cd /opt/apps/{app-name}
./start.sh         # Start application
./stop.sh          # Stop application
./restart.sh       # Restart application
./logs.sh          # View logs (real-time)
./update.sh        # Rebuild and redeploy
./backup.sh        # Create backup
```

---

## 💻 Development Workflows

### For Contributing Code

1. **Fork & Clone**
   ```bash
   git clone https://github.com/amandio-vaz/codes-pub.git
   cd codes-pub
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/my-feature
   ```

3. **Make Changes**
   - Follow existing code style
   - Add comments in Portuguese (pt-BR) for Brazilian audience
   - Test in isolated environment first

4. **Commit Standards**
   ```bash
   git commit -m "feat: Adiciona nova feature"
   git commit -m "fix: Corrige bug no middleware"
   git commit -m "docs: Atualiza README"
   git commit -m "refactor: Melhora performance"
   git commit -m "test: Adiciona testes"
   ```

5. **Push & PR**
   ```bash
   git push origin feature/my-feature
   # Open Pull Request on GitHub
   ```

### Status Tags for Code

When contributing or documenting, always indicate status:

- ✅ **Validado** - Tested and working in specific environment (document env)
- ⚠️ **Não Validado** - Functional but lacks extensive testing
- 🧪 **Experimental** - Proof of concept or in development
- 📚 **Didático** - Educational example

### Testing Before Production

**CRITICAL**: Always test in safe environments first!

```bash
# Docker isolated environment
docker-compose up -d

# Python virtual environment
python -m venv venv
source venv/bin/activate

# Test on non-production servers
ssh test-server
```

---

## 🔧 Key Conventions

### File Naming
- Use `kebab-case` for files: `user-authentication.js`
- Be descriptive: `jwt-middleware.js` (not `middleware.js`)
- Include appropriate extensions

### Code Documentation
- **Language**: Portuguese (pt-BR) for comments (Brazilian audience)
- **Comments**: Explain complex logic, not obvious code
- **Headers**: Include purpose, author, version in script headers
- **TODO/FIXME**: Mark incomplete or problematic code clearly

### Bash Scripting Standards

1. **Error Handling**
   ```bash
   set -e  # Exit on error
   trap 'handle_error ${LINENO}' ERR
   ```

2. **Logging Functions**
   ```bash
   log_section() { ... }    # Section headers
   log_success() { ... }    # Success messages (green)
   log_error() { ... }      # Error messages (red)
   log_warning() { ... }    # Warnings (yellow)
   log_info() { ... }       # Info messages (cyan)
   ```

3. **Color Codes**
   ```bash
   RED='\033[0;31m'
   GREEN='\033[0;32m'
   YELLOW='\033[1;33m'
   BLUE='\033[0;34m'
   CYAN='\033[0;36m'
   MAGENTA='\033[0;35m'
   NC='\033[0m'  # No Color
   ```

4. **User Interaction**
   - Clear ASCII art banners for major scripts
   - Interactive prompts with validation
   - Progress indicators (spinners for long operations)
   - Comprehensive error messages with actionable advice

### Docker Best Practices

1. **Multi-stage Builds** - Keep images small
2. **Alpine Base** - Use `node:18-alpine` for minimal footprint
3. **Layer Caching** - Order Dockerfile commands for optimal caching
4. **Health Checks** - Always include health endpoints
5. **Graceful Shutdown** - Use proper signal handling

### Security Considerations

⚠️ **IMPORTANT**: This repository is PUBLIC!

- **NEVER** commit credentials, API keys, or secrets
- **ALWAYS** use `.env` files (add to `.gitignore`)
- **REMOVE** sensitive data before sharing
- **VALIDATE** all user inputs in scripts
- **REVIEW** code for command injection vulnerabilities
- **TEST** in isolated environments first

---

## 🛠️ Working with This Repository as an AI Assistant

### Understanding Code Status

When analyzing code in this repository:

1. **Check for Status Indicators** - Look for ✅/⚠️/🧪/📚 tags
2. **Read Comments Carefully** - Important context is in Portuguese comments
3. **Validate Dependencies** - Check version requirements
4. **Understand Environment** - Note target OS, Docker versions, etc.

### Making Modifications

1. **Preserve Existing Patterns**
   - Maintain logging structure
   - Keep color coding consistent
   - Follow error handling patterns

2. **Enhance, Don't Replace**
   - Add features incrementally
   - Maintain backward compatibility when possible
   - Document breaking changes clearly

3. **Test Comprehensively**
   - Test happy paths
   - Test error conditions
   - Test edge cases (empty inputs, special characters, etc.)

4. **Document Changes**
   - Update relevant README files
   - Add inline comments for complex logic
   - Update CLAUDE.md if structure changes

### Common Tasks for AI Assistants

#### Adding a New Deployment Script

1. Place in appropriate directory (`bash/` or `react/`)
2. Follow naming conventions
3. Include comprehensive header:
   ```bash
   #!/bin/bash
   #==============================================================================
   # Script Name - Version
   # Author: Name
   # Description: What it does
   #==============================================================================
   ```
4. Add to relevant README
5. Test thoroughly
6. Mark with appropriate status tag

#### Debugging Deployment Issues

1. **Check Logs First**
   ```bash
   # For auto-deploy scripts
   tail -f /opt/docker/apps/cortex/myfuckexam/logs/deploy-*.log

   # For React apps
   manage-apps logs {app-name}
   docker-compose logs
   ```

2. **Verify System Requirements**
   - Docker version
   - Available disk space
   - Port availability
   - File permissions

3. **Check Configuration**
   - .env file validity
   - docker-compose.yml syntax
   - Nginx configuration

4. **Common Issues**
   - Port conflicts → Use different port or stop conflicting service
   - Permission denied → Check file ownership and chmod
   - Image build fails → Check Dockerfile syntax and dependencies
   - Health check fails → Verify endpoint URLs and service startup time

#### Updating Documentation

1. **Keep Consistency**
   - Match existing tone and style
   - Use same formatting patterns
   - Maintain bilingual approach (EN structure, PT comments)

2. **Update Multiple Locations**
   - Main README.md
   - Directory-specific READMEs
   - CLAUDE.md (this file)
   - Inline code comments

---

## 📊 Project Standards

### Minimum Requirements

For deployment scripts to work:

- **OS**: Ubuntu 20.04+ / Debian 10+
- **CPU**: 1+ cores
- **RAM**: 1+ GB (2GB recommended)
- **Disk**: 10+ GB free space
- **Access**: Root or sudo privileges
- **Network**: Internet access for Docker pulls

### Performance Optimizations

Scripts include:
- ⚡ Multi-stage Docker builds
- 🗜️ Gzip compression
- 💾 Static asset caching
- 🔒 Security headers
- 🏥 Integrated health checks
- 🔄 Hot reload in development

---

## 🚨 Important Disclaimers

### Code Validation Levels

This repository contains code at various validation stages:

1. **Validated** (✅) - Tested in documented environments
2. **Not Validated** (⚠️) - Functional but not extensively tested
3. **Experimental** (🧪) - PoC, studies, or examples
4. **Educational** (📚) - For learning purposes

### Responsibility

**CRITICAL**: Users assume ALL responsibility:

- ❌ **No guarantees** of functionality in all environments
- ❌ **No warranty** for data loss, system failures, or security issues
- ❌ **No liability** for direct or indirect damages
- ✅ **Testing required** before production use
- ✅ **Technical knowledge required** - understand before executing
- ✅ **User accepts all risks** associated with usage

### Security Stance

- Review ALL code before execution
- Test in isolated environments
- Remove credentials before adapting
- Validate compatibility with your versions
- Understand implications of every command

---

## 🤝 Contribution Guidelines

### Who Can Contribute

- **Anyone** - Beginner to expert, human or AI
- **No hierarchies** - Quality matters, not credentials
- **Collaborative spirit** - Help others learn

### What to Contribute

- ✅ New deployment scripts or tools
- ✅ Bug fixes and improvements
- ✅ Documentation enhancements
- ✅ Examples and tutorials
- ✅ Performance optimizations
- ✅ Security improvements

### Contribution Standards

1. **Documentation** - All code must be well-documented
2. **Comments** - Explain complex sections (in Portuguese for pt-BR audience)
3. **Status** - Clearly mark validation status
4. **README** - Add or update relevant README files
5. **Clean Code** - Follow best practices
6. **Security** - Remove all sensitive information
7. **Testing** - Test before submitting

### PR Process

1. Fork repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes following conventions
4. Test thoroughly in safe environment
5. Commit with clear messages (feat/fix/docs/refactor/test)
6. Push to your fork: `git push origin feature/my-feature`
7. Open Pull Request with detailed description

---

## 📚 Additional Resources

### Documentation Files

- `README.md` - Main repository overview
- `react/README.md` - Quick start for React deployment
- `react/README-DOCKER.md` - Docker-specific guide
- `react/guia-completo.md` - Complete guide (Portuguese)
- `LICENSE` - MIT License terms

### External References

- [Docker Documentation](https://docs.docker.com)
- [Docker Compose](https://docs.docker.com/compose/)
- [React Documentation](https://react.dev)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Node.js Documentation](https://nodejs.org/docs)

### Useful Commands

```bash
# Repository exploration
tree -L 3 -a                    # View structure
git log --oneline               # View commit history
find . -type f -name "*.sh"     # Find all shell scripts

# Docker operations
docker ps                       # List running containers
docker images                   # List images
docker-compose logs -f          # Follow logs
docker system prune -a          # Clean everything

# System checks
df -h                          # Disk space
netstat -tuln                  # Port usage
systemctl status docker        # Docker status
```

---

## 🎓 Learning from This Repository

### For Beginners

Start with:
1. Read main README.md thoroughly
2. Review `react/README.md` for practical examples
3. Study `install.sh` to understand system setup
4. Try `quick.sh` for hands-on deployment

### For Intermediate Users

Explore:
1. `auto-deploy.sh` for advanced bash patterns
2. Docker multi-stage builds in `Dockerfile`
3. Nginx optimization in `nginx.conf`
4. Error handling and logging patterns

### For Advanced Users

Deep dive:
1. Contribute optimizations
2. Add new deployment targets
3. Enhance security features
4. Create advanced automation workflows

---

## 🔄 Repository Maintenance

### Regular Updates

This repository is actively maintained:

- ⭐ Star for updates
- 👁️ Watch for notifications
- 🔔 Follow releases

### Reporting Issues

- **Bugs**: Open issue with detailed reproduction steps
- **Questions**: Use Discussions
- **Suggestions**: Open issue with "enhancement" label

### Getting Help

1. **Read Documentation** - Check README files first
2. **Search Issues** - Problem might be known
3. **Ask in Discussions** - Community can help
4. **Open Issue** - For new bugs or features

---

## 📝 Version History

### Current Structure (v1.0)
- ✅ Auto-deploy scripts for containerized apps
- ✅ Complete React deployment system
- ✅ Docker + Nginx optimization
- ✅ Interactive management tools
- ✅ Comprehensive documentation

### Planned Additions (Organic Growth)
- 📋 DevOps/SecOps stacks (K8s, CI/CD, IaC)
- 🤖 AI/ML integrations (n8n, LLMs, RAG)
- 🗄️ Database scripts and queries
- 🔒 Enhanced security features
- 📊 Monitoring and observability tools

---

## 👤 About the Author

**Amândio Vaz**
- **Role**: Infrastructure, Security & Observability Engineering
- **Experience**: 20+ years in IT
- **Philosophy**: Knowledge sharing over knowledge hoarding
- **GitHub**: [@amandio-vaz](https://github.com/amandio-vaz)

### Motivation

After 20+ years in IT, this repository is a response to the "knowledge guardian" culture - professionals who hoard information instead of sharing it. This is a space for **genuine collaboration, mutual learning, and collective growth**.

> "We grow when we share. We evolve when we collaborate."

---

## ✨ Quick Reference for AI Assistants

### Repository Type
Public code sharing repository with deployment automation tools

### Primary Language
Bash scripts with some configuration files (YAML, conf)

### Code Language
- Scripts: Bash
- Comments: Portuguese (pt-BR)
- Documentation: English structure, Portuguese details

### Target Audience
Developers, DevOps engineers, system administrators, AI assistants

### Deployment Targets
- Docker containerized applications
- React.js frontend applications
- Node.js backend services
- Nginx web servers

### Key Files to Reference
- `bash/apps-ai/auto-deploy.sh` - Main deployment automation
- `react/install.sh` - System installer
- `react/manage-apps.sh` - Application manager
- `README.md` - Repository overview

### Common Operations
1. **Full app deployment**: `bash/apps-ai/auto-deploy.sh`
2. **React app setup**: `react/install.sh` → `deploy-app`
3. **App management**: `manage-apps list|start|stop|logs`
4. **Debugging**: Check logs in `/opt/docker/apps/*/logs/` or `/opt/apps/*/`

### Warning Flags
- 🚨 Always test in isolated environments
- 🚨 Remove credentials before committing
- 🚨 Validate all user inputs
- 🚨 Check system requirements before deployment

---

**Made with ❤️ by a simple human, for humans and non-humans**

*Last updated: 2025-11-21*
