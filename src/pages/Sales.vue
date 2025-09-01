<!-- path: src/pages/Sales.vue -->
<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold tracking-tight">Bán hàng</h1>

      <div class="flex items-center gap-2">
        <button :class="btnClass('currency')" @click="mode = 'currency'">Currency</button>
        <button :class="btnClass('items')"    @click="mode = 'items'">Items</button>
        <button :class="btnClass('service')"  @click="mode = 'service'">Service</button>
      </div>
    </div>

    <n-card :bordered="false" class="shadow-sm">
      <template v-if="mode !== 'service'">
        <n-alert type="info" title="Đang phát triển">
          Tạm thời sử dụng tab <b>Service</b> để tạo đơn.
        </n-alert>
      </template>

      <template v-else>
        <n-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-placement="top"
          size="large"
          class="space-y-2"
          :show-require-mark="true"
        >
          <n-divider title-placement="center">Bán Service - Boosting</n-divider>

          <!-- Loại hình dịch vụ -->
          <n-form-item path="service_type">
            <template #label><span :id="lid('service_type')">Loại hình dịch vụ</span></template>
            <n-radio-group
              v-model:value="form.service_type"
              name="service_type"
              size="large"
              class="service-type"
              :aria-labelledby="lid('service_type')"
            >
              <n-radio-button value="selfplay">Selfplay</n-radio-button>
              <n-radio-button value="pilot">Pilot</n-radio-button>
            </n-radio-group>
          </n-form-item>

          <!-- Nguồn bán -->
          <n-form-item path="channel_code">
            <template #label><span :id="lid('channel')">Nguồn bán</span></template>
            <n-auto-complete
              v-model:value="form.channel_code"
              :options="channelACOptions"
              placeholder="Chọn hoặc gõ rồi Enter để thêm (≥ 3 ký tự)"
              :get-show="() => acOpen.channel"
              :input-props="acInputProps('channel','channel','channel', lid('channel'))"
              class="w-full"
              @focus="() => { acOpen.channel = true; ensureChannels(); }"
              @blur="() => acOpen.channel = false"
              @update:value="(v:string)=> (search.channel = v)"
            />
          </n-form-item>

          <!-- Tên khách hàng -->
          <n-form-item path="customer_name">
            <template #label><span :id="lid('customer_name')">Tên khách hàng</span></template>
            <n-auto-complete
              v-model:value="form.customer_name"
              :options="customerACOptions"
              placeholder="Chọn hoặc gõ rồi Enter để thêm (≥ 3 ký tự)"
              :get-show="() => acOpen.customer"
              :input-props="acInputProps('customer','customer_name','customer_name', lid('customer_name'))"
              class="w-full"
              @focus="() => {
                acOpen.customer = true;
                form.channel_code ? ensureCustomersForChannel() : loadAllCustomers();
              }"
              @blur="() => acOpen.customer = false"
              @update:value="(v:string)=> (search.customer = v)"
            />
          </n-form-item>

          <!-- Btag / ID + Pwd -->
          <template v-if="form.service_type === 'selfplay'">
            <n-form-item path="btag">
              <template #label><span :id="lid('btag')">Btag (selfplay)</span></template>
              <n-auto-complete
                v-model:value="form.btag"
                :options="btagACOptions"
                placeholder="VD: Player#1234 (lọc theo chuỗi con)"
                :get-show="() => acOpen.btag"
                :input-props="acInputProps('btag','btag','btag', lid('btag'))"
                class="w-full"
                @focus="() => { acOpen.btag = true; ensureBtgsForCustomer(); }"
                @blur="() => acOpen.btag = false"
                @update:value="(v:string)=> (search.btag = v)"
              />
            </n-form-item>
          </template>
          <template v-else>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <n-form-item path="login_id">
                <template #label><span :id="lid('login_id')">ID đăng nhập (pilot)</span></template>
                <n-input
                  v-model:value="form.login_id"
                  placeholder="Login ID"
                  :input-props="{ id: fid('login_id'), name: 'login_id', autocomplete: 'username', 'aria-labelledby': lid('login_id') }"
                />
              </n-form-item>
              <n-form-item path="login_pwd">
                <template #label><span :id="lid('login_pwd')">Mật khẩu (pilot)</span></template>
                <n-input
                  v-model:value="form.login_pwd"
                  type="password"
                  show-password-on="mousedown"
                  placeholder="********"
                  :input-props="{ id: fid('login_pwd'), name: 'login_pwd', autocomplete: 'current-password', 'aria-labelledby': lid('login_pwd') }"
                />
              </n-form-item>
            </div>
          </template>

          <!-- GÓI DỊCH VỤ -->
          <n-form-item>
            <template #label><span :id="lid('pkg')">Gói dịch vụ</span></template>
            <div class="space-y-2 w-full">
              <n-radio-group
                v-model:value="form.package_type"
                name="package_type"
                size="large"
                :aria-labelledby="lid('pkg')"
                class="service-type"
              >
                <n-radio-button value="BASIC">Basic</n-radio-button>
                <n-radio-button value="CUSTOM">Custom</n-radio-button>
                <n-radio-button value="BUILD">Build service</n-radio-button>
              </n-radio-group>

              <!-- ghi chú cho gói hiện tại -->
              <n-input
                v-model:value="form.package_note"
                type="textarea"
                :autosize="{minRows:2, maxRows:4}"
                placeholder="Mô tả/ghi chú cho gói hiện tại"
                :input-props="{ id: fid('package_note'), name: 'package_note', 'aria-labelledby': lid('pkg') }"
              />
            </div>
          </n-form-item>

          <!-- ========== DỊCH VỤ ========== -->
          <n-form-item>
            <template #label><span :id="lid('svc')">Dịch vụ</span></template>
            <div class="space-y-3 w-full">
              <n-checkbox-group v-model:value="svc.selected" :max="16">
                <div class="flex flex-wrap gap-3">
                  <n-checkbox value="GENERIC">Generic</n-checkbox>
                  <n-checkbox value="LEVELING">Leveling / Paragon</n-checkbox>
                  <n-checkbox value="BOSS">Boss</n-checkbox>
                  <n-checkbox value="PIT">The Pit</n-checkbox>
                  <n-checkbox value="MATERIAL">Materials</n-checkbox>
                  <n-checkbox value="MYTHIC">Mythic</n-checkbox>
                  <n-checkbox value="MASTERWORKING">Masterworking</n-checkbox>
                  <n-checkbox value="ALTARS">Altars of Lilith</n-checkbox>
                  <n-checkbox value="RENOWN">Renown</n-checkbox>
                  <n-checkbox value="NIGHTMARE">Nightmare</n-checkbox>
                </div>
              </n-checkbox-group>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <!-- Generic -->
                <div v-if="svc.selected.includes('GENERIC')">
                  <div class="text-sm font-medium mb-1">Generic</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.generic.offers" :key="'g-'+i" class="flex items-center gap-2">
                      <n-input v-model:value="row.desc" placeholder="Mô tả ngắn" />
                      <n-button size="tiny" tertiary @click="removeGeneric(i)" :disabled="svc.generic.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addGeneric()">Thêm offer</n-button>
                  </div>
                </div>

                <!-- Leveling -->
                <div v-if="svc.selected.includes('LEVELING')">
                  <div class="text-sm font-medium mb-1">Leveling / Paragon</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.leveling.offers" :key="'lv-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.kind" :options="levelKinds" style="width:140px" />
                      <n-input-number v-model:value="row.start" placeholder="Start" style="width:110px"/>
                      <span>→</span>
                      <n-input-number v-model:value="row.end" placeholder="End" style="width:110px"/>
                      <n-button size="tiny" tertiary @click="removeLv(i)" :disabled="svc.leveling.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addLv()">Thêm offer</n-button>
                  </div>
                </div>

                <!-- Boss -->
                <div v-if="svc.selected.includes('BOSS')">
                  <div class="text-sm font-medium mb-1">Boss</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.boss.offers" :key="'boss-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.code" :options="bossDict" filterable placeholder="Chọn boss" style="width:220px"/>
                      <n-input-number v-model:value="row.runs" :min="1" placeholder="Số lần" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="removeBoss(i)" :disabled="svc.boss.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addBoss()">Thêm offer</n-button>
                  </div>
                </div>

                <!-- The Pit -->
                <div v-if="svc.selected.includes('PIT')">
                  <div class="text-sm font-medium mb-1">The Pit</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.pit.offers" :key="'pit-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.tier" :options="pitTierDict" filterable placeholder="Tier" style="width:160px"/>
                      <n-input-number v-model:value="row.runs" :min="1" placeholder="Số lần" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="removePit(i)" :disabled="svc.pit.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addPit()">Thêm offer</n-button>
                  </div>
                </div>

                <!-- Materials -->
                <div v-if="svc.selected.includes('MATERIAL')">
                  <div class="text-sm font-medium mb-1">Materials</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.materials.offers" :key="'mat-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.code" :options="materialDict" placeholder="Chọn material" style="width:260px"/>
                      <n-input-number v-model:value="row.qty" :min="1" placeholder="Qty" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="removeMat(i)" :disabled="svc.materials.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addMat()">Thêm offer</n-button>
                  </div>
                </div>

                <!-- Mythic -->
                <div v-if="svc.selected.includes('MYTHIC')">
                  <div class="text-sm font-medium mb-1">Mythic</div>
                  <div class="space-y-2">
                    <div v-for="(row, i) in svc.mythic.offers" :key="'myth-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.item" :options="mythicItemDict" filterable placeholder="Mythic item" style="width:280px"/>
                      <n-select v-model:value="row.ga"   :options="mythicGADict"   placeholder="GA"          style="width:180px"/>
                      <n-input
                        v-if="isGARequest(row.ga)"
                        v-model:value="row.ga_note"
                        placeholder="Tên GA (Request)"
                        style="width:220px"
                      />
                      <n-input-number v-model:value="row.qty" :min="1" placeholder="Qty" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="removeMyth(i)" :disabled="svc.mythic.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addMyth()">Thêm offer</n-button>
                  </div>
                </div>

                <!-- Masterworking -->
                <div v-if="svc.selected.includes('MASTERWORKING')">
                  <div class="text-sm font-medium mb-1">Masterworking</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.masterwork.offers" :key="'mw-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.code" :options="masterworkDict" placeholder="Loại" style="width:200px"/>
                      <n-input-number v-model:value="row.qty" :min="1" placeholder="Qty" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="removeMw(i)" :disabled="svc.masterwork.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addMw()">Thêm offer</n-button>
                  </div>
                </div>

                <!-- Altars -->
                <div v-if="svc.selected.includes('ALTARS')">
                  <div class="text-sm font-medium mb-1">Altars of Lilith</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.altars" :key="'alt-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.region" :options="altarDict" placeholder="Vùng" style="width:200px"/>
                      <n-input-number v-model:value="row.qty" :min="1" placeholder="Qty" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="svc.altars.splice(i,1)" :disabled="svc.altars.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="svc.altars.push({region:'',qty:1})">Thêm vùng</n-button>
                  </div>
                </div>

                <!-- Renown -->
                <div v-if="svc.selected.includes('RENOWN')">
                  <div class="text-sm font-medium mb-1">Renown</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.renown" :key="'ren-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.region" :options="renownDict" placeholder="Vùng" style="width:200px"/>
                      <n-input-number v-model:value="row.qty" :min="1" placeholder="Qty" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="svc.renown.splice(i,1)" :disabled="svc.renown.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="svc.renown.push({region:'',qty:1})">Thêm vùng</n-button>
                  </div>
                </div>

                <!-- Nightmare -->
                <div v-if="svc.selected.includes('NIGHTMARE')">
                  <div class="text-sm font-medium mb-1">Nightmare</div>
                  <div class="space-y-2">
                    <div v-for="(row,i) in svc.nightmare.offers" :key="'nm-'+i" class="flex items-center gap-2">
                      <n-select v-model:value="row.tier" :options="nmTierDict" placeholder="Tier" style="width:160px"/>
                      <n-input-number v-model:value="row.qty" :min="1" placeholder="Qty" style="width:120px"/>
                      <n-button size="tiny" tertiary @click="removeNm(i)" :disabled="svc.nightmare.offers.length===1">Xoá</n-button>
                    </div>
                    <n-button size="tiny" tertiary @click="addNm()">Thêm offer</n-button>
                  </div>
                </div>
              </div>
            </div>
          </n-form-item>
          <!-- ========== /DỊCH VỤ ========== -->

          <n-form-item path="price">
            <template #label><span :id="lid('price')">Giá bán</span></template>
            <n-input-number
              v-model:value="form.price"
              class="price-field w-full"
              :min="0"
              :precision="pricePrecision"
              :show-button="false"
              :format="formatPrice"
              :parse="parsePrice"
              placeholder="Nhập giá"
              :input-props="{ id: fid('price'), name: 'price', inputmode: 'decimal', autocomplete: 'off', 'aria-labelledby': lid('price') }"
            >
              <template #suffix>
                <div class="currency-suffix currency-suffix--fixed" @focus="ensureCurrencies">
                  <n-auto-complete
                    v-model:value="form.currency"
                    :options="currencyACOptions"
                    :get-show="() => acOpen.currency"
                    :bordered="false"
                    :input-props="acInputProps('currency','currency','currency', lid('price'))"
                    class="currency-input"
                    @focus="() => { acOpen.currency = true; ensureCurrencies(); }"
                    @blur="() => acOpen.currency = false"
                    @update:value="(v:string)=> (search.currency = v.toUpperCase())"
                  />
                </div>
              </template>
            </n-input-number>
          </n-form-item>

          <n-form-item path="deadline">
            <template #label><span :id="lid('deadline')">Deadline</span></template>
            <n-date-picker
              v-model:value="form.deadline"
              type="datetime"
              clearable
              placeholder="Chọn hạn chót"
              class="w-full"
              :input-props="{ id: fid('deadline'), name: 'deadline', 'aria-labelledby': lid('deadline') }"
            />
          </n-form-item>

          <div class="flex justify-end gap-2 pt-2">
            <n-button :loading="saving" @click="resetForm">Làm mới</n-button>
            <n-button type="primary" :loading="saving" @click="submit">Lưu đơn</n-button>
          </div>
        </n-form>
      </template>
    </n-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, reactive, computed, nextTick } from 'vue'
