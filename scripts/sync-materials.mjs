import { cpSync, existsSync, mkdirSync, readdirSync, rmSync, statSync } from 'node:fs';
import { join } from 'node:path';

const projectRoot = process.cwd();
const sourceRoot = join(projectRoot, 'src', 'data');
const targetRoot = join(projectRoot, 'public', 'src', 'data');

mkdirSync(targetRoot, { recursive: true });
rmSync(targetRoot, { recursive: true, force: true });
mkdirSync(targetRoot, { recursive: true });

if (!existsSync(sourceRoot)) {
  console.log('No src/data directory found.');
  process.exit(0);
}

cpSync(sourceRoot, targetRoot, { recursive: true });
console.log('Synced downloadable lesson materials to public/src/data.');
