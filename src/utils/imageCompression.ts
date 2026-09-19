// path: src/utils/imageCompression.ts
//
// Nén ảnh sang WebP trước khi upload.
//
// Bối cảnh: bucket work-proofs đạt 83 GB với 35.811 file PNG, trung bình 2.405 kB
// mỗi file. 77 file WebP sẵn có trong cùng bucket trung bình chỉ 185 kB — nhỏ hơn
// 13 lần. Kích thước ảnh trung bình còn đang phình nhanh: 747 kB (03/2026) lên
// 4.266 kB (09/2026) do màn hình độ phân giải cao chụp rồi upload thô.
//
// Module này chạy trong trình duyệt, dùng canvas. Mọi lỗi đều fallback về file
// gốc — nén thất bại thì upload ảnh gốc, không bao giờ chặn người dùng.

/** Cạnh dài nhất sau khi thu nhỏ. Ảnh chụp màn hình 4K không cần giữ nguyên cỡ. */
const MAX_CANH = 2560

/** Chất lượng WebP. 0.82 gần như không phân biệt được bằng mắt với ảnh chụp màn hình. */
const CHAT_LUONG = 0.82

/** Dưới ngưỡng này thì nén không đáng, bỏ qua. */
const NGUONG_BO_QUA = 200 * 1024

/** Chỉ nén các định dạng này. GIF bị loại vì có thể là ảnh động. */
const LOAI_NEN_DUOC = ['image/png', 'image/jpeg', 'image/jpg']

let webpHoTro: boolean | null = null

/** Kiểm tra trình duyệt có xuất được WebP không. Tính một lần rồi nhớ lại. */
function trinhDuyetHoTroWebp(): boolean {
  if (webpHoTro !== null) return webpHoTro
  try {
    const c = document.createElement('canvas')
    c.width = 1
    c.height = 1
    webpHoTro = c.toDataURL('image/webp').startsWith('data:image/webp')
  } catch {
    webpHoTro = false
  }
  return webpHoTro
}

function docAnh(file: File): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(file)
    const img = new Image()
    img.onload = () => {
      URL.revokeObjectURL(url)
      resolve(img)
    }
    img.onerror = () => {
      URL.revokeObjectURL(url)
      reject(new Error('Không đọc được ảnh'))
    }
    img.src = url
  })
}

export interface KetQuaNen {
  /** File để upload — đã nén, hoặc chính file gốc nếu không nén được. */
  file: File
  /** true nếu đã thực sự chuyển sang WebP. */
  daNen: boolean
  byteGoc: number
  byteSau: number
}

/**
 * Nén ảnh sang WebP nếu có lợi.
 *
 * Bỏ qua và trả lại file gốc khi: không phải ảnh PNG/JPEG, file đã nhỏ,
 * trình duyệt không hỗ trợ WebP, hoặc bản nén lại to hơn bản gốc.
 */
export async function nenAnh(file: File): Promise<KetQuaNen> {
  const khongDoi: KetQuaNen = {
    file,
    daNen: false,
    byteGoc: file.size,
    byteSau: file.size,
  }

  if (!LOAI_NEN_DUOC.includes(file.type)) return khongDoi
  if (file.size < NGUONG_BO_QUA) return khongDoi
  if (!trinhDuyetHoTroWebp()) return khongDoi

  try {
    const img = await docAnh(file)

    let { width: w, height: h } = img
    if (w > MAX_CANH || h > MAX_CANH) {
      const tiLe = MAX_CANH / Math.max(w, h)
      w = Math.round(w * tiLe)
      h = Math.round(h * tiLe)
    }

    const canvas = document.createElement('canvas')
    canvas.width = w
    canvas.height = h
    const ctx = canvas.getContext('2d')
    if (!ctx) return khongDoi

    // Nền trắng: PNG có thể trong suốt, WebP giữ alpha nhưng ảnh chụp màn hình
    // trong suốt hiển thị rất khó nhìn trên nền tối.
    ctx.fillStyle = '#ffffff'
    ctx.fillRect(0, 0, w, h)
    ctx.drawImage(img, 0, 0, w, h)

    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, 'image/webp', CHAT_LUONG)
    )
    if (!blob) return khongDoi

    // Nén xong mà to hơn thì giữ bản gốc.
    if (blob.size >= file.size) return khongDoi

    const tenMoi = file.name.replace(/\.(png|jpe?g)$/i, '') + '.webp'
    return {
      file: new File([blob], tenMoi, { type: 'image/webp', lastModified: Date.now() }),
      daNen: true,
      byteGoc: file.size,
      byteSau: blob.size,
    }
  } catch (e) {
    console.warn('[nenAnh] không nén được, dùng file gốc:', e)
    return khongDoi
  }
}

/** Đổi đuôi đường dẫn upload cho khớp với file đã nén. */
export function doiDuoiSangWebp(path: string): string {
  return path.replace(/\.(png|jpe?g)$/i, '.webp')
}
