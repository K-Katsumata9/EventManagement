import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import { createVuetify } from 'vuetify'

export default createVuetify({
  icons: {
    defaultSet: 'mdi',
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#4F46E5',
          secondary: '#6366F1',
          background: '#F5F6FA',
          surface: '#FFFFFF',
        },
      },
    },
  },
  defaults: {
    VCard: {
      rounded: 'lg',
      elevation: 0,
    },
    VBtn: {
      rounded: 'lg',
    },
    VTextField: {
      variant: 'outlined',
      rounded: 'lg',
      density: 'comfortable',
    },
    VTextarea: {
      variant: 'outlined',
      rounded: 'lg',
      density: 'comfortable',
    },
    VSelect: {
      variant: 'outlined',
      rounded: 'lg',
      density: 'comfortable',
    },
    VDialog: {
      VCard: {
        rounded: 'xl',
      },
    },
    VDataTable: {
      rounded: 'lg',
    },
    VAppBar: {
      elevation: 0,
      color: 'surface',
    },
    VChip: {
      rounded: 'lg',
    },
  },
})
