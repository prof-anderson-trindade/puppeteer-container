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

# Define variáveis de ambiente para o Puppeteer ANTES da instalação
# Isso permite que o Puppeteer baixe o Chromium durante npm install
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
# ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV PUPPETEER_CACHE_DIR=/home/node/.cache/puppeteer

# Copia apenas os arquivos de dependências primeiro (para cache eficiente)
COPY package.json package-lock.json* ./

# Se o UID/GID for diferente de 1000, ajusta o usuário node
RUN if [ "$USER_UID" != "1000" ] || [ "$USER_GID" != "1000" ]; then \
        # Modifica o UID/GID do usuário node existente \
        groupmod -g ${USER_GID} node && \
        usermod -u ${USER_UID} -g ${USER_GID} node && \
        # Ajusta as permissões do home do usuário \
        chown -R ${USER_UID}:${USER_GID} /home/node; \
    fi

# Cria o diretório de cache do Puppeteer com permissões corretas
RUN mkdir -p /home/node/.cache/puppeteer && \
    chown -R node:node /home/node/.cache

# Instala as dependências do npm como root
RUN npm ci || npm install

# Instala PM2 globalmente
RUN npm install -g pm2

# Ajusta permissões do diretório de trabalho
RUN chown -R node:node /app

# Adiciona o usuário node aos grupos necessários para o Puppeteer
RUN usermod -a -G audio,video node

# Muda para o usuário node
USER node

# Expõe a porta do servidor
EXPOSE 3000

# Comando padrão - usando PM2
# Copia o arquivo de configuração do PM2 (se existir)
COPY ecosystem.config.js* ./

# Comando padrão - usando PM2 com ecosystem config ou fallback para server.js
CMD ["sh", "-c", "if [ -f ecosystem.config.js ]; then pm2-runtime start ecosystem.config.js; else pm2-runtime start server.js --name puppeteer-app; fi"]