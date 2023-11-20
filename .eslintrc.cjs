module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
    es6: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "prettier",
  ],
  parserOptions: {
    ecmaVersion: 2023,
    sourceType: "module",
  },

  overrides: [
    {
      files: ["*.ts", "*.tsx"],
      parser: "@typescript-eslint/parser",
      extends: [
        "plugin:@typescript-eslint/recommended",
        "plugin:react/recommended",
        "plugin:react-hooks/recommended",
      ],
      rules: {
        "import/named": "off",
        "import/export": "off",
        "import/default": "off",
        "import/namespace": "off",
        "import/no-unresolved": "warn",
        "no-unused-vars": "off",
        "@typescript-eslint/no-unused-vars": "warn",
        "@typescript-eslint/no-explicit-any": "warn",
        "react/no-children-prop": "off",
        "react/jsx-uses-react": "off",
        "react/react-in-jsx-scope": "off",
      },
      plugins: ["@typescript-eslint"],
      parserOptions: {
        warnOnUnsupportedTypeScriptVersion: true,
      },
    },
    {
      files: [".eslintrc.cjs", "*/vite.config.ts", "scripts/**/*.js"],
      env: { node: true },
    },
    {
      files: ["*.cjs"],
      parserOptions: { sourceType: "script" },
    },
  ],

  ignorePatterns: ["/.cache", "/.git", "/*/dist"],

  settings: {
    "import/resolver": {
      typescript: {
        project: ["app/tsconfig.json", "scripts/tsconfig.json"],
      },
    },
    react: {
      version: "detect",
    },
  },
};
