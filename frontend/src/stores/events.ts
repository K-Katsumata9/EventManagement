import { defineStore } from 'pinia'
import axios from 'axios'
import * as eventsApi from '../api/events'
import type { EventPayload, FetchEventsParams } from '../api/events'

export type EventStatus = 'scheduled' | 'in_progress' | 'done'

export interface Event {
  id: number
  title: string
  description: string | null
  start_date: string
  end_date: string | null
  status: EventStatus
  created_at: string
  updated_at: string
}

function extractErrorMessage(error: unknown): string {
  if (axios.isAxiosError(error) && error.response?.data?.errors) {
    return (error.response.data.errors as string[]).join(', ')
  }
  return '通信エラーが発生しました'
}

export const useEventStore = defineStore('events', {
  state: () => ({
    events: [] as Event[],
    loading: false,
    error: null as string | null,
  }),
  actions: {
    async fetchEvents(params: FetchEventsParams = {}) {
      this.loading = true
      this.error = null
      try {
        this.events = await eventsApi.fetchEvents(params)
      } catch (error) {
        this.error = extractErrorMessage(error)
      } finally {
        this.loading = false
      }
    },

    async createEvent(payload: EventPayload) {
      this.error = null
      try {
        await eventsApi.createEvent(payload)
        await this.fetchEvents()
        return true
      } catch (error) {
        this.error = extractErrorMessage(error)
        return false
      }
    },

    async updateEvent(id: number, payload: EventPayload) {
      this.error = null
      try {
        await eventsApi.updateEvent(id, payload)
        await this.fetchEvents()
        return true
      } catch (error) {
        this.error = extractErrorMessage(error)
        return false
      }
    },

    async deleteEvent(id: number) {
      this.error = null
      try {
        await eventsApi.deleteEvent(id)
        await this.fetchEvents()
        return true
      } catch (error) {
        this.error = extractErrorMessage(error)
        return false
      }
    },
  },
})
