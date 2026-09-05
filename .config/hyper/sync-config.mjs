import { writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { basename, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { inspect } from "node:util";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const linuxHome = resolve(scriptDir, "../..");
const linuxUser = basename(linuxHome);

const sourcePath = resolve(linuxHome, ".hyper.js");
const targetPath = resolve(
  "/mnt/c/Users",
  linuxUser,
  "AppData/Roaming/Hyper/.hyper.js",
);

const require = createRequire(import.meta.url);
delete require.cache[require.resolve(sourcePath)];

const source = require(sourcePath);

const config = {
  ...source.config,
  shell: "C:\\Windows\\System32\\wsl.exe",
  shellArgs: [
    "-d",
    "Ubuntu",
    "-u",
    linuxUser,
    "--cd",
    "~",
    "--exec",
    "zsh",
    "--login",
  ],
  paneNavigation: {
    ...source.config?.paneNavigation,
    hotkeys: {
      ...source.config?.paneNavigation?.hotkeys,
      navigation: {
        left: "ctrl+shift+h",
        down: "ctrl+shift+j",
        up: "ctrl+shift+k",
        right: "ctrl+shift+l",
      },
    },
  },
};

const output = `"use strict";

module.exports = ${inspect(
  {
    ...source,
    config,
  },
  {
    depth: null,
    compact: false,
    sorted: false,
  },
)};
`;

writeFileSync(targetPath, output);
