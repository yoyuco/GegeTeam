<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold tracking-tight">Service – Boosting</h1>
      <div class="flex items-center gap-2">
        <n-button size="small" :loading="loading" @click="loadOrders">Làm mới</n-button>
        <n-switch v-model:value="autoRefresh" size="small">
          <template #checked>Auto</template>
          <template #unchecked>Auto</template>
        </n-switch>
      </div>
    </div>

    <n-card :bordered="false" class="shadow-sm">
      <div class="flex items-end gap-3 mb-4 flex-wrap">
        <n-form-item label="Kênh bán" size="small" class="mb-0">
          <n-select
            v-model:value="filters.channels"
            multiple
            clearable
            max-tag-count="responsive"
            :options="channelOptions"
            placeholder="Kênh bán"
            style="width: 200px"
          />
        </n-form-item>

        <n-form-item label="Loại dịch vụ" size="small" class="mb-0">
          <n-select
            v-model:value="filters.serviceTypes"
            multiple
            clearable
            max-tag-count="responsive"
            :options="serviceTypeOptions"
            placeholder="Loại"
            style="width: 150px"
          />
        </n-form-item>

        <n-form-item label="Gói dịch vụ" size="small" class="mb-0">
          <n-select
            v-model:value="filters.packageTypes"
            multiple
            clearable
            max-tag-count="responsive"
            :options="packageTypeOptions"
            placeholder="Gói dịch vụ"
            style="width: 150px"
          />
        </n-form-item>

        <n-form-item label="Trạng thái" size="small" class="mb-0">
          <n-select
            v-model:value="filters.statuses"
            multiple
            clearable
            max-tag-count="responsive"
            :options="statusOptions"
            placeholder="Trạng thái"
            style="width: 200px"
            class="wide-dropdown"
          />
        </n-form-item>

        <n-form-item label="Tên khách hàng" size="small" class="mb-0">
          <n-input v-model:value="filters.customerName" clearable placeholder="Tên khách hàng" />
        </n-form-item>

        <n-form-item label="Người thực hiện" size="small" class="mb-0">
          <n-input v-model:value="filters.assignee" clearable placeholder="Người thực hiện" />
        </n-form-item>

        <n-form-item label="Trạng thái giao hàng" size="small" class="mb-0">
          <n-select
            v-model:value="filters.deliveryStatus"
            clearable
            :options="deliveryStatusOptions"
            placeholder="TT giao hàng"
            style="width: 150px"
          />
        </n-form-item>

        <n-form-item label="Trạng thái review" size="small" class="mb-0">
          <n-select
            v-model:value="filters.reviewStatus"
            clearable
            :options="reviewStatusOptions"
            placeholder="TT Review"
            style="width: 150px"
          />
        </n-form-item>
        <n-button size="small" tertiary @click="resetFilters">Xóa bộ lọc</n-button>
      </div>

      <div class="table-wrap overflow-x-auto">
        <n-data-table
          :columns="columns"
          :data="filteredRows"
          :loading="loading"
          :pagination="pagination"
          size="small"
          :row-key="(r) => r.id"
          class="datatable--tight"
        />
      </div>
    </n-card>

    <n-drawer v-model:show="detailOpen" width="1120" placement="right" @after-leave="onDrawerClose">
      <n-drawer-content title="Thao tác đơn hàng">
        <div class="flex items-center justify-between mb-2">
          <div class="text-sm text-neutral-500">Thông tin đơn hàng</div>
          <div class="flex items-center gap-2">
            <template v-if="!editing">
              <n-button
                v-if="canEditOrderDetails"
                :disabled="isOrderFinalized"
                size="tiny"
                tertiary
                @click="toggleEdit()"
                >Sửa</n-button
              >
            </template>
            <template v-else>
              <n-button size="tiny" type="primary" @click="saveInfo" :loading="savingInfo"
                >Lưu</n-button
              >
              <n-button size="tiny" tertiary @click="cancelEdit">Huỷ</n-button>
            </template>
          </div>
        </div>

        <n-divider class="!my-3">Thông tin chính</n-divider>

        <div class="space-y-1">
          <div class="row">
            <div class="meta">Loại hình</div>
            <div class="val">
              <n-radio-group
                v-model:value="detail.service_type"
                name="service_type"
                size="small"
                :disabled="!editing || isOrderFinalized"
                class="service-type"
              >
                <n-radio-button value="Selfplay">Selfplay</n-radio-button>
                <n-radio-button value="Pilot">Pilot</n-radio-button>
              </n-radio-group>
            </div>
          </div>
          <div class="row">
            <div class="meta">Dịch vụ (gói)</div>
            <div class="val">
              <div class="flex items-center gap-2">
                <n-tag size="small" :type="pkgTypeTag(detail.package_type).type" :bordered="false">
                  {{ pkgTypeTag(detail.package_type).label }}
                </n-tag>
                <span class="text-xs text-neutral-500">|</span>
                <span class="text-sm">{{ detail.channel_code }}</span>
                <span class="text-xs text-neutral-400">•</span>
                <span class="text-sm">{{ detail.customer_name }}</span>
              </div>
              <div v-if="editing" class="mt-2">
                <n-input
                  v-model:value="detail.package_note"
                  type="textarea"
                  :autosize="{ minRows: 1, maxRows: 3 }"
                  placeholder="Ghi chú gói dịch vụ"
                  :disabled="isOrderFinalized"
                />
              </div>
              <div class="text-sm text-neutral-500 mt-1" v-else-if="detail.package_note">
                {{ detail.package_note }}
              </div>
            </div>
          </div>

          <div class="row">
            <div class="meta">Mô tả</div>
            <div class="val">
              <template v-if="detail.service_items?.length">
                <div
                  v-if="isDescCollapsed"
                  class="whitespace-pre-line"
                  v-html="generateServiceDescription(detail.service_items).summaryHtml"
                ></div>
                <div
                  v-else
                  v-html="generateServiceDescription(detail.service_items).detailHtml"
                ></div>

                <n-button
                  text
                  size="tiny"
                  type="primary"
                  @click="isDescCollapsed = !isDescCollapsed"
                  class="mt-1"
                >
                  {{ isDescCollapsed ? 'Xem thêm' : 'Thu gọn' }}
                </n-button>
              </template>

              <span v-else>—</span>
            </div>
          </div>

          <div class="row">
            <div class="meta">Deadline</div>
            <div class="val">
              <template v-if="editing">
                <n-date-picker
                  v-model:value="deadlineModel"
                  type="datetime"
                  clearable
                  placeholder="Chọn hạn chót"
                  class="w-full"
                  :disabled="isOrderFinalized"
                />
              </template>
              <template v-else>
                <n-tooltip trigger="hover" v-if="detail.deadline">
                  <template #trigger>
                    <n-tag size="small" :type="drawerDeadlineDisplay.color" :bordered="false">
                      {{ drawerDeadlineDisplay.text }}
                    </n-tag>
                  </template>
                  {{ new Date(toTs(detail.deadline)!).toLocaleString() }}
                </n-tooltip>
                <span v-else>—</span>
              </template>
            </div>
          </div>

          <div class="row">
            <div class="meta">Trạng thái</div>
            <div class="val">
              <n-tag size="small" :type="statusView(detail.status).type" :bordered="false">
                {{ statusView(detail.status).label }}
              </n-tag>
            </div>
          </div>
          <div class="row">
            <div class="meta">Người thực hiện</div>
            <div class="val">
              <span class="text-sm">{{ detail.assignees_text || '—' }}</span>
            </div>
          </div>
          <div class="row" v-if="detail.service_type === 'Selfplay'">
            <div class="meta">Btag</div>
            <div class="val flex items-center gap-2">
              <n-input
                v-if="editing"
                v-model:value="detail.btag"
                placeholder="Player#1234"
                :disabled="isOrderFinalized"
              />
              <template v-else>
                <span>{{ detail.btag || '—' }}</span>
                <n-button
                  v-if="detail.btag"
                  size="tiny"
                  tertiary
                  @click="copyToClipboard(detail.btag!)"
                  >Copy</n-button
                >
              </template>
            </div>
          </div>
          <template v-else>
            <div class="row">
              <div class="meta">Login ID</div>
              <div class="val flex items-center gap-2">
                <n-input v-if="editing" v-model:value="detail.login_id" placeholder="Login ID" />
                <template v-else>
                  <span>{{ detail.login_id || '—' }}</span>
                  <n-button
                    v-if="detail.login_id"
                    size="tiny"
                    tertiary
                    @click="copyToClipboard(detail.login_id!)"
                    >Copy</n-button
                  >
                </template>
              </div>
            </div>
            <div class="row">
              <div class="meta">Login Pwd</div>
              <div class="val flex items-center gap-2">
                <n-input
                  v-if="editing"
                  v-model:value="detail.login_pwd"
                  type="password"
                  show-password-on="mousedown"
                  placeholder="••••••"
                />
                <template v-else>
                  <span>{{ detail.login_pwd ? '••••••' : '—' }}</span>
                  <n-button
                    v-if="detail.login_pwd"
                    size="tiny"
                    tertiary
                    @click="copyToClipboard(detail.login_pwd!)"
                    >Copy</n-button
                  >
                </template>
              </div>
            </div>
            <div class="row" v-if="detail.service_type === 'Pilot'">
              <div class="meta">Máy thực hiện</div>
              <div class="val flex items-center gap-2">
                <n-input
                  v-model:value="machineInfoModel"
                  placeholder="Ex: Máy 35"
                  :disabled="!isEditingMachineInfo"
                  :class="{
                    'highlight-required': isEditingMachineInfo,
                    'input-as-text': !isEditingMachineInfo && machineInfoModel,
                  }"
                  style="width: 140px"
                />

                <n-button
                  v-if="isEditingMachineInfo"
                  size="tiny"
                  tertiary
                  @click="saveMachineInfo"
                  :loading="savingInfo"
                >
                  Lưu
                </n-button>

                <n-button v-else size="tiny" tertiary @click="isEditingMachineInfo = true">
                  Sửa
                </n-button>
              </div>
            </div>
          </template>
        </div>

        <n-divider class="!my-3">Danh mục sub (svc_items)</n-divider>

        <n-spin :show="detailLoading">
          <div class="space-y-2">
            <div v-for="grp in svcGroups" :key="grp.key" class="svc-kind">
              <div
                class="svc-kind__head flex items-center justify-between cursor-pointer"
                @click="toggleKindCollapse(grp.key)"
              >
                <span>{{ grp.label }}</span>
                <n-icon>
                  <chevron-up v-if="!collapsedKinds.has(grp.key)" />
                  <chevron-down v-else />
                </n-icon>
              </div>
              <div v-show="!collapsedKinds.has(grp.key)" class="svc-kind__grid">
                <div v-for="it in grp.items" :key="it.id" class="svc-item-row">
                  <template v-if="rowMap.has(String(it.id))">
                    <div class="cell cell-check">
                      <n-checkbox
                        :checked="isPicked(it.id)"
                        @update:checked="(c: boolean) => togglePick(it, c)"
                        :disabled="
                          isLevelingItemDisabled(it) || !!it.active_report_id || isOrderFinalized
                        "
                      />
                    </div>
                    <div class="cell cell-label">
                      <div class="flex items-center gap-2">
                        <span v-html="paramsLabel(it)"></span>
                        <n-tag
                          v-if="rowMap.has(String(it.id))"
                          size="tiny"
                          round
                          :type="
                            rowMap.get(String(it.id))?.statusText === 'Hoàn thành'
                              ? 'success'
                              : rowMap.get(String(it.id))?.statusText === 'Đang thực hiện'
                                ? 'warning'
                                : 'default'
                          "
                        >
                          {{ rowMap.get(String(it.id))?.statusText }}
                        </n-tag>
                      </div>
                    </div>
                    <div class="cell cell-actions flex items-center justify-center">
                      <n-tooltip trigger="hover">
                        <template #trigger>
                          <n-button
                            text
                            :disabled="
                              !canCreateReport ||
                              isOrderFinalized ||
                              !!(ws2.sessionId && isPicked(it.id))
                            "
                            @click="openReportModal(it)"
                            :type="it.active_report_id ? 'warning' : 'default'"
                          >
                            <template #icon
                              ><n-icon :component="InformationCircleOutline"
                            /></template>
                          </n-button>
                        </template>
                        {{
                          !canCreateReport
                            ? 'Bạn không có quyền tạo báo cáo'
                            : it.active_report_id
                              ? 'Hạng mục đang có báo cáo'
                              : ws2.sessionId && isPicked(it.id)
                                ? 'Không thể báo cáo hạng mục đang trong phiên làm việc'
                                : 'Báo cáo sai lệch'
                        }}
                      </n-tooltip>
                    </div>
                    <div class="cell cell-num">
                      <n-input-number
                        v-model:value="rowMap.get(String(it.id))!.start_value"
                        :show-button="false"
                        :disabled="
                          !rowMap.get(String(it.id))?.isStartValueEditable || isOrderFinalized
                        "
                        :class="{
                          'highlight-required':
                            rowMap.get(String(it.id))?.isStartValueEditable &&
                            !isOrderFinalized &&
                            isPicked(it.id),
                        }"
                      />
                    </div>
                    <div class="cell cell-exp">
                      <n-input-number
                        v-if="it.kind_code === 'LEVELING'"
                        v-model:value="rowMap.get(String(it.id))!.start_exp"
                        :show-button="false"
                        :disabled="!rowMap.get(String(it.id))?.isExpEditable || isOrderFinalized"
                        placeholder="EXP BĐ"
                        :min="0"
                        :max="100"
                        :class="{
                          'highlight-required':
                            rowMap.get(String(it.id))?.isExpEditable &&
                            !isOrderFinalized &&
                            isPicked(it.id),
                        }"
                      >
                        <template #suffix>%</template>
                      </n-input-number>
                    </div>
                    <n-input-number
                      v-model:value="rowMap.get(String(it.id))!.current_value"
                      :show-button="false"
                      :disabled="!ws2.sessionId || isOrderFinalized"
                      :class="{
                        'highlight-required':
                          !!ws2.sessionId && !isOrderFinalized && isPicked(it.id),
                      }"
                    />
                    <div class="cell cell-exp">
                      <n-input-number
                        v-if="it.kind_code === 'LEVELING'"
                        v-model:value="rowMap.get(String(it.id))!.current_exp"
                        :show-button="false"
                        :disabled="!ws2.sessionId || isOrderFinalized"
                        placeholder="EXP HT"
                        :min="0"
                        :max="100"
                        :class="{
                          'highlight-required':
                            !!ws2.sessionId && !isOrderFinalized && isPicked(it.id),
                        }"
                      >
                        <template #suffix>%</template>
                      </n-input-number>
                    </div>
                    <div
                      class="cell cell-proof"
                      :class="{
                        'highlight-required':
                          !ws2.sessionId && !isOrderFinalized && isPicked(it.id),
                      }"
                    >
                      <div
                        v-if="
                          rowMap.get(String(it.id))?.startPreviewUrl ||
                          rowMap.get(String(it.id))?.startProofUrl
                        "
                        class="proof-box-with-image"
                      >
                        <n-image
                          width="96"
                          height="64"
                          class="rounded object-cover"
                          :src="
                            (rowMap.get(String(it.id))?.startPreviewUrl ||
                              rowMap.get(String(it.id))?.startProofUrl) ??
                            undefined
                          "
                        />
                        <div class="image-actions">
                          <n-upload
                            :default-upload="false"
                            :max="1"
                            list-type="image"
                            :show-file-list="false"
                            :disabled="!!ws2.sessionId || isOrderFinalized"
                            @change="
                              (f) => {
                                const r = rowMap.get(String(it.id))
                                if (r) onPickStartFile(r, f)
                              }
                            "
                          >
                            <n-button circle size="tiny" title="Thay đổi ảnh"
                              ><template #icon><n-icon :component="EditIcon" /></template
                            ></n-button>
                          </n-upload>
                          <n-button
                            circle
                            size="tiny"
                            title="Xóa ảnh"
                            @click="
                              () => {
                                const r = rowMap.get(String(it.id))
                                if (r) removeProof(r, 'start')
                              }
                            "
                            :disabled="!!ws2.sessionId || isOrderFinalized"
                            ><template #icon><n-icon :component="TrashIcon" /></template
                          ></n-button>
                        </div>
                      </div>
                      <div v-else class="proof-box-empty">
                        <n-upload
                          :default-upload="false"
                          :max="1"
                          list-type="image"
                          :show-file-list="false"
                          :disabled="!!ws2.sessionId || isOrderFinalized"
                          @change="
                            (f) => {
                              const r = rowMap.get(String(it.id))
                              if (r) onPickStartFile(r, f)
                            }
                          "
                          @paste="
                            (e: ClipboardEvent) => {
                              if (ws2.sessionId) return
                              const r = rowMap.get(String(it.id))
                              if (r) handlePaste(e, r, 'start')
                            }
                          "
                        >
                          <n-button
                            :disabled="!!ws2.sessionId || isOrderFinalized"
                            size="small"
                            style="padding: 0 10px"
                          >
                            Tải lên/ Dán
                          </n-button>
                        </n-upload>
                      </div>
                    </div>
                    <div
                      v-if="ws2.sessionId && isPicked(it.id)"
                      class="cell cell-proof"
                      :class="{ 'highlight-required': !isOrderFinalized }"
                    >
                      <div
                        v-if="
                          rowMap.get(String(it.id))?.endPreviewUrl ||
                          rowMap.get(String(it.id))?.endProofUrl
                        "
                        class="proof-box-with-image"
                      >
                        <n-image
                          width="96"
                          height="64"
                          class="rounded object-cover"
                          :src="
                            (rowMap.get(String(it.id))?.endPreviewUrl ||
                              rowMap.get(String(it.id))?.endProofUrl) ??
                            undefined
                          "
                        />
                        <div class="image-actions">
                          <n-upload
                            :default-upload="false"
                            :max="1"
                            list-type="image"
                            :show-file-list="false"
                            @change="
                              (f) => {
                                const r = rowMap.get(String(it.id))
                                if (r) onPickEndFile(r, f)
                              }
                            "
                          >
                            <n-button
                              circle
                              size="tiny"
                              title="Thay đổi ảnh"
                              :disabled="isOrderFinalized"
                              ><template #icon><n-icon :component="EditIcon" /></template
                            ></n-button>
                          </n-upload>
                          <n-button
                            circle
                            size="tiny"
                            title="Xóa ảnh"
                            @click="
                              () => {
                                const r = rowMap.get(String(it.id))
                                if (r) removeProof(r, 'end')
                              }
                            "
                            ><template #icon
                              ><n-icon
                                :component="TrashIcon"
                                :disabled="isOrderFinalized" /></template
                          ></n-button>
                        </div>
                      </div>
                      <div v-else class="proof-box-empty">
                        <n-upload
                          :default-upload="false"
                          :max="1"
                          list-type="image"
                          :show-file-list="false"
                          @change="
                            (f) => {
                              const r = rowMap.get(String(it.id))
                              if (r) onPickEndFile(r, f)
                            }
                          "
                          @paste="
                            (e: ClipboardEvent) => {
                              const r = rowMap.get(String(it.id))
                              if (r) handlePaste(e, r, 'end')
                            }
                          "
                        >
                          <n-button :disabled="isOrderFinalized">Tải lên / Dán</n-button>
                        </n-upload>
                      </div>
                    </div>
                    <div v-else class="cell cell-proof"></div>
                  </template>
                </div>
              </div>

              <div
                v-if="grp.key === 'MYTHIC' && showActivity && ws2.sessionId"
                class="mt-3 p-3 border rounded-lg highlight-required"
              >
                <div class="text-xs text-neutral-500 mb-1" :disabled="isOrderFinalized">
                  Hoạt động (Ghi nhận số boss đã đánh)
                </div>
                <div class="grid gap-2">
                  <div
                    v-for="(ar, i) in ws2.activityRows"
                    :key="'act-' + i"
                    class="flex items-center gap-2"
                  >
                    <n-select
                      v-model:value="ar.label"
                      filterable
                      placeholder="Chọn boss"
                      :options="activityOptions"
                      class="flex-grow"
                    />
                    <n-input-number
                      v-model:value="ar.qty"
                      :min="1"
                      :show-button="false"
                      placeholder="Số lượng"
                      style="width: 120px"
                    />
                    <n-button
                      size="tiny"
                      tertiary
                      @click="rmActRow(i)"
                      :disabled="ws2.activityRows.length === 1"
                      >Xoá</n-button
                    >
                  </div>
                  <n-button size="tiny" tertiary @click="addActRow" :disabled="isOrderFinalized"
                    >Thêm hoạt động</n-button
                  >
                </div>
              </div>
            </div>

            <div v-if="!svcGroups.length && !detailLoading" class="text-sm text-neutral-500">
              Chưa có svc_items.
            </div>
            <div class="flex items-center gap-2 mt-2">
              <n-button
                size="small"
                type="primary"
                :disabled="!computedCanStart"
                :loading="sessionLoading"
                @click="startSession"
                >Bắt đầu</n-button
              >
              <n-button
                size="small"
                tertiary
                :disabled="!ws2.sessionId || !canManageActiveSession"
                :loading="submittingFinish"
                @click="cancelSession"
                >Huỷ phiên</n-button
              >
              <n-button
                size="small"
                type="success"
                :disabled="!computedCanFinish"
                :loading="submittingFinish"
                @click="finishSession"
                >Kết thúc</n-button
              >
            </div>
          </div>

          <n-divider class="!my-4" />

          <div v-if="overrunDetected && !detailLoading" class="mb-2 space-y-3">
            <div class="p-3 border border-orange-300 bg-orange-50 rounded-lg space-y-3">
              <div class="font-medium text-sm text-orange-800">Phát hiện vượt chỉ tiêu!</div>

              <n-radio-group v-model:value="ws2.overrun_type" name="overrun_type_rg">
                <n-space>
                  <n-radio value="OBJECTIVE">Lý do khách quan</n-radio>
                  <n-radio value="KPI_FAIL">Không đạt chỉ tiêu</n-radio>
                </n-space>
              </n-radio-group>

              <div>
                <div class="text-xs text-neutral-600 mb-1">
                  Bằng chứng
                  <span v-if="ws2.overrun_type === 'OBJECTIVE'" class="text-red-600"
                    >* (bắt buộc)</span
                  >
                </div>
                <n-upload
                  v-model:file-list="ws2.overrun_proofs"
                  :max="3"
                  multiple
                  list-type="image-card"
                />
              </div>

              <n-input
                v-model:value="ws2.overrun_reason"
                type="textarea"
                :autosize="{ minRows: 2, maxRows: 4 }"
                placeholder="Vui lòng nhập lý do chi tiết (bắt buộc)"
                :disabled="isOrderFinalized"
              />
            </div>
          </div>

          <div class="mb-2" v-if="!detailLoading">
            <n-input
              v-model:value="ws2.note"
              type="textarea"
              :autosize="{ minRows: 2, maxRows: 4 }"
              placeholder="Ghi chú thêm (sẽ được lưu khi Hoàn thành hoặc Hủy bỏ)"
              :disabled="isOrderFinalized"
            />
          </div>
        </n-spin>

        <div
          class="mt-4"
          v-if="!isOrderFinalized || detail.action_proof_urls?.length || hasNewProofs"
        >
          <div class="font-medium mb-2">Bằng chứng (Hoàn thành / Hủy bỏ)</div>
          <n-upload
            v-model:file-list="proofFiles"
            :max="5"
            multiple
            list-type="image-card"
            :disabled="isOrderFinalized && !canEditOrderDetails"
            :on-remove="handleProofRemove"
          />
          <n-button
            v-if="hasNewProofs"
            size="small"
            type="primary"
            class="mt-2"
            :loading="savingNewProofs"
            @click="saveAdditionalProofs"
          >
            Lưu bằng chứng bổ sung
          </n-button>
        </div>

        <div class="flex justify-end gap-2 mt-4">
          <n-button size="small" tertiary @click="detailOpen = false">Đóng</n-button>
          <n-button
            size="small"
            type="error"
            :loading="cancellingOrder"
            :disabled="!canCancelOrder || isOrderFinalized"
            @click="handleCancelOrder"
            >Hủy bỏ đơn hàng</n-button
          >
          <n-button
            size="small"
            type="primary"
            :disabled="!computedCanComplete || isOrderFinalized"
            :loading="closingOrder"
            @click="handleCompleteOrder"
            >Hoàn thành đơn hàng</n-button
          >
        </div>
      </n-drawer-content>
    </n-drawer>

    <n-modal v-model:show="reportModal.open" preset="dialog" title="Báo cáo sai lệch">
      <div class="space-y-3">
        <div class="text-sm">
          Báo cáo cho hạng mục: <strong>{{ reportModal.itemLabel }}</strong>
        </div>
        <n-input
          v-model:value="reportModal.description"
          type="textarea"
          :autosize="{ minRows: 3, maxRows: 6 }"
          placeholder="Mô tả chi tiết vấn đề bạn gặp phải..."
        />
        <div>
          <div class="text-xs text-neutral-500 mb-1">Bằng chứng (nếu có)</div>
          <n-upload
            v-model:file-list="reportModal.proofs"
            :max="3"
            multiple
            list-type="image-card"
          />
        </div>
        <div class="flex justify-end gap-2">
          <n-button
            tertiary
            size="small"
            @click="reportModal.open = false"
            :disabled="reportModal.loading"
            >Huỷ</n-button
          >
          <n-button type="primary" size="small" :loading="reportModal.loading" @click="submitReport"
            >Gửi báo cáo</n-button
          >
        </div>
      </div>
    </n-modal>

    <n-modal
      v-model:show="review.open"
      preset="card"
      title="Đánh giá đơn hàng"
      style="width: 700px"
    >
      <n-spin :show="review.loadingExisting">
        <div
          v-if="review.existingReviews.length > 0"
          class="space-y-4 max-h-[40vh] overflow-y-auto pr-2 mb-4 border-b pb-4"
        >
          <div
            v-for="rev in review.existingReviews"
            :key="rev.id"
            class="p-3 border rounded-lg bg-neutral-50"
          >
            <div class="flex items-center justify-between mb-2">
              <n-rate readonly :value="rev.rating" allow-half />
              <div class="text-xs text-neutral-500">
                <span>{{ rev.reviewer_name }}</span> -
                <span>{{ new Date(rev.created_at).toLocaleString() }}</span>
              </div>
            </div>
            <p v-if="rev.comment" class="text-sm text-neutral-700 mb-2 whitespace-pre-wrap">
              {{ rev.comment }}
            </p>
            <div v-if="rev.proof_urls?.length">
              <n-image-group>
                <div class="flex flex-wrap gap-2">
                  <n-image
                    v-for="url in rev.proof_urls"
                    :key="url"
                    width="80"
                    :src="url"
                    class="rounded"
                  />
                </div>
              </n-image-group>
            </div>
          </div>
        </div>
      </n-spin>

      <div v-if="auth.hasPermission('orders:add_review')" class="space-y-3">
        <div class="font-medium">Thêm đánh giá mới</div>
        <n-rate v-model:value="review.stars" allow-half />
        <n-input
          v-model:value="review.comment"
          type="textarea"
          :autosize="{ minRows: 3, maxRows: 6 }"
          placeholder="Nhận xét (tuỳ chọn)"
        />
        <div>
          <div class="text-xs text-neutral-500 mb-1">Bằng chứng (tuỳ chọn)</div>
          <n-upload v-model:file-list="review.proofs" :max="3" multiple list-type="image-card" />
        </div>
        <div class="flex justify-end">
          <n-button type="primary" size="small" :loading="review.saving" @click="submitReview"
            >Gửi đánh giá</n-button
          >
        </div>
      </div>
    </n-modal>

    <n-modal
      v-model:show="historyModal.open"
      preset="card"
      title="Lịch sử Phiên làm việc"
      style="width: 900px"
    >
      <n-spin :show="historyModal.loading">
        <div v-if="!historyModal.sessions?.length" class="text-center text-neutral-500 py-4">
          Chưa có phiên làm việc nào đã hoàn thành.
        </div>
        <n-collapse v-else class="max-h-[70vh] overflow-y-auto pr-2">
          <n-collapse-item v-for="session in historyModal.sessions" :key="session.session_id">
            <template #header>
              <div class="flex items-center justify-between w-full pr-4">
                <div class="flex items-center gap-2">
                  <n-tooltip v-if="session.has_zero_progress_item" trigger="hover">
                    <template #trigger>
                      <n-icon :component="WarningIcon" color="#f0a020" />
                    </template>
                    Phiên làm việc không ghi nhận tiến độ cho một số hạng mục.
                  </n-tooltip>
                  <div class="font-semibold text-sm">{{ session.farmer_name }}</div>
                </div>
                <div class="text-xs text-neutral-500">
                  {{ formatDateTime(session.started_at) }} - {{ formatDateTime(session.ended_at) }}
                </div>
              </div>
            </template>

            <div class="space-y-4">
              <div v-for="group in groupSessionOutputs(session.outputs)" :key="group.kind">
                <div class="font-semibold text-sm mb-2">{{ group.kind }}</div>
                <div class="space-y-3 pl-4">
                  <div
                    v-for="output in group.items"
                    :key="output.id"
                    class="p-3 border rounded-lg bg-neutral-50/50"
                  >
                    <div class="font-medium text-sm mb-2" v-html="paramsLabel(output)"></div>
                    <div class="grid grid-cols-2 gap-4 items-start">
                      <div>
                        <div class="text-xs text-neutral-500">Bắt đầu</div>
                        <div class="flex items-center gap-2">
                          <span>Chỉ số: {{ output.session_start_value }}</span>
                          <n-button
                            v-if="output.start_proof_url"
                            text
                            tag="a"
                            :href="output.start_proof_url"
                            target="_blank"
                            type="primary"
                          >
                            <template #icon
                              ><n-icon :component="InformationCircleOutline"
                            /></template>
                            Xem ảnh
                          </n-button>
                        </div>
                      </div>
                      <div>
                        <div class="text-xs text-neutral-500">Kết thúc</div>
                        <div class="flex items-center gap-2">
                          <span
                            >Chỉ số: {{ output.session_end_value }} (+{{
                              output.session_delta
                            }})</span
                          >
                          <n-button
                            v-if="output.end_proof_url"
                            text
                            tag="a"
                            :href="output.end_proof_url"
                            target="_blank"
                            type="primary"
                          >
                            <template #icon
                              ><n-icon :component="InformationCircleOutline"
                            /></template>
                            Xem ảnh
                          </n-button>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div
                    v-if="group.activities?.length"
                    class="p-3 border rounded-lg bg-blue-50/50 border-blue-200"
                  >
                    <div class="font-medium text-sm mb-2">Hoạt động farm boss:</div>
                    <div class="space-y-1 pl-4">
                      <div
                        v-for="(activity, index) in group.activities"
                        :key="index"
                        class="text-sm flex items-center gap-2"
                      >
                        <n-icon :component="BookOutline" />
                        <span
                          >{{ getAttributeName(activity.activity_label) }}:
                          <strong>{{ activity.session_delta }}</strong> runs</span
                        >
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </n-collapse-item>
        </n-collapse>
      </n-spin>
    </n-modal>

    <n-modal
      v-model:show="deliveryModal.open"
      preset="card"
      :title="`Bằng chứng trả đơn cho: ${deliveryModal.customerName}`"
      style="width: 600px"
    >
      <div v-if="!deliveryModal.proofs.length" class="text-neutral-500">
        Đơn hàng này không có bằng chứng hoàn thành.
      </div>
      <n-image-group v-else>
        <div class="flex flex-wrap gap-3">
          <n-image
            v-for="url in deliveryModal.proofs"
            :key="url"
            width="150"
            :src="url"
            class="rounded"
          />
        </div>
      </n-image-group>
      <n-divider />
      <n-checkbox
        v-model:checked="deliveryModal.isDelivered"
        @update:checked="handleDeliveryStatusChange"
        :disabled="deliveryModal.loading"
      >
        Đã trả đơn hàng cho khách
      </n-checkbox>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { h, ref, reactive, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import {
  NCard,
  NButton,
  NDataTable,
  NSwitch,
  NTag,
  NTooltip,
  NDrawer,
  NDrawerContent,
  NDivider,
  NInput,
  NUpload,
  NInputNumber,
  NCheckbox,
  NImage,
  NSpin,
  createDiscreteApi,
  useDialog,
  NRadioGroup,
  NRadioButton,
  NDatePicker,
  NRate,
  NModal,
  NSelect,
  NIcon,
  NImageGroup,
  NCollapse,
  NCollapseItem,
  NRadio,
  NSpace,
  type UploadFileInfo,
  type SelectOption,
  type DataTableColumns,
} from 'naive-ui'
import {
  ChevronDown,
  ChevronUp,
  Pencil as EditIcon,
  TrashOutline as TrashIcon,
  InformationCircleOutline,
  EyeOutline,
  AlertCircleOutline as WarningIcon,
  BookOutline,
  PaperPlaneOutline as DeliveryIcon,
} from '@vicons/ionicons5'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'
import {
  fetchLastProofs,
  startWorkSession,
  finishWorkSessionIdem,
  type SessionOutputRow,
  type ActivityRow,
} from '@/lib/progress'
import { formatDistanceToNowStrict, differenceInMilliseconds } from 'date-fns'
import { vi } from 'date-fns/locale'

// =================================================================
// TYPES
// =================================================================
// THAY ĐỔI 1: Định nghĩa type cho một service item trả về từ RPC mới
type SvcItemSummary = {
  id: string
  kind_code: string
  kind_name: string
  params: any
  plan_qty: number | null
  done_qty: number
  active_report_id: string | null
}
type OrderRow = {
  id: string
  line_id: string
  order_id: string
  created_at: string
  updated_at: string | null
  status: string
  channel_code: string
  customer_name: string
  deadline: string | null
  btag: string | null
  login_id: string | null
  login_pwd: string | null
  service_type: 'Selfplay' | 'Pilot'
  package_type: 'BASIC' | 'CUSTOM' | 'BUILD'
  package_note: string | null
  assignees_text: string
  service_items: SvcItemSummary[] | null
  review_id: string | null
  machine_info: string | null
  paused_at: string | null
  delivered_at: string | null
  action_proof_urls: string[] | null
}

type OrderDetail = OrderRow & {
  action_proof_urls: string[] | null
  active_session: {
    session_id: string
    farmer_id: string
    farmer_name: string
    start_state: {
      item_id: string
      start_value: number
      start_proof_url: string | null
      start_exp?: number | null
    }[]
  } | null
}

type SvcItem = {
  id: string
  kind_code: string
  params: any
  plan_qty: number | null
  done_qty: number
  active_report_id: string | null
}
type LastProof = {
  item_id: string
  last_start_proof_url: string | null
  last_end_proof_url: string | null
  last_end: number | null
  last_delta: number | null
  last_exp_percent: number | null
}
type WsRow = {
  item_id: string
  kind_code: string
  label: string
  start_value: number
  current_value: number
  start_exp: number | null
  current_exp: number | null
  isStartValueEditable: boolean
  isExpEditable: boolean
  startFile: File | null
  endFile: File | null
  startPreviewUrl: string | null
  endPreviewUrl: string | null
  startProofUrl: string | null
  endProofUrl: string | null
  statusText: string
}

type PkgType = 'BASIC' | 'CUSTOM' | 'BUILD'

type ProofUploadFileInfo = UploadFileInfo & { isSaved?: boolean }
// =================================================================
// INITIALIZATION & STATE
// =================================================================
const { message } = createDiscreteApi(['message'])
const dialog = useDialog()
const auth = useAuth()
const machineInfoModel = ref('')

const rows = ref<OrderRow[]>([])
const loading = ref(false)
const autoRefresh = ref(true)
const pagination = reactive({
  page: 1,
  pageSize: 100,
  pageSizes: [20, 50, 100, 200],
  showSizePicker: true,
  onUpdatePage: (page: number) => {
    pagination.page = page
  },
  onUpdatePageSize: (pageSize: number) => {
    pagination.pageSize = pageSize
    pagination.page = 1 // Quay về trang 1 khi đổi kích thước
  },
})
const isDescCollapsed = ref(true)
let clock: number | null = null
let poll: number | null = null

const filters = reactive({
  channels: null as string[] | null,
  serviceTypes: null as string[] | null,
  packageTypes: null as string[] | null,
  customerName: '',
  statuses: null as string[] | null,
  assignee: '',
  deliveryStatus: null as string | null,
  reviewStatus: null as string | null,
})

const detailOpen = ref(false)
const detailLoading = ref(false)
const detail = reactive<Partial<OrderDetail>>({})
const editing = ref(false)
const savingInfo = ref(false)
const isEditingMachineInfo = ref(false)
const deadlineModel = ref<number | null>(null)
const svcItems = ref<SvcItem[]>([])
const lastProofMap = ref<Record<string, LastProof>>({})
const attributeMap = ref<Map<string, string>>(new Map())
const bossDict = ref<SelectOption[]>([])
const collapsedKinds = reactive(new Set<string>())

const sessionLoading = ref(false)
const ws2 = ref({
  activityRows: [{ label: null as string | null, qty: null as number | null }],
  note: '',
  overrun_reason: null as string | null,
  overrun_type: null as 'OBJECTIVE' | 'KPI_FAIL' | null,
  overrun_proofs: [] as UploadFileInfo[],
  sessionId: null as string | null,
  selectedIds: [] as string[],
  rows: [] as WsRow[],
})
const submittingFinish = ref(false)
const closingOrder = ref(false)
const cancellingOrder = ref(false)
const proofFiles = ref<ProofUploadFileInfo[]>([])

const reportModal = ref({
  open: false,
  loading: false,
  itemId: null as string | null,
  itemLabel: '',
  description: '',
  proofs: [] as UploadFileInfo[],
})

const review = ref({
  open: false,
  lineId: null as string | null,
  stars: 5,
  comment: '',
  saving: false,
  proofs: [] as UploadFileInfo[],
  // THÊM CÁC TRƯỜNG MỚI ĐỂ XEM REVIEW
  loadingExisting: false,
  existingReviews: [] as any[],
})

const deliveryModal = reactive({
  open: false,
  loading: false,
  orderId: null as string | null,
  customerName: '',
  proofs: [] as string[],
  isDelivered: false,
})

// =================================================================
// PERMISSION & LOGIC COMPUTED PROPERTIES
// =================================================================
const D4_SERVICE_CONTEXT = { game_code: 'DIABLO_4', business_area_code: 'SERVICE' }

// Sửa lại toàn bộ các computed kiểm tra quyền để thêm ngữ cảnh
const canEditOrderDetails = computed(() =>
  auth.hasPermission('orders:edit_details', D4_SERVICE_CONTEXT)
)
const canCreateReport = computed(() => auth.hasPermission('reports:create', D4_SERVICE_CONTEXT))
const canCompleteOrder = computed(() => auth.hasPermission('orders:complete', D4_SERVICE_CONTEXT))
const canCancelOrder = computed(() => auth.hasPermission('orders:cancel', D4_SERVICE_CONTEXT))

const canManageActiveSession = computed(() => {
  const session = detail.active_session
  if (!session) return false

  // <<< SỬA LỖI NẰM Ở ĐÂY >>>
  // So sánh farmer_id (profile_id) với profile.id của người dùng đang đăng nhập
  if (session.farmer_id === auth.profile?.id) {
    // Nếu là chủ phiên, kiểm tra quyền kết thúc hoặc hủy
    return (
      auth.hasPermission('work_session:finish', D4_SERVICE_CONTEXT) ||
      auth.hasPermission('work_session:cancel', D4_SERVICE_CONTEXT)
    )
  }

  // Nếu không phải chủ phiên, kiểm tra quyền override
  return auth.hasPermission('work_session:override', D4_SERVICE_CONTEXT)
})

const computedCanStart = computed(() => {
  if (!auth.hasPermission('work_session:start', D4_SERVICE_CONTEXT)) return false
  if (!ws2.value.selectedIds.length || ws2.value.sessionId) return false

  for (const itemId of ws2.value.selectedIds) {
    const row = rowMap.value.get(itemId)
    if (!row || (!row.startProofUrl && !row.startFile)) return false
    if (row.kind_code === 'LEVELING' && row.start_exp === null) return false
  }

  return true
})

const computedCanFinish = computed(() => {
  // Điều kiện 1: Phải có session đang hoạt động và người dùng phải có quyền quản lý
  if (!ws2.value.sessionId || !canManageActiveSession.value) {
    return false
  }

  // Điều kiện 2: Các hạng mục có tiến độ phải có đủ bằng chứng
  for (const itemId of ws2.value.selectedIds) {
    const row = rowMap.value.get(itemId)
    if (!row) continue

    const hasProgress =
      row.kind_code === 'LEVELING'
        ? round2(row.current_value) >= round2(row.start_value)
        : round2(row.current_value) > round2(row.start_value)

    if (hasProgress) {
      if (!row.endFile && !row.endProofUrl) return false
      if (row.kind_code === 'LEVELING' && row.current_exp === null) return false
    }
  }

  // Điều kiện 3: Phiên Mythic phải có hoạt động farm boss đi kèm
  const isMythicSession = ws2.value.rows.some(
    (r) => ws2.value.selectedIds.includes(r.item_id) && mythicKinds.has(r.kind_code)
  )
  if (isMythicSession) {
    const hasActivity = ws2.value.activityRows.some((a) => a.label && (a.qty ?? 0) > 0)
    if (!hasActivity) return false
  }

  // Điều kiện 4: Nếu vượt chỉ tiêu, phải có đủ lý do và bằng chứng
  if (overrunDetected.value) {
    if (!ws2.value.overrun_type || !ws2.value.overrun_reason?.trim()) {
      return false
    }
    if (ws2.value.overrun_type === 'OBJECTIVE' && ws2.value.overrun_proofs.length === 0) {
      return false
    }
  }

  // Nếu tất cả điều kiện đều đạt
  return true
})

const computedCanComplete = computed(() => {
  if (!canCompleteOrder.value) return false
  if (!svcItems.value.length) return false
  return svcItems.value.every((s) => {
    const plan = Number(s.plan_qty ?? 0)
    const done = Number(s.done_qty ?? 0)
    return plan > 0 ? done >= plan : true
  })
})

const drawerDeadlineDisplay = computed(() => {
  if (!detail.id) {
    return { text: '—', color: 'default' as const }
  }
  // Gọi hàm với đầy đủ 7 tham số
  return formatDeadline(
    detail.created_at,
    detail.deadline,
    detail.updated_at,
    now.value,
    detail.status,
    detail.paused_at,
    detail.service_type
  )
})

const rowMap = computed(() => new Map(ws2.value.rows.map((r) => [String(r.item_id), r])))
const activityOptions = computed(() => bossDict.value)
const svcGroups = computed(() => groupAndSort(svcItems.value))
const mythicKinds = new Set(['MYTHIC', 'MYTHIC_ITEM', 'MYTHIC_GA'])
const showActivity = computed(() =>
  ws2.value.rows.some(
    (r) =>
      ws2.value.selectedIds.includes(r.item_id) &&
      mythicKinds.has(String(r.kind_code || '').toUpperCase())
  )
)
const overrunDetected = computed(() =>
  ws2.value.rows.some((r) => {
    if (!ws2.value.selectedIds.includes(r.item_id)) return false
    const item = svcItems.value.find((s) => String(s.id) === String(r.item_id))
    if (!item) return false
    const kind = String(item.kind_code || '').toUpperCase()
    if (kind === 'LEVELING') {
      const plan_end_level = Number(item.params?.end ?? 0)
      return plan_end_level > 0 && round2(r.current_value) > round2(plan_end_level)
    } else {
      const plan_qty = Number(item.plan_qty ?? 0)
      return plan_qty > 0 && round2(r.current_value) > round2(plan_qty)
    }
  })
)
const isOrderFinalized = computed(() => {
  return detail.status === 'completed' || detail.status === 'cancelled'
})

//Lọc dịch vụ
const statusOptions = computed(() => {
  const allStatuses = [...new Set(rows.value.map((r) => r.status))]
  return allStatuses.map((s) => ({
    label: statusView(s).label,
    value: s,
  }))
})

const channelOptions = computed(() => {
  const allChannels = [...new Set(rows.value.map((r) => r.channel_code).filter(Boolean))]
  return allChannels.map((c) => ({
    label: c,
    value: c,
  }))
})

const packageTypeOptions = computed(() => {
  const allTypes = [...new Set(rows.value.map((r) => r.package_type))]
  return allTypes.map((t) => ({
    label: pkgTypeTag(t).label,
    value: t,
  }))
})

const serviceTypeOptions = computed(() => {
  const allTypes = [...new Set(rows.value.map((r) => r.service_type).filter(Boolean))]
  return allTypes.map((t) => ({
    label: t,
    value: t,
  }))
})

const deliveryStatusOptions = [
  { label: 'Đã trả đơn', value: 'delivered' },
  { label: 'Chưa trả đơn', value: 'not_delivered' },
]

const reviewStatusOptions = [
  { label: 'Đã review', value: 'reviewed' },
  { label: 'Chưa review', value: 'not_reviewed' },
]

const filteredRows = computed(() => {
  let data = rows.value

  // Lọc theo trạng thái đơn hàng (giữ nguyên)
  if (filters.statuses?.length) {
    const statusSet = new Set(filters.statuses)
    data = data.filter((row) => statusSet.has(row.status))
  }

  // Lọc theo kênh bán (giữ nguyên)
  if (filters.channels?.length) {
    const channelSet = new Set(filters.channels)
    data = data.filter((row) => channelSet.has(row.channel_code))
  }

  // Lọc theo tên khách hàng (giữ nguyên)
  const customer = filters.customerName.trim().toLowerCase()
  if (customer) {
    data = data.filter((row) => row.customer_name.toLowerCase().includes(customer))
  }

  // Lọc theo người thực hiện (giữ nguyên)
  const assignee = filters.assignee.trim().toLowerCase()
  if (assignee) {
    data = data.filter((row) => (row.assignees_text || '').toLowerCase().includes(assignee))
  }

  // Lọc theo gói dịch vụ (giữ nguyên)
  if (filters.packageTypes?.length) {
    const packageSet = new Set(filters.packageTypes)
    data = data.filter((row) => packageSet.has(row.package_type))
  }

  // Lọc theo loại dịch vụ (giữ nguyên)
  if (filters.serviceTypes?.length) {
    const serviceSet = new Set(filters.serviceTypes)
    data = data.filter((row) => serviceSet.has(row.service_type))
  }

  // <<< THÊM MỚI: Lọc theo trạng thái giao hàng >>>
  if (filters.deliveryStatus) {
    if (filters.deliveryStatus === 'delivered') {
      data = data.filter((row) => !!row.delivered_at)
    } else if (filters.deliveryStatus === 'not_delivered') {
      data = data.filter((row) => !row.delivered_at)
    }
  }

  // <<< THÊM MỚI: Lọc theo trạng thái review >>>
  if (filters.reviewStatus) {
    if (filters.reviewStatus === 'reviewed') {
      data = data.filter((row) => !!row.review_id)
    } else if (filters.reviewStatus === 'not_reviewed') {
      data = data.filter((row) => !row.review_id)
    }
  }

  return data
})

// =================================================================
// CONSTANTS & HELPERS
// =================================================================
const KIND_UNITS: Record<string, string> = {
  LEVELING: 'levels',
  BOSS: 'runs',
  THE_PIT: 'runs',
  NIGHTMARE: 'runs',
  MATERIALS: 'mats',
  MYTHIC: 'items',
  MASTERWORKING: 'items',
  ALTARS_OF_LILITH: 'altars',
  RENOWN: 'regions',
  GENERIC: '',
}
const KIND_ORDER: Record<string, number> = {
  LEVELING: 10,
  BOSS: 20,
  THE_PIT: 30,
  NIGHTMARE: 40,
  MYTHIC: 50,
  MATERIALS: 60,
  MASTERWORKING: 70,
  ALTARS_OF_LILITH: 80,
  RENOWN: 90,
  GENERIC: 999,
}
const PROOF_BUCKET = 'work-proofs'
function clip(s: string, n = 220) {
  if (!s) return ''
  return s.length > n ? s.slice(0, n - 1) + '…' : s
}
function round2(n: any): number {
  const x = Number(n)
  return Number.isFinite(x) ? Math.round(x * 100) / 100 : 0
}

function generateServiceDescription(items: SvcItemSummary[] | null): {
  summaryHtml: string
  detailHtml: string
} {
  if (!items || items.length === 0) {
    return { summaryHtml: 'N/A', detailHtml: '—' }
  }

  // Helper function để kiểm tra một item đã hoàn thành chưa
  const isItemCompleted = (item: SvcItemSummary) => {
    const plan = Number(item.plan_qty ?? 0)
    // Coi như hoàn thành nếu không có plan_qty (plan = 0)
    if (plan <= 0) return true
    return Number(item.done_qty ?? 0) >= plan
  }

  const kindCodesInOrder = [...new Set(items.map((it) => it.kind_code))].sort(
    (a, b) => (KIND_ORDER[a] ?? 999) - (KIND_ORDER[b] ?? 999)
  )

  // --- Logic tạo chuỗi tóm tắt (summary) - Giữ nguyên không đổi ---
  const summaryParts = kindCodesInOrder.map((code) => {
    const kindName = attributeMap.value.get(code) || code
    const itemsInKind = items.filter((it) => it.kind_code === code)
    const isGroupCompleted = itemsInKind.length > 0 && itemsInKind.every(isItemCompleted)
    return isGroupCompleted ? `<del>${kindName}</del>` : kindName
  })
  const summaryHtml = summaryParts.join(', ')

  // --- Logic tạo chuỗi chi tiết (detailed html) - Cập nhật ở đây ---
  let detailHtml = '<ul class="list-none p-0 m-0 space-y-1">'
  for (const code of kindCodesInOrder) {
    const kindName = attributeMap.value.get(code) || code
    const itemsInKind = items.filter((it) => it.kind_code === code)
    const isGroupCompleted = itemsInKind.length > 0 && itemsInKind.every(isItemCompleted)

    // Vẫn gạch ngang tên kind nếu cả nhóm đã xong
    if (isGroupCompleted) {
      detailHtml += `<li><del><strong>- ${kindName}:</strong></del>`
    } else {
      detailHtml += `<li><strong>- ${kindName}:</strong>`
    }

    if (itemsInKind.length > 0) {
      detailHtml += '<ul class="list-none p-0 m-0 pl-4">'
      for (const item of itemsInKind) {
        // <<< THAY ĐỔI NẰM Ở ĐÂY >>>
        // 1. Lấy nhãn của item
        const itemLabel = paramsLabel(item)
        // 2. Kiểm tra xem item này đã hoàn thành chưa
        const isComplete = isItemCompleted(item)
        // 3. Thêm thẻ <del> nếu đã hoàn thành
        detailHtml += `<li>+ ${isComplete ? `<del>${itemLabel}</del>` : itemLabel}</li>`
      }
      detailHtml += '</ul>'
    }
    detailHtml += '</li>'
  }
  detailHtml += '</ul>'

  return { summaryHtml, detailHtml }
}

const historyModal = reactive({
  open: false,
  loading: false,
  sessions: [] as any[],
  lineId: null as string | null,
})

// Helper để tạo đồng hồ đếm ngược real-time
const now = ref(Date.now())
onMounted(() => {
  const timer = setInterval(() => {
    now.value = Date.now()
  }, 1000) // Cập nhật mỗi giây
  onBeforeUnmount(() => {
    clearInterval(timer)
  })
})

// Helper để chuyển đổi chuỗi ngày tháng sang timestamp (miliseconds)
const toTs = (v: string | null | undefined): number | null => {
  if (!v) return null
  const d = new Date(v)
  return isNaN(d.getTime()) ? null : d.getTime()
}

function formatDateTime(dateString: string | null | undefined): string {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleString('vi-VN')
}

// =================================================================
// DATA TABLE & RENDERERS
// =================================================================
function renderTrunc(text: any, len = 30) {
  const full = (text ?? '').toString()
  const short = clip(full, len)
  if (!full) return '—'
  if (short === full) return full
  return h(
    NTooltip,
    { trigger: 'hover' },
    {
      trigger: () => h('span', { class: 'cell-text' }, short),
      default: () => full,
    }
  )
}

function pkgTypeTag(v: any) {
  const s = (v ?? '').toString().toUpperCase()
  if (s === 'CUSTOM') return { label: 'Custom', type: 'warning' as const }
  if (s === 'BUILD') return { label: 'Build', type: 'info' as const }
  return { label: 'Basic', type: 'success' as const }
}

function statusView(s: any) {
  const v = (s ?? '').toString().toLowerCase()
  switch (v) {
    case 'new':
      return { label: 'Mới', type: 'default' as const }
    case 'in_progress':
      return { label: 'Đang làm', type: 'warning' as const }
    case 'pending_pilot':
      return { label: 'Chờ làm', type: 'info' as const }
    case 'paused_selfplay':
      return { label: 'Tạm dừng', type: 'info' as const }
    case 'pending_completion':
      return { label: 'Chờ hoàn thành', type: 'primary' as const }
    case 'completed':
      return { label: 'Hoàn thành', type: 'success' as const }
    case 'cancelled':
      return { label: 'Đã hủy', type: 'error' as const }
    default:
      return { label: v, type: 'default' as const }
  }
}

function formatDeadline(
  createdAt: string | null | undefined,
  deadline: string | null | undefined,
  updatedAt: string | null | undefined,
  nowMs: number,
  status: string | null | undefined,
  pausedAt: string | null | undefined,
  serviceType: string | null | undefined
) {
  const startTs = toTs(createdAt)
  const endTs = toTs(deadline)
  if (!endTs) return { text: '—', color: 'default' as const }

  const isSelfplay = serviceType === 'Selfplay'
  if (isSelfplay && (status === 'new' || status === 'paused_selfplay')) {
    const referenceTs = status === 'paused_selfplay' && pausedAt ? toTs(pausedAt) : startTs

    if (referenceTs) {
      const remainingMs = endTs - referenceTs

      const d = Math.floor(remainingMs / 86400000)
      const h = Math.floor((remainingMs % 86400000) / 3600000)
      const m = Math.floor((remainingMs % 3600000) / 60000)

      const timeParts = []
      if (d > 0) timeParts.push(`${d}d`)
      if (h > 0) timeParts.push(`${h}h`)
      timeParts.push(`${m}m`)
      const timeString = timeParts.join(' ')

      if (status === 'paused_selfplay') {
        return { text: `Tạm dừng (còn ${timeString})`, color: 'info' as const }
      }
      return { text: `Chờ (còn ${timeString})`, color: 'default' as const }
    }
  }

  // Logic cho các trạng thái còn lại giữ nguyên
  if (status === 'completed') {
    const completionTs = toTs(updatedAt) ?? nowMs
    const diffMs = endTs - completionTs
    const absDiffMs = Math.abs(diffMs)

    const d = Math.floor(absDiffMs / 86400000)
    const h = Math.floor((absDiffMs % 86400000) / 3600000)
    const m = Math.floor((absDiffMs % 3600000) / 60000)

    const timeParts = []
    if (d > 0) timeParts.push(`${d}d`)
    if (h > 0) timeParts.push(`${h}h`)
    if (m > 0 || (d === 0 && h === 0)) {
      timeParts.push(`${m}m`)
    }
    const timeString = timeParts.join(' ')

    if (diffMs < 0) {
      return { text: `Trễ hạn: ${timeString}`, color: 'error' as const }
    } else {
      return { text: `Đúng hạn: ${timeString}`, color: 'success' as const }
    }
  }

  if (status === 'cancelled') {
    return { text: 'Đã hủy', color: 'error' as const }
  }

  const remainingMs = endTs - nowMs
  if (remainingMs < 0) {
    const overdueSeconds = Math.abs(Math.floor(remainingMs / 1000))
    const d = Math.floor(overdueSeconds / 86400)
    const h = Math.floor((overdueSeconds % 86400) / 3600)
    const m = Math.floor((overdueSeconds % 3600) / 60)
    const s = overdueSeconds % 60
    let text = 'Trễ '
    if (d > 0) text += `${d}d ${h}h ${m}m`
    else if (h > 0) text += `${h}h ${m}m ${s}s`
    else if (m > 0) text += `${m}m ${s}s`
    else text += `${s}s`
    return { text, color: 'error' as const }
  }

  const totalDuration = startTs ? endTs - startTs : 0
  if (totalDuration <= 0) return { text: 'Còn lại', color: 'success' as const }

  const ratio = remainingMs / totalDuration
  let color: 'success' | 'primary' | 'warning' | 'error' = 'success'
  if (ratio <= 1 / 3) {
    color = 'warning'
  } else if (ratio <= 2 / 3) {
    color = 'primary'
  }

  const remainingSeconds = Math.floor(remainingMs / 1000)
  const d = Math.floor(remainingSeconds / 86400)
  const h = Math.floor((remainingSeconds % 86400) / 3600)
  const m = Math.floor((remainingSeconds % 3600) / 60)
  const s = remainingSeconds % 60
  let text = 'Còn '
  if (d > 0) text += `${d}d ${h}h ${m}m`
  else if (h > 0) text += `${h}h ${m}m ${s}s`
  else if (m > 0) text += `${m}m ${s}s`
  else text += `${s}s`
  return { text, color }
}

const columns: DataTableColumns<OrderRow> = [
  {
    title: 'Nguồn bán',
    key: 'channel_code',
    width: 115,
    ellipsis: true,
    render: (row: OrderRow) => renderTrunc(row.channel_code, 16),
  },
  {
    title: 'Loại',
    key: 'service_type',
    width: 90,
    align: 'center',
    titleAlign: 'center',
    render: (row: OrderRow) => {
      const typeIsPilot = String(row.service_type || '').toLowerCase() === 'pilot'
      return h(
        NTag,
        { size: 'small', bordered: false, type: typeIsPilot ? 'warning' : 'primary' },
        { default: () => row.service_type || 'N/A' }
      )
    },
  },
  {
    title: 'Tên khách hàng',
    key: 'customer_name',
    width: 150,
    ellipsis: true,
    render: (row: OrderRow) => renderTrunc(row.customer_name, 30),
  },
  {
    title: 'Gói Dịch vụ',
    key: 'package_type',
    width: 110,
    align: 'center',
    render: (row: OrderRow) => {
      const { label, type } = pkgTypeTag(row.package_type)
      return h(NTag, { size: 'small', type, bordered: false }, { default: () => label })
    },
  },
  {
    title: 'Mô tả gói',
    key: 'package_note',
    width: 180,
    render: (row: OrderRow) => {
      if (!row.package_note) return '—'
      const urlRegex = /(https?:\/\/[^\s]+)/g
      if (urlRegex.test(row.package_note)) {
        const noteParts = row.package_note.split(urlRegex)
        const noteContent = noteParts.map((part: string) => {
          if (urlRegex.test(part)) {
            return h(
              'a',
              { href: part, target: '_blank', class: 'text-primary-600 hover:underline' },
              '[link]'
            )
          }
          return h('span', part)
        })
        return h('div', { class: 'text-left' }, noteContent)
      }
      return renderTrunc(row.package_note, 30)
    },
  },
  // THAY ĐỔI NẰM Ở ĐÂY
  {
    title: 'Dịch vụ',
    key: 'service_items',
    minWidth: 250,
    render: (row: OrderRow) => {
      const { summaryHtml, detailHtml } = generateServiceDescription(row.service_items)
      return h(
        NTooltip,
        { trigger: 'hover', placement: 'top-start' },
        {
          trigger: () => h('span', { class: 'cell-text', innerHTML: summaryHtml }),
          default: () => h('div', { class: 'max-w-md', innerHTML: detailHtml }),
        }
      )
    },
  },
  {
    title: 'Trạng thái',
    key: 'status',
    width: 140,
    align: 'center',
    titleAlign: 'center',
    render: (row: OrderRow) => {
      const s = statusView(row.status)
      return h(NTag, { size: 'small', type: s.type, bordered: false }, { default: () => s.label })
    },
  },
  {
    title: 'Người thực hiện',
    key: 'assignees_text',
    width: 150,
    ellipsis: true,
    render: (row: OrderRow) => {
      const assignee = row.assignees_text
      const machine = row.machine_info
      let displayText = ''

      if (assignee && machine) {
        displayText = `${assignee} - ${machine}`
      } else if (assignee) {
        displayText = assignee
      } else if (machine) {
        displayText = `— - ${machine}`
      } else {
        displayText = '—'
      }

      return renderTrunc(displayText, 30)
    },
  },
  {
    title: 'Deadline',
    key: 'deadline',
    width: 140,
    render: (row: OrderRow) => {
      // Gọi hàm với đầy đủ 7 tham số
      const deadlineInfo = formatDeadline(
        row.created_at,
        row.deadline,
        row.updated_at,
        now.value,
        row.status,
        row.paused_at,
        row.service_type
      )
      const tagType = deadlineInfo.color
      return h(
        NTag,
        { size: 'small', bordered: false, type: tagType },
        { default: () => deadlineInfo.text }
      )
    },
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 160,
    align: 'center',
    titleAlign: 'center',
    render: (row: OrderRow) => {
      const actionItems = [
        // Nút chi tiết giữ nguyên
        h(
          NButton,
          {
            size: 'tiny',
            tertiary: true,
            onClick: () => openDetail(row),
          },
          { default: () => 'Chi tiết' }
        ),

        // Nút Lịch sử (biểu tượng quyển sách)
        h(
          NTooltip,
          { trigger: 'hover' },
          {
            trigger: () =>
              h(
                NButton,
                {
                  text: true,
                  class: 'mx-1',
                  onClick: () => openHistoryModal(row),
                },
                {
                  default: () => h(NIcon, { component: BookOutline, color: '#333' }),
                }
              ),
            default: () => 'Lịch sử',
          }
        ),
      ]

      const isFinalized = row.status === 'completed' || row.status === 'cancelled'
      const canViewReviews = auth.hasPermission('orders:view_reviews')
      const canAddReview = auth.hasPermission('orders:add_review')

      // Nút Review (biểu tượng con mắt)
      if (isFinalized && (canAddReview || (row.review_id && canViewReviews))) {
        const reviewColor = row.review_id ? '#208842' : '#333' // Xanh lá nếu đã review, đen nếu chưa
        const tooltipText = row.review_id ? 'Xem/Thêm Review' : 'Thêm Review'

        actionItems.push(
          h(
            NTooltip,
            { trigger: 'hover' },
            {
              trigger: () =>
                h(
                  NButton,
                  {
                    text: true,
                    class: 'mx-1',
                    onClick: () => openReviewModal(row),
                  },
                  {
                    default: () => h(NIcon, { component: EyeOutline, color: reviewColor }),
                  }
                ),
              default: () => tooltipText,
            }
          )
        )
      }

      // Nút TT giao hàng
      if (row.status === 'completed') {
        actionItems.push(
          h(
            NTooltip,
            { trigger: 'hover' },
            {
              trigger: () =>
                h(
                  NButton,
                  {
                    text: true,
                    class: 'mx-1',
                    type: row.delivered_at ? 'primary' : 'default', // Đổi màu nút
                    onClick: () => openDeliveryModal(row),
                  },
                  {
                    default: () => h(NIcon, { component: DeliveryIcon }),
                  }
                ),
              default: () => 'Trạng thái giao hàng',
            }
          )
        )
      }

      return h('div', { class: 'row-actions flex justify-center items-center gap-1' }, actionItems)
    },
  },
]

async function copyToClipboard(text: string) {
  if (!text) return
  try {
    await navigator.clipboard.writeText(text)
    message.success('Đã sao chép!')
  } catch (err) {
    message.error('Không thể sao chép.')
  }
}

// =================================================================
// API & DATA FETCHING
// =================================================================
async function loadOrders() {
  loading.value = true
  try {
    const { data, error } = await supabase.rpc('get_boosting_orders_v2')
    if (error) throw error

    // SỬA ĐỔI NẰM Ở ĐÂY
    rows.value = ((data as any[]) ?? []).map((r: any) => {
      // Thêm khối logic chuẩn hóa service_type vào đây
      if (r.service_type) {
        const typeStr = String(r.service_type).toLowerCase()
        if (typeStr.includes('pilot')) {
          r.service_type = 'Pilot'
        } else if (typeStr.includes('selfplay')) {
          r.service_type = 'Selfplay'
        }
      }
      // Trả về đối tượng đã được chuẩn hóa
      return { ...r, line_id: r.id }
    })
  } catch (e: any) {
    console.error('[loadOrders]', e)
    message.error(e?.message || 'Không tải được danh sách đơn hàng')
  } finally {
    loading.value = false
  }
}

async function loadLastProofs(ids: string[]) {
  if (!ids?.length) return
  try {
    const rows = await fetchLastProofs(ids)
    const m: Record<string, LastProof> = {}
    for (const r of rows || []) {
      m[String(r.item_id)] = r as LastProof
    }
    lastProofMap.value = { ...lastProofMap.value, ...m }
  } catch (e) {
    console.warn('[loadLastProofs]', e)
  }
}

async function uploadProof(
  file: File,
  lineId: string,
  sessionId: string,
  itemId: string,
  phase: 'start' | 'end'
): Promise<string | null> {
  const ext = file.name.split('.').pop()?.toLowerCase() || 'bin'
  const path = `${lineId}/${sessionId}/${itemId}/${phase}.${ext}`

  console.log('Đang upload tới đường dẫn:', path)
  const { error, data } = await supabase.storage
    .from('work-proofs')
    .upload(path, file, { upsert: true })

  if (error) {
    throw new Error(`Lỗi upload bằng chứng cho ${itemId}: ${error.message}`)
  }

  const { data: pub } = supabase.storage.from('work-proofs').getPublicUrl(data.path)
  return pub?.publicUrl || null
}

async function uploadActionProof(
  file: File,
  lineId: string,
  action: 'completion' | 'cancellation'
): Promise<string> {
  if (!file) throw new Error('File không hợp lệ.')
  const fileExt = file.name.split('.').pop()
  const fileName = `${Date.now()}_${Math.random().toString(36).substring(2)}.${fileExt}`
  const filePath = `${lineId}/${action}/${fileName}`
  const { data, error } = await supabase.storage.from('work-proofs').upload(filePath, file)
  if (error) throw new Error(`Lỗi upload bằng chứng: ${error.message}`)
  const { data: publicURL } = supabase.storage.from('work-proofs').getPublicUrl(data.path)
  return publicURL.publicUrl
}

function handlePaste(event: ClipboardEvent, row: WsRow, phase: 'start' | 'end') {
  if (isOrderFinalized.value) return
  event.preventDefault()
  const items = event.clipboardData?.items
  if (!items) return

  for (const item of items) {
    if (item.type.includes('image')) {
      const file = item.getAsFile()
      if (file) {
        const uploadFileInfo: UploadFileInfo = {
          id: file.name + Date.now(),
          name: file.name,
          status: 'pending',
          file: file,
        }

        const payload = { file: uploadFileInfo }
        if (phase === 'start') {
          onPickStartFile(row, payload)
        } else {
          onPickEndFile(row, payload)
        }
        message.success('Đã dán ảnh thành công!')
        break
      }
    }
  }
}

function removeProof(row: WsRow, phase: 'start' | 'end') {
  if (phase === 'start') {
    if (row.startPreviewUrl) {
      URL.revokeObjectURL(row.startPreviewUrl)
    }
    row.startFile = null
    row.startPreviewUrl = null
    row.startProofUrl = null
  } else {
    if (row.endPreviewUrl) {
      URL.revokeObjectURL(row.endPreviewUrl)
    }
    row.endFile = null
    row.endPreviewUrl = null
    row.endProofUrl = null
  }
}

function openDeliveryModal(row: OrderRow) {
  deliveryModal.open = true
  deliveryModal.loading = false
  deliveryModal.orderId = row.order_id
  deliveryModal.customerName = row.customer_name
  deliveryModal.proofs = row.action_proof_urls || []
  deliveryModal.isDelivered = !!row.delivered_at
}

async function handleDeliveryStatusChange(checked: boolean) {
  if (!deliveryModal.orderId) return

  deliveryModal.loading = true
  try {
    const { error } = await supabase.rpc('mark_order_as_delivered_v1', {
      p_order_id: deliveryModal.orderId,
      p_is_delivered: checked,
    })
    if (error) throw error

    message.success('Đã cập nhật trạng thái trả đơn!')
    // Cập nhật lại dòng tương ứng trong bảng để UI thay đổi ngay lập tức
    const idx = rows.value.findIndex((r) => r.order_id === deliveryModal.orderId)
    if (idx > -1) {
      rows.value[idx].delivered_at = checked ? new Date().toISOString() : null
    }
  } catch (e: any) {
    message.error(e.message || 'Cập nhật thất bại.')
    // Trả lại trạng thái cũ của checkbox nếu có lỗi
    deliveryModal.isDelivered = !checked
  } finally {
    deliveryModal.loading = false
  }
}

// =================================================================
// DETAIL DRAWER LOGIC
// =================================================================
async function openDetail(row: OrderRow) {
  isDescCollapsed.value = true
  detailOpen.value = true
  detailLoading.value = true
  collapsedKinds.clear()

  try {
    const { data, error } = await supabase.rpc('get_boosting_order_detail_v1', {
      p_line_id: row.id,
    })
    if (error) throw error
    if (!data) {
      message.error('Không tìm thấy dữ liệu chi tiết.')
      detailOpen.value = false
      return
    }

    // Gán dữ liệu chi tiết từ RPC vào object 'detail'
    Object.assign(detail, data)
    machineInfoModel.value = data.machine_info || ''
    isEditingMachineInfo.value = !data.machine_info
    detail.service_type = row.service_type

    // Xử lý tên người thực hiện (assignee)
    if (data.active_session) {
      detail.assignees_text = data.active_session.farmer_name
    } else {
      detail.assignees_text = row.assignees_text
    }

    svcItems.value = (data.service_items || []) as SvcItem[]

    const allGroupKeys = new Set(
      svcItems.value.map((it) => (it.kind_code || 'GENERIC').toUpperCase())
    )
    allGroupKeys.forEach((key) => collapsedKinds.add(key))

    if (data.active_session && data.active_session.start_state) {
      const activeItemIds = new Set(data.active_session.start_state.map((s: any) => s.item_id))
      const kindsToExpand = new Set<string>()

      svcItems.value.forEach((it) => {
        if (activeItemIds.has(it.id)) {
          kindsToExpand.add((it.kind_code || 'GENERIC').toUpperCase())
        }
      })
      kindsToExpand.forEach((key) => collapsedKinds.delete(key))
    }

    await loadLastProofs(svcItems.value.map((s: SvcItem) => s.id))

    if (data.active_session) {
      ws2.value.sessionId = data.active_session.session_id
      const startStateMap = new Map(
        data.active_session.start_state.map((s: any) => [String(s.item_id), s])
      )
      ws2.value.rows = svcItems.value.map((it) => {
        const state = startStateMap.get(String(it.id))
        const done = Number(it.done_qty ?? 0)
        const plan = Number(it.plan_qty ?? 0)
        let status = 'Đang thực hiện'
        if (plan > 0 && done >= plan) status = 'Hoàn thành'
        return {
          item_id: String(it.id),
          kind_code: (it.kind_code || '').toUpperCase(),
          label: paramsLabel(it),
          start_value: round2((state as any)?.start_value ?? 0),
          current_value: round2((state as any)?.start_value ?? 0),
          start_exp: (state as any)?.start_exp ?? 0,
          current_exp: (state as any)?.start_exp ?? 0,
          isStartValueEditable: false,
          isExpEditable: false,
          startProofUrl: (state as any)?.start_proof_url ?? null,
          startFile: null,
          endFile: null,
          startPreviewUrl: null,
          endPreviewUrl: null,
          endProofUrl: null,
          statusText: status,
        }
      })
      ws2.value.selectedIds = Array.from(startStateMap.keys(), (key) => String(key))
    } else {
      ws2.value.sessionId = null
      ws2.value.rows = svcItems.value.map((it) => {
        const base = baselineFromItem(it)
        const lp = lastProofMap.value[String(it.id)]
        const done = Number(it.done_qty ?? 0)
        const plan = Number(it.plan_qty ?? 0)
        const kind = (it.kind_code || '').toUpperCase()
        const isFirstSession = done === 0 && !lp
        const startExp = lp?.last_exp_percent ?? 0
        let isStartValueEditable = false
        let isExpEditable = false
        if (kind === 'MATERIALS' && detail.service_type === 'Pilot' && isFirstSession) {
          isStartValueEditable = true
        }
        if (kind === 'LEVELING' && isFirstSession) {
          isExpEditable = true
        }
        let status = 'Chờ thực hiện'
        if (plan > 0 && done >= plan) status = 'Hoàn thành'
        else if (done > 0) status = 'Đang thực hiện'
        return {
          item_id: String(it.id),
          kind_code: kind,
          label: paramsLabel(it),
          start_value: round2(lp?.last_end ?? base),
          current_value: round2(lp?.last_end ?? base),
          start_exp: startExp,
          current_exp: startExp,
          isStartValueEditable: isStartValueEditable,
          isExpEditable: isExpEditable,
          startFile: null,
          endFile: null,
          startPreviewUrl: null,
          endPreviewUrl: null,
          startProofUrl: lp?.last_end_proof_url || lp?.last_start_proof_url || null,
          endProofUrl: null,
          statusText: status,
        }
      })
    }
    syncEditModel(true)
  } catch (e: any) {
    console.error('[openDetail]', e)
    message.error(e?.message || 'Không tải được chi tiết đơn hàng')
  } finally {
    detailLoading.value = false
  }
}

async function createServiceReport(itemId: string, description: string, proofUrls: string[]) {
  const { data, error } = await supabase.rpc('create_service_report_v1', {
    p_order_service_item_id: itemId,
    p_description: description,
    p_proof_urls: proofUrls,
  })
  if (error) throw error
  return data
}

function onDrawerClose() {
  Object.assign(detail, {})
  editing.value = false
  deadlineModel.value = null
  svcItems.value = []
  lastProofMap.value = {}
  ws2.value = {
    activityRows: [{ label: null, qty: null }],
    note: '',
    overrun_reason: null,
    overrun_type: null,
    overrun_proofs: [],
    sessionId: null,
    selectedIds: [],
    rows: [],
  }
  proofFiles.value = []
}

function toggleEdit() {
  editing.value = true
  syncEditModel()
}

function cancelEdit() {
  editing.value = false
  syncEditModel(true)
}

function syncEditModel(_reset = false) {
  deadlineModel.value = detail.deadline ? Date.parse(detail.deadline) : null
}

async function saveInfo() {
  if (!detail.id) return
  try {
    savingInfo.value = true

    const payload = {
      p_line_id: detail.id,
      p_service_type: detail.service_type,
      p_deadline: deadlineModel.value ? new Date(deadlineModel.value).toISOString() : null,
      p_package_note: detail.package_note || null,
      p_btag: detail.service_type === 'Selfplay' ? detail.btag || null : null,
      p_login_id: detail.service_type === 'Pilot' ? detail.login_id || null : null,
      p_login_pwd: detail.service_type === 'Pilot' ? detail.login_pwd || null : null,
    }

    const { error } = await supabase.rpc('update_order_details_v1', payload)

    if (error) throw error
    message.success('Đã lưu thay đổi!')
    editing.value = false
    await loadOrders()

    const currentRow = rows.value.find((r) => r.id === detail.id)
    if (currentRow) {
      await openDetail(currentRow)
    }
  } catch (e: any) {
    console.error('[saveInfo]', e)
    message.error(e?.message || 'Không lưu được thay đổi')
  } finally {
    savingInfo.value = false
  }
}

function paramsLabel(it: SvcItem | SvcItemSummary): string {
  const k = (it.kind_code || '').toUpperCase()
  const p = it.params || {}
  const plan = Number(it.plan_qty ?? p.plan_qty ?? p.qty ?? 0)
  const done = Number(it.done_qty ?? 0)
  let mainLabel = ''

  // KHÔNG CẦN `const getName` ở đây nữa

  switch (k) {
    case 'LEVELING':
      mainLabel = `${p.mode === 'paragon' ? 'Paragon' : 'Level'} ${p.start}→${p.end}`
      break
    case 'BOSS':
      mainLabel = `${p.boss_label || getAttributeName(p.boss_code)}`
      break // Dùng getAttributeName
    case 'THE_PIT':
      mainLabel = `${p.tier_label || getAttributeName(p.tier_code)}`
      break // Dùng getAttributeName
    case 'NIGHTMARE':
      mainLabel = `${getAttributeName(p.attribute_code)}`
      break // Dùng getAttributeName
    case 'INFERNAL_HORDES':
      mainLabel = `${getAttributeName(p.attribute_code)}`
      break // Dùng getAttributeName
    case 'MATERIALS':
      mainLabel = `${getAttributeName(p.attribute_code)}`
      break // Dùng getAttributeName
    case 'MASTERWORKING':
      mainLabel = `${getAttributeName(p.attribute_code)}`
      break // Dùng getAttributeName
    case 'ALTARS_OF_LILITH':
      mainLabel = `${getAttributeName(p.attribute_code)}`
      break // Dùng getAttributeName
    case 'RENOWN':
      mainLabel = `${getAttributeName(p.attribute_code)}`
      break // Dùng getAttributeName
    case 'MYTHIC':
      mainLabel = `${p.item_label || getAttributeName(p.item_code)}${p.ga_label ? ` (${p.ga_label}${p.ga_note ? ': ' + p.ga_note : ''})` : ''}`
      break
    case 'GENERIC':
      mainLabel = p.desc || p.note || 'Generic'
      break
    default:
      mainLabel = JSON.stringify(p)
      break
  }

  const unit = KIND_UNITS[k as keyof typeof KIND_UNITS] || ''
  const suffix =
    plan > 0
      ? ` (${done}/${plan}${unit ? ' ' + unit : ''})`
      : done > 0
        ? ` (${done}${unit ? ' ' + unit : ''})`
        : ''

  return mainLabel + suffix
}

const savingMachineInfo = ref(false) // Có thể dùng chung state savingInfo

async function saveMachineInfo() {
  if (!detail.id) return
  savingInfo.value = true
  try {
    const { error } = await supabase.rpc('update_order_line_machine_info_v1', {
      p_line_id: detail.id,
      p_machine_info: machineInfoModel.value.trim() || null,
    })
    if (error) throw error

    message.success('Đã cập nhật thông tin máy!')
    isEditingMachineInfo.value = false

    // Cập nhật lại dữ liệu local để giao diện phản hồi ngay lập tức
    detail.machine_info = machineInfoModel.value.trim() || null
    const idx = rows.value.findIndex((r) => r.id === detail.id)
    if (idx > -1) {
      rows.value[idx].machine_info = detail.machine_info
    }
  } catch (e: any) {
    message.error(e.message || 'Cập nhật thất bại.')
  } finally {
    savingInfo.value = false
  }
}

function groupAndSort(items: SvcItem[]) {
  const groups = new Map<string, { key: string; label: string; code: string; items: SvcItem[] }>()
  for (const it of items) {
    const code = (it.kind_code || 'GENERIC').toString().toUpperCase()
    const label = attributeMap.value.get(code) || code.replace(/_/g, ' ')
    if (!groups.has(code)) {
      groups.set(code, { key: code, label, code, items: [] })
    }
    groups.get(code)!.items.push(it)
  }
  return Array.from(groups.values()).sort(
    (a, b) =>
      (KIND_ORDER[a.code as keyof typeof KIND_ORDER] ?? 999) -
      (KIND_ORDER[b.code as keyof typeof KIND_ORDER] ?? 999)
  )
}

function openReportModal(item: SvcItem) {
  if (item.active_report_id) {
    message.warning('Hạng mục này đã có báo cáo và đang chờ xử lý.')
    return
  }
  reportModal.value.open = true
  reportModal.value.itemId = item.id
  reportModal.value.itemLabel = paramsLabel(item)
  reportModal.value.description = ''
  reportModal.value.proofs = []
  reportModal.value.loading = false
}

async function submitReport() {
  if (!reportModal.value.itemId || !reportModal.value.description.trim()) {
    message.error('Vui lòng nhập mô tả cho báo cáo.')
    return
  }

  reportModal.value.loading = true
  message.loading('Đang xử lý báo cáo...')
  try {
    const proofUrls: string[] = []
    if (reportModal.value.proofs.length > 0) {
      const uploadPromises = reportModal.value.proofs.map((fileInfo) =>
        fileInfo.file
          ? uploadActionProof(fileInfo.file, detail.id!, 'cancellation')
          : Promise.resolve(null)
      )

      const urls = (await Promise.all(uploadPromises)).filter(Boolean) as string[]
      if (urls.length !== reportModal.value.proofs.length) {
        throw new Error('Một vài file bằng chứng upload không thành công.')
      }
      proofUrls.push(...urls)
    }

    // Lưu lại ID của item vừa được báo cáo
    const reportedItemId = reportModal.value.itemId

    await createServiceReport(reportedItemId, reportModal.value.description, proofUrls)

    // <<< THÊM LOGIC MỚI Ở ĐÂY >>>
    // Sau khi báo cáo thành công, tìm và xóa item ID ra khỏi danh sách đang chọn
    if (reportedItemId) {
      const index = ws2.value.selectedIds.indexOf(reportedItemId)
      if (index > -1) {
        ws2.value.selectedIds.splice(index, 1)
      }
    }
    // <<< KẾT THÚC LOGIC MỚI >>>

    message.destroyAll()
    message.success('Gửi báo cáo thành công! Hạng mục đã được bỏ chọn.')
    reportModal.value.open = false

    // Tải lại chi tiết đơn hàng để cập nhật trạng thái "có báo cáo"
    const currentRow = rows.value.find((r) => r.id === detail.id)
    if (currentRow) {
      await openDetail(currentRow)
    }
  } catch (e: any) {
    console.error('[submitReport]', e)
    message.destroyAll()
    message.error(e?.message || 'Không thể gửi báo cáo.')
  } finally {
    reportModal.value.loading = false
  }
}

async function openHistoryModal(row: OrderRow) {
  historyModal.lineId = row.id
  historyModal.open = true
  historyModal.loading = true
  try {
    const { data, error } = await supabase.rpc('get_session_history_v2', { p_line_id: row.id })
    if (error) throw error
    historyModal.sessions = data || []
  } catch (e: any) {
    console.error('[openHistoryModal]', e)
    message.error(e.message || 'Không thể tải lịch sử phiên.')
  } finally {
    historyModal.loading = false
  }
}

function isLevelingItemDisabled(currentItem: SvcItem): boolean {
  if (currentItem.active_report_id) {
    return true
  }

  if (!!ws2.value.sessionId) {
    return true
  }

  const currentIsParagon = (currentItem.params?.mode || '').toLowerCase() === 'paragon'
  if (!currentIsParagon) {
    return false
  }

  const levelItem = svcItems.value.find((it) => (it.params?.mode || '').toLowerCase() === 'level')

  if (levelItem) {
    const levelPlan = Number(levelItem.plan_qty ?? 0)
    const levelDone = Number(levelItem.done_qty ?? 0)
    if (levelDone < levelPlan) {
      return true
    }
  }

  return false
}

// =================================================================
// WORK SESSION LOGIC
// =================================================================
function baselineFromItem(it: SvcItem): number {
  const k = (it.kind_code || '').toUpperCase()
  if (k === 'LEVELING' && it.params?.start != null) {
    return round2(Number(it.params.start) + Number(it.done_qty ?? 0))
  }
  return round2(it.done_qty ?? 0)
}

function addActRow() {
  ws2.value.activityRows.push({ label: '', qty: 0 })
}

function rmActRow(i: number) {
  ws2.value.activityRows.splice(i, 1)
}

function isPicked(id: string) {
  return ws2.value.selectedIds.includes(String(id))
}

function togglePick(it: SvcItem, checked: boolean) {
  if (ws2.value.sessionId) {
    message.warning(
      'Bạn cần hoàn tất hoặc hủy phiên làm việc hiện tại trước khi thay đổi lựa chọn.'
    )
    return
  }
  const id = String(it.id)
  const set = new Set(ws2.value.selectedIds)
  checked ? set.add(id) : set.delete(id)
  ws2.value.selectedIds = Array.from(set)
}

function onPickStartFile(r: WsRow, f: { file?: UploadFileInfo | null }) {
  if (!r || !f.file?.file) return
  const newFile = f.file.file
  if (r.startPreviewUrl) URL.revokeObjectURL(r.startPreviewUrl)
  r.startFile = newFile
  r.startPreviewUrl = URL.createObjectURL(newFile)
}

function onPickEndFile(r: WsRow, f: { file?: UploadFileInfo | null }) {
  if (!r || !f.file?.file) return
  const newFile = f.file.file
  if (r.endPreviewUrl) URL.revokeObjectURL(r.endPreviewUrl)
  r.endFile = newFile
  r.endPreviewUrl = URL.createObjectURL(newFile)
}

async function uploadOverrunProof(file: File, lineId: string, sessionId: string): Promise<string> {
  if (!file) throw new Error('File không hợp lệ.')
  const fileExt = file.name.split('.').pop()
  const fileName = `${Date.now()}_${Math.random().toString(36).substring(2)}.${fileExt}`
  // Tạo đường dẫn file có cấu trúc rõ ràng
  const filePath = `${lineId}/${sessionId}/overrun/${fileName}`

  const { data, error } = await supabase.storage.from('work-proofs').upload(filePath, file)
  if (error) throw new Error(`Lỗi upload bằng chứng vượt chỉ tiêu: ${error.message}`)

  const { data: publicURL } = supabase.storage.from('work-proofs').getPublicUrl(data.path)
  return publicURL.publicUrl
}

async function startSession() {
  console.log('startSession CALLED')

  if (!detail.id) {
    return
  }

  sessionLoading.value = true
  message.loading('Đang upload bằng chứng và tạo phiên...')

  try {
    const selectedRows = ws2.value.rows.filter((r) => ws2.value.selectedIds.includes(r.item_id))
    console.log('Selected Rows:', selectedRows) // LOG 4: Xem các item đã chọn

    const tempSessionId = globalThis.crypto.randomUUID()

    const uploadPromises = selectedRows
      .filter((r) => r.startFile)
      .map((r) => uploadProof(r.startFile!, detail.id!, tempSessionId, r.item_id, 'start'))

    console.log('Upload Promises count:', uploadPromises.length) // LOG 5: Xem có bao nhiêu file cần upload

    const uploadedUrls = await Promise.all(uploadPromises)
    console.log('Uploaded URLs:', uploadedUrls) // LOG 6: Xem kết quả upload

    const urlMap = new Map<string, string>()
    selectedRows
      .filter((r) => r.startFile)
      .forEach((r, i) => {
        if (uploadedUrls[i]) {
          urlMap.set(r.item_id, uploadedUrls[i]!)
        }
      })

    const startStatePayload = selectedRows.map((r) => {
      return {
        item_id: r.item_id,
        start_value: r.start_value,
        start_proof_url: r.startFile ? urlMap.get(r.item_id) : r.startProofUrl,
        start_exp: r.start_exp,
      }
    })
    console.log('Payload to RPC:', startStatePayload) // LOG 7: Xem payload cuối cùng

    const sessionId = await startWorkSession(detail.id, startStatePayload, ws2.value.note)
    ws2.value.sessionId = sessionId

    message.destroyAll()
    message.success('Bắt đầu phiên làm việc thành công!')

    const currentRow = rows.value.find((r) => r.id === detail.id)
    if (currentRow) {
      await openDetail(currentRow)
    }
  } catch (e: any) {
    // LOG 8: BẮT LỖI QUAN TRỌNG
    console.error('ERROR inside startSession:', e)
    message.destroyAll()
    message.error(e.message || 'Không thể bắt đầu phiên làm việc')
  } finally {
    console.log('FINALLY block executed') // LOG 9: Kiểm tra khối finally
    sessionLoading.value = false
  }
}

async function cancelSession() {
  dialog.warning({
    title: 'Xác nhận Hủy phiên',
    content:
      'Bạn có chắc chắn muốn hủy phiên làm việc đang dang dở không? Mọi tiến độ chưa lưu sẽ bị mất.',
    positiveText: 'Chắc chắn Hủy',
    negativeText: 'Không',
    onPositiveClick: async () => {
      const sid = ws2.value.sessionId
      if (!sid || !detail.id) return

      message.loading('Đang hủy phiên...')
      submittingFinish.value = true
      try {
        const { error } = await supabase.rpc('cancel_work_session_v1', { p_session_id: sid })
        if (error) throw error

        message.destroyAll()
        message.success('Đã huỷ phiên')

        ws2.value.sessionId = null
        const currentRow = rows.value.find((r) => r.id === detail.id)
        if (currentRow) {
          await openDetail(currentRow)
        }
      } catch (e: any) {
        console.error('[cancelSession]', e)
        message.destroyAll()
        message.error(e?.message ?? 'Huỷ phiên thất bại')
      } finally {
        submittingFinish.value = false
      }
    },
  })
}

async function finishSession() {
  const sid = ws2.value.sessionId
  if (!sid || !detail.id) return

  try {
    submittingFinish.value = true
    message.loading('Đang xử lý và upload bằng chứng...')

    // BƯỚC 1: UPLOAD BẰNG CHỨNG VƯỢT CHỈ TIÊU (NẾU CÓ)
    let overrunProofUrls: string[] = []
    if (overrunDetected.value && ws2.value.overrun_proofs.length > 0) {
      const uploadPromises = ws2.value.overrun_proofs.map((fileInfo) =>
        fileInfo.file ? uploadOverrunProof(fileInfo.file, detail.id!, sid) : Promise.resolve(null)
      )

      const urls = (await Promise.all(uploadPromises)).filter(Boolean) as string[]
      if (urls.length !== ws2.value.overrun_proofs.length) {
        throw new Error('Một vài file bằng chứng vượt chỉ tiêu upload không thành công.')
      }
      overrunProofUrls = urls
    }

    // BƯỚC 2: UPLOAD BẰNG CHỨNG CÔNG VIỆC VÀ TẠO PAYLOAD (LOGIC CŨ)
    const selectedItems = ws2.value.rows.filter((r) => ws2.value.selectedIds.includes(r.item_id))
    const outputs: SessionOutputRow[] = await Promise.all(
      selectedItems.map(async (r) => {
        const startUrl = r.startFile
          ? await uploadProof(r.startFile, detail.id!, sid, r.item_id, 'start')
          : (r.startProofUrl ?? null)
        const endUrl = r.endFile
          ? await uploadProof(r.endFile, detail.id!, sid, r.item_id, 'end')
          : (r.endProofUrl ?? null)
        const params: any = {}
        if (r.kind_code === 'LEVELING' && r.current_exp != null) {
          params.exp_percent = r.current_exp
        }
        return {
          item_id: r.item_id,
          start_value: Number(r.start_value),
          current_value: Number(r.current_value),
          start_proof_url: startUrl,
          end_proof_url: endUrl,
          params: Object.keys(params).length > 0 ? params : undefined,
        }
      })
    )
    const acts: ActivityRow[] = []
    const selectedMythicItemIds = selectedItems
      .filter((r) => mythicKinds.has(r.kind_code))
      .map((r) => r.item_id)
    if (selectedMythicItemIds.length > 0) {
      ws2.value.activityRows.forEach((activity) => {
        if (activity.label && (activity.qty ?? 0) > 0) {
          selectedMythicItemIds.forEach((mythicId) => {
            acts.push({
              item_id: mythicId,
              kind_code: 'ACTIVITY',
              delta: Number(activity.qty),
              params: { label: String(activity.label).trim() || ' ' },
              start_value: 0,
              current_value: Number(activity.qty),
              start_proof_url: null,
              end_proof_url: null,
            })
          })
        }
      })
    }
    if (
      selectedMythicItemIds.length > 0 &&
      ws2.value.activityRows.some((a) => a.label && (a.qty ?? 0) > 0) &&
      acts.length === 0
    ) {
      throw new Error('Lỗi logic: Không thể liên kết hoạt động farm boss với item Mythic đã chọn.')
    }

    // BƯỚC 3: GỌI RPC VỚI ĐẦY ĐỦ THAM SỐ
    const idem = globalThis.crypto?.randomUUID?.() ?? sid
    const { error } = await finishWorkSessionIdem(
      sid,
      outputs,
      acts,
      ws2.value.overrun_reason ?? null,
      idem,
      ws2.value.overrun_type ?? null,
      overrunProofUrls
    )
    if (error) throw error

    message.destroyAll()
    message.success('Đã kết thúc phiên thành công!')
    ws2.value.selectedIds = []
    ws2.value.sessionId = null
    await loadOrders()
    const currentRow = rows.value.find((r) => r.id === detail.id)
    if (currentRow) {
      await openDetail(currentRow)
    }
  } catch (e: any) {
    console.error('[finishSession]', e)
    message.destroyAll()
    message.error(e?.message || 'Không thể kết thúc phiên')
  } finally {
    submittingFinish.value = false
  }
}

function resetFilters() {
  filters.channels = null
  filters.serviceTypes = null
  filters.packageTypes = null
  filters.customerName = ''
  filters.statuses = null
  filters.assignee = ''
  filters.deliveryStatus = null
  filters.reviewStatus = null
}

function getAttributeName(code: string): string {
  if (!code) return 'Không rõ'
  return attributeMap.value.get(code) || code
}

async function loadAttributeMap() {
  try {
    // Lấy tất cả attributes
    const { data: attributes, error } = await supabase
      .from('attributes')
      .select('id, code, name, type')
    if (error) throw error
    if (!attributes) return

    // Lấy tất cả các mối quan hệ
    const { data: relationships, error: relError } = await supabase
      .from('attribute_relationships')
      .select('parent_attribute_id, child_attribute_id')
    if (relError) throw relError

    // --- Bắt đầu xử lý dữ liệu ---

    // 1. Tạo các map để tra cứu
    const attrMapById = new Map(attributes.map((a) => [a.id, a]))
    const childrenMap = new Map<string, string[]>()
    for (const rel of relationships!) {
      if (!childrenMap.has(rel.parent_attribute_id)) {
        childrenMap.set(rel.parent_attribute_id, [])
      }
      childrenMap.get(rel.parent_attribute_id)!.push(rel.child_attribute_id)
    }
    const toSelectOption = (attr: any) => ({ label: attr.name, value: attr.code })
    const sortFn = (a: { label: string }, b: { label: string }) => a.label.localeCompare(b.label)

    // 2. Populate attributeMap (giữ lại logic cũ)
    const newAttrMap = new Map<string, string>()
    attributes.forEach((attr) => newAttrMap.set(attr.code, attr.name))
    attributeMap.value = newAttrMap

    // 3. MỚI: Populate bossDict (logic giống hệt Sales.vue)
    const sellableBosses: { label: string; value: string }[] = []
    const bossServiceKind = attributes.find((a) => a.code === 'BOSS' && a.type === 'SERVICE_KIND')
    if (bossServiceKind) {
      const bossTypeIds = childrenMap.get(bossServiceKind.id) || []
      for (const bossTypeId of bossTypeIds) {
        const concreteBossIds = childrenMap.get(bossTypeId) || []
        for (const bossId of concreteBossIds) {
          const bossAttr = attrMapById.get(bossId)
          if (bossAttr) sellableBosses.push(toSelectOption(bossAttr))
        }
      }
    }
    bossDict.value = sellableBosses.sort(sortFn)
  } catch (e: any) {
    console.error('[loadAttributeMap]', e)
    message.error('Không tải được từ điển attributes: ' + e.message)
  }
}

function toggleKindCollapse(key: string) {
  if (collapsedKinds.has(key)) {
    collapsedKinds.delete(key)
  } else {
    collapsedKinds.add(key)
  }
}

// =================================================================
// ORDER ACTIONS (COMPLETE / CANCEL / REVIEW)
// =================================================================
function handleCompleteOrder() {
  dialog.success({
    title: 'Xác nhận Hoàn thành',
    content: 'Bạn có chắc chắn muốn đánh dấu đơn hàng này là hoàn thành?',
    positiveText: 'Hoàn thành',
    negativeText: 'Hủy',
    onPositiveClick: () => {
      markLineDone()
    },
  })
}

async function markLineDone() {
  if (!detail.id) return
  if (proofFiles.value.length === 0) {
    message.error('Vui lòng tải lên ít nhất một ảnh bằng chứng.')
    return
  }
  closingOrder.value = true
  message.loading('Đang xử lý, vui lòng chờ...')
  try {
    const uploadPromises = proofFiles.value.map((fileInfo) =>
      fileInfo.file
        ? uploadActionProof(fileInfo.file, detail.id!, 'completion')
        : Promise.resolve(null)
    )
    const proofUrls = (await Promise.all(uploadPromises)).filter((url) => url !== null) as string[]
    if (proofUrls.length !== proofFiles.value.length) {
      throw new Error('Một vài file upload không thành công, vui lòng thử lại.')
    }
    const { error: rpcError } = await supabase.rpc('complete_order_line_v1', {
      p_line_id: detail.id,
      p_completion_proof_urls: proofUrls,
      p_reason: ws2.value.note || null,
    })
    if (rpcError) throw rpcError
    message.destroyAll()
    message.success('Đã hoàn thành đơn hàng!')
    detailOpen.value = false
    await loadOrders()
  } catch (e: any) {
    console.error('[markLineDone]', e)
    message.destroyAll()
    message.error(e?.message || 'Không thể đóng đơn hàng.')
  } finally {
    closingOrder.value = false
  }
}

function handleCancelOrder() {
  dialog.warning({
    title: 'Xác nhận Hủy đơn hàng',
    content: 'Bạn có chắc chắn muốn hủy đơn hàng này không? Thao tác này không thể hoàn tác.',
    positiveText: 'Chắc chắn',
    negativeText: 'Không',
    onPositiveClick: () => {
      cancelOrderLine()
    },
  })
}

async function cancelOrderLine() {
  if (!detail.id) return
  if (!ws2.value.note.trim()) {
    message.error('Vui lòng nhập lý do hủy bỏ vào ô Ghi chú.')
    return
  }
  if (proofFiles.value.length === 0) {
    message.error('Vui lòng tải lên bằng chứng hủy bỏ.')
    return
  }
  cancellingOrder.value = true
  message.loading('Đang xử lý, vui lòng chờ...')
  try {
    const uploadPromises = proofFiles.value.map((f) =>
      f.file ? uploadActionProof(f.file, detail.id!, 'cancellation') : Promise.resolve(null)
    )
    const proofUrls = (await Promise.all(uploadPromises)).filter(Boolean) as string[]
    if (proofUrls.length !== proofFiles.value.length) {
      throw new Error('Một vài file upload không thành công, vui lòng thử lại.')
    }
    const { error: rpcError } = await supabase.rpc('cancel_order_line_v1', {
      p_line_id: detail.id,
      p_cancellation_proof_urls: proofUrls,
      p_reason: ws2.value.note,
    })
    if (rpcError) throw rpcError
    message.destroyAll()
    message.success('Đã hủy đơn hàng thành công!')
    detailOpen.value = false
    await loadOrders()
  } catch (e: any) {
    console.error('[cancelOrderLine]', e)
    message.destroyAll()
    message.error(e.message || 'Hủy đơn hàng thất bại.')
  } finally {
    cancellingOrder.value = false
  }
}

async function openReviewModal(row: OrderRow) {
  // Reset state
  review.value = {
    ...review.value,
    open: true,
    lineId: row.id,
    stars: 5,
    comment: '',
    proofs: [],
    loadingExisting: true,
    existingReviews: [],
  }

  // Tải các review cũ
  try {
    const { data, error } = await supabase.rpc('get_reviews_for_order_line_v1', {
      p_line_id: row.id,
    })
    if (error) throw error
    review.value.existingReviews = data || []
  } catch (e: any) {
    console.error('[openReviewModal]', e)
    message.error(e.message || 'Không thể tải danh sách review.')
  } finally {
    review.value.loadingExisting = false
  }
}

async function submitReview() {
  const currentLineId = review.value.lineId // Lưu lại lineId
  if (!currentLineId) return
  if (review.value.stars === 0) {
    message.error('Vui lòng chọn số sao đánh giá.')
    return
  }

  review.value.saving = true
  message.loading('Đang gửi đánh giá...')
  try {
    let proofUrls: string[] = []
    if (review.value.proofs.length > 0) {
      const uploadPromises = review.value.proofs.map((fileInfo) =>
        fileInfo.file
          ? uploadActionProof(fileInfo.file, currentLineId, 'completion')
          : Promise.resolve(null)
      )

      const urls = (await Promise.all(uploadPromises)).filter(Boolean) as string[]
      if (urls.length !== review.value.proofs.length) {
        throw new Error('Tải lên một vài file bằng chứng không thành công.')
      }
      proofUrls = urls
    }

    const { error } = await supabase.rpc('submit_order_review_v1', {
      p_line_id: currentLineId,
      p_rating: review.value.stars,
      p_comment: review.value.comment || null,
      p_proof_urls: proofUrls.length > 0 ? proofUrls : null,
    })
    if (error) throw error

    message.destroyAll()
    message.success('Gửi đánh giá thành công!')
    review.value.open = false // Đóng modal sau khi thành công
    await loadOrders() // Tải lại bảng chính để cập nhật tag "Đã review"
  } catch (e: any) {
    console.error('[submitReview]', e)
    message.destroyAll()
    message.error(e?.message || 'Gửi đánh giá thất bại')
  } finally {
    review.value.saving = false
  }
}

const savingNewProofs = ref(false)

// Computed này kiểm tra xem có ảnh mới nào vừa được thêm vào không
const hasNewProofs = computed(() => {
  return isOrderFinalized.value && proofFiles.value.some((f) => !f.isSaved)
})

function handleShowRemoveButton({ file }: { file: ProofUploadFileInfo }): boolean {
  // Nếu file có thuộc tính isSaved, nghĩa là file cũ -> không hiện nút xóa
  return !file.isSaved
}

function handleProofRemove({ file }: { file: ProofUploadFileInfo }): boolean {
  // Logic: Kiểm tra ID của file.
  // Nếu file này là file cũ được tải từ database (có id bắt đầu bằng 'proof-'),
  // thì không cho phép xóa -> return false.
  if (file.id.startsWith('proof-')) {
    message.warning('Bạn không thể xóa bằng chứng đã được lưu trữ.')
    return false // Ngăn chặn hành động xóa
  }

  // Ngược lại, cho phép xóa (đây là file mới do người dùng vừa thêm vào).
  return true
}

// Hàm này sẽ được gọi khi nhấn nút "Lưu bằng chứng mới"
async function saveAdditionalProofs() {
  if (!detail.id || !hasNewProofs.value) return

  savingNewProofs.value = true
  message.loading('Đang upload và lưu bằng chứng mới...')
  try {
    const oldUrls = detail.action_proof_urls || []

    // Lọc ra các file mới cần upload
    const newFilesToUpload = proofFiles.value.filter((f) => !f.isSaved && f.file)

    // Upload các file mới
    const uploadPromises = newFilesToUpload.map((f) =>
      uploadActionProof(f.file!, detail.id!, 'completion')
    )
    const newUrls = await Promise.all(uploadPromises)

    // Gộp URL cũ và mới
    const combinedUrls = [...oldUrls, ...newUrls]

    // Gọi RPC để cập nhật
    const { error } = await supabase.rpc('update_action_proofs_v1', {
      p_line_id: detail.id,
      p_new_urls: combinedUrls,
    })
    if (error) throw error

    message.destroyAll()
    message.success('Đã lưu bằng chứng bổ sung!')

    // Tải lại dữ liệu cho drawer để cập nhật
    const currentRow = rows.value.find((r) => r.id === detail.id)
    if (currentRow) {
      await openDetail(currentRow)
    }
  } catch (e: any) {
    console.error('[saveAdditionalProofs]', e)
    message.destroyAll()
    message.error(e.message || 'Lưu bằng chứng thất bại')
  } finally {
    savingNewProofs.value = false
  }
}

function groupSessionOutputs(outputs: any[]) {
  if (!outputs || !outputs.length) return []

  // Bước 1: Tách riêng các hạng mục công việc và các hoạt động farm boss
  const realItems = outputs.filter((o) => !o.is_activity)
  const activityItems = outputs.filter((o) => o.is_activity)

  // Bước 2: Nhóm các hạng mục công việc (logic không đổi)
  const groups = new Map<string, { kind: string; items: any[]; activities?: any[] }>()
  for (const output of realItems) {
    const kindName = attributeMap.value.get(output.kind_code) || output.kind_code

    if (!groups.has(kindName)) {
      groups.set(kindName, { kind: kindName, items: [] })
    }
    groups.get(kindName)!.items.push(output)
  }

  // Bước 3: Lấy ra MỘT hoạt động đại diện và gắn vào nhóm Mythic
  if (activityItems.length > 0) {
    // Chỉ cần lấy hoạt động đầu tiên vì chúng đều đại diện cho cùng một kết quả
    const representativeActivity = activityItems[0]

    const mythicKindName = attributeMap.value.get('MYTHIC') || 'MYTHIC'
    const mythicGroup = Array.from(groups.values()).find((g) => g.kind === mythicKindName)

    if (mythicGroup) {
      // Gắn một mảng chỉ chứa MỘT hoạt động duy nhất
      // Template v-for sẽ chỉ lặp một lần và hiển thị đúng
      mythicGroup.activities = [representativeActivity]
    }
  }

  return Array.from(groups.values())
}

// =================================================================
// PROOF FILES FOR ORDER ACTIONS
// =================================================================
watch(
  () => detail.action_proof_urls,
  (urls) => {
    if (urls && urls.length > 0) {
      proofFiles.value = urls.map((url, index) => ({
        id: `proof-${index}-${url}`,
        name: `Bằng chứng ${index + 1}`,
        status: 'finished',
        url: url,
        isSaved: true,
      }))
    } else {
      proofFiles.value = []
    }
  },
  { immediate: true }
)

// =================================================================
// LIFECYCLE & POLLING
// =================================================================
function startClock() {
  stopClock()
  clock = window.setInterval(() => {
    now.value = Date.now()
  }, 1000)
}

function stopClock() {
  if (clock) {
    clearInterval(clock)
    clock = null
  }
}

function startPoll() {
  stopPoll()
  poll = window.setInterval(() => {
    if (autoRefresh.value) {
      loadOrders()
    }
  }, 30000)
}

function stopPoll() {
  if (poll) {
    clearInterval(poll)
    poll = null
  }
}

onMounted(() => {
  loadAttributeMap()
  startClock()
  startPoll()
  loadOrders()
})

onBeforeUnmount(() => {
  stopClock()
  stopPoll()
})
</script>

<style scoped>
:deep(.n-card) {
  border-radius: 14px;
}
.datatable--tight :deep(.n-data-table-th),
.datatable--tight :deep(.n-data-table-td) {
  padding: 8px 10px;
}
.wide-dropdown :deep(.n-select-menu) {
  min-width: 150px !important;
}

.cell-text {
  display: inline-block;
  max-width: 100%;
  vertical-align: bottom;
}
.row-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.row {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  padding: 0.25rem 0;
}
.meta {
  font-size: 12px;
  color: #6b7280;
  flex-shrink: 0;
  width: 120px;
}
.val {
  font-size: 14px;
  word-break: break-all;
}
.pre {
  white-space: pre-line;
}
.service-type {
  display: inline-flex !important;
  gap: 8px;
  align-items: center;
}

.service-type :deep(.n-radio-button) {
  min-width: 92px;
  height: 32px;
  padding: 0 10px;
  border-radius: 10px;
  border: 1px solid #e5e7eb !important;
  background: #fff;
  transition: all 0.2s ease;
  display: inline-flex;
  justify-content: center;
  align-items: center;
  box-shadow: none;
}

.service-type :deep(.n-radio-button--checked) {
  background: #111827;
  color: #fff;
  border-color: #111827 !important;
}

.svc-kind {
  border: 1px dashed #e5e7eb;
  border-radius: 10px;
  padding: 8px 10px;
}
.svc-kind + .svc-kind {
  margin-top: 6px;
}
.svc-kind__head {
  font-weight: 600;
  font-size: 13px;
  margin-bottom: 4px;
}
.svc-kind__grid {
  display: grid;
  grid-template-columns: 24px 1fr 30px 90px 60px 90px 60px 95px 100px;
  gap: 12px 8px;
  align-items: center;
}

.svc-item-row {
  display: contents;
}

.cell {
  padding: 4px 0;
}
.cell-check {
  display: flex;
  justify-content: center;
}
.cell-label {
  overflow: hidden;
}
.svc-proof {
  display: flex;
  align-items: center;
  gap: 8px;
}
.service-type :deep(.n-radio-group__splitor) {
  display: none !important;
}

.proof-box-empty {
  width: 96px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.proof-box-with-image {
  position: relative;
  width: 96px;
  height: 64px;
  border-radius: 4px;
  overflow: hidden;
}

.proof-box-with-image .n-image {
  width: 100%;
  height: 100%;
}

.proof-box-with-image :deep(img) {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-actions {
  position: absolute;
  top: 4px;
  right: 4px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s;
  background-color: rgba(255, 255, 255, 0.7);
  border-radius: 50%;
  padding: 2px;
}

.proof-box-with-image:hover .image-actions {
  opacity: 1;
}

.highlight-required {
  border-radius: 6px;
  box-shadow: 0 0 0 2px rgba(24, 160, 88, 0.2);
  outline: 1px solid rgba(24, 160, 88, 0.4);
  outline-offset: 2px;
  transition: all 0.2s ease;
}

.input-as-text :deep(.n-input__border),
.input-as-text :deep(.n-input__state-border) {
  /* Ẩn viền đi */
  display: none;
}

/* Ghi đè màu nền cho cả input wrapper và cụ thể là khi nó ở trạng thái disabled */
.input-as-text :deep(.n-input),
.input-as-text :deep(.n-input.n-input--disabled) {
  background-color: transparent !important;
  cursor: default !important;
}

/* Ghi đè trực tiếp lên thẻ <input> bên trong, đây là bước quan trọng nhất */
.input-as-text :deep(.n-input__input-el) {
  background-color: transparent !important;
  cursor: default !important;
  /* Đảm bảo màu chữ không bị mờ đi khi disable */
  color: inherit !important;
}
</style>
