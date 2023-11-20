import react from "@vitejs/plugin-react-swc";
import { defineProject } from "vitest/config";

/**
 * Vite configuration
 * https://vitejs.dev/config/
 */

process.env.VITE_CONFIG;

export default defineProject(async ({ mode }) => {
  return {
    envDir: `${__dirname}/../env`,
    cacheDir: `../.cache/vite-app`,
    optimizeDeps: {
      include: ["linked-dep"],
    },
    build: {
      commonjsOptions: {
        include: [/linked-dep/, /node_modules/],
      },
      rollupOptions: {
        output: {
          manualChunks: {
            react: ["react", "react-dom", "react-router-dom"],
          },
        },
      },
    },

    plugins: [react()],

    resolve: {
      alias: [
        { find: "@", replacement: "./" },
        { find: "@core", replacement: "./core" },
        { find: "@components", replacement: "./components" },
      ],
    },
    // server: {
    //   proxy: {
    //     "/api": {
    //       target: process.env.LOCAL_API_ORIGIN ?? process.env.API_ORIGIN,
    //       changeOrigin: true,
    //     },
    //   },
    // },

    test: {
      ...{ cache: { dir: "../.cache/vitest" } },
      environment: "happy-dom",
    },
  };
});
