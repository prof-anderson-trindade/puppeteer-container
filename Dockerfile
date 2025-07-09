# Use a imagem oficial do Node.js
FROM node:20-slim

# Define argumentos de build para UID e GID
ARG USER_UID=1000
ARG USER_GID=1000

# Instala as dependências necessárias para o Puppeteer
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Define variáveis de ambiente para o Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# Copia apenas os arquivos de dependências primeiro
COPY package.json package-lock.json* ./

# Cria usuário apropriado baseado no UID/GID
RUN if [ "${USER_UID}" = "1000" ] && [ "${USER_GID}" = "1000" ]; then \
        echo "Using existing node user (UID 1000)" && \
        echo "PUPPETEER_CACHE_DIR=/home/node/.cache/puppeteer" >> /etc/environment; \
    else \
        echo "Creating new appuser with UID ${USER_UID}" && \
        groupadd -g ${USER_GID} appuser && \
        useradd -m -u ${USER_UID} -g ${USER_GID} appuser && \
        echo "PUPPETEER_CACHE_DIR=/home/appuser/.cache/puppeteer" >> /etc/environment; \
    fi

# Cria diretórios necessários baseado no usuário
RUN if [ "${USER_UID}" = "1000" ] && [ "${USER_GID}" = "1000" ]; then \
        mkdir -p /home/node/.cache/puppeteer /app/logs; \
    else \
        mkdir -p /home/appuser/.cache/puppeteer /app/logs; \
    fi

# Instala as dependências do npm como root
RUN npm ci || npm install

# Instala PM2 globalmente
RUN npm install -g pm2

# Copia o arquivo de configuração do PM2 (se existir)
COPY ecosystem.config.js* ./

# Adiciona o usuário aos grupos necessários e ajusta permissões
RUN if [ "${USER_UID}" = "1000" ] && [ "${USER_GID}" = "1000" ]; then \
        usermod -a -G audio,video node && \
        chown -R node:node /app /home/node; \
    else \
        usermod -a -G audio,video appuser && \
        chown -R appuser:appuser /app /home/appuser; \
    fi

# Muda para o usuário apropriado
# Se UID=1000, usa node. Senão, usa appuser
USER ${USER_UID}

RUN npx puppeteer browsers install

# Expõe a porta do servidor
EXPOSE 3000

# Comando padrão
CMD ["sh", "-c", "if [ -f ecosystem.config.js ]; then pm2-runtime start ecosystem.config.js; else pm2-runtime start server.js --name puppeteer-app; fi"]