
export const isEnvBrowser = (): boolean => !window.invokeNative;
export const noop = (): void => { };
export const capitalize = (val: string) => String(val).charAt(0).toUpperCase() + String(val).slice(1);
