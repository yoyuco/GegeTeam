<!-- path: src/pages/Sales.vue -->
<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold tracking-tight">Bán hàng</h1>

      <div class="flex items-center gap-2">
        <button :class="btnClass('currency')" @click="mode = 'currency'">Currency</button>
        <button :class="btnClass('items')" @click="mode = 'items'">Items</button>
        <button :class="btnClass('service')" @click="mode = 'service'">Service</button>
      </div>
    </div>

    <n-card :bordered="false" class="shadow-sm">
      <template v-if="mode !== 'service'">
        <n-alert type="info" title="Đang phát triển">
          Tạm thời sử dụng tab <b>Service</b> để tạo đơn.
        </n-alert>
      </template>

      <template v-else>
        <div v-if="auth.loading" class="text-center p-4 text-neutral-500">
          Đang kiểm tra quyền...
        </div>
        <div v-else-if="!canCreateOrder">
          <n-alert type="error" title="Không có quyền">
            Bạn không có quyền tạo đơn hàng trong khu vực này.
          </n-alert>
        </div>

        <n-form
          v-else
          ref="formRef"
          :model="form"
          :rules="rules"
          label-placement="top"
          size="large"
          class="space-y-2"
          :show-require-mark="true"
        >
          <n-divider title-placement="center">Bán Service - Boosting</n-divider>

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

          <n-form-item path="channel_code">
            <template #label><span :id="lid('channel')">Nguồn bán</span></template>
            <n-auto-complete
              v-model:value="form.channel_code"
              :options="channelACOptions"
              placeholder="Chọn hoặc gõ rồi Enter để thêm (≥ 3 ký tự)"
              :get-show="() => acOpen.channel"
              :input-props="acInputProps('channel', 'channel', 'channel', lid('channel'))"
              class="w-full"
              @focus="
                () => {
                  acOpen.channel = true
                  ensureChannels()
                }
              "
              @blur="() => (acOpen.channel = false)"
              @update:value="(v: string) => (search.channel = v)"
            />
          </n-form-item>

          <n-form-item path="customer_name">
            <template #label><span :id="lid('customer_name')">Tên khách hàng</span></template>
            <n-auto-complete
              v-model:value="form.customer_name"
              :options="customerACOptions"
              placeholder="Chọn hoặc gõ rồi Enter để thêm (≥ 3 ký tự)"
              :get-show="() => acOpen.customer"
              :input-props="
                acInputProps('customer', 'customer_name', 'customer_name', lid('customer_name'))
              "
              class="w-full"
              @focus="
                () => {
                  acOpen.customer = true
                  form.channel_code ? ensureCustomersForChannel() : loadAllCustomers()
                }
              "
              @blur="() => (acOpen.customer = false)"
              @update:value="(v: string) => (search.customer = v)"
            />
          </n-form-item>

          <n-form-item
            v-if="form.customer_name"
            :label="form.service_type === 'selfplay' ? 'Chọn Btag' : 'Chọn Tài khoản Login'"
            path="selectedAccountId"
          >
            <div class="w-full space-y-3">
              <n-select
                v-model:value="form.selectedAccountId"
                filterable
                placeholder="Chọn tài khoản đã lưu hoặc thêm mới..."
                :options="accountOptions"
                :loading="loadingAccounts"
              />

              <div v-if="isAddingNewAccount" class="p-3 border border-neutral-200/60 rounded-lg">
                <div
                  class="grid gap-x-4"
                  :class="form.service_type === 'selfplay' ? 'grid-cols-2' : 'grid-cols-3'"
                >
                  <n-form-item label="Nhãn gợi nhớ" path="newAccount.label" :show-feedback="false">
                    <n-input v-model:value="newAccount.label" placeholder="VD: Acc chính" />
                  </n-form-item>

                  <template v-if="form.service_type === 'selfplay'">
                    <n-form-item label="Btag mới" path="newAccount.btag" :show-feedback="false">
                      <n-input v-model:value="newAccount.btag" placeholder="Player#1234" />
                    </n-form-item>
                  </template>
                  <template v-else>
                    <n-form-item
                      label="Login ID mới"
                      path="newAccount.login_id"
                      :show-feedback="false"
                    >
                      <n-input v-model:value="newAccount.login_id" placeholder="Login ID" />
                    </n-form-item>
                    <n-form-item
                      label="Mật khẩu mới"
                      path="newAccount.login_pwd"
                      :show-feedback="false"
                    >
                      <n-input
                        v-model:value="newAccount.login_pwd"
                        type="password"
                        show-password-on="mousedown"
                        placeholder="••••••"
                      />
                    </n-form-item>
                  </template>
                </div>
              </div>
            </div>
          </n-form-item>

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

              <n-input
                v-model:value="form.package_note"
                type="textarea"
                :autosize="{ minRows: 2, maxRows: 4 }"
                placeholder="Mô tả/ghi chú cho gói hiện tại"
                :input-props="{
                  id: fid('package_note'),
                  name: 'package_note',
                  'aria-labelledby': lid('pkg'),
                }"
              />
            </div>
          </n-form-item>

          <n-form-item>
            <template #label><span :id="lid('svc')">Dịch vụ</span></template>
            <div class="space-y-3 w-full">
              <n-checkbox-group v-model:value="svc.selected" :max="16">
                <div class="flex flex-wrap gap-4">
                  <n-checkbox value="GENERIC" label="Generic" />
                  <n-checkbox value="LEVELING" label="Leveling" />
                  <n-checkbox value="THE_PIT" label="The Pit" />
                  <n-checkbox value="BOSS" label="Boss" />
                  <n-checkbox value="MYTHIC" label="Mythic" />
                  <n-checkbox value="MASTERWORKING" label="Masterworking" />
                  <n-checkbox value="MATERIALS" label="Materials" />
                  <n-checkbox value="INFERNAL_HORDES" label="Infernal Hordes" />
                  <n-checkbox value="NIGHTMARE" label="Nightmare" />
                  <n-checkbox value="RENOWN" label="Renown" />
                  <n-checkbox value="ALTARS_OF_LILITH" label="Altars of Lilith" />
                </div>
              </n-checkbox-group>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div
                  v-if="svc.selected.includes('GENERIC')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Generic</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.generic.offers"
                      :key="'g-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-input
                        v-model:value="row.desc"
                        placeholder="Mô tả ngắn"
                        class="flex-grow"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.generic.offers.length === 1"
                        @click="removeGeneric(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addGeneric()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('LEVELING')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Leveling / Paragon</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.leveling.offers"
                      :key="'lv-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <div class="grid grid-cols-3 gap-3 flex-grow">
                        <n-select v-model:value="row.kind" :options="levelKinds" />
                        <n-input-number
                          v-model:value="row.start"
                          placeholder="Start"
                          :min="1"
                          :max="row.kind === 'PARAGON' ? 300 : 60"
                        />
                        <n-input-number
                          v-model:value="row.end"
                          placeholder="End"
                          :min="1"
                          :max="row.kind === 'PARAGON' ? 300 : 60"
                        />
                      </div>
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.leveling.offers.length === 1"
                        @click="removeLv(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addLv()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('THE_PIT')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">The Pit</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.pit.offers"
                      :key="'pit-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.tier"
                        :options="pitTierDict"
                        filterable
                        placeholder="Tier"
                        style="width: 160px"
                      />
                      <n-input-number
                        v-model:value="row.runs"
                        :min="1"
                        placeholder="Số lần"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.pit.offers.length === 1"
                        @click="removePit(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addPit()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('BOSS')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Boss</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.boss.offers"
                      :key="'boss-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.code"
                        :options="bossDict"
                        filterable
                        placeholder="Chọn boss"
                        style="width: 220px"
                      />
                      <n-input-number
                        v-model:value="row.runs"
                        :min="1"
                        placeholder="Số lần"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.boss.offers.length === 1"
                        @click="removeBoss(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addBoss()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('MYTHIC')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Mythic</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.mythic.offers"
                      :key="'myth-' + i"
                      class="space-y-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <div class="flex items-center gap-2 flex-wrap">
                        <n-select
                          v-model:value="row.item"
                          :options="mythicItemDict"
                          filterable
                          placeholder="Mythic item"
                          style="width: 280px"
                        />
                        <n-select
                          v-model:value="row.ga"
                          :options="mythicGADict"
                          placeholder="GA"
                          style="width: 180px"
                        />
                        <n-input-number
                          v-model:value="row.qty"
                          :min="1"
                          placeholder="Qty"
                          style="width: 120px"
                        />
                        <n-button
                          size="tiny"
                          tertiary
                          :disabled="svc.mythic.offers.length === 1"
                          @click="removeMyth(i)"
                          >Xoá</n-button
                        >
                      </div>
                      <div v-if="getStatCountForGA(row.ga) > 0" class="pl-2 space-y-2">
                        <div class="text-xs text-neutral-500">
                          Chọn đúng {{ getStatCountForGA(row.ga) }} stat(s) yêu cầu
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-2">
                          <n-select
                            v-if="getStatCountForGA(row.ga) >= 1"
                            v-model:value="row.stats[0]"
                            :options="getFilteredStatOptions(i, 0)"
                            filterable
                            clearable
                            placeholder="Stat 1"
                          />
                          <n-select
                            v-if="getStatCountForGA(row.ga) >= 2"
                            v-model:value="row.stats[1]"
                            :options="getFilteredStatOptions(i, 1)"
                            filterable
                            clearable
                            placeholder="Stat 2"
                            :disabled="!row.stats[0]"
                          />
                          <n-select
                            v-if="getStatCountForGA(row.ga) >= 3"
                            v-model:value="row.stats[2]"
                            :options="getFilteredStatOptions(i, 2)"
                            filterable
                            clearable
                            placeholder="Stat 3"
                            :disabled="!row.stats[1]"
                          />
                        </div>
                      </div>
                    </div>
                    <n-button size="tiny" tertiary @click="addMyth()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('MASTERWORKING')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Masterworking</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.masterwork.offers"
                      :key="'mw-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.code"
                        :options="masterworkDict"
                        placeholder="Loại"
                        style="width: 200px"
                      />
                      <n-input-number
                        v-model:value="row.qty"
                        :min="1"
                        placeholder="Qty"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.masterwork.offers.length === 1"
                        @click="removeMw(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addMw()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('MATERIALS')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Materials</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.materials.offers"
                      :key="'mat-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.code"
                        :options="materialDict"
                        filterable
                        placeholder="Loại nguyên liệu"
                        style="width: 200px"
                      />
                      <n-input-number
                        v-model:value="row.qty"
                        :min="1"
                        placeholder="Qty"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.materials.offers.length === 1"
                        @click="removeMat(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addMat()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('INFERNAL_HORDES')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Infernal Hordes</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.infernalHordes.offers"
                      :key="'horde-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.tier"
                        :options="hordesTierDict"
                        filterable
                        placeholder="Độ khó"
                        style="width: 200px"
                      />
                      <n-input-number
                        v-model:value="row.qty"
                        :min="1"
                        placeholder="Qty"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.infernalHordes.offers.length === 1"
                        @click="removeHorde(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addHorde()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('NIGHTMARE')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Nightmare</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.nightmare.offers"
                      :key="'nm-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.tier"
                        :options="nmTierDict"
                        placeholder="Tier"
                        style="width: 160px"
                      />
                      <n-input-number
                        v-model:value="row.qty"
                        :min="1"
                        placeholder="Qty"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.nightmare.offers.length === 1"
                        @click="removeNm(i)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button size="tiny" tertiary @click="addNm()">Thêm offer</n-button>
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('RENOWN')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Renown</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.renown.offers"
                      :key="'ren-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.region"
                        :options="renownDict"
                        placeholder="Vùng"
                        style="width: 200px"
                      />
                      <n-input-number
                        v-model:value="row.qty"
                        :min="1"
                        :max="row.region === 'ALL' ? 6 : 1"
                        :disabled="row.region !== 'ALL' && row.region !== ''"
                        placeholder="Qty"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.renown.offers.length === 1"
                        @click="svc.renown.offers.splice(i, 1)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button
                      size="tiny"
                      tertiary
                      @click="svc.renown.offers.push({ region: '', qty: 1 })"
                      >Thêm offer</n-button
                    >
                  </div>
                </div>

                <div
                  v-if="svc.selected.includes('ALTARS_OF_LILITH')"
                  class="p-3 border border-neutral-200 rounded-lg space-y-2"
                >
                  <div class="text-sm font-medium">Altars of Lilith</div>
                  <div class="space-y-2">
                    <div
                      v-for="(row, i) in svc.altars.offers"
                      :key="'alt-' + i"
                      class="flex items-center gap-2 p-2 rounded-lg border border-neutral-200/60"
                    >
                      <n-select
                        v-model:value="row.region"
                        :options="altarDict"
                        placeholder="Vùng"
                        style="width: 200px"
                      />
                      <n-input-number
                        v-model:value="row.qty"
                        :min="1"
                        :max="row.region === 'ALL' ? 190 : undefined"
                        placeholder="Qty"
                        style="width: 120px"
                      />
                      <n-button
                        size="tiny"
                        tertiary
                        :disabled="svc.altars.offers.length === 1"
                        @click="svc.altars.offers.splice(i, 1)"
                        >Xoá</n-button
                      >
                    </div>
                    <n-button
                      size="tiny"
                      tertiary
                      @click="svc.altars.offers.push({ region: '', qty: 1 })"
                      >Thêm offer</n-button
                    >
                  </div>
                </div>
              </div>
            </div>
          </n-form-item>

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
              :input-props="{
                id: fid('price'),
                name: 'price',
                inputmode: 'decimal',
                autocomplete: 'off',
                'aria-labelledby': lid('price'),
              }"
            >
              <template #suffix>
                <div class="currency-suffix currency-suffix--fixed">
                  <n-auto-complete
                    v-model:value="form.currency"
                    :options="currencyACOptions"
                    :get-show="() => acOpen.currency"
                    :bordered="false"
                    :input-props="acInputProps('currency', 'currency', 'currency', lid('price'))"
                    class="currency-input"
                    @focus="
                      () => {
                        acOpen.currency = true
                        ensureCurrencies()
                      }
                    "
                    @blur="() => (acOpen.currency = false)"
                    @update:value="(v: string) => (search.currency = v.toUpperCase())"
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
              :input-props="{
                id: fid('deadline'),
                name: 'deadline',
                'aria-labelledby': lid('deadline'),
              }"
            />
          </n-form-item>

          <div class="flex justify-end gap-2 pt-2">
            <n-button :loading="saving" @click="resetForm">Làm mới</n-button>
            <n-button type="primary" :loading="saving" :disabled="!canCreateOrder" @click="submit"
              >Lưu đơn</n-button
            >
          </div>
        </n-form>
      </template>
    </n-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, reactive, computed, nextTick } from 'vue'
