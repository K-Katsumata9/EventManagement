import apiClient from './client'
import type { Event, EventStatus } from '../stores/events'

export interface EventPayload {
  title: string
  description?: string | null
  start_date: string
  end_date?: string | null
  status?: EventStatus
}

export interface FetchEventsParams {
  status?: EventStatus
  sort?: 'asc' | 'desc'
}

export async function fetchEvents(params: FetchEventsParams = {}): Promise<Event[]> {
  const response = await apiClient.get<Event[]>('/api/events', { params })
  return response.data
}

export async function createEvent(payload: EventPayload): Promise<Event> {
  const response = await apiClient.post<Event>('/api/events', { event: payload })
  return response.data
}

export async function updateEvent(id: number, payload: EventPayload): Promise<Event> {
  const response = await apiClient.patch<Event>(`/api/events/${id}`, { event: payload })
  return response.data
}

export async function deleteEvent(id: number): Promise<void> {
  await apiClient.delete(`/api/events/${id}`)
}
