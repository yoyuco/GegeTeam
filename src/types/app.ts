// path: src/types/app.ts
// Các kiểu dữ liệu dùng chung cho toàn bộ ứng dụng

/**
 * Đại diện cho một vai trò trong hệ thống (tương ứng với bảng `roles`).
 */
export type Role = {
  id: string
  name: string
  code: string
}

/**
 * Đại diện cho một quyền hạn/chức năng trong hệ thống (tương ứng với bảng `permissions`).
 */
export type Permission = {
  id: string
  code: string
  description: string
  group: string
  description_vi?: string // Mô tả bằng tiếng Việt (tùy chọn)
}

/**
 * Đại diện cho một bản ghi gán quyền cho vai trò (tương ứng với bảng `role_permissions`).
 */
export type RolePermissionAssignment = {
  role_id: string
  permission_id: string
}
