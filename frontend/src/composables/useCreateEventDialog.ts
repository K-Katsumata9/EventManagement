import { ref } from 'vue'

const isOpen = ref(false)
const initialDate = ref<string | null>(null)

export function useCreateEventDialog() {
  function openCreateDialog(date?: string | null) {
    initialDate.value = date ?? null
    isOpen.value = true
  }

  function closeCreateDialog() {
    isOpen.value = false
  }

  return {
    isCreateDialogOpen: isOpen,
    createDialogInitialDate: initialDate,
    openCreateDialog,
    closeCreateDialog,
  }
}
