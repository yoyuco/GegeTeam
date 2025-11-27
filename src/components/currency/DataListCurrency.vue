<!-- path: src/components/currency/DataListCurrency.vue -->
<template>
  <div class="data-list-currency">
    <!-- Header with Actions -->
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-3">
      </div>

      <div class="flex items-center gap-3">
        <!-- Search -->
        <n-input
          v-model:value="searchQuery"
          placeholder="Tìm kiếm..."
          clearable
          class="w-64"
          @input="onSearch"
        >
          <template #prefix>
            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
          </template>
        </n-input>

        <!-- Filter -->
        <n-button quaternary @click="showFilters = !showFilters">
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
              />
            </svg>
          </template>
          Bộ lọc
        </n-button>

        <!-- Export -->
        <n-button quaternary @click="onExport">
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
          </template>
          Xuất file
        </n-button>
      </div>
    </div>

    <!-- Enhanced Filters Panel -->
    <div v-if="showFilters" class="mb-6 p-4 bg-gray-50 rounded-lg">
      <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-4 gap-4">
        <!-- Trạng thái -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Trạng thái</label>
          <n-select
            v-model:value="filters.status"
            :options="statusOptions"
            placeholder="Chọn trạng thái"
            clearable
            @update:value="onFilterChange"
          />
        </div>

        <!-- Loại giao dịch -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Loại giao dịch</label>
          <n-select
            v-model:value="filters.type"
            :options="typeOptions"
            placeholder="Chọn loại giao dịch"
            clearable
            @update:value="onFilterChange"
          />
        </div>

        <!-- Thời gian bắt đầu -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            <span class="flex items-center gap-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Từ ngày
            </span>
          </label>
          <n-date-picker
            v-model:value="filters.startDateTime"
            type="datetime"
            placeholder="Chọn ngày giờ bắt đầu"
            clearable
            format="dd/MM/yyyy HH:mm"
            value-format="x"
            @update:value="onFilterChange"
          />
        </div>

        <!-- Thời gian kết thúc -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            <span class="flex items-center gap-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Đến ngày
            </span>
          </label>
          <n-date-picker
            v-model:value="filters.endDateTime"
            type="datetime"
            placeholder="Chọn ngày giờ kết thúc"
            clearable
            format="dd/MM/yyyy HH:mm"
            value-format="x"
            @update:value="onFilterChange"
          />
        </div>

        <!-- Quick Filter Buttons -->
        <div class="lg:col-span-2 xl:col-span-4">
          <div class="flex flex-wrap gap-2 pt-2 border-t border-gray-200">
            <span class="text-sm text-gray-600 py-1">Lọc nhanh:</span>
            <n-button size="small" @click="setQuickDateRange('today')" quaternary type="info">
              Hôm nay
            </n-button>
            <n-button size="small" @click="setQuickDateRange('yesterday')" quaternary type="info">
              Hôm qua
            </n-button>
            <n-button size="small" @click="setQuickDateRange('thisWeek')" quaternary type="info">
              Tuần này
            </n-button>
            <n-button size="small" @click="setQuickDateRange('lastWeek')" quaternary type="info">
              Tuần trước
            </n-button>
            <n-button size="small" @click="setQuickDateRange('thisMonth')" quaternary type="info">
              Tháng này
            </n-button>
            <n-button size="small" @click="setQuickDateRange('lastMonth')" quaternary type="info">
              Tháng trước
            </n-button>
            <n-button size="small" @click="clearDateFilters" quaternary type="warning">
              Xóa bộ lọc ngày
            </n-button>
          </div>
        </div>
      </div>
    </div>

    <!-- Statistics Cards -->
    <!-- Different layouts for delivery vs history tabs -->
    <div v-if="modelType === 'delivery'" class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <!-- Delivery Tab Stats: Only show assigned and in-progress -->
      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Tổng đơn đang xử lý</p>
            <p class="text-2xl font-bold text-gray-800">{{ stats.total }}</p>
          </div>
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Đã phân công</p>
            <p class="text-2xl font-bold text-blue-600">{{ stats.assigned }}</p>
          </div>
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Đang xử lý</p>
            <p class="text-2xl font-bold text-purple-600">{{ stats.inProgress }}</p>
          </div>
          <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 10V3L4 14h7v7l9-11h-7z"
              />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <!-- History Tab Stats: Only show completed and cancelled -->
      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Tổng lịch sử</p>
            <p class="text-2xl font-bold text-gray-800">{{ stats.total }}</p>
          </div>
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Hoàn thành</p>
            <p class="text-2xl font-bold text-green-600">{{ stats.completed }}</p>
          </div>
          <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Hủy bỏ</p>
            <p class="text-2xl font-bold text-red-600">{{ stats.cancelled }}</p>
          </div>
          <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Data Table -->
    <div class="bg-white rounded-lg border border-gray-200">
      <n-data-table
        v-if="props.data && props.data.length >= 0"
        :columns="tableColumns"
        :data="filteredData"
        :loading="loading"
        :pagination="pagination"
        :row-key="rowKey"
        striped
        size="medium"
        @update:page="onPageChange"
        @update:page-size="onPageSizeChange"
      />
    </div>

    <!-- Detail Modal -->
    <n-modal v-model:show="showDetailModal" :style="{ width: '900px' }" preset="card">
      <template #header>
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <div>
            <h2 class="text-xl font-bold text-gray-900">Chi tiết giao dịch</h2>
            <p class="text-sm text-gray-500">{{ selectedItem?.order_number || '#' + selectedItem?.id?.slice(0, 8) }}</p>
          </div>
        </div>
      </template>

      <div v-if="selectedItem" class="space-y-6">
        <!-- Status Badge Section -->
        <div class="flex items-center justify-between p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border border-blue-200">
          <div class="flex items-center gap-3">
            <div :class="getStatusBadgeClass(selectedItem.status)" class="px-4 py-2 rounded-full font-semibold text-sm">
              {{ getStatusLabel(selectedItem.status, selectedItem.order_type) }}
            </div>
            <div v-if="selectedItem.order_type" :class="getOrderTypeBadgeClass(selectedItem.order_type)" class="px-3 py-1 rounded-full text-sm font-medium border">
              {{ selectedItem.order_type === 'PURCHASE' ? '📥 Mua hàng' : selectedItem.order_type === 'SALE' ? '📤 Bán hàng' : '🔄 Trao đổi' }}
            </div>
          </div>
          <div class="text-right">
            <p class="text-xs text-gray-500">Ngày tạo</p>
            <p class="text-sm font-medium text-gray-900">{{ new Date(selectedItem.created_at || selectedItem.createdAt).toLocaleString('vi-VN') }}</p>
          </div>
        </div>

        <!-- Main Information Grid -->
        <div class="grid grid-cols-2 gap-6">
          <!-- Order Information -->
          <div class="bg-white rounded-lg border border-gray-200 p-5">
            <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
              Thông tin đơn hàng
            </h3>
            <div class="space-y-3">
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Mã đơn hàng:</span>
                <span class="text-sm font-medium text-gray-900 bg-gray-100 px-2 py-1 rounded">{{ selectedItem?.order_number || '#' + selectedItem?.id?.slice(0, 8) }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Loại currency:</span>
                <span class="text-sm font-medium text-gray-900">{{ selectedItem?.currency_attribute?.name || selectedItem?.currencyName || selectedItem?.currency?.name || '-' }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Số lượng:</span>
                <span class="font-bold text-blue-600 text-lg">{{ selectedItem?.quantity || selectedItem?.amount || 0 }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Game:</span>
                <span class="text-sm font-medium text-gray-900">{{ getGameDisplayName(selectedItem) }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Server:</span>
                <span class="text-sm font-medium text-gray-900">{{ getServerDisplayName(selectedItem) }}</span>
              </div>
              <div v-if="selectedItem?.exchange_type && selectedItem.exchange_type !== 'none' && selectedItem?.order_type !== 'EXCHANGE'" class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Loại trao đổi:</span>
                <span class="text-sm font-medium text-gray-900">{{ getExchangeTypeLabel(selectedItem.exchange_type) }}</span>
              </div>
              </div>
          </div>

          <!-- Additional Information -->
          <div class="bg-white rounded-lg border border-gray-200 p-5">
            <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              {{ selectedItem?.order_type === 'EXCHANGE' ? 'Thông tin trao đổi' : 'Thông tin khách hàng' }}
            </h3>

            <!-- Exchange Order Specific Information -->
            <div v-if="selectedItem?.order_type === 'EXCHANGE'" class="space-y-3">
              <!-- Account -->
              <div v-if="selectedItem?.game_account" class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Account:</span>
                <span class="text-sm font-medium text-gray-900">{{ selectedItem.game_account?.account_name || '-' }}</span>
              </div>
              <!-- Destination Currency -->
              <div v-if="selectedItem?.exchange_details?.target_currency?.code || selectedItem?.foreign_currency_code" class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Loại Currency Đích:</span>
                <span class="text-sm font-medium text-gray-900">
                  {{
        (selectedItem?.foreign_currency_attribute?.name) ||
        (selectedItem?.foreign_currency_name) ||
        (selectedItem?.foreign_currency?.name) ||
        (selectedItem?.exchange_details?.target_currency?.code || selectedItem?.foreign_currency_code || '-')
      }}
                </span>
              </div>
              <!-- Destination Amount -->
              <div v-if="selectedItem?.foreign_amount || selectedItem?.exchange_details?.target_currency?.quantity" class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Số lượng đích:</span>
                <span class="font-bold text-blue-600 text-lg">
                  {{ selectedItem?.exchange_details?.target_currency?.quantity || selectedItem?.foreign_amount || 0 }}
                </span>
              </div>
              <!-- Performed By (Creator) -->
              <div v-if="selectedItem?.created_by" class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Người thực hiện:</span>
                <span class="text-sm font-medium text-gray-900">
                  {{ selectedItem?.created_by_profile?.display_name || 'Người dùng ' + (selectedItem?.created_by?.slice(0, 8) || '#') }}
                </span>
              </div>
            </div>

            <!-- Regular Customer/Supplier Information -->
            <div v-else class="space-y-3">
              <!-- Channel (moved to top) -->
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Kênh:</span>
                <span class="text-sm font-medium text-gray-900">{{ selectedItem?.channel?.name || selectedItem?.channelName || '-' }}</span>
              </div>
              <!-- Customer/Supplier Name (conditional display) -->
              <div v-if="selectedItem?.order_type !== 'EXCHANGE'" class="flex justify-between items-center">
                <span class="text-sm text-gray-600">{{ selectedItem?.order_type === 'SALE' ? 'Tên khách hàng:' : selectedItem?.order_type === 'PURCHASE' ? 'Tên nhà cung cấp:' : 'Tên khách hàng:' }}</span>
                <span class="text-sm font-medium text-gray-900">
                {{ selectedItem?.party?.name ||
                  (selectedItem?.order_type === 'PURCHASE'
                    ? selectedItem?.supplier_name || selectedItem?.customer_name || selectedItem?.customerName
                    : selectedItem?.customer_name || selectedItem?.customerName) ||
                  selectedItem?.customer?.name ||
                  '-' }}
              </span>
              </div>
              <!-- Game Tag/Delivery Info -->
              <div v-if="selectedItem?.delivery_info">
                <div class="flex justify-between items-center mb-1">
                  <span class="text-sm text-gray-600">{{ selectedItem.order_type === 'PURCHASE' ? 'ID Game:' : 'ID Game bán:' }}</span>
                  <n-button
                    v-if="selectedItem.delivery_info && selectedItem.delivery_info !== '-'"
                    size="tiny"
                    type="primary"
                    ghost
                    @click="handleCopyGameTag"
                    class="text-xs"
                  >
                    <template #icon>
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </template>
                    Copy
                  </n-button>
                </div>
                <p class="text-sm font-medium text-gray-900 mt-1 bg-gray-50 p-2 rounded break-all">
                  {{ selectedItem.delivery_info }}
                </p>
              </div>

              <!-- Notes -->
              <div v-if="selectedItem?.notes">
                <div class="flex justify-between items-center mb-1">
                  <span class="text-sm text-gray-600">Thông tin bổ sung:</span>
                  <n-button
                    v-if="selectedItem.notes && selectedItem.notes !== '-'"
                    size="tiny"
                    type="primary"
                    ghost
                    @click="handleCopyNotes"
                    class="text-xs"
                  >
                    <template #icon>
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </template>
                    Copy
                  </n-button>
                </div>
                <p class="text-sm font-medium text-gray-900 mt-1 bg-gray-50 p-2 rounded break-all">
                  {{ selectedItem.notes }}
                </p>
              </div>

  
  
  
              </div>
          </div>
        </div>

        <!-- Proof Information (for History Tab) - Full Width -->
        <div v-if="props.modelType === 'history' && selectedItem?.proofs && Object.keys(selectedItem.proofs).length > 0" class="bg-white rounded-lg border border-gray-200 p-5">
          <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <svg class="w-5 h-5 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Bằng chứng đính kèm
          </h3>

          <!-- Show all proofs (handle both array and object formats) -->
          <div class="space-y-3">
            <div v-if="getProofsArray(selectedItem.proofs).length > 0">
              <div class="grid grid-cols-3 gap-3">
              <div
                v-for="(proof, index) in getProofsArray(selectedItem.proofs)"
                :key="index"
                class="border border-gray-200 rounded-lg p-3 hover:bg-gray-50"
              >
                <div class="flex items-center justify-between mb-2">
                  <span class="text-xs font-medium text-gray-700">
                    {{ proof.type || 'Bằng chứng' }} {{ index + 1 }}
                  </span>
                  <span v-if="proof.uploaded_at" class="text-xs text-gray-500">
                    {{ new Date(proof.uploaded_at).toLocaleDateString('vi-VN') }}
                  </span>
                </div>

                <div v-if="proof.url" class="space-y-2">
                  <div v-if="isImageFile(proof.url)" class="cursor-pointer" @click="viewImage(proof.url)">
                    <img
                      :src="getImageUrl(proof.url)"
                      :alt="proof.type || 'Proof image'"
                      class="w-full h-24 object-cover rounded border border-gray-300 hover:border-blue-400 transition-colors"
                    />
                    <p class="text-xs text-blue-600 mt-1 text-center">Click để xem lớn</p>
                  </div>

                  <div v-else class="flex items-center justify-between">
                    <span class="text-xs text-gray-600 truncate flex-1 mr-2">{{ getFileName(proof.url) }}</span>
                    <n-button
                      size="tiny"
                      type="primary"
                      ghost
                      @click="downloadFile(proof.url)"
                    >
                      <template #icon>
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                      </template>
                      Tải
                    </n-button>
                  </div>
                </div>

                <div v-if="proof.uploaded_by" class="text-xs text-gray-500 mt-2">
                  Người tải: {{ proof.uploaded_by }}
                </div>
                <div v-else class="text-sm text-gray-500 italic">
                  Không có bằng chứng nào được tải lên
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>

        <!-- Proof Upload Section for Delivery Tab -->
        <div v-if="props.modelType === 'delivery'" class="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl border border-green-200 p-5">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-3">
              <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <h4 class="text-lg font-semibold text-gray-900">
                  {{ selectedItem?.order_type === 'PURCHASE' ? 'Bằng chứng nhận hàng' : 'Bằng chứng giao hàng' }}
                </h4>
              </div>
            </div>
          </div>

          <!-- SimpleProofUpload Component -->
          <div class="mt-4">
            <SimpleProofUpload
              ref="simpleProofUploadRef"
              :max-files="5"
              v-model="selectedProofFiles"
              :auto-upload="false"
            />
          </div>

          <!-- Confirmation Button -->
          <div class="mt-4">
            <n-button
              type="primary"
              size="large"
              :disabled="!canConfirmDelivery"
              :loading="uploading"
              @click="handleConfirmDelivery"
              block
            >
              <template #icon>
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </template>
              {{ selectedItem?.order_type === 'PURCHASE' ? 'Xác nhận đã nhận hàng' : 'Xác nhận đã giao hàng' }}
            </n-button>
          </div>
        </div>
      </div>
    </n-modal>

    <!-- Cancel Order Modal -->
    <n-modal v-model:show="showCancelModal" :style="{ width: '600px' }" preset="card">
      <template #header>
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </div>
          <div>
            <h2 class="text-xl font-bold text-gray-900">Hủy đơn hàng</h2>
            <p class="text-sm text-gray-500">{{ selectedOrderToCancel?.order_number || '#' + selectedOrderToCancel?.id?.slice(0, 8) }}</p>
          </div>
        </div>
      </template>

      <div v-if="selectedOrderToCancel" class="space-y-6">
        <!-- Order Summary -->
        <div class="bg-gray-50 p-4 rounded-lg">
          <h3 class="text-sm font-semibold text-gray-700 mb-2">Thông tin đơn hàng</h3>
          <div class="space-y-1 text-sm">
            <div class="flex justify-between">
              <span class="text-gray-600">Loại:</span>
              <span class="font-medium">{{ selectedOrderToCancel.order_type === 'PURCHASE' ? 'Mua hàng' : 'Bán hàng' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">Currency:</span>
              <span class="font-medium">{{ selectedOrderToCancel.currency_attribute?.name || selectedOrderToCancel.currencyName || '-' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">Số lượng:</span>
              <span class="font-medium">{{ selectedOrderToCancel.quantity || selectedOrderToCancel.amount || 0 }}</span>
            </div>
          </div>
        </div>

        <!-- Cancellation Reason -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Lý do hủy <span class="text-red-500">*</span>
          </label>
          <n-input
            v-model:value="cancelReason"
            type="textarea"
            :rows="4"
            placeholder="Nhập lý do hủy đơn hàng..."
            size="large"
            :maxlength="500"
            show-count
          />
        </div>

        <!-- Upload Proof Images -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Tải lên bằng chứng hủy đơn (nếu có)
          </label>
          <SimpleProofUpload
            ref="cancelProofUploadRef"
            :max-files="3"
            v-model="cancelProofFiles"
            :auto-upload="false"
          />
        </div>

        <!-- Confirmation Checkbox -->
        <div class="flex items-start gap-3">
          <input
            v-model="cancelConfirmed"
            type="checkbox"
            id="cancelConfirm"
            class="mt-1 w-4 h-4 text-red-600 border-gray-300 rounded focus:ring-red-500"
          />
          <label for="cancelConfirm" class="text-sm text-gray-700">
            Tôi xác nhận muốn hủy đơn hàng này.
          </label>
        </div>

        <!-- Action Buttons -->
        <div class="flex gap-3 pt-4 border-t">
          <n-button
            @click="showCancelModal = false"
            size="large"
            class="flex-1"
          >
            Quay lại
          </n-button>
          <n-button
            type="error"
            size="large"
            :disabled="!cancelReason.trim() || !cancelConfirmed || cancellingOrder"
            :loading="cancellingOrder"
            @click="handleConfirmCancel"
            class="flex-1"
          >
            <template #icon>
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </template>
            Xác nhận hủy đơn
          </n-button>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import SimpleProofUpload from '@/components/SimpleProofUpload.vue'
import { supabase } from '@/lib/supabase'
import { NButton, NDataTable, NDatePicker, NInput, NModal, NSelect, useMessage } from 'naive-ui'
import { computed, h, nextTick, onMounted, ref, watch } from 'vue'

// Props
interface Props {
  modelType: 'delivery' | 'history' // Determines which data model to use
  title?: string
  description?: string
  data?: Array<any>
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelType: 'delivery',
  title: 'Danh sách giao dịch',
  description: 'Quản lý các giao dịch currency',
  data: () => [],
  loading: false
})


// Emits
interface Emits {
  (e: 'search', query: string): void
  (e: 'filter', filters: any): void
  (e: 'export'): void
  (e: 'view-detail', item: any): void
  (e: 'update-status', item: any, status: string): void
  (e: 'finalize-order', item: any): void
  (e: 'proof-uploaded', data: { orderId: string; proofs: any }): void
  (e: 'process-inventory', data: { order: any; currentStatus: string; targetStatus: string }): void
  (e: 'refresh-data'): void
}

const emit = defineEmits<{
  (e: 'assign', item: any): void
  (e: 'start', item: any): void
  (e: 'complete', item: any): void
  (e: 'finalize', item: any): void
  (e: 'update-status', item: any, status: string): void
  (e: 'finalize-order', item: any): void
  (e: 'proof-uploaded', data: { orderId: string; proofs: any }): void
  (e: 'process-inventory', data: { order: any; currentStatus: string; targetStatus: string }): void
  (e: 'refresh-data'): void
  (e: 'filter-change', filters: any): void
  (e: 'search', query: string): void
  (e: 'export'): void
  (e: 'view-detail', item: any): void
}>()

// Composables
const message = useMessage()

// State
const searchQuery = ref('')
const showFilters = ref(false)
const showDetailModal = ref(false)
const selectedItem = ref<any>(null)
const selectedProofFiles = ref<any[]>([])
const uploading = ref(false)

// Cancel order modal state
const showCancelModal = ref(false)
const selectedOrderToCancel = ref<any>(null)
const cancelReason = ref('')
const cancelProofFiles = ref<any[]>([])
const cancelConfirmed = ref(false)
const cancellingOrder = ref(false)

const filters = ref<{
  status: string | null
  type: string | null
  startDateTime: number | null
  endDateTime: number | null
}>({
  status: null,
  type: null,
  startDateTime: null,
  endDateTime: null
})

const pagination = ref({
  page: 1,
  pageSize: 10,
  itemCount: 0,
  showSizePicker: true,
  pageSizes: [10, 20, 50, 100]
})

// Statistics
const stats = computed(() => {
  const data = props.data || []
  const total = data.length

  // Stats differ based on model type
  if (props.modelType === 'delivery') {
    // For delivery tab: only show assigned and in-progress orders
    const assigned = data.filter(item => item.status === 'assigned').length
    // "Đang xử lý" includes multiple statuses: preparing, ready, delivering
    const inProgress = data.filter(item =>
      ['preparing', 'ready', 'delivering'].includes(item.status)
    ).length
    return { total, assigned, inProgress }
  } else {
    // For history tab: only show completed and cancelled
    const completed = data.filter(item => item.status === 'completed').length
    const cancelled = data.filter(item => item.status === 'cancelled').length
    return { total, completed, cancelled }
  }
})

// Filter options based on model type
const statusOptions = computed(() => {
  if (props.modelType === 'delivery') {
    return [
      { label: 'Chờ xử lý', value: 'pending' },
      { label: 'Đã phân công', value: 'assigned' },
      { label: 'Đang chuẩn bị', value: 'preparing' },
      { label: 'Sẵn sàng', value: 'ready' },
      { label: 'Đang giao', value: 'delivering' },
      { label: 'Đã giao', value: 'delivered' },
      { label: 'Hủy bỏ', value: 'cancelled' }
    ]
  } else {
    return [
      { label: 'Hoàn thành', value: 'completed' },
      { label: 'Hủy bỏ', value: 'cancelled' }
    ]
  }
})

const typeOptions = computed(() => {
  if (props.modelType === 'delivery') {
    return [
      { label: 'Mua currency', value: 'PURCHASE' },
      { label: 'Bán currency', value: 'SALE' },
      { label: 'Đổi currency', value: 'EXCHANGE' }
    ]
  } else {
    return [
      { label: 'Mua currency', value: 'PURCHASE' },
      { label: 'Bán currency', value: 'SALE' },
      { label: 'Đổi currency', value: 'EXCHANGE' },
      { label: 'Nạp tiền', value: 'DEPOSIT' },
      { label: 'Rút tiền', value: 'WITHDRAW' }
    ]
  }
})

// Table columns based on model type
const tableColumns = computed(() => {
  // For delivery tab, use the requested order
  if (props.modelType === 'delivery') {
    const deliveryColumns = [
      {
        title: 'Mã đơn',
        key: 'order_number',
        width: 120,
        render: (row: any) => row.order_number || `#${row.id?.slice(0, 8)}...`
      },
      {
        title: 'Loại',
        key: 'order_type',
        width: 100,
        render: (row: any) => {
          const orderType = row.order_type || row.type
          const colors: { [key: string]: string } = {
            PURCHASE: 'green',
            SALE: 'red',
            EXCHANGE: 'purple',
            purchase: 'green',
            sale: 'red',
            exchange: 'purple',
            deposit: 'orange',
            withdraw: 'red'
          }
          const labels: { [key: string]: string } = {
            PURCHASE: 'Mua',
            SALE: 'Bán',
            EXCHANGE: 'Đổi',
            purchase: 'Mua',
            sale: 'Bán',
            exchange: 'Đổi',
            deposit: 'Nạp',
            withdraw: 'Rút'
          }
          const colorKey = (orderType as string) in colors ? orderType as string : 'gray'
          return h('span', {
            class: `px-2 py-1 text-xs rounded-full bg-${colors[colorKey]}-100 text-${colors[colorKey]}-800`
          }, labels[orderType as string] || orderType)
        }
      },
      {
        title: 'Kênh',
        key: 'channel',
        width: 120,
        render: (row: any) => {
          const channelName = row.channel?.name || row.channelName || '-'
          const channelCode = row.channel?.code || row.channelCode || 'Other'

          if (channelName === '-') return channelName

          return h('span', {
            class: `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getChannelTagClass(channelCode)}`
          }, channelName)
        }
      },
      {
        title: 'Customer/Supplier',
        key: 'customer',
        width: 150,
        render: (row: any) => {
          // For purchase orders, show supplier name, for sell orders show customer name
          const partyName = row.party?.name || (row.order_type === 'PURCHASE' ? row.supplier_name || row.customer_name : row.customer_name || row.customerName) || '-'
          return partyName
        }
      },
      {
        title: 'Currency',
        key: 'currency',
        width: 120,
        render: (row: any) => {
          const currencyName = row.currency_attribute?.name || row.currencyName || row.currency?.name || '-'
          const currencyCode = row.currency_attribute?.code || row.currencyCode || row.currency?.code || 'Other'

          if (currencyName === '-') return currencyName

          return h('span', {
            class: `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getCurrencyTagClass(currencyCode)}`
          }, currencyName)
        }
      },
      {
        title: 'Số lượng',
        key: 'quantity',
        width: 120,
        render: (row: any) => {
          const quantity = row.quantity || row.amount || 0
          return `${quantity.toLocaleString()}`
        }
      },
      {
        title: 'Game Tag',
        key: 'delivery_info',
        width: 150,
        render: (row: any) => {
          const gameTag = row.delivery_info || row.deliveryInfo || '-'
          return gameTag
        }
      },
      {
        title: 'Thao tác',
        key: 'actions',
        width: 200,
        render: (row: any) => {
          const buttons = []

          // Always show "Xem" button for all orders
          buttons.push(h(NButton, {
            size: 'small',
            type: 'primary',
            ghost: true,
            onClick: () => onViewDetail(row)
          }, () => 'Xem'))

          // For delivered status: show "Hoàn tất" button
          if (row.status === 'delivered') {
            buttons.push(h(NButton, {
              size: 'small',
              type: 'success',
              onClick: () => onFinalizeOrder(row)
            }, () => 'Hoàn tất'))
          }
          // For all other statuses (except completed/cancelled/delivered): show "Hủy bỏ" button
          else if (row.status !== 'completed' && row.status !== 'cancelled' && row.status !== 'delivered') {
            buttons.push(h(NButton, {
              size: 'small',
              type: 'error',
              ghost: true,
              onClick: () => handleCancelOrder(row)
            }, () => 'Hủy bỏ'))
          }

          return h('div', { class: 'flex gap-1' }, buttons.filter(Boolean))
        }
      },
      {
        title: 'Trạng thái',
        key: 'status',
        width: 120,
        render: (row: any) => {
          const statusColors: { [key: string]: string } = {
            draft: 'gray',
            pending: 'yellow',
            assigned: 'blue',
            preparing: 'purple',
            ready: 'blue',
            delivering: 'blue',
            delivered: 'teal', // Delivered but waiting final confirmation
            completed: 'green',
            cancelled: 'red',
            failed: 'red'
          }
          const statusLabels: { [key: string]: string } = {
            draft: 'Nháp',
            pending: 'Chờ xử lý',
            assigned: 'Đã phân công',
            preparing: 'Đang chuẩn bị',
            ready: 'Sẵn sàng giao',
            delivering: row.order_type === 'PURCHASE' ? 'Đang nhận' : 'Đang giao',
            delivered: row.order_type === 'PURCHASE' ? 'Đã nhận hàng' : 'Đã giao hàng', // Different text based on order type
            completed: 'Hoàn thành',
            cancelled: 'Hủy bỏ',
            failed: 'Thất bại'
          }
          const statusKey = (row.status as string) in statusColors ? row.status as string : 'gray'
          return h('span', {
            class: `px-2 py-1 text-xs rounded-full bg-${statusColors[statusKey]}-100 text-${statusColors[statusKey]}-800`
          }, statusLabels[row.status as string] || row.status)
        }
      }
    ]
    return deliveryColumns
  }

  // For other tabs (history), use only 8 columns as requested
  if (props.modelType === 'history') {
    return [
      {
        title: 'Mã đơn',
        key: 'order_number',
        width: 120,
        render: (row: any) => row.order_number || `#${row.id?.slice(0, 8)}...`
      },
      {
        title: 'Loại',
        key: 'order_type',
        width: 100,
        render: (row: any) => {
          const orderType = row.order_type || row.type
          const colors: { [key: string]: string } = {
            PURCHASE: 'green',
            SALE: 'red',
            EXCHANGE: 'purple',
            purchase: 'green',
            sale: 'red',
            exchange: 'purple',
            deposit: 'orange',
            withdraw: 'red'
          }
          const labels: { [key: string]: string } = {
            PURCHASE: 'Mua',
            SALE: 'Bán',
            EXCHANGE: 'Đổi',
            purchase: 'Mua',
            sale: 'Bán',
            exchange: 'Đổi',
            deposit: 'Gửi',
            withdraw: 'Rút'
          }
          const statusKey = orderType && orderType.toString().toUpperCase() in colors ? orderType.toString().toUpperCase() : 'gray'
          return h('span', {
            class: `px-2 py-1 text-xs rounded-full bg-${colors[statusKey]}-100 text-${colors[statusKey]}-800`
          }, labels[orderType] || orderType)
        }
      },
      {
        title: 'Kênh',
        key: 'channel',
        width: 120,
        render: (row: any) => {
          const channelName = row.channel?.name || row.channelName || '-'
          const channelCode = row.channel?.code || row.channelCode || 'Other'

          if (channelName === '-') return channelName

          return h('span', {
            class: `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getChannelTagClass(channelCode)}`
          }, channelName)
        }
      },
      {
        title: 'Khách hàng',
        key: 'customer',
        width: 150,
        render: (row: any) => {
          // For Exchange orders, show creator name
          if (row.order_type === 'EXCHANGE') {
            return row.created_by_profile?.display_name || 'Người dùng ' + (row?.created_by?.slice(0, 8) || '#')
          }
          // For purchase orders, show supplier, for sale orders show customer
          const partyName = row.party?.name || (row.order_type === 'PURCHASE' ? row.supplier_name || row.customer_name : row.customer_name || row.customerName) || '-'
          return partyName
        }
      },
      {
        title: 'Currency',
        key: 'currency',
        width: 120,
        render: (row: any) => {
          const currencyName = row.currency_attribute?.name || row.currencyName || row.currency?.name || '-'
          const currencyCode = row.currency_attribute?.code || row.currencyCode || row.currency?.code || 'Other'

          if (currencyName === '-') return currencyName

          return h('span', {
            class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border border-blue-200 bg-blue-50 text-blue-700'
          }, currencyName)
        }
      },
      {
        title: 'Số lượng',
        key: 'quantity',
        width: 120,
        render: (row: any) => {
          const quantity = row.quantity || row.amount || 0
          return quantity.toLocaleString()
        }
      },
      {
        title: 'Trạng thái',
        key: 'status',
        width: 120,
        render: (row: any) => {
          const statusColors: { [key: string]: string } = {
            completed: 'green',
            cancelled: 'red'
          }
          const statusLabels: { [key: string]: string } = {
            completed: 'Hoàn thành',
            cancelled: 'Hủy bỏ'
          }
          const statusKey = (row.status as string) in statusColors ? row.status as string : 'gray'
          return h('span', {
            class: `px-2 py-1 text-xs rounded-full bg-${statusColors[statusKey]}-100 text-${statusColors[statusKey]}-800`
          }, statusLabels[row.status as string] || row.status)
        }
      },
      {
        title: 'Thao tác',
        key: 'actions',
        width: 120,
        render: (row: any) => {
          return h(NButton, {
            size: 'small',
            type: 'primary',
            ghost: true,
            onClick: () => onViewDetail(row)
          }, () => 'Xem')
        }
      }
    ]
  }

  // Return empty array for other model types (shouldn't happen with current props)
  return []
})

// Computed data
const filteredData = computed(() => {
  let data = [...(props.data || [])]

  // Apply search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    data = data.filter(item =>
      (item.id && item.id.toString().toLowerCase().includes(query)) ||
      (item.order_number && item.order_number.toLowerCase().includes(query)) ||
      // Search customer names from various possible fields
      (item.party?.name && item.party.name.toLowerCase().includes(query)) ||
      (item.customer_name && item.customer_name.toLowerCase().includes(query)) ||
      (item.customerName && item.customerName.toLowerCase().includes(query)) ||
      (item.customer?.name && item.customer.name.toLowerCase().includes(query)) ||
      // Search currency names
      (item.currency_attribute?.name && item.currency_attribute.name.toLowerCase().includes(query)) ||
      (item.currencyName && item.currencyName.toLowerCase().includes(query)) ||
      // Search employee names
      (item.assigned_employee?.display_name && item.assigned_employee.display_name.toLowerCase().includes(query)) ||
      (item.employeeName && item.employeeName.toLowerCase().includes(query)) ||
      // Search game and server codes
      (item.game_code && item.game_code.toLowerCase().includes(query)) ||
      (item.server_attribute_code && item.server_attribute_code.toLowerCase().includes(query)) ||
      // Search channel names
      (item.channel?.name && item.channel.name.toLowerCase().includes(query)) ||
      (item.channelName && item.channelName.toLowerCase().includes(query))
    )
  }

  // Apply filters
  if (filters.value.status) {
    data = data.filter(item => item.status === filters.value.status)
  }
  // Apply order type filter
  if (filters.value.type) {
    data = data.filter(item => item.order_type === filters.value.type)
  }
  // Apply datetime filter
  if (filters.value.startDateTime || filters.value.endDateTime) {
    data = data.filter(item => {
      const itemDate = new Date(item.created_at).getTime()
      const startDate = filters.value.startDateTime
      const endDate = filters.value.endDateTime

      if (startDate && endDate) {
        return itemDate >= startDate && itemDate <= endDate
      } else if (startDate) {
        return itemDate >= startDate
      } else if (endDate) {
        return itemDate <= endDate
      }
      return true
    })
  }

  pagination.value.itemCount = data.length
  return data
})

// Computed property for delivery confirmation button
const canConfirmDelivery = computed(() => {
  // Must have selected item and proof files
  if (!selectedItem.value || selectedProofFiles.value.length === 0) {
    return false
  }

  // Only allow confirmation for specific statuses
  const allowedStatuses = ['assigned', 'preparing', 'ready', 'delivering']
  return allowedStatuses.includes(selectedItem.value.status)
})


// Helper functions for labels
const getStatusLabel = (status: string, orderType?: string) => {
  const statusLabels: { [key: string]: string } = {
    draft: 'Nháp',
    pending: 'Chờ xử lý',
    assigned: 'Đã phân công',
    preparing: 'Đang chuẩn bị',
    ready: 'Sẵn sàng giao',
    delivering: orderType === 'PURCHASE' ? 'Đang nhận' : 'Đang giao',
    delivered: orderType === 'PURCHASE' ? 'Đã nhận hàng' : 'Đã giao hàng', // Different text based on order type
    completed: 'Hoàn thành',
    cancelled: 'Hủy bỏ',
    failed: 'Thất bại'
  }
  return statusLabels[status] || status
}

// Timeline helper functions
const formatTime = (dateString: string) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })
}

const formatDate = (dateString: string) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

const getTimeDifference = (fromField: string, toField: string) => {
  if (!selectedItem.value || !selectedItem.value[fromField] || !selectedItem.value[toField]) {
    return null
  }

  const from = new Date(selectedItem.value[fromField])
  const to = new Date(selectedItem.value[toField])
  const diffMs = to.getTime() - from.getTime()

  if (diffMs < 0) return null

  const diffMinutes = Math.floor(diffMs / (1000 * 60))
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

  if (diffDays > 0) {
    return `${diffDays} ngày ${diffHours % 24} giờ`
  } else if (diffHours > 0) {
    return `${diffHours} giờ ${diffMinutes % 60} phút`
  } else if (diffMinutes > 0) {
    return `${diffMinutes} phút`
  } else {
    return 'vài giây'
  }
}

const getTimelineStepClass = (step: string) => {
  if (!selectedItem.value) return 'bg-gray-100 text-gray-400'

  const isCompleted: { [key: string]: boolean } = {
    assigned: !!selectedItem.value.assigned_at,
    preparation: !!selectedItem.value.preparation_at,
    delivery: !!selectedItem.value.delivery_at,
    completed: !!selectedItem.value.completed_at
  }

  const isCurrent: { [key: string]: boolean } = {
    assigned: !!selectedItem.value.assigned_at && !selectedItem.value.preparation_at,
    preparation: !!selectedItem.value.preparation_at && !selectedItem.value.delivery_at,
    delivery: !!selectedItem.value.delivery_at && !selectedItem.value.completed_at,
    completed: !!selectedItem.value.completed_at
  }

  if (isCompleted[step]) {
    return 'bg-green-500 text-white'
  } else if (isCurrent[step]) {
    return 'bg-blue-500 text-white'
  } else {
    return 'bg-gray-100 text-gray-400'
  }
}


// Cache for game and server names to avoid repeated queries
const gameNameCache = ref<Map<string, string>>(new Map())
const serverNameCache = ref<Map<string, string>>(new Map())

// Function to get game name from code
const getGameNameFromCode = async (gameCode: string): Promise<string> => {
  if (!gameCode) return '-'

  // Check cache first
  if (gameNameCache.value.has(gameCode)) {
    const cached = gameNameCache.value.get(gameCode)!
    return cached
  }

  try {
    const { data, error } = await supabase
      .from('attributes')
      .select('name')
      .eq('code', gameCode)
      .eq('type', 'GAME')
      .single()

    if (error || !data) {
      console.warn('Failed to fetch game name:', error)
      gameNameCache.value.set(gameCode, gameCode) // Cache fallback
      return gameCode
    }
    gameNameCache.value.set(gameCode, data.name)
    return data.name
  } catch (error) {
    console.error('Error fetching game name:', error)
    gameNameCache.value.set(gameCode, gameCode) // Cache fallback
    return gameCode
  }
}

// Function to get server name from code
const getServerNameFromCode = async (serverCode: string): Promise<string> => {
  if (!serverCode) return '-'

  // Check cache first
  if (serverNameCache.value.has(serverCode)) {
    return serverNameCache.value.get(serverCode)!
  }

  try {
    const { data, error } = await supabase
      .from('attributes')
      .select('name')
      .eq('code', serverCode)
      .in('type', ['SERVER', 'GAME_SERVER'])
      .single()

    if (error || !data) {
      console.warn('Failed to fetch server name:', error)
      serverNameCache.value.set(serverCode, serverCode) // Cache fallback
      return serverCode
    }

    serverNameCache.value.set(serverCode, data.name)
    return data.name
  } catch (error) {
    console.error('Error fetching server name:', error)
    serverNameCache.value.set(serverCode, serverCode) // Cache fallback
    return serverCode
  }
}

// Reactive display name functions
const gameDisplayNames = ref<Map<string, string>>(new Map())
const serverDisplayNames = ref<Map<string, string>>(new Map())

// Functions to get display names from attributes
const getGameDisplayName = (item: any) => {
  if (!item) return '-'

  // Check if name is already available (this should be set by CurrencyOps.vue)
  if (item?.game_name) {
    return item.game_name
  }

  // If we have game attribute with name, use it
  if (item?.game_attribute?.name) {
    return item.game_attribute.name
  }

  // Use cached name if available
  const gameCode = item?.game_code

  if (gameCode && gameDisplayNames.value.has(gameCode)) {
    const cachedName = gameDisplayNames.value.get(gameCode)!
    return cachedName
  }

  // Fetch name and cache it
  if (gameCode) {
    getGameNameFromCode(gameCode).then(name => {
      gameDisplayNames.value.set(gameCode, name)
    })
  }

  // Fallback to code while loading
  return gameCode || '-'
}

const getServerDisplayName = (item: any) => {
  if (!item) return '-'

  // Check if name is already available (this should be set by CurrencyOps.vue)
  if (item?.server_name) {
    return item.server_name
  }

  // If we have server attribute with name, use it
  if (item?.server_attribute?.name) {
    return item.server_attribute.name
  }

  // Use cached name if available
  const serverCode = item?.server_attribute_code

  if (serverCode && serverDisplayNames.value.has(serverCode)) {
    const cachedName = serverDisplayNames.value.get(serverCode)!
    return cachedName
  }

  // Fetch name and cache it
  if (serverCode) {
    getServerNameFromCode(serverCode).then(name => {
      serverDisplayNames.value.set(serverCode, name)
    })
  }

  // Fallback to code while loading
  return serverCode || '-'
}

const getPriorityLabel = (level: number) => {
  const priorityLabels: { [key: number]: string } = {
    1: 'Rất cao',
    2: 'Cao',
    3: 'Trung bình',
    4: 'Thấp',
    5: 'Rất thấp'
  }
  return priorityLabels[level] || `Độ ưu tiên ${level}`
}

// Badge styling functions for the modal
const getStatusBadgeClass = (status: string) => {
  const statusClasses: { [key: string]: string } = {
    draft: 'bg-gray-100 text-gray-800',
    pending: 'bg-yellow-100 text-yellow-800',
    assigned: 'bg-blue-100 text-blue-800',
    preparing: 'bg-purple-100 text-purple-800',
    ready: 'bg-indigo-100 text-indigo-800',
    delivering: 'bg-orange-100 text-orange-800',
    delivered: 'bg-teal-100 text-teal-800', // Delivered but waiting final confirmation
    completed: 'bg-green-100 text-green-800',
    cancelled: 'bg-red-100 text-red-800',
    failed: 'bg-red-100 text-red-800'
  }
  return statusClasses[status] || 'bg-gray-100 text-gray-800'
}

// Get order type badge class for modal header
const getOrderTypeBadgeClass = (orderType: string) => {
  const orderTypeClasses: { [key: string]: string } = {
    PURCHASE: 'bg-green-100 text-green-800 border-green-200',
    SALE: 'bg-red-100 text-red-800 border-red-200',
    EXCHANGE: 'bg-purple-100 text-purple-800 border-purple-200',
    purchase: 'bg-green-100 text-green-800 border-green-200',
    sale: 'bg-red-100 text-red-800 border-red-200',
    exchange: 'bg-purple-100 text-purple-800 border-purple-200'
  }
  return orderTypeClasses[orderType] || 'bg-gray-100 text-gray-800 border-gray-200'
}

const getPriorityBadgeClass = (level: number) => {
  const priorityClasses: { [key: number]: string } = {
    1: 'bg-red-100 text-red-800',
    2: 'bg-orange-100 text-orange-800',
    3: 'bg-yellow-100 text-yellow-800',
    4: 'bg-green-100 text-green-800',
    5: 'bg-gray-100 text-gray-800'
  }
  return priorityClasses[level] || 'bg-gray-100 text-gray-800'
}

// Color-coded tag functions for channels and currencies
const getChannelTagClass = (channelCode: string) => {
  const channelColors: { [key: string]: string } = {
    'G2G': 'bg-blue-100 text-blue-800 border-blue-200',
    'Eldorado': 'bg-purple-100 text-purple-800 border-purple-200',
    'Facebook': 'bg-indigo-100 text-indigo-800 border-indigo-200',
    'Discord': 'bg-violet-100 text-violet-800 border-violet-200',
    'WeChat': 'bg-green-100 text-green-800 border-green-200',
    'PlayerAuctions': 'bg-orange-100 text-orange-800 border-orange-200',
    'Other': 'bg-gray-100 text-gray-800 border-gray-200'
  }
  return channelColors[channelCode] || channelColors['Other']
}

const getCurrencyTagClass = (currencyCode: string) => {
  // Comprehensive currency grouping rules based on game and rarity
  if (!currencyCode) return 'bg-gray-100 text-gray-800 border-gray-200'

  // Determine game and currency type from code
  const gameCode = currencyCode.includes('_POE1') ? 'POE1' :
                   currencyCode.includes('_POE2') ? 'POE2' :
                   currencyCode.includes('_NW') || currencyCode.includes('_NEW_WORLD') ? 'NEW_WORLD' :
                   currencyCode.includes('_D4') ? 'DIABLO_4' : 'UNKNOWN'

  const currencyType = getCurrencyType(currencyCode)

  // Path of Exile 1 - Red Family
  if (gameCode === 'POE1') {
    switch (currencyType) {
      // Premium Orbs - Dark red background, black border (most important)
      case 'DIVINE_ORB':
      case 'EXALTED_ORB':
      case 'MIRROR':
        return 'bg-red-900 text-white border-black'

      // Standard Orbs - Medium red background, dark red border
      case 'CHAOS_ORB':
      case 'ANCIENT_ORB':
      case 'AWAKENERS_ORB':
        return 'bg-red-700 text-white border-red-900'

      // Common Orbs - Light red background, red border
      case 'ORB':
        return 'bg-red-500 text-white border-red-700'

      // Eldritch Group - Orange tones with intensity levels
      case 'ELDRITCH':
        if (currencyCode.includes('GRAND_')) return 'bg-orange-600 text-white border-orange-800'
        if (currencyCode.includes('GREATER_')) return 'bg-orange-500 text-white border-orange-700'
        if (currencyCode.includes('EXCEPTIONAL_')) return 'bg-orange-400 text-white border-orange-600'
        return 'bg-orange-300 text-orange-900 border-orange-500' // LESSER

      // Lifeforce Group - Yellow-orange tones
      case 'LIFEFORCE':
        if (currencyCode.includes('PRIMAL_')) return 'bg-yellow-600 text-white border-yellow-800'
        if (currencyCode.includes('SACRED_')) return 'bg-yellow-500 text-white border-yellow-700'
        return 'bg-yellow-400 text-yellow-900 border-yellow-600' // VIVID, WILD

      // Utility Items - Light yellow tones
      case 'SEXTANT':
      case 'SCROLL':
      case 'PRISM':
      case 'BAUBLE':
      case 'CHISEL':
      case 'SCRAP':
      case 'WHETSTONE':
        return 'bg-yellow-200 text-yellow-900 border-yellow-400'

      // Miscellaneous
      case 'MISC':
      default:
        return 'bg-red-200 text-red-900 border-red-400'
    }
  }

  // Path of Exile 2 - Blue Family
  if (gameCode === 'POE2') {
    switch (currencyType) {
      // Premium Orbs - Dark blue background, black border
      case 'DIVINE_ORB':
      case 'EXALTED_ORB':
      case 'MIRROR':
        return 'bg-blue-900 text-white border-black'

      // Standard Orbs - Medium blue background, dark blue border
      case 'CHAOS_ORB':
      case 'ANCIENT_ORB':
      case 'AWAKENERS_ORB':
        return 'bg-blue-700 text-white border-blue-900'

      // Common Orbs - Light blue background, blue border
      case 'ORB':
        return 'bg-blue-500 text-white border-blue-700'

      // Eldritch Group - Cyan tones with intensity levels
      case 'ELDRITCH':
        if (currencyCode.includes('GRAND_')) return 'bg-cyan-600 text-white border-cyan-800'
        if (currencyCode.includes('GREATER_')) return 'bg-cyan-500 text-white border-cyan-700'
        if (currencyCode.includes('EXCEPTIONAL_')) return 'bg-cyan-400 text-white border-cyan-600'
        return 'bg-cyan-300 text-cyan-900 border-cyan-500' // LESSER

      // Lifeforce Group - Teal-green tones
      case 'LIFEFORCE':
        if (currencyCode.includes('PRIMAL_')) return 'bg-teal-600 text-white border-teal-800'
        if (currencyCode.includes('SACRED_')) return 'bg-teal-500 text-white border-teal-700'
        return 'bg-teal-400 text-teal-900 border-teal-600' // VIVID, WILD

      // Utility Items - Light sky blue tones
      case 'SEXTANT':
      case 'SCROLL':
      case 'PRISM':
      case 'BAUBLE':
      case 'CHISEL':
      case 'SCRAP':
      case 'WHETSTONE':
        return 'bg-sky-200 text-sky-900 border-sky-400'

      // Miscellaneous
      case 'MISC':
      default:
        return 'bg-blue-200 text-blue-900 border-blue-400'
    }
  }

  // New World - Green Family
  if (gameCode === 'NEW_WORLD') {
    switch (currencyType) {
      case 'GOLD':
        return 'bg-green-700 text-white border-green-900' // Premium currency
      default:
        return 'bg-green-500 text-white border-green-700'
    }
  }

  // Diablo 4 - Purple Family
  if (gameCode === 'DIABLO_4') {
    switch (currencyType) {
      case 'GOLD':
        return 'bg-purple-700 text-white border-purple-900' // Premium currency
      default:
        return 'bg-purple-500 text-white border-purple-700'
    }
  }

  // Default for unknown currencies
  return 'bg-gray-100 text-gray-800 border-gray-200'
}

// Helper function to determine currency type from code
const getCurrencyType = (code: string) => {
  if (code.includes('MIRROR')) return 'MIRROR'
  if (code.includes('DIVINE')) return 'DIVINE_ORB'
  if (code.includes('EXALTED')) return 'EXALTED_ORB'
  if (code.includes('CHAOS')) return 'CHAOS_ORB'
  if (code.includes('ANCIENT')) return 'ANCIENT_ORB'
  if (code.includes('AWAKENERS')) return 'AWAKENERS_ORB'
  if (code.includes('ELDRITCH')) return 'ELDRITCH'
  if (code.includes('SEXTANT')) return 'SEXTANT'
  if (code.includes('SCRAP')) return 'SCRAP'
  if (code.includes('WHETSTONE')) return 'WHETSTONE'
  if (code.includes('CHISEL')) return 'CHISEL'
  if (code.includes('PRISM')) return 'PRISM'
  if (code.includes('BAUBLE')) return 'BAUBLE'
  if (code.includes('GOLD')) return 'GOLD'
  if (code.includes('SCROLL')) return 'SCROLL'
  if (code.includes('SACRED') || code.includes('PRIMAL') || code.includes('VIVID') || code.includes('WILD')) return 'LIFEFORCE'
  if (code.includes('JEWELLERS')) return 'JEWELLERS_ORB'
  if (code.includes('CHROMATIC')) return 'CHROMATIC_ORB'
  if (code.includes('REGAL')) return 'REGAL_ORB'
  if (code.includes('ALCHEMY')) return 'ALCHEMY_ORB'
  if (code.includes('ALTERATION')) return 'ALTERATION_ORB'
  if (code.includes('AUGMENTATION')) return 'AUGMENTATION_ORB'
  if (code.includes('TRANSMUTATION')) return 'TRANSMUTATION_ORB'
  if (code.includes('CHANCE')) return 'CHANCE_ORB'
  if (code.includes('FUSING')) return 'FUSING_ORB'
  if (code.includes('ORB')) return 'ORB'
  return 'MISC'
}

// Currency formatting function
const formatCurrency = (amount: number | string, currency: string = 'VND') => {
  const numAmount = typeof amount === 'string' ? parseFloat(amount) || 0 : amount

  // Format based on currency type
  switch (currency.toUpperCase()) {
    case 'VND':
      // Vietnamese Dong: format with comma separators, no decimal places
      return `${numAmount.toLocaleString('vi-VN', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      })} ₫`

    case 'USD':
      // US Dollar: format with comma separators, 2 decimal places
      return `$${numAmount.toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })}`

    case 'CNY':
      // Chinese Yuan: format with comma separators, 2 decimal places
      return `¥${numAmount.toLocaleString('zh-CN', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })}`

    case 'EUR':
      // Euro: format with comma separators, 2 decimal places
      return `€${numAmount.toLocaleString('de-DE', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })}`

    default:
      // Default formatting: use Vietnamese locale for thousands separator
      const formatted = numAmount.toLocaleString('vi-VN', {
        minimumFractionDigits: currency === 'VND' ? 0 : 2,
        maximumFractionDigits: currency === 'VND' ? 0 : 2
      })

      // Add currency symbol if not VND (which already has ₫)
      return currency === 'VND' ? `${formatted} ₫` : `${formatted} ${currency}`
  }
}

// Note: getCombinedDeliveryInfo function removed since modal now shows delivery_info and notes separately

// Row key for table
const rowKey = (row: any) => row.id

// Event handlers
const onSearch = () => {
  emit('search', searchQuery.value)
}

const onFilterChange = () => {
  emit('filter-change', filters.value)
}

// Quick date range methods
const setQuickDateRange = (range: string) => {
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000)

  switch (range) {
    case 'today':
      filters.value.startDateTime = today.getTime()
      filters.value.endDateTime = tomorrow.getTime() - 1 // End of today
      break

    case 'yesterday':
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000)
      filters.value.startDateTime = yesterday.getTime()
      filters.value.endDateTime = today.getTime() - 1
      break

    case 'thisWeek':
      const thisWeekStart = new Date(today)
      thisWeekStart.setDate(today.getDate() - today.getDay())
      thisWeekStart.setHours(0, 0, 0, 0)
      filters.value.startDateTime = thisWeekStart.getTime()
      filters.value.endDateTime = tomorrow.getTime() - 1
      break

    case 'lastWeek':
      const lastWeekStart = new Date(today)
      lastWeekStart.setDate(today.getDate() - today.getDay() - 7)
      lastWeekStart.setHours(0, 0, 0, 0)
      const lastWeekEnd = new Date(today)
      lastWeekEnd.setDate(today.getDate() - today.getDay())
      lastWeekEnd.setHours(0, 0, 0, 0)
      filters.value.startDateTime = lastWeekStart.getTime()
      filters.value.endDateTime = lastWeekEnd.getTime() - 1
      break

    case 'thisMonth':
      const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1)
      filters.value.startDateTime = thisMonthStart.getTime()
      filters.value.endDateTime = tomorrow.getTime() - 1
      break

    case 'lastMonth':
      const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1)
      const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 1)
      filters.value.startDateTime = lastMonthStart.getTime()
      filters.value.endDateTime = lastMonthEnd.getTime() - 1
      break
  }

  // Trigger filter change after setting date range
  emit('filter-change', filters.value)
}

