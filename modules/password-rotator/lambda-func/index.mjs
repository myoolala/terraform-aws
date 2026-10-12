import fs from 'fs';
import { loadConfig } from './config.mjs';

let hooks = {};

async function callHook(name, ...args) {
  if (hooks && typeof hooks[name] === 'function') {
    try {
      return await hooks[name](...args);
    } catch (e) {
      console.warn(`Hook ${name} error`, e);
    }
  }
}

export const handler = async () => {
  const cfg = await loadConfig();
  const hookFilePath = cfg.hookFilePath || '/opt/hooks.mjs';
  try {
    if (!fs.existsSync(hookFilePath)) {
      throw new Error(`Hook file not found at ${hookFilePath}`);
    }
    const mod = await import('file://' + hookFilePath);
    hooks = mod.default ?? {}; // exports default object of hooks
  } catch (e) {
    throw new Error(`Failed to import hooks from ${hookFilePath}: ${e.message}`);
  }

  try {
    // onStart
    await callHook('onStart');

    // getCurrentCredentials
    const currentCreds = await callHook('getCurrentCredentials');

    // generateCredentials
    const newCreds = await callHook('generateCredentials');

    // updateCredentials
    const updatedCreds = await callHook('updateCredentials', currentCreds, newCreds);

    // storeCredentials
    const storeResult = await callHook('storeCredentials', updatedCreds);

    // revert if store failed
    if (!storeResult) {
      await callHook('revertCredentials', updatedCreds);
    }

    // onComplete
    await callHook('onComplete');
  } catch (err) {
    // onFail with error
    await callHook('onFail', err);
    throw err;
  }
};
