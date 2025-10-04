<template>
  <div>
    <!-- Summary view (collapsed) -->
    <div v-if="collapsed" class="whitespace-pre-line">
      <template v-for="(kind, index) in kindGroups" :key="kind.code">
        <span v-if="index > 0">, </span>
        <span :class="{ 'line-through': kind.isCompleted }">{{ kind.name }}</span>
      </template>
    </div>

    <!-- Detail view (expanded) -->
    <ul v-else class="list-none p-0 m-0 space-y-1">
      <li v-for="kind in kindGroups" :key="kind.code">
        <strong :class="{ 'line-through': kind.isCompleted }">- {{ kind.name }}:</strong>
        <ul v-if="kind.items.length > 0" class="list-none p-0 m-0 pl-4">
          <li v-for="item in kind.items" :key="item.id">
            + <ServiceItemLabel :item="item" :show-completed="true" />
          </li>
        </ul>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { computed, inject, type Ref } from 'vue'
import ServiceItemLabel from './ServiceItemLabel.vue'

// Types
type SvcItemSummary = {
  id: string
  kind_code: string
  kind_name: string
  params: Record<string, unknown>
  plan_qty: number | null
  done_qty: number
  active_report_id: string | null
}

// Props
const props = defineProps<{
  items: SvcItemSummary[] | null
  collapsed?: boolean
}>()

// Constants
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

// Inject attributeMap từ parent component
const attributeMap = inject<Ref<Map<string, string>>>('attributeMap', {
  value: new Map(),
} as Ref<Map<string, string>>)

// Helper function
const isItemCompleted = (item: SvcItemSummary) => {
  const plan = Number(item.plan_qty ?? 0)
  if (plan <= 0) return true
  return Number(item.done_qty ?? 0) >= plan
}

// Computed
const kindGroups = computed(() => {
  if (!props.items || props.items.length === 0) {
    return []
  }

  // Lấy danh sách kind_code và sắp xếp theo KIND_ORDER
  const kindCodesInOrder = [...new Set(props.items.map((it) => it.kind_code))].sort(
    (a, b) => (KIND_ORDER[a] ?? 999) - (KIND_ORDER[b] ?? 999)
  )

  return kindCodesInOrder.map((code) => {
    const kindName = attributeMap.value.get(code) || code
    const itemsInKind = props.items!.filter((it) => it.kind_code === code)
    const isGroupCompleted = itemsInKind.length > 0 && itemsInKind.every(isItemCompleted)

    return {
      code,
      name: kindName,
      items: itemsInKind,
      isCompleted: isGroupCompleted,
    }
  })
})
</script>
