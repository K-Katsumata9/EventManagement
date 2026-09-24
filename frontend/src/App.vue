<script setup lang="ts">
import { useRoute } from 'vue-router'

const route = useRoute()
</script>

<template>
  <v-app>
    <v-app-bar title="イベント管理">
      <v-tabs :model-value="route.name as string" align-tabs="end">
        <v-tab value="event-list" to="/">一覧</v-tab>
        <v-tab value="event-calendar" to="/calendar">カレンダー</v-tab>
      </v-tabs>
    </v-app-bar>
    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>
