import { createRouter, createWebHistory } from 'vue-router'
import EventListView from '../views/EventListView.vue'
import EventCalendarView from '../views/EventCalendarView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'event-list', component: EventListView },
    { path: '/calendar', name: 'event-calendar', component: EventCalendarView },
  ],
})

export default router
