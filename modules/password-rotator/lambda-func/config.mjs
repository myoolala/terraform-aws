import fs from 'fs';

const defaultConfig = {
  hookFilePath: '/opt/hooks.mjs',
  logLevel: 'INFO',
};

function loadFileConfig(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(content);
  } catch (_) {
    return null;
  }
}

function loadEnvConfig() {
  const cfg = {};
  Object.keys(process.env).forEach((k) => {
    const v = process.env[k];
    if (/^(true|false)$/i.test(v)) cfg[k] = v.toLowerCase() === 'true';
    else if (!Number.isNaN(Number(v))) cfg[k] = Number(v);
    else {
      try {
        cfg[k] = JSON.parse(v);
      } catch (_) {
        cfg[k] = v;
      }
    }
  });
  return cfg;
}

function validateConfig(cfg) { /* no-op for test */ }
export async function loadConfig() {
  const fileCfg = loadFileConfig('/opt/config.json');
  const envCfg = loadEnvConfig();
  const cfg = { ...defaultConfig, ...fileCfg, ...envCfg };
  validateConfig(cfg);
  return cfg;
}