import {
  NCard, NAlert, NForm, NFormItem, NInput, NDatePicker, NButton, NDivider,
  NRadioGroup, NRadioButton, NAutoComplete, NInputNumber,
  NCheckbox, NCheckboxGroup, NSelect,
  type FormInst, type FormRules, createDiscreteApi, type SelectOption
} from 'naive-ui'
import { supabase } from '@/lib/supabase'
import { createServiceOrder } from '@/lib/orders'
import type { CoreForm, SubServiceRow } from '@/types/service'
import { makeLabelMapsFromOptions, type LabelMaps, mapRowsToRpcItems } from '@/lib/service-desc'

/* ===== Tabs ===== */
type Mode = 'currency' | 'items' | 'service'
const mode = ref<Mode>('service')
const baseBtn = 'px-3 py-1.5 rounded-md text-sm transition bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
const activeBtn = 'bg-neutral-900 text-white'
const btnClass = (m: Mode) => (mode.value === m ? `${baseBtn} ${activeBtn}` : baseBtn)

const { message } = createDiscreteApi(['message'])

/* ===== Model ===== */
const formRef = ref<FormInst | null>(null)
type ServiceType = 'selfplay' | 'pilot'
type PackageType = 'BASIC' | 'CUSTOM' | 'BUILD'
interface ServiceForm {
  channel_code: string
  service_type: ServiceType
  customer_name: string
  btag: string
  login_id: string
  login_pwd: string
  deadline: number | null
  price: number | null
  currency: string
  package_type: PackageType
  package_note: string
}
const form = ref<ServiceForm>({
  channel_code: '',
  service_type: 'selfplay',
  customer_name: '',
  btag: '',
  login_id: '',
  login_pwd: '',
  deadline: null,
  price: null,
  currency: 'USD',
  package_type: 'BASIC',
  package_note: ''
})

