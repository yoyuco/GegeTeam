module.exports = {
  env: {
    browser: false,
    es2021: true,
    deno: true, // Enable Deno environment
  },
  globals: {
    Deno: 'readonly', // Define Deno as a global readonly variable
  },
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  rules: {
    'no-undef': 'off', // Disable no-undef for Deno globals
  },
}
