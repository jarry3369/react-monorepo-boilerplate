import { expect, test } from "vitest";

test("example", () => {
  expect({ pass: true }).toMatchInlineSnapshot(`
    {
      "pass": true,
    }
  `);
});
