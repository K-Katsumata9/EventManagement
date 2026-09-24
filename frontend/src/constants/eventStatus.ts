import type { EventStatus } from '../stores/events'

export const EVENT_STATUS_OPTIONS: { value: EventStatus; label: string; color: string }[] = [
  { value: 'scheduled', label: '予定', color: 'grey' },
  { value: 'in_progress', label: '対応中', color: 'amber' },
  { value: 'done', label: '完了', color: 'green' },
]

export function statusLabel(status: EventStatus): string {
  return EVENT_STATUS_OPTIONS.find((option) => option.value === status)?.label ?? status
}

export function statusColor(status: EventStatus): string {
  return EVENT_STATUS_OPTIONS.find((option) => option.value === status)?.color ?? 'grey'
}
