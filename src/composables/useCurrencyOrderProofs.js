import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'

export function useCurrencyOrderProofs() {
  const proofs = ref({})
  const uploading = ref(false)

  // Initialize empty proofs structure
  const initializeProofs = (orderType) => {
    const structure = {
      order_creation: {
        [orderType]: {
          description: '',
          files: [],
        },
      },
      order_processing: {
        purchase: {
          receiving: { description: '', files: [] },
          inventory_update: { description: '', files: [] },
        },
        sell: {
          delivery: { description: '', files: [] },
        },
      },
      order_completion: {
        [orderType]: {
          description: '',
          files: [],
        },
      },
      currency_exchange: {
        before_exchange: { description: '', files: [] },
        exchange_process: { description: '', files: [] },
        after_exchange: { description: '', files: [] },
      },
    }

    // Remove currency_exchange for non-exchange orders
    if (orderType !== 'sell' && orderType !== 'purchase') {
      delete structure.currency_exchange
    }

    return structure
  }

  // Upload proof files
  const uploadProofFiles = async (orderId, stage, category, files, description) => {
    uploading.value = true

    try {
      const uploadedFiles = []

      // Upload each file to Supabase Storage
      for (const file of files) {
        const fileName = `${orderId}/${stage}/${category}/${Date.now()}_${file.name}`

        const { error } = await supabase.storage
          .from('currency-order-proofs')
          .upload(fileName, file)

        if (error) throw error

        const {
          data: { publicUrl },
        } = supabase.storage.from('currency-order-proofs').getPublicUrl(fileName)

        uploadedFiles.push({
          url: publicUrl,
          type: file.type.startsWith('image/') ? 'image' : 'video',
          name: file.name,
          size: file.size,
          uploaded_at: new Date().toISOString(),
          uploaded_by: (await supabase.auth.getUser()).data.user?.id,
        })
      }

      // Update proofs in database
      await updateProofCategory(orderId, stage, category, {
        description,
        files: uploadedFiles,
      })

      return uploadedFiles
    } catch (error) {
      console.error('Upload failed:', error)
      throw error
    } finally {
      uploading.value = false
    }
  }

  // Update specific proof category
  const updateProofCategory = async (orderId, stage, category, data) => {
    const { data: currentOrder } = await supabase
      .from('currency_orders')
      .select('proofs, order_type')
      .eq('id', orderId)
      .single()

    if (!currentOrder) throw new Error('Order not found')

    const updatedProofs = { ...currentOrder.proofs }

    // Initialize stage if not exists
    if (!updatedProofs[stage]) {
      updatedProofs[stage] = {}
    }

    // Update category
    updatedProofs[stage][category] = data

    // Update database
    const { error } = await supabase
      .from('currency_orders')
      .update({ proofs: updatedProofs })
      .eq('id', orderId)

    if (error) throw error
  }

  // Get proofs by stage
  const getProofsByStage = computed(() => (stage) => {
    return proofs.value[stage] || {}
  })

  // Get proof files by stage and category
  const getProofFiles = computed(() => (stage, category) => {
    return proofs.value[stage]?.[category]?.files || []
  })

  // Get all proof files across all stages
  const getAllProofFiles = computed(() => {
    const allFiles = []

    Object.values(proofs.value).forEach((stage) => {
      Object.values(stage).forEach((category) => {
        if (category.files) {
          allFiles.push(...category.files)
        }
      })
    })

    return allFiles
  })

  // Remove proof file
  const removeProofFile = async (orderId, stage, category, fileIndex) => {
    const { data: currentOrder } = await supabase
      .from('currency_orders')
      .select('proofs')
      .eq('id', orderId)
      .single()

    if (!currentOrder) throw new Error('Order not found')

    const updatedProofs = { ...currentOrder.proofs }
    const files = [...updatedProofs[stage][category].files]

    // Remove file at index
    files.splice(fileIndex, 1)

    // Update files array
    updatedProofs[stage][category].files = files

    // Update database
    const { error } = await supabase
      .from('currency_orders')
      .update({ proofs: updatedProofs })
      .eq('id', orderId)

    if (error) throw error
  }

  // Load proofs for an order
  const loadProofs = async (orderId) => {
    const { data, error } = await supabase
      .from('currency_orders')
      .select('proofs, order_type')
      .eq('id', orderId)
      .single()

    if (error) throw error

    proofs.value = data.proofs || initializeProofs(data.order_type)
    return data
  }

  // Proof stages configuration
  const proofStages = computed(() => {
    const stages = [
      {
        key: 'order_creation',
        label: 'Bằng chứng khi tạo đơn',
        description: 'Thỏa thuận, screenshot, confirmation',
      },
      {
        key: 'order_processing',
        label: 'Bằng chứng khi xử lý',
        description: 'Nhận hàng, giao hàng, inventory',
      },
      {
        key: 'order_completion',
        label: 'Bằng chứng khi hoàn thành',
        description: 'Xác nhận hoàn thành, cuối cùng',
      },
    ]

    // Add currency exchange stage if needed
    if (Object.keys(proofs.value).includes('currency_exchange')) {
      stages.push({
        key: 'currency_exchange',
        label: 'Bằng chứng đổi currency',
        description: 'Before/after, quá trình đổi',
      })
    }

    return stages
  })

  return {
    proofs,
    uploading,
    initializeProofs,
    uploadProofFiles,
    updateProofCategory,
    getProofsByStage,
    getProofFiles,
    getAllProofFiles,
    removeProofFile,
    loadProofs,
    proofStages,
  }
}
