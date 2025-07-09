# 🎭 Puppeteer Docker Image

[![GitHub Actions](https://github.com/prof-anderson.trindade/puppeteer-docker/workflows/Build%20and%20Push%20Docker%20Image/badge.svg)](https://github.com/prof-anderson.trindade/puppeteer-docker/actions)
[![GitHub Package Registry](https://img.shields.io/badge/ghcr.io-available-brightgreen)](https://github.com/prof-anderson.trindade/puppeteer-docker/pkgs/container/puppeteer-docker)

Imagem Docker pronta para produção com Node.js 20 e Puppeteer, otimizada para ambientes headless.

## 🚀 Quick Start

```bash
docker pull ghcr.io/prof-anderson.trindade/puppeteer-docker:latest
```

## 📦 O que está incluído?

- Node.js 20 (slim)
- Puppeteer com todas as dependências
- Chrome/Chromium dependencies
- Usuário não-root configurado
- Suporte para AMD64 e ARM64

## 🔨 Uso

### Básico

```bash
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  ghcr.io/prof-anderson.trindade/puppeteer-docker:latest \
  node seu-script.js
```

### Docker Compose

```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/prof-anderson.trindade/puppeteer-docker:latest
    volumes:
      - ./:/app
    working_dir: /app
    command: node index.js
    cap_add:
      - SYS_ADMIN
    security_opt:
      - seccomp:unconfined
```

### Com package.json local

```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/prof-anderson.trindade/puppeteer-docker:latest
    volumes:
      - ./:/app
    working_dir: /app
    command: sh -c "npm install && npm start"
    cap_add:
      - SYS_ADMIN
```

## 💡 Exemplo de Script

```javascript
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu'
    ]
  });

  const page = await browser.newPage();
  await page.goto('https://example.com');
  
  const title = await page.title();
  console.log('Título:', title);
  
  await browser.close();
})();
```

## 🏷️ Tags Disponíveis

- `latest` - Última versão estável
- `main` - Build da branch principal
- `v1.0.0`, `v1.0`, `v1` - Versões semânticas

## 🔧 Build Local

```bash
# Clone o repositório
git clone https://github.com/prof-anderson.trindade/puppeteer-docker.git
cd puppeteer-docker

# Build
docker build -t ghcr.io/prof-anderson.trindade/puppeteer-docker:local .

# Testar localmente
docker run -it --rm ghcr.io/prof-anderson.trindade/puppeteer-docker:local node --version
```

## 📄 Licença

MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.