import {
  NCard,
  NAlert,
  NForm,
  NFormItem,
  NInput,
  NDatePicker,
  NButton,
  NDivider,
  NRadioGroup,
  NRadioButton,
  NAutoComplete,
  NInputNumber,
  NCheckbox,
  NCheckboxGroup,
  NSelect,
  type FormInst,
  type FormRules,
  createDiscreteApi,
  type SelectOption,
} from 'naive-ui'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'
import { makeLabelMapsFromOptions, type LabelMaps } from '@/lib/service-desc'

/* ===== Types ===== */
type OrderWithChannel = {
  channels: { code: string } | { code: string }[] | null
}
type Mode = 'currency' | 'items' | 'service'
type ServiceType = 'selfplay' | 'pilot'
type PackageType = 'BASIC' | 'CUSTOM' | 'BUILD'
interface ServiceForm {
  channel_code: string
  service_type: ServiceType
  customer_name: string
  selectedAccountId: string | null
  deadline: number | null
  price: number | null
  currency: string
  package_type: PackageType
  package_note: string
}
type CustomerAccount = {
  id: string
  label: string
  btag?: string | null
  login_id?: string | null
}
type Opt = SelectOption & { _db?: boolean }
type CreateKind = 'channel' | 'customer' | 'currency'
const MIN_CHAN_CUST = 2

