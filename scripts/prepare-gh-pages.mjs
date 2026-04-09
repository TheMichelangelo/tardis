import { copyFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const projectRoot = process.cwd();
const distRoot = join(projectRoot, 'dist');
const indexPath = join(distRoot, 'index.html');
const fallbackPath = join(distRoot, '404.html');

if (!existsSync(indexPath)) {
  console.error('Cannot create GitHub Pages fallback: dist/index.html was not found.');
  process.exit(1);
}

copyFileSync(indexPath, fallbackPath);
console.log('Created dist/404.html for GitHub Pages SPA fallback.');
