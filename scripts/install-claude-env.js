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
const current = settings.env.PATH || "${PATH}";
settings.env.PATH = current.includes(prefix) ? current : `${prefix}:${current}`;

fs.writeFileSync(settingsPath, `${JSON.stringify(settings, null, 2)}\n`);
console.log(`safe-install: updated Claude PATH in ${settingsPath}`);
