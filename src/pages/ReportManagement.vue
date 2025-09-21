<!-- path: src/pages/ReportManagement.vue -->
<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold tracking-tight">Quản lý Báo cáo</h1>
      <n-button size="small" :loading="loading" @click="fetchReports">Làm mới</n-button>
    </div>

    <n-card v-if="!allowed" :bordered="false" class="shadow-sm">
      <div class="text-sm text-neutral-600">
        Bạn không có quyền truy cập trang này.
      </div>
    </n-card>

    <n-card v-else :bordered="false" class="shadow-sm">
      <n-data-table
        :columns="columns"
        :data="reports"
        :loading="loading"
        :pagination="{ pageSize: 20 }"
        :row-key="(r) => r.report_id"
        size="small"
      />
    </n-card>

    <n-drawer v-model:show="drawer.open" width="600" placement="right">
      <n-drawer-content :title="`Xử lý Báo cáo #${selectedReport?.report_id.substring(0, 8)}`">
        <template v-if="selectedReport">
          <n-spin :show="isSubmitting">
            <n-tabs type="line" animated>
              <n-tab-pane name="report" tab="Chi tiết Báo cáo">
                <n-descriptions label-placement="top" :column="1" bordered>
                  <n-descriptions-item label="Người báo cáo">{{ selectedReport.reporter_name }}</n-descriptions-item>
                  <n-descriptions-item label="Thời điểm">{{ new Date(selectedReport.reported_at).toLocaleString() }}</n-descriptions-item>
                  <n-descriptions-item label="Nội dung báo cáo">{{ selectedReport.report_description }}</n-descriptions-item>
                  <n-descriptions-item label="Hạng mục bị báo cáo">
                    <code>{{ paramsLabel(selectedReport.reported_item) }}</code>
                  </n-descriptions-item>
                </n-descriptions>
                <div v-if="selectedReport.report_proof_urls?.length" class="mt-4">
                  <h4 class="font-medium mb-2">Bằng chứng</h4>
                  <n-image-group>
                    <n-space>
                      <n-image v-for="url in selectedReport.report_proof_urls" :key="url" width="100" :src="url" />
                    </n-space>
                  </n-image-group>
                </div>
              </n-tab-pane>

              <n-tab-pane name="edit-item" tab="Sửa Hạng mục Bị báo cáo">
                <n-form :model="itemEditForm" label-placement="top" class="space-y-2">
                  <div class="grid grid-cols-2 gap-4">
                    <n-form-item label="Số lượng Kế hoạch (Plan Qty)">
                      <n-input-number v-model:value="itemEditForm.plan_qty" class="w-full" :min="0"/>
                    </n-form-item>
                    <n-form-item label="Số lượng Đã hoàn thành (Done Qty)">
                      <n-input-number v-model:value="itemEditForm.done_qty" class="w-full" :min="0"/>
                    </n-form-item>
                  </div>

                  <template v-if="selectedReport.reported_item?.kind_code === 'LEVELING'">
                    <n-form-item label="Chế độ">
                      <n-select v-model:value="itemEditForm.params.mode" :options="levelingModeOptions" />
                    </n-form-item>
                    <div class="grid grid-cols-2 gap-4">
                      <n-form-item label="Level Bắt đầu">
                        <n-input-number v-model:value="itemEditForm.params.start" class="w-full" :min="1" />
                      </n-form-item>
                      <n-form-item label="Level Kết thúc (Mục tiêu)">
                        <n-input-number v-model:value="itemEditForm.params.end" class="w-full" :min="1" />
                      </n-form-item>
                    </div>
                  </template>

                  <template v-if="selectedReport.reported_item?.kind_code === 'BOSS'">
                    <n-form-item label="Tên Boss">
                      <n-select v-model:value="itemEditForm.params.boss_code" :options="bossDict" filterable />
                    </n-form-item>
                  </template>

                  <template v-if="selectedReport.reported_item?.kind_code === 'THE_PIT'">
                    <n-form-item label="Tier">
                      <n-select v-model:value="itemEditForm.params.tier_code" :options="pitTierDict" filterable />
                    </n-form-item>
                  </template>

                  <template v-if="['MATERIALS', 'MASTERWORKING', 'NIGHTMARE'].includes(selectedReport.reported_item?.kind_code)">
                    <n-form-item label="Loại">
                      <n-select v-model:value="itemEditForm.params.attribute_code" :options="materialDict" filterable />
                    </n-form-item>
                  </template>

                  <template v-if="selectedReport.reported_item?.kind_code === 'MYTHIC'">
                    <n-form-item label="Mythic Item">
                      <n-select v-model:value="itemEditForm.params.item_code" :options="mythicItemDict" filterable />
                    </n-form-item>
                    <n-form-item label="Greater Affix (GA)">
                      <n-select v-model:value="itemEditForm.params.ga_code" :options="mythicGADict" filterable clearable/>
                    </n-form-item>

                    <div v-if="itemEditForm.params.ga_code?.includes('REQUEST')" class="space-y-2 border p-3 rounded-md">
                      <div class="text-sm font-medium">Chỉ số yêu cầu</div>

                      <n-form-item v-if="itemEditForm.params.ga_code.startsWith('1GA')" label="Stat 1">
                        <n-select
                          v-model:value="itemEditForm.params.stats[0]"
                          :options="currentMythicStatOptions.filter((opt: SelectOption) => opt.value === itemEditForm.params.stats[0] || !itemEditForm.params.stats.includes(opt.value))"
                          filterable clearable
                        />
                      </n-form-item>

                      <template v-if="itemEditForm.params.ga_code.startsWith('2GA')">
                        <n-form-item label="Stat 1">
                          <n-select
                            v-model:value="itemEditForm.params.stats[0]"
                            :options="currentMythicStatOptions.filter((opt: SelectOption) => opt.value === itemEditForm.params.stats[0] || !itemEditForm.params.stats.includes(opt.value))"
                            filterable clearable
                          />
                        </n-form-item>
                        <n-form-item label="Stat 2">
                          <n-select
                            v-model:value="itemEditForm.params.stats[1]"
                            :options="currentMythicStatOptions.filter((opt: SelectOption) => opt.value === itemEditForm.params.stats[1] || !itemEditForm.params.stats.includes(opt.value))"
                            filterable clearable :disabled="!itemEditForm.params.stats[0]"
                          />
                        </n-form-item>
                      </template>

                      <template v-if="itemEditForm.params.ga_code.startsWith('3GA')">
                        <n-form-item label="Stat 1">
                          <n-select
                            v-model:value="itemEditForm.params.stats[0]"
                            :options="currentMythicStatOptions.filter((opt: SelectOption) => opt.value === itemEditForm.params.stats[0] || !itemEditForm.params.stats.includes(opt.value))"
                            filterable clearable
                          />
                        </n-form-item>
                        <n-form-item label="Stat 2">
                          <n-select
                            v-model:value="itemEditForm.params.stats[1]"
                            :options="currentMythicStatOptions.filter((opt: SelectOption) => opt.value === itemEditForm.params.stats[1] || !itemEditForm.params.stats.includes(opt.value))"
                            filterable clearable :disabled="!itemEditForm.params.stats[0]"
                          />
                        </n-form-item>
                        <n-form-item label="Stat 3">
                          <n-select
                            v-model:value="itemEditForm.params.stats[2]"
                            :options="currentMythicStatOptions.filter((opt: SelectOption) => opt.value === itemEditForm.params.stats[2] || !itemEditForm.params.stats.includes(opt.value))"
                            filterable clearable :disabled="!itemEditForm.params.stats[1]"
                          />
                        </n-form-item>
                      </template>
                    </div>
                  </template>

                  <n-alert title="Lưu ý" type="warning" class="mt-4">
                    Việc thay đổi các giá trị này sẽ ảnh hưởng trực tiếp đến tiến độ của đơn hàng. Hãy chắc chắn rằng bạn đã nhập đúng.
                  </n-alert>
                  
                  <n-button type="primary" block @click="handleSaveItemChanges" class="mt-4">Lưu thay đổi Hạng mục</n-button>
                </n-form>
              </n-tab-pane>

              <n-tab-pane name="edit-order" tab="Sửa Đơn hàng Chung">
                <n-form :model="editForm" label-placement="top">
                  <n-form-item label="Deadline">
                    <n-date-picker v-model:value="editForm.deadline" type="datetime" clearable class="w-full" />
                  </n-form-item>
                  <n-form-item label="Ghi chú gói">
                    <n-input v-model:value="editForm.package_note" type="textarea" :autosize="{minRows: 2}" />
                  </n-form-item>
                  <n-form-item v-if="selectedReport.service_type === 'Selfplay'" label="Battle Tag">
                    <n-input v-model:value="editForm.btag" />
                  </n-form-item>
                  <template v-if="selectedReport.service_type === 'Pilot'">
                      <n-form-item label="Login ID">
                          <n-input v-model:value="editForm.login_id" />
                      </n-form-item>
                      <n-form-item label="Login Password">
                          <n-input v-model:value="editForm.login_pwd" type="password" show-password-on="mousedown" :input-props="{ autocomplete: 'new-password' }" />
                      </n-form-item>
                  </template>
                  <n-button type="primary" block @click="handleSaveChanges">Lưu thay đổi Đơn hàng</n-button>
                </n-form>
              </n-tab-pane>

              <n-tab-pane name="resolve" tab="Giải quyết">
                 <div class="space-y-4">
                    <p>Sau khi đã chỉnh sửa thông tin đơn hàng (nếu cần), hãy nhập ghi chú giải quyết và đóng báo cáo này.</p>
                    <n-input
                      v-model:value="resolverNotes"
                      type="textarea"
                      placeholder="Nhập ghi chú giải quyết cho Farmer..."
                      :autosize="{minRows: 4}"
                    />
                    <n-button type="success" block @click="handleResolveReport">Đánh dấu đã giải quyết</n-button>
                 </div>
              </n-tab-pane>
            </n-tabs>
          </n-spin>
        </template>
      </n-drawer-content>
    </n-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, h, reactive, computed, watch } from 'vue';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/stores/auth';