const clearDateFilters = () => {
  filters.value.startDateTime = null
  filters.value.endDateTime = null
  emit('filter-change', filters.value)
}

const onExport = () => {
  emit('export')
}

const onPageChange = (page: number) => {
  pagination.value.page = page
}

const onPageSizeChange = (pageSize: number) => {
  pagination.value.pageSize = pageSize
  pagination.value.page = 1
}

const onViewDetail = (item: any) => {
  selectedItem.value = item
  showDetailModal.value = true
  emit('view-detail', item)

  // Fix aria-hidden warning by focusing modal content after it opens
  nextTick(() => {
    const modalElement = document.querySelector('[role="dialog"]')
    if (modalElement) {
      // Move focus to first focusable element in modal
      const firstFocusable = modalElement.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])') as HTMLElement
      if (firstFocusable) {
        firstFocusable.focus()
      }
    }
  })
}

const onUpdateStatus = (item: any, status: string) => {
  emit('update-status', item, status)
}

const onFinalizeOrder = (item: any) => {
  emit('finalize-order', item)
}

// Helper function to update order status and show message
const updateOrderStatusAndShowMessage = async (copiedText: string, textType: string) => {
  try {
    // Copy to clipboard
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(copiedText)
    } else {
      // Fallback for older browsers
      const textArea = document.createElement('textarea')
      textArea.value = copiedText
      document.body.appendChild(textArea)
      textArea.focus()
      textArea.select()
      document.execCommand('copy')
      document.body.removeChild(textArea)
    }

    // Update order status to 'delivering' if current status allows it
    const allowedStatuses = ['preparing', 'ready']
    if (allowedStatuses.includes(selectedItem.value?.status)) {
      emit('update-status', selectedItem.value, 'delivering')
    }

    // Show success message
    const deliveringText = selectedItem.value?.order_type === 'PURCHASE' ? 'Đang nhận' : 'Đang giao'
    message.success(`Đã copy ${textType}${allowedStatuses.includes(selectedItem.value?.status) ? ` và chuyển sang trạng thái "${deliveringText}"` : ''}`)

  } catch (error) {
    console.error('Error copying:', error)
    message.error(`Không thể copy ${textType}`)
  }
}

