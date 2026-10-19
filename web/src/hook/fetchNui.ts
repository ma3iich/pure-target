import { isEnvBrowser } from "@/utils";

export async function fetchNui<T = unknown>(
  eventName: string,
  data?: unknown,
  mock?: { data: T; delay?: number }
): Promise<T> {
  if (isEnvBrowser()) {
    if (!mock) return await new Promise<T>((resolve) => resolve(undefined as T));
    await new Promise((resolve) => setTimeout(resolve, mock.delay ?? 0));
    return mock.data;
  }

  const options = {
    method: "post",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(data),
  };

  const resourceName = window.GetParentResourceName
    ? window.GetParentResourceName()
    : "nui-frame-app";

  const resp = await fetch(`https://${resourceName}/${eventName}`, options);

  const text = await resp.text();
  if (!text || text.trim() === "") return undefined as T;

  try {
    return JSON.parse(text) as T;
  } catch {
    return undefined as T;
  }
}