import {
  NCard, NButton, NDataTable, NDrawer, NDrawerContent, NSpin,
  NTabs, NTabPane, NDescriptions, NDescriptionsItem, NImage, NImageGroup,
  NSpace, NForm, NFormItem, NInput, NDatePicker, NInputNumber,
  NSelect, NAlert,
  type DataTableColumns, createDiscreteApi, type SelectOption
} from 'naive-ui';

// TYPES
type ReportRow = {
  report_id: string;
  reported_at: string;
  report_status: string;
  report_description: string;
  report_proof_urls: string[];
  reporter_name: string;
  order_line_id: string;
  customer_name: string;
  channel_code: string;
  deadline: string | null;
  package_note: string | null;
  btag: string | null;
  login_id: string | null;
  login_pwd: string | null;
  service_type: string | null;
  reported_item: any;
};

const itemEditForm = reactive({
  plan_qty: null as number | null,
  done_qty: null as number | null,
  params: {} as any
});

const auth = useAuth();

// STATE
const allowed = ref(false);
const loading = ref(false);
const reports = ref<ReportRow[]>([]);
const drawer = reactive({ open: false });
const selectedReport = ref<ReportRow | null>(null);
const resolverNotes = ref('');
const isSubmitting = ref(false);
const editForm = reactive({
  deadline: null as number | null,
  package_note: '',
  btag: '',
  login_id: '',
  login_pwd: ''
});
const attributeMap = ref<Map<string, { name: string; type: string }>>(new Map());
const bossDict = ref<SelectOption[]>([]);
const pitTierDict = ref<SelectOption[]>([]);
const materialDict = ref<SelectOption[]>([]);
const mythicItemDict = ref<SelectOption[]>([]);
const mythicGADict = ref<SelectOption[]>([]);
const itemStatsSortDict = ref<SelectOption[]>([]);
const mythicStatsMap = ref<Map<string, SelectOption[]>>(new Map());
const levelingModeOptions = ref([
  { label: 'Level', value: 'level' },
  { label: 'Paragon', value: 'paragon' }
]);