const handleCopyGameTag = async () => {
  if (!selectedItem.value) return

  const gameTagText = selectedItem.value?.delivery_info || selectedItem.value?.deliveryInfo || ''
  await updateOrderStatusAndShowMessage(gameTagText, 'tên nhân vật/ID Game')
}

const handleCopyNotes = async () => {
  if (!selectedItem.value) return

  const notesText = selectedItem.value?.notes || ''
  await updateOrderStatusAndShowMessage(notesText, 'thông tin giao hàng + Ghi chú')
}

// Legacy function for backward compatibility
const handleCopyDeliveryInfo = handleCopyNotes



// Handle proof upload completion
const handleProofUploadComplete = async () => {
  // Files are uploaded and cached by SimpleProofUpload component
}

const handleConfirmDelivery = async () => {
  if (!selectedItem.value || selectedProofFiles.value.length === 0) {
    message.error('Vui lòng tải lên ít nhất một bằng chứng')
    return
  }

  try {
    uploading.value = true

    const order = selectedItem.value
    const orderNumber = order.order_number || `#${order.id?.slice(0, 8)}`

    // Additional validation check
    if (!order.id || !order.order_type || !order.status) {
      throw new Error('Dữ liệu đơn hàng không hợp lệ')
    }

  
    // Upload files manually (work-proofs is bucket name, not part of path)
    const uploadPath = order.order_type === 'PURCHASE'
      ? `currency/purchase/${order.order_number}/delivery`
      : `currency/sale/${order.order_number}/delivery`

    // Import uploadFile function
    const { uploadFile } = await import('@/lib/supabase')
    const { createUniqueFilename } = await import('@/utils/filenameUtils')

    // Upload all files
    const uploadPromises = selectedProofFiles.value.map(async (f, index) => {
      if (!f.file) {
        throw new Error(`File ${f.name} không có dữ liệu`)
      }

      // Create unique filename with sanitization
      const filename = createUniqueFilename(f.file.name)
      const filePath = `${uploadPath}/${filename}`

      const uploadResult = await uploadFile(f.file, filePath, 'work-proofs')

      if (!uploadResult.success) {
        throw new Error(uploadResult.error || 'Upload thất bại')
      }

      return {
        url: uploadResult.publicUrl,
        path: uploadResult.path,
        filename: f.name,
        type: order.order_type === 'PURCHASE' ? 'receiving' : 'delivery',
        uploaded_at: new Date().toISOString()
      }
    })

    const newProofFiles = await Promise.all(uploadPromises)

    // Prepare proof data for database - handle different proof formats
    let existingProofs: any[] = []

    if (order.proofs) {
      try {
        // Handle case where proofs is a stringified JSON
        if (typeof order.proofs === 'string') {
          existingProofs = JSON.parse(order.proofs)
        }
        // Handle case where proofs is an array but might be corrupted
        else if (Array.isArray(order.proofs)) {
          // Check if array contains corrupted character data
          if (order.proofs.length > 0 && typeof order.proofs[0] === 'string' && order.proofs[0].length === 1) {
            // Corrupted array - skip it and start fresh
            existingProofs = []
            console.warn('Found corrupted proofs array, starting fresh')
          } else {
            existingProofs = order.proofs
          }
        }
      } catch (error) {
        console.error('Error parsing existing proofs:', error)
        existingProofs = []
      }
    }

    // Merge proofs by type to preserve all proof types
    let mergedProofs = [...existingProofs]

    // Remove any existing proofs of the same type to avoid duplicates
    const newProofType = order.order_type === 'PURCHASE' ? 'receiving' : 'delivery'
    mergedProofs = mergedProofs.filter(proof => proof.type !== newProofType)

    // Add new proofs
    const newProofs = [...mergedProofs, ...newProofFiles]

    // For SELL orders: Don't update proofs here - let the backend function handle it
    // For PURCHASE orders: Update proofs normally
    if (order.order_type !== 'SALE') {
      // Upload proofs first
      const updateData: any = {
        proofs: newProofs,
        updated_at: new Date().toISOString()
      }

      const { error: proofUpdateError } = await supabase
        .from('currency_orders')
        .update(updateData)
        .eq('id', order.id)

      if (proofUpdateError) {
        console.error('Error updating order with proofs:', proofUpdateError)
        throw proofUpdateError
      }

      // Update local data
      if (selectedItem.value) {
        selectedItem.value.proofs = newProofs
      }

      const successMessage = `✅ Đã tải lên ${newProofFiles.length} bằng chứng cho đơn ${orderNumber} thành công!`
      message.success(successMessage)

      // Emit event to refresh parent data
      emit('proof-uploaded', { orderId: order.id, proofs: newProofs })
    }

    // Reset files (for all order types)
    selectedProofFiles.value = []

    // Step 2: Process inventory BEFORE changing status (only for purchase orders)
    if (order.order_type === 'PURCHASE' && ['assigned', 'delivering', 'ready', 'preparing'].includes(order.status)) {
      // Emit a special event for inventory processing
      emit('process-inventory', {
        order: { ...order, proofs: newProofs },
        currentStatus: order.status,
        targetStatus: 'delivered'
      })

      // Close modal after processing
      showDetailModal.value = false
      return
    }

    // For SELL orders: Use delivery processing with profit calculation
    if (order.order_type === 'SALE' && ['assigned', 'delivering', 'ready', 'preparing'].includes(order.status)) {
      try {
        // Get current user profile ID using existing function
        const { data: profileId, error: profileError } = await supabase.rpc('get_current_profile_id')

        if (profileError || !profileId) {
          throw new Error('Unable to get current user profile')
        }

        // Get delivery proof URL from new proofs
        const deliveryProof = newProofFiles.find(proof => proof.type === 'delivery')
        const deliveryProofUrl = deliveryProof?.url || newProofFiles[newProofFiles.length - 1]?.url

        if (!deliveryProofUrl) {
          throw new Error('Vui lòng tải lên bằng chứng giao hàng (bắt buộc)')
        }

        // Call the delivery processing function
        const { data: processResult, error: processError } = await supabase.rpc(
          'process_sell_order_delivery',
          {
            p_order_id: order.id,
            p_delivery_proof_url: deliveryProofUrl,
            p_user_id: profileId
          }
        )

        if (processError) {
          throw new Error(processError.message || 'Failed to process delivery')
        }

        if (!processResult[0]?.success) {
          throw new Error(processResult[0]?.message || 'Delivery processing failed')
        }

        // Show profit information if available
        const profitInfo = processResult[0]
        let successMessage = `✅ Đã xử lý giao hàng đơn ${orderNumber} thành công`

        if (profitInfo.profit_amount) {
          successMessage += `\n💰 Lợi nhuận: $${Number(profitInfo.profit_amount).toFixed(2)} USD`
        }

        // Show fees breakdown if available
        if (profitInfo.fees_breakdown && Array.isArray(profitInfo.fees_breakdown)) {
          successMessage += `\n📊 Phí áp dụng: ${profitInfo.fees_breakdown.length} khoản phí`
        }

        message.success(successMessage)

        // Update local status
        if (selectedItem.value) {
          selectedItem.value.status = 'delivered'
          selectedItem.value.delivery_at = new Date().toISOString()
          selectedItem.value.profit_amount = profitInfo.profit_amount
          selectedItem.value.profit_currency_code = 'USD'
        }

        // Emit status update
        emit('update-status', { ...order, status: 'delivered' }, 'delivered')

        // Close modal after successful delivery processing
        showDetailModal.value = false

      } catch (deliveryError: any) {
        console.error('Error processing delivery:', deliveryError)
        throw new Error(`Lỗi xử lý giao hàng: ${deliveryError.message}`)
      }
    }
    // For non-purchase orders or orders not eligible for inventory processing
    // Just update status normally
    else if (['assigned', 'delivering', 'ready', 'preparing'].includes(order.status)) {

      const { error: statusUpdateError } = await supabase
        .from('currency_orders')
        .update({
          status: 'delivered',
          updated_at: new Date().toISOString()
        })
        .eq('id', order.id)

      if (statusUpdateError) {
        console.error('Error updating order status:', statusUpdateError)
        throw statusUpdateError
      }

      // Update local status
      if (selectedItem.value) {
        selectedItem.value.status = 'delivered'
      }

      // Emit status update
      emit('update-status', { ...order, status: 'delivered' }, 'delivered')
    }

    // Close detail modal after successful confirmation
    showDetailModal.value = false

  } catch (error: any) {
    console.error('Error confirming delivery:', error)
    message.error(error.message || 'Không thể xác nhận giao/nhận hàng. Vui lòng thử lại.')
  } finally {
    uploading.value = false
  }
}

