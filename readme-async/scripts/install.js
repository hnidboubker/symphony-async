#!/usr/bin/env node
// install.js — Install readme-async skill into a project (Node.js version for npm/npx)

import {
  copyFileSync,
  cpSync,
  existsSync,
  mkdirSync,
  readdirSync,
  rmSync,
  statSync,
} from 'fs';
import { dirname, join, relative, resolve } from 'path';
import { fileURLToPath } from 'url';
import { prompt } from './prompt.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const SKILL_NAME = 'readme-async';
const SCRIPT_DIR = __dirname;

// The root of the readme-async package itself.
const SKILL_SOURCE_DIR = resolve(SCRIPT_DIR, '..');

// The project where the skill should be installed.
const TARGET_DIR = resolve(process.argv[2] || process.cwd());

const log = (msg) =>
  console.log('\x1b[1;32m[INFO]\x1b[0m', msg);

const err = (msg) =>
  console.error('\x1b[1;31m[ERROR]\x1b[0m', msg);

const warn = (msg) =>
  console.warn('\x1b[1;33m[WARN]\x1b[0m', msg);

/**
 * Returns true if target is the same directory as source
 * or is located somewhere inside source.
 */
function isInside(source, target) {
  const relativePath = relative(source, target);

  return (
    relativePath === '' ||
    (!relativePath.startsWith('..') && !relativePath.startsWith('/'))
  );
}

async function main() {
  log(`Installing ${SKILL_NAME} skill...`);
  log(`Source: ${SKILL_SOURCE_DIR}`);
  log(`Target: ${TARGET_DIR}`);

  // Validate target
  if (!existsSync(TARGET_DIR) || !statSync(TARGET_DIR).isDirectory()) {
    err(`Target directory not found: ${TARGET_DIR}`);
    process.exit(1);
  }

  /*
   * Prevent recursive/self installation.
   *
   * This happens when npm install is executed directly inside
   * the readme-async repository itself, for example in CI:
   *
   * /home/runner/work/readme-async/readme-async
   *
   * In that case the package source is already the target.
   */
  if (isInside(SKILL_SOURCE_DIR, TARGET_DIR)) {
    log('Target is inside the readme-async package source directory.');
    log('Skipping self-installation.');
    return;
  }

  const skillsDir = join(TARGET_DIR, '.claude', 'skills');
  const targetSkillDir = join(skillsDir, SKILL_NAME);

  // Create .claude/skills if needed
  if (!existsSync(skillsDir)) {
    mkdirSync(skillsDir, { recursive: true });
  }

  // Check if already installed
  if (existsSync(targetSkillDir)) {
    warn(`Skill already installed at ${targetSkillDir}`);

    const answer = await prompt('Overwrite? (y/N) ');

    if (!/^[Yy]$/.test(answer.trim())) {
      log('Installation cancelled');
      process.exit(0);
    }

    rmSync(targetSkillDir, {
      recursive: true,
      force: true,
    });
  }

  // Copy skill files
  log('Copying skill files...');

  const exclude = new Set([
    'scripts',
    'install.sh',
    'install.ps1',
    'install.js',
    'prompt.js',
    'package.json',
    'package-lock.json',
    'node_modules',
  ]);

  for (const entry of readdirSync(SKILL_SOURCE_DIR, {
    withFileTypes: true,
  })) {
    if (exclude.has(entry.name)) {
      continue;
    }

    const src = join(SKILL_SOURCE_DIR, entry.name);
    const dest = join(targetSkillDir, entry.name);

    if (entry.isDirectory()) {
      cpSync(src, dest, {
        recursive: true,
      });
    } else {
      mkdirSync(targetSkillDir, {
        recursive: true,
      });

      copyFileSync(src, dest);
    }
  }

  log(`Skill installed successfully at ${targetSkillDir}`);
  log('');
  log('To use the skill, run:');
  log('  /skill readme-async');
  log('');
  log('Or add to your CLAUDE.md:');
  log('  - readme-async: Keep README.md synchronized with codebase');
}

main().catch((e) => {
  err(e.message);
  process.exit(1);
});