<template>
  <span :class="{ 'line-through': isCompleted }">{{ label }}</span>
</template>

<script setup lang="ts">
import { computed, inject, type Ref } from 'vue'

// Types
type SvcItem = {
  id: string
  kind_code: string
  params: Record<string, unknown>
  plan_qty: number | null
  done_qty: number
  active_report_id: string | null
}

type SvcItemSummary = {
  id: string
  kind_code: string
  kind_name: string
  params: Record<string, unknown>
  plan_qty: number | null
  done_qty: number
  active_report_id: string | null
}

interface SessionOutput {
  kind: string
  kind_code: string
  id: string
  item_id?: string
  is_activity?: boolean
  activity_label?: string
  session_start_value?: number
  session_end_value?: number
  session_delta?: number
  start_proof_url?: string | null
  end_proof_url?: string | null
  params?: Record<string, unknown>
  [key: string]: unknown
}

// Props
const props = defineProps<{
  item: SvcItem | SvcItemSummary | SessionOutput
  showProgress?: boolean
  showCompleted?: boolean
}>()

// Constants
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

// Inject attributeMap từ parent component
const attributeMap = inject<Ref<Map<string, string>>>('attributeMap', {
  value: new Map(),
} as Ref<Map<string, string>>)

// Helper function
function getAttributeName(code: string): string {
  if (!code) return 'Không rõ'
  return attributeMap.value.get(code) || code
}

// Computed
const isCompleted = computed(() => {
  if (!props.showCompleted) return false
  const plan = Number((props.item as SvcItem | SvcItemSummary).plan_qty ?? 0)
  if (plan <= 0) return true
  const done = Number((props.item as SvcItem | SvcItemSummary).done_qty ?? 0)
  return done >= plan
})

const label = computed(() => {
  const k = (props.item.kind_code || '').toUpperCase()
  const p = props.item.params || {}
  const plan = Number((props.item as SvcItem | SvcItemSummary).plan_qty ?? p.plan_qty ?? p.qty ?? 0)
  const done = Number((props.item as SvcItem | SvcItemSummary).done_qty ?? 0)
  let mainLabel = ''

  switch (k) {
    case 'LEVELING':
      mainLabel = `${p.mode === 'paragon' ? 'Paragon' : 'Level'} ${p.start}→${p.end}`
      break
    case 'BOSS':
      mainLabel = `${p.boss_label || getAttributeName(String(p.boss_code || ''))}`
      break
    case 'THE_PIT':
      mainLabel = `${p.tier_label || getAttributeName(String(p.tier_code || ''))}`
      break
    case 'NIGHTMARE':
      mainLabel = `${getAttributeName(String(p.attribute_code || ''))}`
      break
    case 'INFERNAL_HORDES':
      mainLabel = `${getAttributeName(String(p.attribute_code || ''))}`
      break
    case 'MATERIALS':
      mainLabel = `${getAttributeName(String(p.attribute_code || ''))}`
      break
    case 'MASTERWORKING':
      mainLabel = `${getAttributeName(String(p.attribute_code || ''))}`
      break
    case 'ALTARS_OF_LILITH':
      mainLabel = `${getAttributeName(String(p.attribute_code || ''))}`
      break
    case 'RENOWN':
      mainLabel = `${getAttributeName(String(p.attribute_code || ''))}`
      break
    case 'MYTHIC':
      mainLabel = `${p.item_label || getAttributeName(String(p.item_code || ''))}${p.ga_label ? ` (${p.ga_label}${p.ga_note ? ': ' + p.ga_note : ''})` : ''}`
      break
    case 'GENERIC':
      mainLabel = String(p.desc || p.note || 'Generic')
      break
    default:
      mainLabel = JSON.stringify(p)
      break
  }

  if (!props.showProgress) {
    return mainLabel
  }

  const unit = KIND_UNITS[k as keyof typeof KIND_UNITS] || ''
  const suffix =
    plan > 0
      ? ` (${done}/${plan}${unit ? ' ' + unit : ''})`
      : done > 0
        ? ` (${done}${unit ? ' ' + unit : ''})`
        : ''

  return mainLabel + suffix
})
</script>
