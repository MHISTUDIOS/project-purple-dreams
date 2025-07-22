import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import {
  getFlowLauncherPath,
  getUseAutoTiling,
  getAutoTilingWebSocketUri,
  getMediaMaxWidth
} from '../utils/getFromEnv';

interface ConfigContextType {
  flowLauncherPath: string;
  useAutoTiling: boolean;
  autoTilingWebSocketUri: string;
  mediaMaxWidth: string;
  isLoading: boolean;
}

const defaultConfig: ConfigContextType = {
  flowLauncherPath: 'C:\\Program Files\\FlowLauncher\\Flow.Launcher.exe',
  useAutoTiling: false,
  autoTilingWebSocketUri: 'ws://localhost:6123',
  mediaMaxWidth: '400',
  isLoading: true
};

const ConfigContext = createContext<ConfigContextType>(defaultConfig);

export const useConfig = () => useContext(ConfigContext);

interface ConfigProviderProps {
  children: ReactNode;
}

export const ConfigProvider: React.FC<ConfigProviderProps> = ({ children }) => {
  const [config, setConfig] = useState<ConfigContextType>(defaultConfig);

  useEffect(() => {
    const loadConfig = async () => {
      try {
        const [flowLauncherPath, useAutoTiling, autoTilingWebSocketUri, mediaMaxWidth] = await Promise.all([
          getFlowLauncherPath(),
          getUseAutoTiling(),
          getAutoTilingWebSocketUri(),
          getMediaMaxWidth(),
        ]);

        setConfig({
          flowLauncherPath,
          useAutoTiling,
          autoTilingWebSocketUri,
          mediaMaxWidth,
          isLoading: false
        });
      } catch (error) {
        console.error('Failed to load configuration:', error);
        setConfig(prev => ({ ...prev, isLoading: false }));
      }
    };

    loadConfig();
  }, []);

  return (
    <ConfigContext.Provider value={config}>
      {children}
    </ConfigContext.Provider>
  );
};
