module.exports = {
  apps: [{
    name: 'puppeteer-app',
    script: './server.js',
    instances: 1,
    exec_mode: 'fork',

    // Restart settings
    autorestart: true,
    watch: false,
    max_restarts: 10,
    min_uptime: '10s',
    restart_delay: 4000,

    // Memory management
    max_memory_restart: '3G',

    // Error handling
    error_file: './logs/error.log',
    out_file: './logs/output.log',
    log_file: './logs/combined.log',
    time: true,

    // Environment variables
    env: {
      NODE_ENV: 'production',
      PUPPETEER_SKIP_CHROMIUM_DOWNLOAD: 'false',
    },

    // Graceful shutdown
    kill_timeout: 5000,
    listen_timeout: 3000,

    // Crash handling
    exp_backoff_restart_delay: 100,
  }]
};