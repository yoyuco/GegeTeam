import { describe, it, expect } from 'vitest'
import { ref } from 'vue'
import { mount } from '@vue/test-utils'
import ServiceDescription from '../ServiceDescription.vue'

describe('ServiceDescription', () => {
  // Create attributeMap for all tests
  const mockAttributeMap = ref(
    new Map([
      ['LEVELING', 'Leveling'],
      ['BOSS', 'Boss'],
    ])
  )

  it('renders properly with items', () => {
    const mockItems = [
      {
        id: '1',
        kind_code: 'LEVELING',
        kind_name: 'Leveling',
        plan_qty: 100,
        done_qty: 50,
        params: {},
        active_report_id: null,
      },
    ]

    const wrapper = mount(ServiceDescription, {
      props: {
        items: mockItems,
        collapsed: false,
      },
      global: {
        provides: {
          attributeMap: mockAttributeMap,
        },
        stubs: {
          ServiceItemLabel: {
            template: '<div>Level Mock</div>',
            props: ['item', 'showCompleted', 'showProgress'],
          },
        },
      },
    })

    expect(wrapper.text()).toContain('LEVELING')
  })

  it('shows collapsed view when collapsed prop is true', () => {
    const mockItems = [
      {
        id: '1',
        kind_code: 'LEVELING',
        kind_name: 'Leveling',
        plan_qty: 100,
        done_qty: 50,
        params: {},
        active_report_id: null,
      },
    ]

    const wrapper = mount(ServiceDescription, {
      props: {
        items: mockItems,
        collapsed: true,
      },
      global: {
        provides: {
          attributeMap: mockAttributeMap,
        },
      },
    })

    expect(wrapper.find('div').exists()).toBe(true)
    expect(wrapper.text()).toContain('LEVELING')
  })

  it('shows empty state when no items', () => {
    const wrapper = mount(ServiceDescription, {
      props: {
        items: null,
        collapsed: false,
      },
      global: {
        provides: {
          attributeMap: mockAttributeMap,
        },
      },
    })

    // Should render empty div when no items
    expect(wrapper.text()).toBe('')
  })

  it('groups items by kind_code correctly', () => {
    const mockItems = [
      {
        id: '1',
        kind_code: 'LEVELING',
        kind_name: 'Leveling',
        plan_qty: 100,
        done_qty: 50,
        params: {},
        active_report_id: null,
      },
      {
        id: '2',
        kind_code: 'BOSS',
        kind_name: 'Boss',
        plan_qty: 10,
        done_qty: 5,
        params: {},
        active_report_id: null,
      },
    ]

    const wrapper = mount(ServiceDescription, {
      props: {
        items: mockItems,
        collapsed: false,
      },
      global: {
        provides: {
          attributeMap: mockAttributeMap,
        },
        stubs: {
          ServiceItemLabel: {
            template: '<div>Item Mock</div>',
            props: ['item', 'showCompleted', 'showProgress'],
          },
        },
      },
    })

    expect(wrapper.text()).toContain('LEVELING')
    expect(wrapper.text()).toContain('BOSS')
  })
})