const { message, dialog } = createDiscreteApi(['message', 'dialog']);

// DATA FETCHING
async function fetchReports() {
  if (!allowed.value) return;
  loading.value = true;
  try {
    const { data, error } = await supabase.rpc('get_service_reports_v1', { p_status: 'new' });
    if (error) throw error;
    reports.value = data || [];
  } catch (e: any) {
    message.error(e.message || 'Không thể tải danh sách báo cáo.');
  } finally {
    loading.value = false;
  }
}

async function loadAttributeMap() {
  try {
    const { data: attributes, error } = await supabase.from('attributes').select('id, code, name, type');
    if (error) throw error;
    if (!attributes) return;

    // Tải tất cả relationships
    const { data: relationships, error: relError } = await supabase
      .from('attribute_relationships')
      .select('parent_attribute_id, child_attribute_id');
    if (relError) throw relError;

    // === Xây dựng các Map hỗ trợ ===
    const attrMapById = new Map(attributes.map(a => [a.id, a]));
    const childrenMap = new Map<string, string[]>();
    for (const rel of relationships!) {
      if (!childrenMap.has(rel.parent_attribute_id)) {
        childrenMap.set(rel.parent_attribute_id, []);
      }
      childrenMap.get(rel.parent_attribute_id)!.push(rel.child_attribute_id);
    }
    
    const newAttrMap = new Map<string, { name: string; type: string }>();
    attributes.forEach(attr => newAttrMap.set(attr.code, { name: attr.name, type: attr.type }));
    attributeMap.value = newAttrMap;

    const toSelectOption = (attr: any) => ({ label: attr.name, value: attr.code });
    const sortFn = (a: SelectOption, b: SelectOption) => String(a.label).localeCompare(String(b.label));
    
    // === Xây dựng các SelectOption cho UI ===
    const groupedOptions: Record<string, SelectOption[]> = {};
    for (const attr of attributes) {
      if (!groupedOptions[attr.type]) groupedOptions[attr.type] = [];
      groupedOptions[attr.type].push(toSelectOption(attr));
    }
    
    bossDict.value = (groupedOptions['BOSS_NAME'] || []).sort(sortFn);
    materialDict.value = (groupedOptions['MATS_NAME'] || []).sort(sortFn);
    mythicItemDict.value = (groupedOptions['MYTHIC_NAME'] || []).sort(sortFn);
    pitTierDict.value = (groupedOptions['TIER_DIFFICULTY'] || []).sort((a,b) => parseInt(String(a.label).match(/\d+/)?.[0] || '0') - parseInt(String(b.label).match(/\d+/)?.[0] || '0'));
    mythicGADict.value = (groupedOptions['MYTHIC_GA_TYPE'] || []).sort(sortFn);
    itemStatsSortDict.value = (groupedOptions['ITEM_STATS_SORT'] || []).sort(sortFn);

    // === XÂY DỰNG MAP QUAN HỆ GIỮA MYTHIC ITEM VÀ STATS ===
    const newMythicStatsMap = new Map<string, SelectOption[]>();
    const mythicNameAttrs = attributes.filter(a => a.type === 'MYTHIC_NAME');
    for (const mythicAttr of mythicNameAttrs) {
      const statIds = childrenMap.get(mythicAttr.id) || [];
      const statsOptions = statIds
        .map(id => attrMapById.get(id))
        .filter(Boolean)
        .map(attr => toSelectOption(attr!));
      newMythicStatsMap.set(mythicAttr.code, statsOptions.sort(sortFn));
    }
    mythicStatsMap.value = newMythicStatsMap;

  } catch (e: any) {
    message.error('Không tải được danh mục attributes: ' + e.message);
  }
}

