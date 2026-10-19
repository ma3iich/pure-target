/// <reference types="vite/client" />

interface Window {
  invokeNative?: (action: string, data: string) => void;
  GetParentResourceName?: () => string;
}
