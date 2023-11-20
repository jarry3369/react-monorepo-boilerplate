import * as React from "react";
import "vite/client";

interface Window {
  dataLayer: unknown[];
}

interface ImportMetaEnv {
  readonly VITE_CONFIG: string;
}

declare module "relay-runtime" {
  interface PayloadError {
    errors?: Record<string, string[] | undefined>;
  }
}

declare module "*.css";

declare module "*.svg" {
  const content: React.FC<React.SVGProps<SVGElement>>;
  export default content;
}
