import { Fragment } from "react";
import { Routes, Route } from "react-router-dom";

type servedType = {
  [key: string | number | symbol]: any;
};

/**
 * File System 기반 라우터
 * 수정 금지
 */

const PRESERVED = import.meta.glob<Record<string, string>>("../pages/(_app|404).(js|jsx|ts|tsx)", {
  eager: true,
});
const ROUTES = import.meta.glob<Record<string, string>>("../pages/**/[a-z[]*.(js|jsx|ts|tsx)", {
  eager: true,
});

const preserve: servedType = Object.keys(PRESERVED).reduce((p, file) => {
  const key = file.replace(/\.\.\/pages\/|\.(js|jsx|ts|tsx)$/g, "");
  return { ...p, [key]: PRESERVED[file].default };
}, {});

const routes = Object.keys(ROUTES).map((route) => {
  const path = route
    .replace(/\.\.\/pages|index|\.(js|jsx|ts|tsx)$/g, "")
    .replace(/\[\.{3}[^/]+\]/, "*")
    .replace(/\[([^/]+)\]/g, ":$1");

  return { path, component: ROUTES[route].default };
});

export default function FileRoutes() {
  const App = preserve?.["_app"] || Fragment;
  const NotFound = preserve?.["404"] || Fragment;

  return (
    <App>
      <Routes>
        {routes.map(({ path, component: Component = Fragment }) => {
          return <Route key={path} path={path} element={<Component />} />;
        })}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </App>
  );
}