// METHODS
function openDrawer(row: ReportRow) {
  selectedReport.value = row;
  resolverNotes.value = '';
  
  // Populate general order edit form
  editForm.deadline = row.deadline ? new Date(row.deadline).getTime() : null;
  editForm.package_note = row.package_note || '';
  editForm.btag = row.btag || '';
  editForm.login_id = row.login_id || '';
  editForm.login_pwd = row.login_pwd || '';

  // Populate reported item edit form
  const item = row.reported_item;
  if (item) {
    itemEditForm.plan_qty = item.plan_qty;
    itemEditForm.done_qty = item.done_qty;
    itemEditForm.params = JSON.parse(JSON.stringify(item.params || {}));
    
    // Khởi tạo mảng stats cho Mythic nếu chưa có
    if (item.kind_code === 'MYTHIC' && !itemEditForm.params.stats) {
      itemEditForm.params.stats = [null, null, null];
    }
  }

  drawer.open = true;
}

async function handleSaveChanges() {
  if (!selectedReport.value) return;
  isSubmitting.value = true;
  try {
    const { error } = await supabase.rpc('update_order_details_v1', {
      p_line_id: selectedReport.value.order_line_id,
      p_deadline: editForm.deadline ? new Date(editForm.deadline).toISOString() : null,
      p_package_note: editForm.package_note,
      p_btag: editForm.btag,
      p_login_id: editForm.login_id,
      p_login_pwd: editForm.login_pwd
    });
    if (error) throw error;
    message.success('Đã cập nhật thông tin đơn hàng thành công!');
  } catch (e: any) {
    message.error(e.message || 'Lỗi khi cập nhật đơn hàng.');
  } finally {
    isSubmitting.value = false;
  }
}

const currentMythicStatOptions = computed(() => {
  const itemCode = itemEditForm.params.item_code;
  if (!itemCode) return [];
  return mythicStatsMap.value.get(itemCode) || [];
});