/* ===== State ===== */
const mode = ref<Mode>('service')
const baseBtn =
  'px-3 py-1.5 rounded-md text-sm transition bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
const activeBtn = 'bg-neutral-900 text-white'
const { message } = createDiscreteApi(['message'])
const auth = useAuth()

const canCreateOrder = computed(() => {
  return auth.hasPermission('orders:create', {
    game_code: 'DIABLO_4',
    business_area_code: 'SERVICE',
  })
})

const formRef = ref<FormInst | null>(null)
const form = ref<ServiceForm>({
  channel_code: '',
  service_type: 'selfplay',
  customer_name: '',
  selectedAccountId: null,
  deadline: null,
  price: null,
  currency: 'USD',
  package_type: 'BASIC',
  package_note: '',
})

const customerAccounts = ref<CustomerAccount[]>([])
const loadingAccounts = ref(false)
const ADD_NEW_ACCOUNT = 'add_new_account'
const newAccount = reactive({
  label: '',
  btag: '',
  login_id: '',
  login_pwd: '',
})
const isAddingNewAccount = computed(() => form.value.selectedAccountId === ADD_NEW_ACCOUNT)
const isProgrammaticChange = ref(false) // <-- BIẾN CỜ ĐỂ ĐIỀU PHỐI LOGIC

const levelKinds = [
  { label: 'Level', value: 'LEVEL' },
  { label: 'Paragon', value: 'PARAGON' },
]
const svc = reactive({
  selected: [] as string[],
  generic: { offers: [{ desc: '' }] },
  leveling: {
    offers: [
      { kind: 'LEVEL' as 'LEVEL' | 'PARAGON', start: 1 as number | null, end: 60 as number | null },
    ],
  },
  pit: { offers: [{ tier: '', runs: 1 as number | null }] },
  boss: { offers: [{ code: '', runs: 1 as number | null }] },
  mythic: {
    offers: [
      { item: '', ga: '', stats: [null, null, null] as (string | null)[], qty: 1 as number | null },
    ],
  },
  masterwork: { offers: [{ code: '', qty: 1 as number | null }] },
  materials: { offers: [{ code: '', qty: 1 as number | null }] },
  infernalHordes: { offers: [{ tier: '' as string, qty: 1 as number | null }] },
  nightmare: { offers: [{ tier: '', qty: 1 as number | null }] },
  renown: { offers: [{ region: '', qty: 1 as number | null }] },
  altars: { offers: [{ region: '', qty: 1 as number | null }] },
})