/* ===== Service builder ===== */
const levelKinds = [
  { label: 'Level', value: 'LEVEL' },
  { label: 'Paragon', value: 'PARAGON' }
]

const svc = reactive({
  selected: [] as string[],
  generic: { offers: [{ desc: '' }] },
  leveling: { offers: [{ kind: 'LEVEL' as 'LEVEL'|'PARAGON', start: 1 as number | null, end: 60 as number | null }] },
  boss: { offers: [{ code: '' as string, runs: 1 as number | null }] },
  pit:  { offers: [{ tier: '' as string, runs: 1 as number | null }] },
  materials: { offers: [{ code: '' as string, qty: 1 as number | null }] },
  mythic: { offers: [{ item: '' as string, ga: '' as string, ga_note: '' as string, qty: 1 as number | null }] },
  masterwork: { offers: [{ code: '' as string, qty: 1 as number | null }] },
  altars: [{ region: '', qty: 1 as number | null }],
  renown: [{ region: '', qty: 1 as number | null }],
  nightmare: { offers: [{ tier: '' as string, qty: 1 as number | null }] }
})

/* ===== Validation ===== */
const rules: FormRules = {
  channel_code: [{ required: true, message: 'Chọn/nhập nguồn bán', trigger: ['blur', 'change'] }],
  service_type: [{ required: true, message: 'Chọn loại dịch vụ', trigger: ['blur', 'change'] }],
  customer_name: [{ required: true, message: 'Chọn/nhập khách hàng', trigger: ['blur', 'change'] }],
  btag: [{
    validator: (_r, v) => form.value.service_type === 'selfplay' ? !!String(v || '').trim() : true,
    message: 'Nhập Btag cho selfplay', trigger: ['blur', 'input', 'change']
  }],
  login_id: [{
    validator: (_r, v) => form.value.service_type === 'pilot' ? !!String(v || '').trim() : true,
    message: 'Nhập ID đăng nhập cho pilot', trigger: ['blur', 'input', 'change']
  }],
  login_pwd: [{
    validator: (_r, v) => form.value.service_type === 'pilot' ? !!String(v || '').trim() : true,
    message: 'Nhập mật khẩu cho pilot', trigger: ['blur', 'input', 'change']
  }],
  price: [{
    validator: (_r, v) => v !== null && v !== undefined && !Number.isNaN(Number(v)) && Number(v) >= 0,
    message: 'Nhập giá bán hợp lệ', trigger: ['blur', 'change', 'input']
  }],
  currency: [{ required: true, message: 'Chọn tiền tệ', trigger: ['blur', 'change'] }]
}

