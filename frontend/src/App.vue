<script setup lang="ts">
import { useRoute } from 'vue-router'
import { useEventStore } from './stores/events'
import { useCreateEventDialog } from './composables/useCreateEventDialog'
import EventFormDialog from './components/EventFormDialog.vue'

const route = useRoute()
const eventStore = useEventStore()
const { isCreateDialogOpen, createDialogInitialDate, openCreateDialog, closeCreateDialog } =
  useCreateEventDialog()

async function handleCreate(payload: Parameters<typeof eventStore.createEvent>[0]) {
  const ok = await eventStore.createEvent(payload)
  if (ok) closeCreateDialog()
}
</script>

<template>
  <v-app>
    <v-app-bar class="border-b px-4" flat height="72">
      <span class="text-headline-small font-weight-bold">イベント管理</span>
      <v-spacer />
      <v-tabs :model-value="route.name as string" color="primary">
        <v-tab value="event-list" to="/">一覧</v-tab>
        <v-tab value="event-calendar" to="/calendar">カレンダー</v-tab>
      </v-tabs>
    </v-app-bar>

    <v-navigation-drawer permanent width="220" class="border-e">
      <div class="pa-3">
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          rounded="xl"
          size="large"
          block
          @click="openCreateDialog()"
        >
          イベントを追加
        </v-btn>
      </div>
    </v-navigation-drawer>

    <v-main class="bg-background fill-height">
      <router-view />
    </v-main>

    <EventFormDialog
      :model-value="isCreateDialogOpen"
      :event="null"
      :initial-date="createDialogInitialDate"
      :saving="false"
      @update:model-value="(value) => (value ? openCreateDialog() : closeCreateDialog())"
      @submit="handleCreate"
    />
  </v-app>
</template>