const channelOptions = ref<Opt[]>([])
const customerOptions = ref<Opt[]>([])
const currencyOptions = ref<Opt[]>([])
const acOpen = reactive({ channel: false, customer: false, currency: false })
const search = reactive({ channel: '', customer: '', currency: '' })

const bossDict = ref<SelectOption[]>([])
const pitTierDict = ref<SelectOption[]>([])
const hordesTierDict = ref<SelectOption[]>([])
const materialDict = ref<SelectOption[]>([])
const masterworkDict = ref<SelectOption[]>([])
const nmTierDict = ref<SelectOption[]>([])
const mythicItemDict = ref<SelectOption[]>([])
const mythicGADict = ref<SelectOption[]>([])
const altarDict = ref<SelectOption[]>([])
const renownDict = ref<SelectOption[]>([])
const itemStatsSortDict = ref<SelectOption[]>([])

/* ===== Computed ===== */
const btnClass = (m: Mode) => (mode.value === m ? `${baseBtn} ${activeBtn}` : baseBtn)
const accountOptions = computed(() => {
  const options = customerAccounts.value.map((acc) => ({
    label: `${acc.label} (${acc.btag || acc.login_id || 'N/A'})`,
    value: acc.id,
  }))
  options.push({ label: 'Thêm tài khoản mới...', value: ADD_NEW_ACCOUNT })
  return options
})
const pricePrecision = computed(() => (form.value.currency === 'VND' ? 0 : 2))
const asVL = (arr: SelectOption[]) =>
  (arr ?? []).map((o) => ({
    value: String(o.value ?? ''),
    label: String(o.label ?? o.value ?? ''),
  }))
const labelMaps = computed<LabelMaps>(() =>
  makeLabelMapsFromOptions({
    BOSS: asVL(bossDict.value),
    PIT: asVL(pitTierDict.value),
    MATERIAL: asVL(materialDict.value),
    MASTERWORKING: asVL(masterworkDict.value),
    ALTARS: asVL(altarDict.value),
    RENOWN: asVL(renownDict.value),
    NIGHTMARE: asVL(nmTierDict.value),
    MYTHIC_ITEM: asVL(mythicItemDict.value),
    MYTHIC_GA: asVL(mythicGADict.value),
    ITEM_STATS_SORT: asVL(itemStatsSortDict.value), // <-- THÊM DÒNG NÀY
  })
)

function filterAC(list: Opt[], kw: string) {
  const s = (kw || '').toLowerCase()
  const arr = list.map((o) => String(o.value))
  if (!s) return arr
  return arr.filter((v) => v.toLowerCase().includes(s))
}
const channelACOptions = computed(() => filterAC(channelOptions.value, search.channel))
const currencyACOptions = computed(() => filterAC(currencyOptions.value, search.currency))
const customersByChannel = ref<Record<string, Opt[]>>({})

// SỬA LỖI AUTOCOMPLETE: Logic này đảm bảo chỉ hiển thị khách hàng của kênh đã chọn.
const customerACOptions = computed(() => {
  const ch = (form.value.channel_code || '').trim()
  if (ch) {
    // Nếu có kênh, CHỈ hiển thị khách hàng của kênh đó (kể cả khi đang tải hoặc rỗng)
    return filterAC(customersByChannel.value[ch] || [], search.customer)
  }
  // Nếu không có kênh, hiển thị tất cả khách hàng
  return filterAC(customerOptions.value, search.customer)
})

/* ===== Validation ===== */
const rules: FormRules = {
  channel_code: [{ required: true, message: 'Chọn/nhập nguồn bán', trigger: ['blur', 'change'] }],
  customer_name: [{ required: true, message: 'Chọn/nhập khách hàng', trigger: ['blur', 'change'] }],
  price: [
    {
      validator: (_r, v) => v != null && !Number.isNaN(Number(v)) && Number(v) >= 0,
      message: 'Nhập giá bán hợp lệ',
      trigger: ['blur', 'change', 'input'],
    },
  ],
  currency: [{ required: true, message: 'Chọn tiền tệ', trigger: ['blur', 'change'] }],
  selectedAccountId: [
    {
      required: true,
      validator: (_rule, value) => {
        if (!isAddingNewAccount.value && !value) {
          return new Error('Vui lòng chọn một tài khoản có sẵn')
        }
        return true
      },
      trigger: ['blur', 'change'],
    },
  ],
  'newAccount.label': [
    {
      validator: () => !isAddingNewAccount.value || !!newAccount.label.trim(),
      message: 'Vui lòng nhập nhãn gợi nhớ cho tài khoản mới',
    },
  ],
  'newAccount.btag': [
    {
      validator: () =>
        !isAddingNewAccount.value ||
        form.value.service_type !== 'selfplay' ||
        !!newAccount.btag.trim(),
      message: 'Vui lòng nhập Btag cho tài khoản mới',
    },
  ],
  'newAccount.login_id': [
    {
      validator: () =>
        !isAddingNewAccount.value ||
        form.value.service_type !== 'pilot' ||
        !!newAccount.login_id.trim(),
      message: 'Vui lòng nhập Login ID cho tài khoản mới',
    },
  ],
}

/* ===== Data Loading & Watchers ===== */
const hasLoadedChannels = ref(false)
const hasLoadedCurrencies = ref(false)

function getStatCountForGA(gaCode?: string | null): number {
  const code = String(gaCode || '').toUpperCase()
  if (code === '1GA_REQUEST') return 1
  if (code === '2GA_REQUEST') return 2
  if (code === '3GA_REQUEST') return 3
  return 0 // Mặc định không hiển thị ô nào
}

async function loadChannels() {
  const { data, error } = await supabase.from('channels').select('code').order('code')
  if (error) {
    console.error('channels/select', error)
    return message.error('Không tải được Nguồn bán: ' + error.message)
  }
  channelOptions.value = (data ?? []).map((r: { code: string }) => ({
    label: r.code,
    value: r.code,
    _db: true,
  }))
  hasLoadedChannels.value = true
}
async function loadAllCustomers() {
  const { data, error } = await supabase
    .from('parties')
    .select('name')
    .eq('type', 'customer')
    .order('name')
  if (error) {
    console.error('parties/select', error)
    return message.error('Không tải được Khách hàng: ' + error.message)
  }
  customerOptions.value = (data ?? []).map((r: { name: string }) => ({
    label: r.name,
    value: r.name,
    _db: true,
  }))
}

