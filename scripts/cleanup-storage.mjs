#!/usr/bin/env node
// path: scripts/cleanup-storage.mjs
//
// Dọn file cũ và file mồ côi trong bucket work-proofs.
//
// MẶC ĐỊNH LÀ CHẠY THỬ. Không xoá gì cho tới khi truyền --execute.
//
// Vì sao phải có script này thay vì chạy SQL: xoá dòng trong storage.objects
// KHÔNG xoá file thật dưới S3. Làm vậy chỉ mất dấu vết, dung lượng không giảm
// mà file thành rác vĩnh viễn không truy cập được. Xoá thật phải qua Storage API.
//
// Cách dùng:
//   export SUPABASE_URL=https://susuoambmzdmcygovkea.supabase.co
//   export SUPABASE_SERVICE_ROLE_KEY=...        # KHÔNG commit khoá này
//
//   node scripts/cleanup-storage.mjs                      # chạy thử, ghi manifest
//   node scripts/cleanup-storage.mjs --execute            # xoá thật
//   node scripts/cleanup-storage.mjs --orphans-only       # chỉ file mồ côi
//   node scripts/cleanup-storage.mjs --older-than "6 months"
//
// Trước khi xoá, script luôn ghi manifest đầy đủ ra ./storage-cleanup-manifest.json
// để còn đối chiếu về sau.

import { createClient } from '@supabase/supabase-js'
import { writeFileSync } from 'node:fs'
import { createInterface } from 'node:readline/promises'

const URL_SB = process.env.SUPABASE_URL
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!URL_SB || !KEY) {
  console.error('Thiếu biến môi trường SUPABASE_URL hoặc SUPABASE_SERVICE_ROLE_KEY.')
  process.exit(1)
}

const args = process.argv.slice(2)
const THUC_THI = args.includes('--execute')
const CHI_MO_COI = args.includes('--orphans-only')
const BUCKET = 'work-proofs'
const LO = 500 // Storage API nhận tối đa 1000 path mỗi lần; 500 cho chắc.

const i = args.indexOf('--older-than')
const MOC = i >= 0 && args[i + 1] ? args[i + 1] : '3 months'

const sb = createClient(URL_SB, KEY, { auth: { persistSession: false } })

const mb = (b) => (b / 1024 / 1024).toFixed(1) + ' MB'
const gb = (b) => (b / 1024 / 1024 / 1024).toFixed(2) + ' GB'

console.log(`Bucket:        ${BUCKET}`)
console.log(`Mốc thời gian: ${CHI_MO_COI ? '(bỏ qua, chỉ lấy mồ côi)' : 'cũ hơn ' + MOC}`)
console.log(`Chế độ:        ${THUC_THI ? '*** XOÁ THẬT ***' : 'chạy thử (không xoá gì)'}`)
console.log()

console.log('Đang lấy danh sách từ database...')
const { data: ds, error: loi } = await sb.rpc('storage_cleanup_candidates', {
  p_bucket: BUCKET,
  p_older_than: CHI_MO_COI ? '100 years' : MOC,
  p_include_orphans: true,
})

if (loi) {
  console.error('Không gọi được storage_cleanup_candidates:', loi.message)
  process.exit(1)
}
if (!ds?.length) {
  console.log('Không có file nào cần dọn.')
  process.exit(0)
}

const theoLyDo = {}
let tong = 0
for (const f of ds) {
  theoLyDo[f.ly_do] ??= { n: 0, bytes: 0 }
  theoLyDo[f.ly_do].n++
  theoLyDo[f.ly_do].bytes += Number(f.kich_thuoc || 0)
  tong += Number(f.kich_thuoc || 0)
}

console.log('\nSẽ xoá:')
for (const [ly_do, v] of Object.entries(theoLyDo)) {
  console.log(`  ${ly_do.padEnd(14)} ${String(v.n).padStart(6)} file   ${mb(v.bytes).padStart(12)}`)
}
console.log(`  ${'TỔNG'.padEnd(14)} ${String(ds.length).padStart(6)} file   ${gb(tong).padStart(12)}`)

const manifest = './storage-cleanup-manifest.json'
writeFileSync(
  manifest,
  JSON.stringify(
    { bucket: BUCKET, moc: MOC, chi_mo_coi: CHI_MO_COI, tao_luc: new Date().toISOString(), tong_file: ds.length, tong_bytes: tong, files: ds },
    null,
    2
  )
)
console.log(`\nĐã ghi manifest: ${manifest}`)

if (!THUC_THI) {
  console.log('\nĐây là chạy thử, không có gì bị xoá.')
  console.log('Chạy lại kèm --execute để xoá thật.')
  process.exit(0)
}

// Xoá thật thì bắt gõ xác nhận. Việc này không hoàn tác được.
const rl = createInterface({ input: process.stdin, output: process.stdout })
const tl = await rl.question(`\nXoá VĨNH VIỄN ${ds.length} file (${gb(tong)})? Gõ "XOA" để xác nhận: `)
rl.close()
if (tl.trim() !== 'XOA') {
  console.log('Đã huỷ.')
  process.exit(0)
}

let daXoa = 0
let loiXoa = 0
let bytesDaXoa = 0

for (let k = 0; k < ds.length; k += LO) {
  const lo = ds.slice(k, k + LO)
  const paths = lo.map((f) => f.duong_dan)
  const { error } = await sb.storage.from(BUCKET).remove(paths)
  if (error) {
    loiXoa += lo.length
    console.error(`  lô ${k / LO + 1}: LỖI — ${error.message}`)
  } else {
    daXoa += lo.length
    bytesDaXoa += lo.reduce((s, f) => s + Number(f.kich_thuoc || 0), 0)
    process.stdout.write(`\r  đã xoá ${daXoa}/${ds.length} file (${gb(bytesDaXoa)})   `)
  }
}

console.log(`\n\nXong. Đã xoá ${daXoa} file, giải phóng ${gb(bytesDaXoa)}.`)
if (loiXoa) console.log(`${loiXoa} file xoá lỗi — xem manifest để chạy lại.`)
console.log('\nLưu ý: các bản ghi trong database vẫn còn URL trỏ tới file đã xoá,')
console.log('nên giao diện sẽ hiện ảnh vỡ ở những chỗ đó. Xem phần cuối README của script.')
