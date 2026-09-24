<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useEventStore } from '../stores/events'
import type { Event } from '../stores/events'
import type { EventPayload } from '../api/events'
import { statusColor } from '../constants/eventStatus'
import EventFormDialog from '../components/EventFormDialog.vue'

const eventStore = useEventStore()

const focus = ref('')

const dialogOpen = ref(false)
const editingEvent = ref<Event | null>(null)
const initialDate = ref<string | null>(null)
const saving = ref(false)

onMounted(() => {
  eventStore.fetchEvents()
})

const calendarEvents = computed(() =>
  eventStore.events.map((event) => ({
    name: event.title,
    start: event.start_date,
    end: event.end_date ?? event.start_date,
    color: statusColor(event.status),
    allDay: true,
    raw: event,
  })),
)

function openCreateDialog(date?: string) {
  editingEvent.value = null
  initialDate.value = date ?? null
  dialogOpen.value = true
}

function handleClickDate(_nativeEvent: MouseEvent, dateInfo: { date: string }) {
  openCreateDialog(dateInfo.date)
}

function handleClickEvent(_nativeEvent: MouseEvent, scope: { event: { raw: Event } }) {
  editingEvent.value = scope.event.raw
  initialDate.value = null
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
</script>

<template>
  <v-container>
    <div class="d-flex align-center justify-space-between mb-4">
      <h1 class="text-h5">カレンダー</h1>
      <v-btn color="primary" prepend-icon="mdi-plus" @click="openCreateDialog()">
        イベントを追加
      </v-btn>
    </div>

    <v-alert v-if="eventStore.error" type="error" class="mb-4" closable>
      {{ eventStore.error }}
    </v-alert>

    <v-sheet height="600">
      <v-calendar
        v-model="focus"
        :events="calendarEvents"
        type="month"
        event-overlap-mode="stack"
        @click:date="handleClickDate"
        @click:event="handleClickEvent"
      />
    </v-sheet>

    <EventFormDialog
      v-model="dialogOpen"
      :event="editingEvent"
      :initial-date="initialDate"
      :saving="saving"
      @submit="handleSubmit"
    />
  </v-container>
</template>
