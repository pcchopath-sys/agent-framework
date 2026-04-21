const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    selectFolder: () => ipcRenderer.invoke('dialog:openDirectory'),
    chat: (payload) => ipcRenderer.invoke('ai:chat', payload),
    getStatus: () => ipcRenderer.invoke('ai:getStatus'),
    getModels: () => ipcRenderer.invoke('ai:getModels'),
    getTokenStats: () => ipcRenderer.invoke('ai:getTokenStats'),
    getChat: (projectId) => ipcRenderer.invoke('ai:getChat', { projectId }),
    getProjects: () => ipcRenderer.invoke('ai:getProjects'),
    addProject: (project) => ipcRenderer.invoke('ai:addProject', project),
    deleteProject: (projectId) => ipcRenderer.invoke('ai:deleteProject', { projectId }),
    stageFiles: (files) => ipcRenderer.invoke('fs:stageFiles', { files }),
    listFiles: (path) => ipcRenderer.invoke('fs:listFiles', { path }),
    readFile: (filePath) => ipcRenderer.invoke('fs:readFile', { filePath }),
    writeFile: (data) => ipcRenderer.invoke('fs:writeFile', data),
    copyToClipboard: (text) => ipcRenderer.invoke('clipboard:write', text),
    readFromClipboard: () => ipcRenderer.invoke('clipboard:read'),
    windowMinimize: () => ipcRenderer.invoke('window:minimize'),
    windowMaximize: () => ipcRenderer.invoke('window:maximize'),
    windowClose: () => ipcRenderer.invoke('window:close'),
    getApiConfig: () => ipcRenderer.invoke('ai:getApiConfig'),
    setApiConfig: (provider, key) => ipcRenderer.invoke('ai:setApiConfig', { provider, key }),
});
