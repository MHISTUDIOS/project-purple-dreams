import { useEffect } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { useConfig } from "../context/ConfigContext";

export const useAutoTiling = () => {
  const queryClient = useQueryClient();
  const { autoTilingWebSocketUri, useAutoTiling: isAutoTilingEnabled } = useConfig();

  useEffect(() => {
    // Only connect to WebSocket if auto-tiling is enabled
    if (!isAutoTilingEnabled) return;

    const websocket = new WebSocket(autoTilingWebSocketUri);

    websocket.onopen = () => {
      websocket.send("sub -e window_managed");
    };

    websocket.onmessage = async (event) => {
      try {
        const response = JSON.parse(event.data);

        if (response.messageType === "client_response") {
          console.log(`Event subscription: ${response.success}`);
        } else if (response.messageType === "event_subscription") {
          const tilingSize = response?.data?.managedWindow?.tilingSize;

          if (tilingSize !== null && tilingSize <= 0.5) {
            websocket.send("c toggle-tiling-direction");
          }

          queryClient.setQueryData(["tilingSize"], tilingSize);
        }
      } catch (err) {
        console.error("Error parsing WebSocket message:", err);
      }
    };

    websocket.onerror = (error) => {
      console.error("WebSocket error:", error);
    };

    return () => {
      websocket.close();
    };
  }, [queryClient, autoTilingWebSocketUri, isAutoTilingEnabled]);

  return {
    tilingSize: queryClient.getQueryData(["tilingSize"]),
    isAutoTilingEnabled,
  };
};

export default useAutoTiling;
