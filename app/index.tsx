import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import FileRoutes from "@core/route";

import "./index.css";

/**
 * 수정 금지
 */

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <FileRoutes />
      </BrowserRouter>
    </QueryClientProvider>
  </React.StrictMode>,
);