async function loadCustomersForChannel(code: string) {
  if (!code) return

  try {
    // Gọi hàm RPC thay vì truy vấn trực tiếp
    const { data, error } = await supabase.rpc('get_customers_by_channel_v1', {
      p_channel_code: code,
    })

    if (error) throw error

    // Kết quả trả về là một mảng các object { name: '...' }
    const names = (data || []).map((r: { name: string }) => r.name)

    customersByChannel.value[code] = names.map((n: string) => ({ label: n, value: n, _db: true }))
  } catch (e: unknown) {
    console.error('[loadCustomersForChannel]', e)
    customersByChannel.value[code] = []
    message.error('Không tải được danh sách khách hàng cho kênh này.')
  }
}

async function loadCurrencies() {
  const { data, error } = await supabase.from('currencies').select('code').order('code')
  if (error) {
    console.error('currencies/select', error)
    return message.error('Không tải được Tiền tệ: ' + error.message)
  }
  currencyOptions.value = (data ?? []).map((r: { code: string }) => ({
    label: r.code,
    value: r.code,
    _db: true,
  }))
  hasLoadedCurrencies.value = true
}
function ensureChannels() {
  if (!hasLoadedChannels.value) loadChannels()
}
function ensureCurrencies() {
  if (!hasLoadedCurrencies.value) loadCurrencies()
}
function ensureChannelOption(code: string) {
  if (!code) return
  const exists = channelOptions.value.some((o) => String(o.value) === code)
  if (!exists) channelOptions.value.push({ label: code, value: code, _db: true })
}
function ensureCustomersForChannel() {
  const code = (form.value.channel_code || '').trim()
  if (code) loadCustomersForChannel(code)
}

async function loadServiceDict() {
  try {
    const { data: attributes, error } = await supabase
      .from('attributes')
      .select('id, code, name, type')

    if (error) throw error
    if (!attributes) {
      message.warning('Không có dữ liệu danh mục dịch vụ.')
      return
    }

    // Tải tất cả relationships
    const { data: relationships, error: relError } = await supabase
      .from('attribute_relationships')
      .select('parent_attribute_id, child_attribute_id')
    if (relError) throw relError

    // === BƯỚC 1: Xây dựng các Map ===
    const attrMapById = new Map(attributes.map((a) => [a.id, a]))
    const childrenMap = new Map<string, string[]>()
    for (const rel of relationships!) {
      if (!childrenMap.has(rel.parent_attribute_id)) {
        childrenMap.set(rel.parent_attribute_id, [])
      }
      childrenMap.get(rel.parent_attribute_id)!.push(rel.child_attribute_id)
    }

    // MỚI: Populate kindCodeToIdMap và dictCodeToIdMap
    const newKindCodeToIdMap = new Map<string, string>()
    const newDictCodeToIdMap = new Map<string, string>()
    for (const attr of attributes) {
      newDictCodeToIdMap.set(attr.code, attr.id) // Map tất cả code vào id
      if (attr.type === 'SERVICE_KIND') {
        newKindCodeToIdMap.set(attr.code, attr.id)
      }
    }
    kindCodeToIdMap.value = newKindCodeToIdMap
    dictCodeToIdMap.value = newDictCodeToIdMap

    // === BƯỚC 2: Xây dựng các SelectOption cho UI ===
    const toSelectOption = (attr: { name: string; code: string }) => ({
      label: attr.name,
      value: attr.code,
    })
    const sortFn = (a: { label: string }, b: { label: string }) => a.label.localeCompare(b.label)

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

    const groupedOptions: Record<string, { label: string; value: string }[]> = {}
    for (const attr of attributes) {
      if (!attr.type) continue
      if (!groupedOptions[attr.type]) groupedOptions[attr.type] = []
      groupedOptions[attr.type].push(toSelectOption(attr))
    }

    pitTierDict.value = (groupedOptions['TIER_DIFFICULTY'] || []).sort(
      (a, b) =>
        parseInt(a.label.match(/\d+/)?.[0] || '0') - parseInt(b.label.match(/\d+/)?.[0] || '0')
    )
    materialDict.value = (groupedOptions['MATS_NAME'] || []).sort(sortFn)
    masterworkDict.value = (groupedOptions['MW_TYPE'] || []).sort(sortFn)
    mythicItemDict.value = (groupedOptions['MYTHIC_NAME'] || []).sort(sortFn)
    hordesTierDict.value = (groupedOptions['TORMENT_DIFFICULTY'] || []).sort(sortFn)
    nmTierDict.value = (groupedOptions['TORMENT_DIFFICULTY'] || []).sort(sortFn)
    mythicGADict.value = (groupedOptions['MYTHIC_GA_TYPE'] || []).sort(sortFn)

    const allOption = (groupedOptions['SPECIAL'] || []).find((opt) => opt.value === 'ALL')
    const regions = (groupedOptions['REGIONS_NAME'] || []).sort(sortFn)
    renownDict.value = allOption ? [allOption, ...regions] : regions
    altarDict.value = allOption ? [allOption, ...regions] : regions
    itemStatsSortDict.value = (groupedOptions['ITEM_STATS_SORT'] || []).sort(sortFn)

    const newMythicStatsMap = new Map<string, { label: string; value: string }[]>()
    const mythicNameAttrs = attributes.filter((a) => a.type === 'MYTHIC_NAME')
    for (const mythicAttr of mythicNameAttrs) {
      const statIds = childrenMap.get(mythicAttr.id) || []
      const statsOptions = statIds
        .map((id) => attrMapById.get(id))
        .filter(Boolean)
        .map((attr) => toSelectOption(attr!))
      newMythicStatsMap.set(mythicAttr.code, statsOptions.sort(sortFn))
    }
    mythicStatsMap.value = newMythicStatsMap
  } catch (e: unknown) {
    const error = e as Error
    console.error('[loadServiceDict]', error)
    message.error('Không tải được danh mục dịch vụ: ' + error.message)
  }
}