/* ===== Options + search ===== */
type Opt = SelectOption & { _db?: boolean }
const channelOptions  = ref<Opt[]>([])
const customerOptions = ref<Opt[]>([])
const currencyOptions = ref<Opt[]>([])
const btagOptions     = ref<Opt[]>([])
const acOpen = reactive({ channel: false, customer: false, currency: false, btag: false })
const search = reactive({ channel: '', customer: '', currency: '', btag: '' })

function filterAC(list: Opt[], kw: string) {
  const s = (kw || '').toLowerCase()
  const arr = list.map(o => String(o.value))
  if (!s) return arr
  return arr.filter(v => v.toLowerCase().includes(s))
}
const channelACOptions  = computed(() => filterAC(channelOptions.value,  search.channel))
const currencyACOptions = computed(() => filterAC(currencyOptions.value, search.currency))
const btagACOptions     = computed(() => filterAC(btagOptions.value,     search.btag))

const customersByChannel = ref<Record<string, Opt[]>>({})
const customerACOptions = computed(() => {
  const ch = (form.value.channel_code || '').trim()
  const baseList = ch && customersByChannel.value[ch]?.length
    ? customersByChannel.value[ch]
    : customerOptions.value
  return filterAC(baseList, search.customer)
})

/* tải data cơ bản */
const hasLoadedChannels   = ref(false)
const hasLoadedCurrencies = ref(false)
const hasLoadedBtgsForCus = ref<string>('')

