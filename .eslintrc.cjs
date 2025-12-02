module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true,
    node: true,
    deno: true, // Add Deno environment
  },
  globals: {
    Deno: 'readonly', // Define Deno as global for Supabase functions
  },
  extends: [
    'plugin:vue/vue3-recommended',
    'eslint:recommended',
    '@typescript-eslint/recommended',
    'prettier',
  ],
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: ['vue', '@typescript-eslint', 'prettier'],
  rules: {
    'prettier/prettier': 'error',
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'vue/multi-word-component-names': 'off',
    'no-undef': 'error', // Re-enable no-undef with Deno global defined
  },
  ignorePatterns: [
    'dist/**',
    'node_modules/**',
    // 'supabase/functions/**', // Removed to enable ESLint for Supabase functions
  ],
}