// SỬA LỖI XUNG ĐỘT LOGIC: Watcher này được cập nhật để xử lý cả hai chiều
watch(
  () => form.value.customer_name,
  async (name) => {
    // Khi tên khách hàng thay đổi (hoặc bị xóa), reset danh sách tài khoản
    customerAccounts.value = []
    form.value.selectedAccountId = null
    const v = (name || '').trim()
    if (!v) return

    loadingAccounts.value = true
    try {
      const { data: party, error: partyErr } = await supabase
        .from('parties')
        .select('id')
        .eq('name', v)
        .eq('type', 'customer')
        .maybeSingle()
      if (partyErr) throw partyErr
      if (!party) return

      const accountTypeForQuery = form.value.service_type === 'pilot' ? 'login' : 'btag'
      const { data: accounts, error: accErr } = await supabase
        .from('customer_accounts')
        .select('id, label, btag, login_id')
        .eq('party_id', party.id)
        .eq('account_type', accountTypeForQuery)

      if (accErr) throw accErr
      customerAccounts.value = accounts || []

      if (customerAccounts.value.length > 0) {
        form.value.selectedAccountId = customerAccounts.value[0].id
      }

      // Tự động điền kênh bán hàng gần nhất của khách hàng
      if (!String(form.value.channel_code || '').trim() && party.id) {
        const { data: ord, error: e2 } = (await supabase
          .from('orders')
          .select('channels(code)')
          .eq('customer_id', party.id)
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle()) as { data: OrderWithChannel | null; error: unknown }
        if (e2) throw e2
        const chan = ord?.channels
        const code = Array.isArray(chan) ? chan[0]?.code : chan?.code
        if (typeof code === 'string' && code.trim()) {
          ensureChannelOption(code)
          isProgrammaticChange.value = true // <-- Đặt cờ báo hiệu đây là thay đổi nội bộ
          form.value.channel_code = code
          await loadCustomersForChannel(code)
        }
      }
      await nextTick()
      formRef.value?.restoreValidation?.()
    } catch (e: unknown) {
      const error = e as Error
      console.error(error)
      message.error('Không tải được dữ liệu khách hàng hoặc tài khoản.')
    } finally {
      loadingAccounts.value = false
    }
  }
)

// SỬA LỖI XUNG ĐỘT LOGIC: Watcher này được cập nhật để xử lý cả hai chiều
watch(
  () => form.value.channel_code,
  (code) => {
    // Nếu thay đổi này là do logic chọn khách hàng gây ra, bỏ qua
    if (isProgrammaticChange.value) {
      isProgrammaticChange.value = false
      return
    }

    // Nếu người dùng tự tay thay đổi kênh bán, xóa khách hàng hiện tại
    form.value.customer_name = ''

    // Luôn tải danh sách khách hàng cho kênh mới
    if (code) {
      loadCustomersForChannel(code)
    }
  }
)

watch(
  () => form.value.service_type,
  () => {
    const currentName = form.value.customer_name
    if (currentName) {
      form.value.customer_name = ''
      nextTick(() => {
        form.value.customer_name = currentName
      })
    }
  }
)

watch(
  () => svc.leveling.offers,
  (offers) => {
    for (const offer of offers) {
      const max = offer.kind === 'PARAGON' ? 300 : 60

      if (offer.start && offer.start > max) {
        offer.start = max
      }

      if (offer.end && offer.end > max) {
        offer.end = max
      }
    }
  },
  { deep: true }
)

watch(
  () => svc.renown.offers,
  (offers) => {
    for (const offer of offers) {
      if (offer.region && offer.region !== 'ALL' && offer.qty !== 1) {
        offer.qty = 1
      }
    }
  },
  { deep: true }
)

// Logic gói dịch vụ (UX) được giữ lại
watch(
  () => svc.selected.length,
  (selectedCount) => {
    if (form.value.package_type === 'BASIC' && selectedCount >= 2) {
      form.value.package_type = 'CUSTOM'
    } else if (form.value.package_type === 'CUSTOM' && selectedCount < 2) {
      form.value.package_type = 'BASIC'
    }
  }
)

const mythicStatsMap = ref<Map<string, { label: string; value: string }[]>>(new Map())

// Helper computed để lấy danh sách stats cho từng offer mythic
const offerStatsOptions = computed(() => {
  return svc.mythic.offers.map((offer) => {
    if (!offer.item) return []
    return mythicStatsMap.value.get(offer.item) || []
  })
})

function getFilteredStatOptions(offerIndex: number, statIndex: number) {
  const allStats = offerStatsOptions.value[offerIndex] || []
  const selectedStats = svc.mythic.offers[offerIndex].stats
  const currentSelection = selectedStats[statIndex]

  return allStats.filter((stat) => {
    // Luôn hiển thị lựa chọn hiện tại
    if (stat.value === currentSelection) return true
    // Ẩn đi nếu đã được chọn ở ô khác
    return !selectedStats.includes(stat.value)
  })
}

/* ===== Helpers ===== */
// ... (Các hàm helper khác giữ nguyên không đổi)
const fid = (s: string) => `sales-${s}`
const lid = (s: string) => `${fid(s)}-label`
function acInputProps(kind: CreateKind, idBase: string, name: string, ariaId: string) {
  const ac = kind === 'customer' ? 'name' : 'off'
  const props: Record<string, unknown> = {
    id: fid(idBase),
    name,
    autocomplete: ac,
    'aria-labelledby': ariaId,
    onKeydown: (e: KeyboardEvent) => {
      if (e.key === 'Enter') {
        e.preventDefault()
        e.stopPropagation()
        commitCreate(kind)
      }
    },
  }
  if (kind === 'currency') {
    props.maxlength = 3
    props.style = 'text-transform: uppercase; text-align:center;'
  }
  return props
}
function commitCreate(kind: CreateKind) {
  const raw = (
    kind === 'channel'
      ? search.channel || form.value.channel_code
      : kind === 'customer'
        ? search.customer || form.value.customer_name
        : (search.currency || form.value.currency).toUpperCase()
  ).trim()
  if (!raw) return
  const list =
    kind === 'channel'
      ? channelOptions.value
      : kind === 'customer'
        ? customerOptions.value
        : currencyOptions.value

  if (kind === 'currency') {
    if (!/^[A-Z]{3}$/.test(raw)) {
      message.warning('Tiền tệ phải đúng 3 ký tự A–Z (VD: USD, VND)')
      return
    }
  } else if (raw.length < MIN_CHAN_CUST) {
    message.warning(`Nhập tối thiểu ${MIN_CHAN_CUST} ký tự rồi Enter`)
    return
  }

  if (!list.some((o) => String(o.value).toLowerCase() === raw.toLowerCase())) {
    list.push({ label: raw, value: raw, _db: false })
  }
  if (kind === 'channel') form.value.channel_code = raw
  if (kind === 'customer') form.value.customer_name = raw
  if (kind === 'currency') form.value.currency = raw
}

