// path: src/utils/localBlobCache.ts
//
// Giữ lại bản blob trong trình duyệt của ảnh vừa upload, để hiển thị ngay mà
// không phải tải lại từ server.
//
// Bối cảnh: sau mỗi thao tác bắt đầu/kết thúc phiên hoặc hoàn thành đơn, ứng
// dụng upload ảnh lên storage rồi LẬP TỨC tải chính ảnh đó về để hiển thị.
// Đo trên production, lượt GET tải lại mất 540-846ms — trong khi đúng bytes ấy
// vẫn đang nằm sẵn trong bộ nhớ trình duyệt.
//
// Cách hoạt động: uploadFile() ghi lại ánh xạ publicUrl -> blob URL cục bộ.
// Component hiển thị gọi giaiQuyetUrl() và nhận blob URL nếu có, còn không thì
// nhận lại đúng URL gốc. Không có blob thì mọi thứ chạy y như trước.

/** Số ảnh giữ lại tối đa. Vượt quá thì bỏ cái cũ nhất và thu hồi blob URL. */
const SUC_CHUA = 60

/** publicUrl -> blob URL. Map giữ nguyên thứ tự chèn nên dùng làm LRU được. */
const bo_nho = new Map<string, string>()

function coTheTaoBlobUrl(): boolean {
  return typeof URL !== 'undefined' && typeof URL.createObjectURL === 'function'
}

/**
 * Ghi nhớ bytes cục bộ của một file vừa upload xong.
 * Gọi sau khi upload thành công, với đúng file đã gửi đi (bản đã nén).
 */
export function ghiNhoBlob(publicUrl: string, file: Blob): void {
  if (!publicUrl || !file || !coTheTaoBlobUrl()) return
  try {
    // Ghi đè thì thu hồi bản cũ trước cho khỏi rò bộ nhớ.
    const cu = bo_nho.get(publicUrl)
    if (cu) URL.revokeObjectURL(cu)

    bo_nho.set(publicUrl, URL.createObjectURL(file))

    while (bo_nho.size > SUC_CHUA) {
      const khoaCuNhat = bo_nho.keys().next().value as string | undefined
      if (khoaCuNhat === undefined) break
      const blobCu = bo_nho.get(khoaCuNhat)
      if (blobCu) URL.revokeObjectURL(blobCu)
      bo_nho.delete(khoaCuNhat)
    }
  } catch (e) {
    console.warn('[localBlobCache] không ghi nhớ được blob:', e)
  }
}

/**
 * Trả về blob URL cục bộ nếu đã có, ngược lại trả lại chính URL truyền vào.
 * An toàn để gọi với bất kỳ URL nào, kể cả chuỗi rỗng.
 */
export function giaiQuyetUrl(url: string | null | undefined): string {
  if (!url) return url ?? ''
  return bo_nho.get(url) ?? url
}

/** Thu hồi toàn bộ blob URL. Gọi khi rời trang. */
export function donDep(): void {
  for (const blobUrl of bo_nho.values()) {
    try {
      URL.revokeObjectURL(blobUrl)
    } catch {
      /* không sao, trang đang đóng */
    }
  }
  bo_nho.clear()
}

if (typeof window !== 'undefined') {
  // pagehide đáng tin hơn beforeunload, nhất là trên Safari iOS.
  window.addEventListener('pagehide', donDep)
}
