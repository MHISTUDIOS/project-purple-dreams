import { Maximize, Minimize } from "lucide-react";
import { IconButton } from "../IconButton";
import { CommandProps } from "./types/command";

// TODO: Make issue to GlazeWM to export window types.
enum WindowType {
  TILING = "tiling",
  FLOATING = "floating",
  MINIMIZED = "minimized",
  FULLSCREEN = "fullscreen",
}

export const Floating = ({ glazewm }: CommandProps) => {
  const tooltipText = "Toggle fullscreen state of window";
  const isFloating =
    glazewm?.focusedContainer.state.type === WindowType.FLOATING;
  const command = isFloating ? "set-tiling" : "set-floating";
  console.log(glazewm?.focusedContainer.state.type);

  return (
    <IconButton
      animateKey={isFloating ? "maximise" : "minimise"}
      key={command}
      title={tooltipText}
      onClick={() => glazewm?.runCommand(command)}
      icon={isFloating ? Minimize : Maximize}
    />
  );
};