const formatPrice = (value: number | null): string => {
  if (value == null || Number.isNaN(value)) return ''
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: pricePrecision.value,
    maximumFractionDigits: pricePrecision.value,
  }).format(Number(value))
}
const parsePrice = (input: string): number | null => {
  if (!input) return null
  const n = Number(input.replace(/[,\s]/g, ''))
  return Number.isNaN(n) ? null : n
}

function addGeneric() {
  svc.generic.offers.push({ desc: '' })
}
function removeGeneric(i: number) {
  svc.generic.offers.splice(i, 1)
}
function addLv() {
  svc.leveling.offers.push({ kind: 'LEVEL', start: 1, end: 60 })
}
function removeLv(i: number) {
  svc.leveling.offers.splice(i, 1)
}
function addBoss() {
  svc.boss.offers.push({ code: '', runs: 1 })
}
function removeBoss(i: number) {
  svc.boss.offers.splice(i, 1)
}
function addPit() {
  svc.pit.offers.push({ tier: '', runs: 1 })
}
function removePit(i: number) {
  svc.pit.offers.splice(i, 1)
}
function addHorde() {
  svc.infernalHordes.offers.push({ tier: '', qty: 1 })
}
function removeHorde(i: number) {
  svc.infernalHordes.offers.splice(i, 1)
}
function addMat() {
  svc.materials.offers.push({ code: '', qty: 1 })
}
function removeMat(i: number) {
  svc.materials.offers.splice(i, 1)
}
function addMyth() {
  svc.mythic.offers.push({ item: '', ga: '', stats: [null, null, null], qty: 1 })
}
function removeMyth(i: number) {
  svc.mythic.offers.splice(i, 1)
}
function addMw() {
  svc.masterwork.offers.push({ code: '', qty: 1 })
}
function removeMw(i: number) {
  svc.masterwork.offers.splice(i, 1)
}
function addNm() {
  svc.nightmare.offers.push({ tier: '', qty: 1 })
}
function removeNm(i: number) {
  svc.nightmare.offers.splice(i, 1)
}

/* ===== Reset ===== */
function resetForm() {
  form.value = {
    channel_code: '',
    service_type: 'selfplay',
    customer_name: '',
    selectedAccountId: null,
    deadline: null,
    price: null,
    currency: 'USD',
    package_type: 'BASIC',
    package_note: '',
  }
  customerAccounts.value = []
  Object.assign(newAccount, { label: '', btag: '', login_id: '', login_pwd: '' })
  svc.selected = []
  svc.generic = { offers: [{ desc: '' }] }
  svc.leveling = { offers: [{ kind: 'LEVEL', start: 1, end: 60 }] }
  svc.boss = { offers: [{ code: '', runs: 1 }] }
  svc.pit = { offers: [{ tier: '', runs: 1 }] }
  svc.materials = { offers: [{ code: '', qty: 1 }] }
  svc.infernalHordes = { offers: [{ tier: '', qty: 1 }] }
  svc.nightmare = { offers: [{ tier: '', qty: 1 }] }
  svc.mythic = { offers: [{ item: '', ga: '', stats: [null, null, null], qty: 1 }] }
  svc.masterwork = { offers: [{ code: '', qty: 1 }] }
  // SỬA LẠI: Bọc mảng trong object { offers: [...] } để đồng bộ với cấu trúc mới
  svc.altars = { offers: [{ region: '', qty: 1 }] }
  svc.renown = { offers: [{ region: '', qty: 1 }] }
}

/* ===== Submit ===== */
const saving = ref(false)
const kindCodeToIdMap = ref<Map<string, string>>(new Map())
const dictCodeToIdMap = ref<Map<string, string>>(new Map())

// TÌM HÀM NÀY TRONG Sales.vue VÀ THAY THẾ NÓ
interface ServiceItemPayload {
  service_kind_id: string
  params: Record<string, unknown>
  plan_qty: number | null
}

