<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { Event, EventStatus } from '../stores/events'
import type { EventPayload } from '../api/events'
import { EVENT_STATUS_OPTIONS } from '../constants/eventStatus'

const props = defineProps<{
  modelValue: boolean
  event: Event | null
  saving: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  submit: [payload: EventPayload]
}>()

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emit('update:modelValue', value),
})

const isEditMode = computed(() => props.event !== null)

const form = ref<{
  title: string
  description: string
  start_date: string
  end_date: string
  status: EventStatus
}>({
  title: '',
  description: '',
  start_date: '',
  end_date: '',
  status: 'scheduled',
})

const titleRules = [(value: string) => !!value || 'タイトルは必須です']
const startDateRules = [(value: string) => !!value || '開始日は必須です']

function resetForm() {
  if (props.event) {
    form.value = {
      title: props.event.title,
      description: props.event.description ?? '',
      start_date: props.event.start_date,
      end_date: props.event.end_date ?? '',
      status: props.event.status,
    }
  } else {
    form.value = {
      title: '',
      description: '',
      start_date: '',
      end_date: '',
      status: 'scheduled',
    }
  }
}

watch(
  () => [props.modelValue, props.event],
  () => {
    if (props.modelValue) resetForm()
  },
  { immediate: true },
)

function handleSubmit() {
  emit('submit', {
    title: form.value.title,
    description: form.value.description || null,
    start_date: form.value.start_date,
    end_date: form.value.end_date || null,
    status: form.value.status,
  })
}
</script>

<template>
  <v-dialog v-model="isOpen" max-width="480">
    <v-card :title="isEditMode ? 'イベントを編集' : 'イベントを追加'">
      <v-form @submit.prevent="handleSubmit">
        <v-card-text>
          <v-text-field
            v-model="form.title"
            label="タイトル"
            :rules="titleRules"
            required
          />
          <v-textarea v-model="form.description" label="詳細" rows="3" />
          <v-text-field
            v-model="form.start_date"
            label="開始日"
            type="date"
            :rules="startDateRules"
            required
          />
          <v-text-field v-model="form.end_date" label="終了日（任意）" type="date" />
          <v-select
            v-model="form.status"
            label="ステータス"
            :items="EVENT_STATUS_OPTIONS"
            item-title="label"
            item-value="value"
          />
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn @click="isOpen = false">キャンセル</v-btn>
          <v-btn color="primary" type="submit" :loading="saving">保存</v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
  </v-dialog>
</template>