async function loadChannels() {
  const { data, error } = await supabase.from('channels').select('code').order('code')
  if (error) { console.error('channels/select', error); return message.error('Không tải được Nguồn bán: ' + error.message) }
  channelOptions.value = (data ?? []).map((r: any) => ({ label: r.code, value: r.code, _db: true }))
  hasLoadedChannels.value = true
}
async function loadAllCustomers() {
  const { data, error } = await supabase.from('parties').select('name').eq('type', 'customer').order('name')
  if (error) { console.error('parties/select', error); return message.error('Không tải được Khách hàng: ' + error.message) }
  customerOptions.value = (data ?? []).map((r: any) => ({ label: r.name, value: r.name, _db: true }))
}
async function loadCustomersForChannel(code: string) {
  if (!code) return
  if (customersByChannel.value[code]) return
  try {
    // Đọc từ view để tránh phụ thuộc FK/relationship
    const { data, error } = await supabase
      .from('orders_sales_v1')
      .select('customer_name, created_at')
      .eq('channel_code', code)
      .order('created_at', { ascending: false })
      .limit(2000)

    if (error) throw error

    const names = Array.from(
      new Set((data ?? []).map((r: any) => r.customer_name).filter(Boolean))
    )
    customersByChannel.value[code] = names.map((n: string) => ({ label: n, value: n, _db: true }))
  } catch (e) {
    console.error('[loadCustomersForChannel]', e)
  }
}
async function loadCurrencies() {
  const { data, error } = await supabase.from('currencies').select('code').order('code')
  if (error) { console.error('currencies/select', error); return message.error('Không tải được Tiền tệ: ' + error.message) }
  currencyOptions.value = (data ?? []).map((r: any) => ({ label: r.code, value: r.code, _db: true }))
  hasLoadedCurrencies.value = true
}
async function ensureBtgsForCustomer() {
  const name = (form.value.customer_name || '').trim()
  if (!name) { btagOptions.value = []; return }
  if (hasLoadedBtgsForCus.value === name) return
  const { data, error } = await supabase.from('parties')
    .select('btag').eq('type','customer').eq('name', name).not('btag','is',null).order('btag')
  if (error) { console.error('btag/select', error); return message.error('Không tải được Btag: ' + error.message) }
  const uniq = Array.from(new Set((data ?? []).map((r:any)=>r.btag))).filter(Boolean)
  btagOptions.value = uniq.map((b:string)=>({ label:b, value:b, _db:true }))
  hasLoadedBtgsForCus.value = name
}
function ensureChannels()   { if (!hasLoadedChannels.value)   loadChannels() }
function ensureCurrencies() { if (!hasLoadedCurrencies.value) loadCurrencies() }
function ensureChannelOption(code: string) {
  if (!code) return
  const exists = channelOptions.value.some(o => String(o.value) === code)
  if (!exists) channelOptions.value.push({ label: code, value: code, _db: true })
}
function ensureCustomersForChannel() {
  const code = (form.value.channel_code || '').trim()
  if (code) loadCustomersForChannel(code)
}

/* ===== Service dictionary (label-first) ===== */
const bossDict        = ref<SelectOption[]>([])
const pitTierDict     = ref<SelectOption[]>([])
const materialDict    = ref<Array<{ value: string; label: string }>>([])
const masterworkDict  = ref<SelectOption[]>([])
const altarDict       = ref<SelectOption[]>([])
const renownDict      = ref<SelectOption[]>([])
const nmTierDict      = ref<SelectOption[]>([])
const mythicItemDict  = ref<SelectOption[]>([])
const mythicGADict    = ref<SelectOption[]>([])

async function loadServiceDict() {
  try {
    const pick = async (kind: string) =>
      (await supabase.from('service_dict').select('code,label').eq('kind', kind).eq('active', true).order('sort')).data ?? []
    const [bosses, pits, mats, mws, altars, renowns, nms, mythItems, mythGAs] = await Promise.all([
      pick('BOSS'), pick('PIT'), pick('MATERIAL'), pick('MASTERWORKING'),
      pick('ALTARS'), pick('RENOWN'), pick('NIGHTMARE'),
      pick('MYTHIC_ITEM'), pick('MYTHIC_GA')
    ])
    const map = (arr:any[]) => arr.map((r:any)=>({ value: r.code, label: r.label }))
    bossDict.value        = map(bosses)
    pitTierDict.value     = map(pits)
    materialDict.value    = mats.map((r:any)=>({ value: r.code, label: r.label }))
    masterworkDict.value  = map(mws)
    altarDict.value       = map(altars)
    renownDict.value      = map(renowns)
    nmTierDict.value      = map(nms)
    mythicItemDict.value  = map(mythItems)
    mythicGADict.value    = map(mythGAs)
  } catch (e:any) {
    console.error('[loadServiceDict]', e)
    message.error('Không tải được danh mục dịch vụ')
  }
}

/* ===== Helpers (AC thêm nhanh) ===== */
function normalize(s: string) { return (s || '').trim() }
function exists(list: Opt[], val: string) {
  const v = val.toLowerCase()
  return list.some(o => String(o.value).toLowerCase() === v)
}
const fid = (s: string) => `sales-${s}`
const lid = (s: string) => `${fid(s)}-label`