function buildServiceItemsPayload(): ServiceItemPayload[] {
  const items: ServiceItemPayload[] = []

  for (const kindCode of svc.selected) {
    const serviceKindId = kindCodeToIdMap.value.get(kindCode)
    if (!serviceKindId) continue

    switch (kindCode) {
      case 'GENERIC':
        for (const offer of svc.generic.offers) {
          if (offer.desc && offer.desc.trim()) {
            items.push({
              service_kind_id: serviceKindId,
              params: { note: offer.desc.trim() },
              plan_qty: 1,
            })
          }
        }
        break

      case 'LEVELING':
        for (const offer of svc.leveling.offers) {
          if (offer.start != null && offer.end != null && offer.end > offer.start) {
            items.push({
              service_kind_id: serviceKindId,
              params: {
                mode: offer.kind?.toLowerCase(),
                start: offer.start,
                end: offer.end,
              },
              plan_qty: offer.end - offer.start,
            })
          }
        }
        break

      case 'THE_PIT':
        for (const offer of svc.pit.offers) {
          if (offer.tier && (offer.runs ?? 0) > 0) {
            items.push({
              service_kind_id: serviceKindId,
              params: {
                tier_code: offer.tier,
                tier_label: labelMaps.value.PIT?.get(offer.tier) || offer.tier,
              },
              plan_qty: offer.runs,
            })
          }
        }
        break

      case 'BOSS':
        for (const offer of svc.boss.offers) {
          if (offer.code && (offer.runs ?? 0) > 0) {
            items.push({
              service_kind_id: serviceKindId,
              params: {
                boss_code: offer.code,
                boss_label: labelMaps.value.BOSS?.get(offer.code) || offer.code,
              },
              plan_qty: offer.runs,
            })
          }
        }
        break

      case 'MYTHIC':
        for (const offer of svc.mythic.offers) {
          if (offer.item && (offer.qty ?? 0) > 0) {
            const statLabels = offer.stats
              ?.filter(Boolean)
              .map((statCode) => labelMaps.value.ITEM_STATS_SORT?.get(statCode!) || statCode)

            items.push({
              service_kind_id: serviceKindId,
              params: {
                item_code: offer.item,
                item_label: labelMaps.value.MYTHIC_ITEM?.get(offer.item) || offer.item,
                ga_code: offer.ga || undefined,
                ga_label: offer.ga
                  ? labelMaps.value.MYTHIC_GA?.get(offer.ga) || offer.ga
                  : undefined,
                ga_note: statLabels?.length ? statLabels.join(', ') : undefined,
              },
              plan_qty: offer.qty,
            })
          }
        }
        break

      case 'MATERIALS':
      case 'MASTERWORKING': {
        const offersToProcess =
          kindCode === 'MATERIALS' ? svc.materials.offers : svc.masterwork.offers
        for (const offer of offersToProcess) {
          if (offer.code && (offer.qty ?? 0) > 0) {
            items.push({
              service_kind_id: serviceKindId,
              params: { attribute_code: offer.code },
              plan_qty: offer.qty,
            })
          }
        }
        break
      }

      case 'INFERNAL_HORDES':
      case 'NIGHTMARE': {
        const tierOffers =
          kindCode === 'INFERNAL_HORDES' ? svc.infernalHordes.offers : svc.nightmare.offers
        for (const offer of tierOffers) {
          if (offer.tier && (offer.qty ?? 0) > 0) {
            items.push({
              service_kind_id: serviceKindId,
              params: { attribute_code: offer.tier },
              plan_qty: offer.qty,
            })
          }
        }
        break
      }

      case 'RENOWN':
      case 'ALTARS_OF_LILITH': {
        const regionOffers = kindCode === 'RENOWN' ? svc.renown.offers : svc.altars.offers
        for (const offer of regionOffers) {
          if (offer.region) {
            items.push({
              service_kind_id: serviceKindId,
              params: { attribute_code: offer.region },
              plan_qty: offer.qty,
            })
          }
        }
        break
      }
    }
  }
  return items
}

// THAY THẾ HÀM submit CŨ BẰNG HÀM NÀY
async function submit() {
  saving.value = true
  try {
    await formRef.value?.validate()

    const serviceItemsPayload = buildServiceItemsPayload()

    if (serviceItemsPayload.length === 0 && svc.selected.length > 0) {
      message.warning('Vui lòng chọn chi tiết cho các dịch vụ đã tick.')
      saving.value = false
      return
    }

    // Payload này chứa ĐÚNG và ĐỦ 12 tham số mà RPC mong đợi
    const payload = {
      p_channel_code: form.value.channel_code,
      p_service_type: form.value.service_type,
      p_customer_name: form.value.customer_name,
      p_deadline: form.value.deadline ? new Date(form.value.deadline).toISOString() : null,
      p_price: form.value.price,
      p_currency_code: form.value.currency,
      p_package_type: form.value.package_type,
      p_package_note: form.value.package_note,
      p_customer_account_id: isAddingNewAccount.value ? null : form.value.selectedAccountId,
      p_new_account_details: isAddingNewAccount.value
        ? {
            account_type: form.value.service_type === 'pilot' ? 'login' : 'btag',
            label: newAccount.label,
            btag: form.value.service_type === 'selfplay' ? newAccount.btag : null,
            login_id: form.value.service_type === 'pilot' ? newAccount.login_id : null,
            login_pwd: form.value.service_type === 'pilot' ? newAccount.login_pwd : null,
          }
        : null,
      p_game_code: 'DIABLO_4',
      p_service_items: serviceItemsPayload,
    }

    const { error } = await supabase.rpc('create_service_order_v1', payload)
    if (error) throw error

    message.success(`Đã tạo đơn hàng thành công!`)
    resetForm()
  } catch (e: unknown) {
    const error = e as Error
    console.error('LỖI CHI TIẾT KHI LƯU ĐƠN:', JSON.stringify(error, null, 2))
    message.error(error?.message || 'Không thể lưu đơn. Vui lòng kiểm tra Console (F12).')
  } finally {
    saving.value = false
  }
}

/* mount */
onMounted(() => {
  ensureChannels()
  ensureCurrencies()
  loadServiceDict()
  loadAllCustomers()
})
</script>

<style scoped>
:deep(.n-card) {
  border-radius: 14px;
}
.price-field :deep(.n-input-number .n-input__suffix) {
  padding-right: 0;
}
.currency-suffix {
  display: inline-flex;
  align-items: center;
  height: 100%;
}
.currency-suffix--fixed {
  width: 75px;
  flex: 0 0 75px;
}
.currency-input {
  width: 100% !important;
  min-width: 0;
}
.currency-suffix :deep(.n-input) {
  width: 100% !important;
  border: none !important;
  background: transparent !important;
  box-shadow: none !important;
}
.currency-suffix :deep(.n-input .n-input__border),
.currency-suffix :deep(.n-input .n-input__state-border) {
  display: none !important;
}
.currency-suffix :deep(.n-input__input-el) {
  text-align: center;
  padding: 0 4px;
}
.service-type {
  display: inline-flex !important;
  gap: 12px;
  align-items: center;
}
.service-type :deep(.n-radio-button) {
  min-width: 110px;
  height: 40px;
  padding: 0 18px;
  border-radius: 12px;
  border: 1px solid #e5e7eb !important;
  background: #fff;
  transition: all 0.2s ease;
  display: inline-flex;
  justify-content: center;
  align-items: center;
  box-shadow: none;
}
.service-type :deep(.n-radio-button:hover) {
  border-color: #cbd5e1;
}
.service-type :deep(.n-radio-button--checked),
.service-type :deep(.n-radio-button--checked) {
  background-color: #111827 !important;
  color: #fff !important;
  border-color: #111827 !important;
  box-shadow: 0 6px 14px rgba(17, 24, 39, 0.18) !important;
}
.service-type :deep(.n-radio-button--checked .n-radio-button__state-border) {
  border-color: #111827 !important;
}
.service-type :deep(.n-radio-group__splitor) {
  display: none !important;
}
</style>