// Cancel order functions
const handleCancelOrder = (item: any) => {
  selectedOrderToCancel.value = item
  cancelReason.value = ''
  cancelProofFiles.value = []
  cancelConfirmed.value = false
  showCancelModal.value = true
}

const handleConfirmCancel = async () => {
  if (!selectedOrderToCancel.value || !cancelReason.value.trim()) {
    message.error('Vui lòng nhập lý do hủy đơn hàng')
    return
  }

  try {
    cancellingOrder.value = true
    const order = selectedOrderToCancel.value
    const orderNumber = order.order_number || `#${order.id?.slice(0, 8)}`

  
    // Step 1: Upload proof files if any
    let newProofsData: any[] = []
    if (cancelProofFiles.value.length > 0) {
      const uploadPath = order.order_type === 'PURCHASE'
        ? `currency/purchase/${order.order_number}/cancel`
        : `currency/sale/${order.order_number}/cancel`

      // Import uploadFile function
      const { uploadFile } = await import('@/lib/supabase')
      const { createUniqueFilename } = await import('@/utils/filenameUtils')

      // Upload all cancel proof files
      const uploadPromises = cancelProofFiles.value.map(async (f) => {
        if (!f.file) {
          throw new Error(`File ${f.name} không có dữ liệu`)
        }

        // Create unique filename with sanitization
        const filename = createUniqueFilename(f.file.name)
        const filePath = `${uploadPath}/${filename}`

  
        const uploadResult = await uploadFile(
          f.file,
          filePath,
          'work-proofs'
        )

        if (!uploadResult.success) {
          throw new Error(`Lỗi upload file ${f.name}: ${uploadResult.error}`)
        }

        // Return proof object in correct format for JSONB storage
        return {
          url: uploadResult.publicUrl,
          path: uploadResult.path,
          type: 'cancel',
          filename: f.file.name,
          uploaded_at: new Date().toISOString()
        }
      })

      newProofsData = await Promise.all(uploadPromises)
    }

    // Step 2: Combine all updates in a single query
    const cancelNote = `HỦY ĐƠN: ${cancelReason.value.trim()}`

    // Get existing proofs and add new cancel proofs
    const existingProofs = Array.isArray(order.proofs) ? order.proofs : []
    const updatedProofs = [...existingProofs, ...newProofsData]

    // Update order in a single query
    const { error: orderError } = await supabase
      .from('currency_orders')
      .update({
        status: 'cancelled',
        cancelled_at: new Date().toISOString(),
        notes: order.notes ? `${order.notes}\n\n${cancelNote}` : cancelNote,
        proofs: updatedProofs,
        updated_at: new Date().toISOString()
      })
      .eq('id', order.id)

    if (orderError) {
      throw new Error(`Lỗi cập nhật trạng thái đơn: ${orderError.message}`)
    }

    // Step 3: Emit refresh event to parent (no status processing needed)
    emit('refresh-data')

    // Show success message
    message.success(`Đã hủy đơn hàng ${orderNumber} thành công`)

    // Close cancel modal
    showCancelModal.value = false

    // Reset form
    cancelReason.value = ''
    cancelProofFiles.value = []
    cancelConfirmed.value = false
    selectedOrderToCancel.value = null

  } catch (error: any) {
    console.error('Error cancelling order:', error)
    message.error(error.message || 'Không thể hủy đơn hàng. Vui lòng thử lại.')
  } finally {
    cancellingOrder.value = false
  }
}

