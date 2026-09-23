import { defineStore } from 'pinia'

export interface Event {
  id: number
  title: string
  description: string | null
  startDate: string
  endDate: string | null
  status: 'scheduled' | 'in_progress' | 'done'
}

export const useEventStore = defineStore('events', {
  state: () => ({
    events: [] as Event[],
  }),
})
