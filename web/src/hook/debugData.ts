import { isEnvBrowser } from "@/utils";
const IS_DEVELOPMENT = import.meta.env.MODE === "development";

interface DebugEvent<T = unknown> {
  action: string;
  data: T;
}

export const debugData = <P>(events: DebugEvent<P>[], timer = 1000): void => {
  if (IS_DEVELOPMENT && isEnvBrowser()) {
    for (const event of events) {
      setTimeout(() => {
        window.dispatchEvent(
          new MessageEvent("message", {
            data: {
              action: event.action,
              data: event.data,
            },
          })
        );
      }, timer);
    }
  }
};