// Helper function to get exchange type label
const getExchangeTypeLabel = (exchangeType: string) => {
  const labels: { [key: string]: string } = {
    none: 'Không trao đổi',
    buy_to_sell: 'Mua → Bán',
    sell_to_buy: 'Bán → Mua',
    deposit: 'Nạp tiền',
    withdraw: 'Rút tiền',
    exchange: 'Trao đổi'
  }
  return labels[exchangeType] || exchangeType
}

// File handling functions for proof display
const isImageFile = (url: string) => {
  if (!url) return false
  const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp']
  const extension = url.split('.').pop()?.toLowerCase()
  return imageExtensions.includes('.' + (extension || ''))
}

const getFileName = (url: string) => {
  if (!url) return 'Unknown file'
  return url.split('/').pop() || url.split('\\').pop() || 'Unknown file'
}

const getImageUrl = (url: string) => {
  if (!url) return ''
  // If it's a full URL, return as is
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url
  }
  // If it's a Supabase storage path, get public URL
  if (url.startsWith('currency/')) {
    const { data: { publicUrl } } = supabase.storage
      .from('currency')
      .getPublicUrl(url)
    return publicUrl
  }
  // Otherwise, return as is
  return url
}

// Helper function to handle both object and array proof formats
const getProofsArray = (proofs: any) => {
  if (!proofs) return []

  // If it's already an array, return as is
  if (Array.isArray(proofs)) return proofs

  // If it's an object with url property, convert to array
  if (typeof proofs === 'object' && proofs.url) {
    return [proofs]
  }

  // If it's any other object, try to convert to array
  if (typeof proofs === 'object') {
    return [proofs]
  }

  return []
}