type CreateKind = 'channel' | 'customer' | 'currency' | 'btag'
const MIN_CHAN_CUST = 3
function acInputProps(kind: CreateKind, idBase: string, name: string, ariaId: string) {
  const ac = kind === 'customer' ? 'name' : 'off'
  return {
    id: fid(idBase), name, autocomplete: ac, 'aria-labelledby': ariaId,
    ...(kind === 'currency' ? { maxlength: 3, style: 'text-transform: uppercase; text-align:center;' } : {}),
    onKeydown: (e: KeyboardEvent) => {
      if (e.key === 'Enter') { e.preventDefault(); e.stopPropagation(); commitCreate(kind) }
    }
  } as Record<string, any>
}
function commitCreate(kind: CreateKind) {
  const raw = normalize(
    kind === 'channel'  ? (search.channel || form.value.channel_code)
  : kind === 'customer' ? (search.customer || form.value.customer_name)
  : kind === 'btag'     ? (search.btag || form.value.btag)
  :                       (search.currency || form.value.currency).toUpperCase()
  )
  if (!raw) return
  const list = kind === 'channel' ? channelOptions.value
            : kind === 'customer' ? customerOptions.value
            : kind === 'btag'     ? btagOptions.value
            : currencyOptions.value

  if (kind === 'currency') {
    if (!/^[A-Z]{3}$/.test(raw)) { message.warning('Tiền tệ phải đúng 3 ký tự A–Z (VD: USD, VND)'); return }
  } else if (kind !== 'btag' && raw.length < MIN_CHAN_CUST) {
    message.warning(`Nhập tối thiểu ${MIN_CHAN_CUST} ký tự rồi Enter`)
    return
  }

  if (!exists(list, raw)) list.push({ label: raw, value: raw, _db: false })
  if (kind === 'channel')  form.value.channel_code  = raw
  if (kind === 'customer') form.value.customer_name = raw
  if (kind === 'btag')     form.value.btag          = raw
  if (kind === 'currency') form.value.currency      = raw
}

/* ===== Auto behaviors ===== */
watch(() => form.value.customer_name, async (val) => {
  const v = normalize(val)
  if (!v) return
  try {
    const { data: party, error } = await supabase
      .from('parties').select('id, btag, login_id, login_pwd')
      .eq('type', 'customer').eq('name', v).maybeSingle()
    if (error) throw error
    if (party) {
      if (form.value.service_type === 'selfplay') form.value.btag = party.btag || ''
      else { form.value.login_id = party.login_id || ''; form.value.login_pwd = party.login_pwd || '' }

      if (!String(form.value.channel_code || '').trim() && party.id) {
        try {
          const { data: ord, error: e2 } = await supabase
            .from('orders')
            .select('id, created_at, channels(code)')
            .eq('counterparty_id', party.id)
            .order('created_at', { ascending: false })
            .limit(1)
          if (e2) throw e2
          const ch = (ord?.[0] ?? {}) as any
          const chan = (ch.channels ?? null) as any
          const code: string | undefined = Array.isArray(chan) ? chan[0]?.code : chan?.code
          if (typeof code === 'string' && code.trim()) {
            ensureChannelOption(code)
            form.value.channel_code = code
            await loadCustomersForChannel(code)
          }
        } catch (e) { console.error('[autoPickChannelForCustomer]', e) }
      }

      await nextTick(); formRef.value?.restoreValidation?.()
    }
  } catch (e:any) { console.error(e) }
})
watch(() => form.value.service_type, () => { formRef.value?.restoreValidation?.() })
watch(() => form.value.channel_code, (code) => { if (code) loadCustomersForChannel(code) })

/* ===== Giá ===== */
const pricePrecision = computed(() => (form.value.currency === 'VND' ? 0 : 2))
const formatPrice = (value: number | null) => {
  if (value == null || Number.isNaN(value)) return ''
  return new Intl.NumberFormat('en-US', { minimumFractionDigits: pricePrecision.value, maximumFractionDigits: pricePrecision.value }).format(Number(value))
}
const parsePrice = (input: string) => {
  if (!input) return null
  const n = Number(input.replace(/[,\s]/g, ''))
  return Number.isNaN(n) ? null : n
}

/* ===== Add/Remove helpers ===== */
function addGeneric() { svc.generic.offers.push({ desc:'' }) }
function removeGeneric(i:number) { svc.generic.offers.splice(i,1) }
function addLv() { svc.leveling.offers.push({ kind:'LEVEL', start:1, end:60 }) }
function removeLv(i:number) { svc.leveling.offers.splice(i,1) }
function addBoss() { svc.boss.offers.push({ code:'', runs:1 }) }
function removeBoss(i:number) { svc.boss.offers.splice(i,1) }
function addPit() { svc.pit.offers.push({ tier:'', runs:1 }) }
function removePit(i:number) { svc.pit.offers.splice(i,1) }
function addMat() { svc.materials.offers.push({ code:'', qty:1 }) }
function removeMat(i:number) { svc.materials.offers.splice(i,1) }
function addMyth() { svc.mythic.offers.push({ item:'', ga:'', ga_note:'', qty:1 }) }
function removeMyth(i:number) { svc.mythic.offers.splice(i,1) }
function addMw() { svc.masterwork.offers.push({ code:'', qty:1 }) }
function removeMw(i:number) { svc.masterwork.offers.splice(i,1) }
function addNm() { svc.nightmare.offers.push({ tier:'', qty:1 }) }
function removeNm(i:number) { svc.nightmare.offers.splice(i,1) }

