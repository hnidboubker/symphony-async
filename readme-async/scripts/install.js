#!/usr/bin/env node
// install.js — Verify readme-async skill installation in symphony-async project

import {
  existsSync,
  statSync,
  readFileSync,
} from 'fs';
import { dirname, join, resolve } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const SKILL_NAME = 'readme-async';
const SCRIPT_DIR = __dirname;
const SKILL_SOURCE_DIR = resolve(SCRIPT_DIR, '..');
const REPO_ROOT = resolve(SKILL_SOURCE_DIR, '..');

const log = (msg) =>
  console.log('\x1b[1;32m[INFO]\x1b[0m', msg);

const err = (msg) =>
  console.error('\x1b[1;31m[ERROR]\x1b[0m', msg);

const warn = (msg) =>
  console.warn('\x1b[1;33m[WARN]\x1b[0m', msg);

async function main() {
  log(`Verifying ${SKILL_NAME} skill installation...`);
  log(`Repository root: ${REPO_ROOT}`);
  log(`Skill directory: ${SKILL_SOURCE_DIR}`);

  // 1. Verify Node.js is installed
  try {
    const { execSync } = await import('child_process');
    const nodeVersion = execSync('node --version', { encoding: 'utf8' }).trim();
    log(`✓ Node.js found: ${nodeVersion}`);
  } catch {
    err('Node.js is not installed or not in PATH');
    process.exit(1);
  }

  // 2. Verify npm is installed
  try {
    const { execSync } = await import('child_process');
    const npmVersion = execSync('npm --version', { encoding: 'utf8' }).trim();
    log(`✓ npm found: ${npmVersion}`);
  } catch {
    err('npm is not installed or not in PATH');
    process.exit(1);
  }

  // 3. Verify package.json exists and is valid
  const packageJsonPath = join(SKILL_SOURCE_DIR, 'package.json');
  if (!existsSync(packageJsonPath)) {
    err(`package.json not found at ${packageJsonPath}`);
    process.exit(1);
  }

  let packageJson;
  try {
    packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
    log(`✓ package.json valid: ${packageJson.name}@${packageJson.version}`);
  } catch (e) {
    err(`Invalid package.json: ${e.message}`);
    process.exit(1);
  }

  // 4. Verify SKILL.md exists
  const skillMdPath = join(SKILL_SOURCE_DIR, 'SKILL.md');
  if (!existsSync(skillMdPath)) {
    err(`SKILL.md not found at ${skillMdPath}`);
    process.exit(1);
  }
  log('✓ SKILL.md found');

  // 5. Verify references/CONTEXT.md exists
  const contextMdPath = join(SKILL_SOURCE_DIR, 'references', 'CONTEXT.md');
  if (!existsSync(contextMdPath)) {
    warn(`references/CONTEXT.md not found at ${contextMdPath}`);
  } else {
    log('✓ references/CONTEXT.md found');
  }

  // 6. Verify scripts directory exists
  const scriptsDir = join(SKILL_SOURCE_DIR, 'scripts');
  if (!existsSync(scriptsDir) || !statSync(scriptsDir).isDirectory()) {
    err(`scripts directory not found at ${scriptsDir}`);
    process.exit(1);
  }
  log('✓ scripts directory found');

  // 7. Verify install scripts exist
  const requiredScripts = ['install.js', 'install.sh', 'install.ps1', 'prompt.js'];
  for (const script of requiredScripts) {
    const scriptPath = join(scriptsDir, script);
    if (!existsSync(scriptPath)) {
      warn(`Script not found: ${script}`);
    } else {
      log(`✓ ${script} found`);
    }
  }

  // 8. Check if dependencies are installed (node_modules)
  const nodeModulesPath = join(SKILL_SOURCE_DIR, 'node_modules');
  if (!existsSync(nodeModulesPath)) {
    warn('Dependencies not installed. Run "npm install" in the readme-async directory.');
  } else {
    log('✓ Dependencies installed (node_modules found)');
  }

  // 9. Verify the skill is properly registered in the symphony-async structure
  const symphonySkillDir = join(REPO_ROOT, '.claude', 'skills', SKILL_NAME);
  if (existsSync(symphonySkillDir)) {
    log(`✓ Skill registered in symphony-async at ${symphonySkillDir}`);
  } else {
    log('');
    log('Note: Skill is not yet registered in symphony-async/.claude/skills/');
    log('To register, run:');
    log('  bash scripts/install.sh');
    log('  or: pwsh scripts/install.ps1');
  }

  log('');
  log('=== Verification Complete ===');
  log('');
  log('To use the skill in this project:');
  log('  /skill readme-async');
  log('');
  log('To install this skill into another project:');
  log('  npx readme-async [target-project-path]');
  log('  or: bash scripts/install.sh [target-project-path]');
}

main().catch((e) => {
  err(e.message);
  process.exit(1);
});