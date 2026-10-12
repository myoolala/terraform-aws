// Test harness for password-rotator Lambda hooks

import fs from 'fs';
import { handler } from './index.mjs';

const createHookFile = (path, hooks) => {
  const content = `export default ${JSON.stringify(hooks, null, 2)};`;
  fs.writeFileSync(path, content, 'utf8');
  process.env.hookFilePath = path;
};

const runTest = async (name, hooks, expectedOrder, expectedRevert = false, shouldThrow = false) => {
  const hookPath = `temp-${name}.hooks.mjs`;
  createHookFile(hookPath, hooks);
  const order = [];
  const errors = [];
  // Replace hooks to push into order
  const wrappedHooks = {
    onStart: async () => order.push('onStart'),
    getCurrentCredentials: async () => { order.push('getCurrent'); return {}; },
    generateCredentials: async () => { order.push('generate'); return {}; },
    updateCredentials: async () => { order.push('update'); return {}; },
    storeCredentials: async () => { order.push('store'); return hooks.store ?? true; },
    revertCredentials: async () => { order.push('revert'); },
    onComplete: async () => order.push('complete'),
    onFail: async (err) => { errors.push(err); order.push('fail'); }
  };
  // Write wrapped hooks
  const content = `export default ${JSON.stringify(wrappedHooks, null, 2)};`;
  fs.writeFileSync(hookPath, content, 'utf8');
  process.env.hookFilePath = hookPath;

  try {
    await handler();
    if (shouldThrow) throw new Error('Expected handler to throw');
  } catch (e) {
    if (!shouldThrow) throw e;
  }

  const passed = JSON.stringify(order) === JSON.stringify(expectedOrder);
  console.log(`Test ${name} ${passed ? 'PASSED' : 'FAILED'}`);
  if (!passed) {
    console.log('Expected order:', expectedOrder);
    console.log('Actual order  :', order);
  }
  if (expectedRevert) {
    const revertCalled = order.includes('revert');
    console.log(`Revert ${revertCalled ? 'called' : 'NOT called'} as expected`);
  }
  if (shouldThrow) {
    console.log('Errors captured:', errors.length > 0 ? errors[0].message : 'none');
  }
};

(async () => {
  // Test 1: normal order
  await runTest('order', {}, ['onStart','getCurrent','generate','update','store','complete']);

  // Test 2: store failure triggers revert
  await runTest('revert', { store: false }, ['onStart','getCurrent','generate','update','store','revert','complete'], true);

  // Test 3: hook throws error, onFail called
  await runTest('error', { getCurrent: async () => {throw new Error('oops');} }, [], false, true);
})();