/* ===== Helper: GA request? ===== */
function isGARequest(v: string) { return /request/i.test(String(v || '')) }

/* ===== Map UI -> SubServiceRow[] ===== */
const parseTierNum = (v: string): number => { const m = String(v || '').match(/\d+/); return m ? parseInt(m[0], 10) : 0 }
function toSubRows(): SubServiceRow[] {
  const rows: SubServiceRow[] = []
  if (svc.selected.includes('GENERIC')) for (const r of svc.generic.offers) { const note = (r.desc || '').trim(); if (note) rows.push({ kind: 'GENERIC', note } as any) }
  if (svc.selected.includes('LEVELING')) for (const r of svc.leveling.offers) if (r.start != null && r.end != null)
    rows.push({ kind:'LEVELING', from:Number(r.start), to:Number(r.end), mode: r.kind === 'PARAGON' ? 'paragon' : 'level' } as any)
  if (svc.selected.includes('BOSS')) for (const r of svc.boss.offers) if (r.code) rows.push({ kind:'BOSS', boss_code:r.code, qty:Number(r.runs || 1) } as any)
  if (svc.selected.includes('PIT')) for (const r of svc.pit.offers) if (r.tier) rows.push({ kind:'PIT', tier:parseTierNum(r.tier), runs:Number(r.runs || 1) } as any)
  if (svc.selected.includes('MATERIAL')) for (const r of svc.materials.offers) { const n = Number(r.qty || 0); if (r.code && n > 0) rows.push({ kind:'MATERIAL', code:r.code, qty:n } as any) }
  if (svc.selected.includes('MYTHIC')) for (const r of svc.mythic.offers) if (r.item)
    rows.push({ kind:'MYTHIC', item_code:r.item, ga_code:r.ga || '', qty:Number(r.qty || 1), ga_note: isGARequest(r.ga) ? (r.ga_note || '').trim() : '' } as any)
  if (svc.selected.includes('MASTERWORKING')) for (const r of svc.masterwork.offers) if (r.code) rows.push({ kind:'MASTERWORKING', variant:(r.code as any), qty:Number(r.qty || 1) } as any)
  if (svc.selected.includes('ALTARS')) for (const r of svc.altars) if (r.region && Number(r.qty || 0) > 0) rows.push({ kind:'ALTARS', region:r.region, qty:Number(r.qty) } as any)
  if (svc.selected.includes('RENOWN')) for (const r of svc.renown) if (r.region && Number(r.qty || 0) > 0) rows.push({ kind:'RENOWN', region:r.region, qty:Number(r.qty) } as any)
  if (svc.selected.includes('NIGHTMARE')) for (const r of svc.nightmare.offers) if (r.tier) rows.push({ kind:'NIGHTMARE', tier:parseTierNum(r.tier) as 1|2|3|4, runs:Number(r.qty || 1) } as any)
  return rows
}

/* ===== Đếm KIND có dữ liệu & auto gói ===== */
function countSelectedKinds(): number {
  let n = 0
  if (svc.selected.includes('GENERIC') && svc.generic.offers.some(r => (r.desc || '').trim())) n++
  if (svc.selected.includes('LEVELING') && svc.leveling.offers.some(r => r.start!=null && r.end!=null)) n++
  if (svc.selected.includes('BOSS') && svc.boss.offers.some(r => r.code)) n++
  if (svc.selected.includes('PIT') && svc.pit.offers.some(r => r.tier)) n++
  if (svc.selected.includes('MATERIAL') && svc.materials.offers.some(r => r.code && (r.qty ?? 0) > 0)) n++
  if (svc.selected.includes('MYTHIC') && svc.mythic.offers.some(r => r.item)) n++
  if (svc.selected.includes('MASTERWORKING') && svc.masterwork.offers.some(r => r.code)) n++
  if (svc.selected.includes('ALTARS') && svc.altars.some(r => r.region && (r.qty ?? 0) > 0)) n++
  if (svc.selected.includes('RENOWN') && svc.renown.some(r => r.region && (r.qty ?? 0) > 0)) n++
  if (svc.selected.includes('NIGHTMARE') && svc.nightmare.offers.some(r => r.tier)) n++
  return n
}
const selectedKindCount = computed(() => countSelectedKinds())
watch(selectedKindCount, (v) => { if (form.value.package_type === 'BASIC' && v >= 2) form.value.package_type = 'CUSTOM' })

/* ===== LabelMaps từ dict ===== */
const asVL = (arr: SelectOption[]) =>
  (arr ?? []).map((o: any) => ({ value: String(o.value ?? ''), label: String(o.label ?? o.value ?? '') }))

