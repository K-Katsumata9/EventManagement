<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useEventStore } from '../stores/events'
import type { Event, EventStatus } from '../stores/events'
import type { EventPayload } from '../api/events'
import { EVENT_STATUS_OPTIONS, statusColor, statusLabel } from '../constants/eventStatus'
import { useCreateEventDialog } from '../composables/useCreateEventDialog'
import EventFormDialog from '../components/EventFormDialog.vue'

const eventStore = useEventStore()
const { isCreateDialogOpen } = useCreateEventDialog()

const statusFilter = ref<EventStatus | null>(null)
const sortDirection = ref<'asc' | 'desc'>('asc')

const dialogOpen = ref(false)
const editingEvent = ref<Event | null>(null)
const saving = ref(false)

const deleteTarget = ref<Event | null>(null)
const deleteDialogOpen = ref(false)

const headers = [
  { title: 'タイトル', key: 'title' },
  { title: '開始日', key: 'start_date' },
  { title: '終了日', key: 'end_date' },
  { title: 'ステータス', key: 'status' },
  { title: '操作', key: 'actions', sortable: false },
]

async function reload() {
  await eventStore.fetchEvents({
    status: statusFilter.value ?? undefined,
    sort: sortDirection.value,
  })
}

onMounted(reload)
watch([statusFilter, sortDirection], reload)
watch(isCreateDialogOpen, (open, wasOpen) => {
  if (!open && wasOpen) reload()
})

function openEditDialog(event: Event) {
  editingEvent.value = event
  dialogOpen.value = true
}

async function handleSubmit(payload: EventPayload) {
  saving.value = true
  const ok = editingEvent.value
    ? await eventStore.updateEvent(editingEvent.value.id, payload)
    : await eventStore.createEvent(payload)
  saving.value = false
  if (ok) dialogOpen.value = false
}

function confirmDelete(event: Event) {
  deleteTarget.value = event
  deleteDialogOpen.value = true
}

async function handleDelete() {
  if (!deleteTarget.value) return
  await eventStore.deleteEvent(deleteTarget.value.id)
  deleteDialogOpen.value = false
  deleteTarget.value = null
}

async function handleStatusChange(event: Event, status: EventStatus) {
  await eventStore.updateEvent(event.id, {
    title: event.title,
    description: event.description,
    start_date: event.start_date,
    end_date: event.end_date,
    status,
  })
}

const sortIcon = computed(() =>
  sortDirection.value === 'asc' ? 'mdi-sort-ascending' : 'mdi-sort-descending',
)

function toggleSortDirection() {
  sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
}
</script>

<template>
  <v-container class="py-6" max-width="1100">
    <v-alert v-if="eventStore.error" type="error" class="mb-4" rounded="lg" closable>
      {{ eventStore.error }}
    </v-alert>

    <v-card class="pa-4 mb-4" border>
      <v-row align="center" no-gutters>
        <v-col cols="12" sm="4">
          <v-select
            v-model="statusFilter"
            label="ステータスで絞り込み"
            :items="EVENT_STATUS_OPTIONS"
            item-title="label"
            item-value="value"
            clearable
            density="compact"
            hide-details
          />
        </v-col>
        <v-col cols="12" sm="4" class="ml-2">
          <v-btn variant="text" color="primary" :prepend-icon="sortIcon" @click="toggleSortDirection">
            開始日で並び替え
          </v-btn>
        </v-col>
      </v-row>
    </v-card>

    <v-card border>
      <v-data-table
        :headers="headers"
        :items="eventStore.events"
        :loading="eventStore.loading"
        item-value="id"
      >
        <template #item.status="{ item }">
          <v-select
            :model-value="item.status"
            :items="EVENT_STATUS_OPTIONS"
            item-title="label"
            item-value="value"
            density="compact"
            hide-details
            variant="plain"
            @update:model-value="(value) => handleStatusChange(item, value as EventStatus)"
          >
            <template #selection="{ item: selected }">
              <v-chip :color="statusColor(selected.value)" size="small" label>
                {{ statusLabel(selected.value) }}
              </v-chip>
            </template>
          </v-select>
        </template>
        <template #item.actions="{ item }">
          <v-btn icon="mdi-pencil" variant="text" size="small" @click="openEditDialog(item)" />
          <v-btn icon="mdi-delete" variant="text" size="small" @click="confirmDelete(item)" />
        </template>
      </v-data-table>
    </v-card>

    <EventFormDialog
      v-model="dialogOpen"
      :event="editingEvent"
      :saving="saving"
      @submit="handleSubmit"
    />

    <v-dialog v-model="deleteDialogOpen" max-width="400">
      <v-card title="イベントを削除しますか？" rounded="xl">
        <v-card-text v-if="deleteTarget">「{{ deleteTarget.title }}」を削除します。</v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn @click="deleteDialogOpen = false">キャンセル</v-btn>
          <v-btn color="error" variant="flat" @click="handleDelete">削除</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>
