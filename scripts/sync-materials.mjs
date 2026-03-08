import { cpSync, existsSync, mkdirSync, readdirSync, rmSync, statSync } from 'node:fs';
import { join } from 'node:path';

const projectRoot = process.cwd();
const sourceRoot = join(projectRoot, 'src', 'data');
const targetRoot = join(projectRoot, 'public', 'src', 'data');

function isLessonMaterialDir(name) {
  if (!name) return false;
  if (name.startsWith('.')) return false;
  // Keep only folders that store lesson assets.
  return name.startsWith('lesson-');
}

mkdirSync(targetRoot, { recursive: true });

// Clean existing synced lesson directories.
for (const entry of readdirSync(targetRoot)) {
  const full = join(targetRoot, entry);
  if (statSync(full).isDirectory()) {
    rmSync(full, { recursive: true, force: true });
  }
}

if (!existsSync(sourceRoot)) {
  console.log('No src/data directory found.');
  process.exit(0);
}

let copied = 0;
for (const entry of readdirSync(sourceRoot)) {
  const sourcePath = join(sourceRoot, entry);
  if (!statSync(sourcePath).isDirectory()) {
    continue;
  }
  if (!isLessonMaterialDir(entry)) {
    continue;
  }
  const targetPath = join(targetRoot, entry);
  cpSync(sourcePath, targetPath, { recursive: true });
  copied += 1;
}

console.log(`Synced ${copied} lesson material folder(s) to public/src/data.`);