const labelMaps = computed<LabelMaps>(() =>
  makeLabelMapsFromOptions({
    BOSS: asVL(bossDict.value),
    PIT: asVL(pitTierDict.value),
    MATERIAL: materialDict.value,            // [{value,label}]
    MASTERWORKING: asVL(masterworkDict.value),
    ALTARS: asVL(altarDict.value),
    RENOWN: asVL(renownDict.value),
    NIGHTMARE: asVL(nmTierDict.value),
    MYTHIC_ITEM: asVL(mythicItemDict.value),
    MYTHIC_GA: asVL(mythicGADict.value)
  })
)

/* ===== Reset ===== */
function resetForm() {
  form.value = {
    channel_code: '', service_type: 'selfplay', customer_name: '', btag: '',
    login_id: '', login_pwd: '', deadline: null, price: null, currency: 'USD',
    package_type: 'BASIC', package_note: ''
  }
  svc.selected = []
  svc.generic.offers = [{ desc: '' }]
  svc.leveling.offers = [{ kind:'LEVEL', start:1, end:60 }]
  svc.boss.offers = [{ code:'', runs:1 }]
  svc.pit.offers = [{ tier:'', runs:1 }]
  svc.materials.offers = [{ code:'', qty:1 }]
  svc.mythic.offers = [{ item:'', ga:'', ga_note:'', qty:1 }]
  svc.masterwork.offers = [{ code:'', qty:1 }]
  svc.altars = [{ region:'', qty:1 }]
  svc.renown = [{ region:'', qty:1 }]
  svc.nightmare.offers = [{ tier:'', qty:1 }]
}

/* ===== Submit ===== */
const saving = ref(false)
async function submit() {
  await formRef.value?.validate()

  const k = countSelectedKinds()
  if ((form.value.package_type === 'CUSTOM' || form.value.package_type === 'BUILD') && k < 2) {
    form.value.package_type = 'BASIC'
  }
  if (k < 1) return message.warning('Chọn ít nhất 1 loại dịch vụ.')

  const rows = toSubRows()

  const coreForm: CoreForm = {
    channel_code: form.value.channel_code || '',
    service_type: form.value.service_type,
    customer_name: form.value.customer_name || '',
    btag: form.value.service_type === 'selfplay' ? (form.value.btag || undefined) : undefined,
    login_id: form.value.service_type === 'pilot' ? (form.value.login_id || undefined) : undefined,
    login_pwd: form.value.service_type === 'pilot' ? (form.value.login_pwd || undefined) : undefined,
    deadline: form.value.deadline ? new Date(form.value.deadline).toISOString() : undefined,
    price: Number(form.value.price ?? 0),
    currency: form.value.currency,
    package_type: form.value.package_type,
    package_note: form.value.package_note?.trim() || undefined
  }

  saving.value = true
  try {
    // ✅ Tạo order + line + sub-items NGAY TRONG RPC
    const { order_id, line_id } = await createServiceOrder(coreForm, rows, labelMaps.value)
    message.success(`Đã lưu đơn #${order_id}`)
    hasLoadedChannels.value = hasLoadedCurrencies.value = false
    ensureChannels(); ensureCurrencies(); loadServiceDict(); loadAllCustomers()
    resetForm()
  } catch (e: any) {
    console.error(e)
    message.error(e?.message || 'Không thể lưu đơn')
  } finally {
    saving.value = false
  }
}

/* mount */
onMounted(() => { ensureChannels(); ensureCurrencies(); loadServiceDict(); loadAllCustomers() })
</script>

<style scoped>
:deep(.n-card) { border-radius: 14px; }

/* Ô giá + currency ở suffix */
.price-field :deep(.n-input-number .n-input__suffix) { padding-right: 0; }
.currency-suffix { display: inline-flex; align-items: center; height: 100%; }
.currency-suffix--fixed { width: 75px; flex: 0 0 75px; }
.currency-input { width: 100% !important; min-width: 0; }
.currency-suffix :deep(.n-input) {
  width: 100% !important; border: none !important; background: transparent !important; box-shadow: none !important;
}
.currency-suffix :deep(.n-input .n-input__border),
.currency-suffix :deep(.n-input .n-input__state-border) { display: none !important; }
.currency-suffix :deep(.n-input__input-el) { text-align: center; padding: 0 4px; }

/* Radio group style */
.service-type { display: inline-flex !important; gap: 12px; align-items: center; }
.service-type :deep(.n-radio-button) {
  min-width: 110px; height: 40px; padding: 0 18px; border-radius: 12px;
  border: 1px solid #e5e7eb !important; background: #fff; transition: all .2s ease;
  display: inline-flex; justify-content: center; align-items: center; box-shadow: none;
}
.service-type :deep(.n-radio-button:hover) { border-color: #cbd5e1; }
.service-type :deep(.n-radio-button--checked),
.service-type :deep(.n-radio-button--checked) {
  background-color: #111827 !important;
  color: #fff !important;
  border-color: #111827 !important;
  box-shadow: 0 6px 14px rgba(17,24,39,.18) !important;
}
.service-type :deep(.n-radio-button--checked .n-radio-button__state-border) {
  border-color: #111827 !important;
}
.service-type :deep(.n-radio-group__splitor){ display:none!important; }
</style>
