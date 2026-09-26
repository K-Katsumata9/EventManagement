<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useEventStore } from '../stores/events'
import type { Event } from '../stores/events'
import type { EventPayload } from '../api/events'
import { statusColor } from '../constants/eventStatus'
import { useCreateEventDialog } from '../composables/useCreateEventDialog'
import EventFormDialog from '../components/EventFormDialog.vue'

const eventStore = useEventStore()
const { isCreateDialogOpen, openCreateDialog } = useCreateEventDialog()

const focus = ref('')
const calendarRef = ref<{ title: string; prev: () => void; next: () => void } | null>(null)

const editDialogOpen = ref(false)
const editingEvent = ref<Event | null>(null)
const saving = ref(false)

async function reload() {
  await eventStore.fetchEvents()
}

onMounted(reload)
watch(isCreateDialogOpen, (open, wasOpen) => {
  if (!open && wasOpen) reload()
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

const calendarTitle = computed(() => calendarRef.value?.title ?? '')

function goToPrevMonth() {
  calendarRef.value?.prev()
}

function goToNextMonth() {
  calendarRef.value?.next()
}

function goToToday() {
  focus.value = ''
}

function handleClickDate(_nativeEvent: MouseEvent, dateInfo: { date: string }) {
  openCreateDialog(dateInfo.date)
}

function handleClickEvent(_nativeEvent: MouseEvent, scope: { event: { raw: Event } }) {
  editingEvent.value = scope.event.raw
  editDialogOpen.value = true
}

async function handleSubmit(payload: EventPayload) {
  if (!editingEvent.value) return
  saving.value = true
  const ok = await eventStore.updateEvent(editingEvent.value.id, payload)
  saving.value = false
  if (ok) editDialogOpen.value = false
}
</script>

<template>
  <div class="calendar-page d-flex flex-column">
    <v-alert v-if="eventStore.error" type="error" class="mx-3 mt-2 flex-shrink-0" rounded="lg" closable>
      {{ eventStore.error }}
    </v-alert>

    <div class="d-flex align-center ga-2 px-3 py-2 border-b flex-shrink-0">
      <v-btn variant="outlined" color="default" size="small" @click="goToToday">今日</v-btn>
      <v-btn icon="mdi-chevron-left" variant="text" density="comfortable" @click="goToPrevMonth" />
      <v-btn icon="mdi-chevron-right" variant="text" density="comfortable" @click="goToNextMonth" />
      <div class="text-title-large font-weight-medium ml-2">{{ calendarTitle }}</div>
    </div>

    <v-calendar
      ref="calendarRef"
      v-model="focus"
      class="flex-grow-1"
      :events="calendarEvents"
      type="month"
      event-overlap-mode="stack"
      @click:date="handleClickDate"
      @click:event="handleClickEvent"
    />

    <EventFormDialog
      v-model="editDialogOpen"
      :event="editingEvent"
      :saving="saving"
      @submit="handleSubmit"
    />
  </div>
</template>

<style scoped>
.calendar-page {
  height: 100%;
  min-height: 0;
}

.calendar-page :deep(.v-calendar) {
  height: 100%;
  min-height: 0;
}

.calendar-page :deep(.v-calendar-weekly) {
  height: 100%;
}

.calendar-page :deep(.v-calendar-weekly__head-weekday) {
  padding-top: 4px;
  line-height: 1.4;
}

.calendar-page :deep(.v-calendar-weekly__day-label) {
  margin-bottom: 4px;
}

.calendar-page :deep(.v-calendar-weekly__day-label .v-icon-btn) {
  width: 26px !important;
  height: 26px !important;
  font-size: 12px;
}
</style>
