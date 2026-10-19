import React, { useEffect } from 'react'
import { debugData } from '@/hook'
import { isEnvBrowser } from '@/utils'
import { ContextMenu } from '@/features'
import './index.css'

const BROWSER = isEnvBrowser()

// Browser preview (npm run dev): right-click anywhere to open this demo menu.
const App: React.FC = () => {
  useEffect(() => {
    if (!BROWSER) return
    debugData([
      {
        action: 'nui:context-menu:setData',
        data: [
          { id: 1, name: 'Open the front left door', icon: 'fa-solid fa-door-open' },
          { id: 2, name: 'Windows', icon: 'fa-solid fa-window-maximize', child: [
            { id: 3, name: 'Roll down front left window', icon: 'fa-solid fa-arrow-down' },
            { id: 4, name: 'Roll down front right window', icon: 'fa-solid fa-arrow-down' },
          ] },
          { id: 5, name: 'Lock / Unlock', icon: 'fa-solid fa-lock' },
          { id: 6, name: 'Search the trunk', icon: 'fa-solid fa-magnifying-glass', description: 'Requires a lockpick.' },
          { id: 7, name: 'Police', icon: 'fa-solid fa-shield-halved', child: [
            { id: 8, name: 'Check plate', icon: 'fa-solid fa-id-card' },
            { id: 9, name: 'Impound', icon: 'fa-solid fa-truck-pickup' },
          ] },
          { id: 10, name: 'Plate', icon: 'fa-solid fa-id-card', value: 'OFF 123' },
          { id: 11, name: 'Engine running', icon: 'fa-solid fa-power-off', checkable: true, checked: true },
          { id: 12, name: 'Delete vehicle', icon: 'fa-solid fa-trash', style: { color: [239, 68, 68] } },
        ],
      },
    ], 0)
    debugData([{ action: 'nui:context-menu:visible', data: true }], 50)
  }, [])

  return <ContextMenu />
}

export default App
