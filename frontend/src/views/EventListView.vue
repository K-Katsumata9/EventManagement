<script setup lang="ts">
import { onMounted, ref } from 'vue'
import apiClient from '../api/client'

const healthStatus = ref<string>('確認中...')

onMounted(async () => {
  try {
    const response = await apiClient.get('/api/health')
    healthStatus.value = response.data.status
  } catch {
    healthStatus.value = 'API接続エラー'
  }
})
</script>

<template>
  <v-container>
    <h1>イベント一覧</h1>
    <p>バックエンド疎通確認: {{ healthStatus }}</p>
  </v-container>
</template>
