#!/usr/bin/env node
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const settingsPath = process.argv[2] || path.join(process.env.HOME || "", ".claude", "settings.json");

if (!settingsPath || !fs.existsSync(settingsPath)) {
  console.error(`safe-install: Claude settings not found: ${settingsPath}`);
  process.exit(2);
}

const settings = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
settings.env = settings.env || {};

const prefix = path.join(root, "bin");
const fallbackPath = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
const current = [settings.env.PATH || "", process.env.PATH || "", fallbackPath].join(":");
const seen = new Set();
const parts = current
  .split(":")
  .filter((part) => part && part !== "${PATH}" && part !== "$PATH")
  .filter((part) => path.basename(part) !== "bin" || path.basename(path.dirname(part)) !== "safe-install")
  .filter((part) => !part.includes("/.codex/tmp/"))
  .filter((part) => !part.includes("/codex.system/"))
  .filter((part) => !part.startsWith("/Applications/Codex.app/"))
  .filter((part) => {
    if (seen.has(part)) {
      return false;
    }
    seen.add(part);
    return true;
  });
settings.env.PATH = [prefix, ...parts].join(":");

fs.writeFileSync(settingsPath, `${JSON.stringify(settings, null, 2)}\n`);
console.log(`safe-install: updated Claude PATH in ${settingsPath}`);