const viewImage = (url: string) => {
  const imageUrl = getImageUrl(url)
  if (imageUrl) {
    // Create a temporary link to test if URL is accessible
    const testLink = document.createElement('a')
    testLink.href = imageUrl
    testLink.target = '_blank'

    // Try to fetch first to verify it's an image
    fetch(imageUrl, { method: 'GET' })
      .then(async response => {
        if (response.ok && response.headers.get('content-type')?.startsWith('image/')) {
          // It's a valid image, open it
          window.open(imageUrl, '_blank')
        } else {
          // Not an image or error, get the actual response content
          const responseText = await response.text()
          let errorDetails = {
            url: imageUrl,
            status: response.status,
            contentType: response.headers.get('content-type'),
            response: responseText
          }

          console.error('Invalid image response:', errorDetails)

          // Check if response is empty - file likely doesn't exist in storage
          if (!responseText || responseText.trim() === '') {
            message.error('File bằng chứng không tồn tại trong storage. Cần upload lại bằng chứng cho đơn hàng này.')
            console.error('File not found in storage. The upload may have failed but URL was saved to database.')
          } else {
            // Try to parse as JSON to get meaningful error message
            try {
              const jsonResponse = JSON.parse(responseText)

              // Check if it's SimpleProofUpload component data
              if (jsonResponse.id && jsonResponse.name && jsonResponse.status === 'pending' && jsonResponse.url === null) {
                message.error('URL đang trỏ đến component data thay vì image file. Có thể có routing hoặc CORS issue.')
                console.error('URL routing issue - getting SimpleProofUpload data instead of image:', {
                  url: imageUrl,
                  componentData: jsonResponse
                })
              } else {
                const errorMessage = jsonResponse?.error?.message || jsonResponse?.message || 'Lỗi không xác định'
                message.error(`Không thể tải hình ảnh: ${errorMessage}`)
              }
            } catch {
              // Not JSON, show generic error
              message.error(`Không thể tải hình ảnh: Server trả về ${response.headers.get('content-type')} thay vì image`)
            }
          }
        }
      })
      .catch(error => {
        message.error(`Lỗi khi tải hình ảnh: ${error.message}`)
        console.error('Error fetching image:', error)
      })
  } else {
    message.error('URL hình ảnh không hợp lệ')
  }
}

const downloadFile = (url: string) => {
  const fileUrl = getImageUrl(url)
  if (fileUrl) {
    const link = document.createElement('a')
    link.href = fileUrl
    link.download = getFileName(url)
    link.target = '_blank'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}

// Load data on mount
onMounted(() => {
  pagination.value.itemCount = props.data.length
})

// Watch data changes
watch(() => props.data, () => {
  pagination.value.itemCount = props.data.length
})

</script>

<style scoped>
.data-list-currency {
  width: 100%;
}

.n-data-table {
  --n-td-color: white;
  --n-th-color: #f8fafc;
}

.n-data-table :deep(.n-data-table-th) {
  background-color: #f8fafc;
  font-weight: 600;
  color: #374151;
}

.n-data-table :deep(.n-data-table-td) {
  padding: 12px 16px;
}

.n-data-table :deep(.n-data-table-tr:hover) {
  background-color: #f9fafb;
}
</style>