async function handleSaveItemChanges() {
  if (!selectedReport.value?.reported_item?.id) return;
  
  const item = selectedReport.value.reported_item;
  const formParams = itemEditForm.params;

  // Logic đặc biệt cho Mythic: tạo ga_note từ stats đã chọn
  if (item.kind_code === 'MYTHIC' && formParams.ga_code?.includes('REQUEST')) {
    const selectedStats = formParams.stats?.filter(Boolean) || [];
    if (selectedStats.length > 0) {
      formParams.ga_note = selectedStats
        .map((statCode: string) => itemStatsSortDict.value.find(s => s.value === statCode)?.label || statCode)
        .join(', ');
    } else {
      formParams.ga_note = null;
    }
  }

  isSubmitting.value = true;
  try {
    const { error } = await supabase.rpc('correct_reported_item_v1', { // <-- ĐỔI TÊN RPC Ở ĐÂY
      p_service_item_id: selectedReport.value.reported_item.id,
      p_plan_qty: itemEditForm.plan_qty,
      p_done_qty: itemEditForm.done_qty,
      p_params: formParams
    });
    if (error) throw error;
    message.success('Đã cập nhật thông tin hạng mục thành công!');
    await fetchReports(); // Tải lại danh sách để cập nhật
  } catch (e: any) {
    message.error(e.message || 'Lỗi khi cập nhật hạng mục.');
  } finally {
    isSubmitting.value = false;
  }
}

function handleResolveReport() {
  if (!selectedReport.value) return;

  dialog.warning({
    title: 'Xác nhận giải quyết',
    content: 'Bạn có chắc chắn muốn đóng báo cáo này? Thao tác này sẽ gỡ bỏ trạng thái báo cáo khỏi hạng mục.',
    positiveText: 'Chắc chắn',
    negativeText: 'Huỷ',
    onPositiveClick: async () => {
      isSubmitting.value = true;
      try {
        const { error } = await supabase.rpc('resolve_service_report_v1', {
          p_report_id: selectedReport.value!.report_id,
          p_resolver_notes: resolverNotes.value
        });
        if (error) throw error;
        message.success('Đã giải quyết báo cáo!');
        drawer.open = false;
        await fetchReports(); // Refresh the list
      } catch (e: any) {
        message.error(e.message || 'Lỗi khi giải quyết báo cáo.');
      } finally {
        isSubmitting.value = false;
      }
    }
  });
}

// Helper to display item label (can be copied from ServiceBoosting)
function paramsLabel(it: any): string {
  const k = (it.kind_code || '').toUpperCase();
  const p = it.params || {};
  const getName = (code: string) => attributeMap.value.get(code)?.name || code;
  let mainLabel = '';

  switch (k) {
    case 'LEVELING': mainLabel = `${p.mode === 'paragon' ? 'Paragon' : 'Level'} ${p.start}→${p.end}`; break;
    case 'BOSS': mainLabel = `${p.boss_label || getName(p.boss_code)}`; break;
    case 'THE_PIT': mainLabel = `${p.tier_label || getName(p.tier_code)}`; break;
    case 'MATERIALS': mainLabel = `${getName(p.attribute_code)}`; break;
    case 'MYTHIC': mainLabel = `${p.item_label || getName(p.item_code)}`; break;
    case 'GENERIC': mainLabel = (p.desc || p.note || 'Generic'); break;
    default: mainLabel = JSON.stringify(p); break;
  }
  return mainLabel;
}

// TABLE COLUMNS
const columns: DataTableColumns<ReportRow> = [
  { title: 'Thời gian', key: 'reported_at', render: (row) => new Date(row.reported_at).toLocaleString() },
  { title: 'Người báo cáo', key: 'reporter_name' },
  { title: 'Khách hàng', key: 'customer_name' },
  { title: 'Hạng mục', key: 'reported_item', render: (row) => h('code', paramsLabel(row.reported_item)) },
  {
    title: 'Hành động',
    key: 'actions',
    render: (row) => h(NButton, { size: 'small', onClick: () => openDrawer(row) }, { default: () => 'Xem & Xử lý' })
  }
];

// LIFECYCLE
onMounted(() => {
  let unwatch: () => void;
  unwatch = watch(() => auth.loading, (isLoading) => {
    if (!isLoading) {
      // Sử dụng hệ thống phân quyền mới
      allowed.value = auth.hasPermission('reports:view');
      if (allowed.value) {
        Promise.all([
            fetchReports(),
            loadAttributeMap()
        ]);
      }
      // Ngừng theo dõi sau khi kiểm tra lần đầu
      if (unwatch) {
        unwatch();
      }
    }
  }, { immediate: true });
});

</script>