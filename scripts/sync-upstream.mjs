// 从 npm 拉取上游 dsh-thinking-slider 的浏览器端产物，注入档位名映射，写进 lib/client.js。
//
//   node scripts/sync-upstream.mjs 0.3.3
//
// 上游换了版本时跑一次，然后把 package.json 的 version 改成 `<upstream>-liang.N`。
// 脚本会校验锚点行是否存在 —— 上游若改了那段代码结构，它会直接报错而不是产出坏包。
import { createHash } from 'node:crypto'
import { mkdirSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

/** 档位 id → 显示名。改这里就能换名字，不用碰上游代码。 */
const NAMES = { off: '小难梁', low: '梁子', high: '梁圣', max: '梁祖' }

const version = process.argv[2]
if (!version) {
  console.error('用法: node scripts/sync-upstream.mjs <upstream-version>')
  process.exit(1)
}

const ANCHOR = '      const efforts = Array.isArray(currentModel?.reasoning?.efforts) ? currentModel.reasoning.efforts : []'

const replacement = [
  `      const LIANG_LEVEL_NAMES = ${JSON.stringify(NAMES)}`,
  '      const efforts = (Array.isArray(currentModel?.reasoning?.efforts) ? currentModel.reasoning.efforts : [])',
  '        .map((level) => level !== null && level !== undefined && LIANG_LEVEL_NAMES[level.id] !== undefined',
  '          ? { ...level, name: LIANG_LEVEL_NAMES[level.id] }',
  '          : level)',
].join('\n')

const url = `https://unpkg.com/dsh-thinking-slider@${version}/lib/client.js`
const response = await fetch(url)
if (!response.ok) {
  console.error(`拉取失败 ${url} -> HTTP ${response.status}`)
  process.exit(1)
}
const source = await response.text()

const hits = source.split(ANCHOR).length - 1
if (hits !== 1) {
  console.error(`锚点行出现 ${hits} 次（期望 1 次）。上游 ${version} 的代码结构变了，需要人工检查。`)
  process.exit(1)
}

const patched = source.replace(ANCHOR, replacement)
const outDir = join(dirname(fileURLToPath(import.meta.url)), '..', 'lib')
mkdirSync(outDir, { recursive: true })
const outFile = join(outDir, 'client.js')
writeFileSync(outFile, patched, 'utf8')

const sha = createHash('sha256').update(patched).digest('hex')
console.log(`上游版本 : ${version}`)
console.log(`写入     : lib/client.js (${patched.length} 字节)`)
console.log(`sha256   : ${sha}`)
