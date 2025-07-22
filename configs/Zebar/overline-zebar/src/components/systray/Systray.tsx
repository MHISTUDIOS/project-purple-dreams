import { useState } from "react";
import { SystrayOutput } from "zebar";
import { ExpandingCarousel } from "./components/ExpandingCarousel";
import { SystrayItem } from "./components/SystrayItem";

type SystrayProps = {
  systray: SystrayOutput | null;
}

export default function Systray({ systray }: SystrayProps) {
  if (!systray) return;
  const icons = systray.icons;

  const [expanded, setExpanded] = useState(false);
  const ICON_CUTOFF = 4;

  // Toggle icon expansion on Shift+Click
  const handleClick = (e: React.MouseEvent) => {
    if (e.shiftKey) {
      e.preventDefault();
      setExpanded(!expanded);
    }
  }

  const systrayIcons = icons.map((item) => <SystrayItem key={item.id} systray={systray} icon={item} />);

  return (
    <div className="flex items-center gap-1.5" onClick={handleClick}>
      <ExpandingCarousel items={systrayIcons} expanded={expanded} gap={6} itemWidth={16} visibleCount={ICON_CUTOFF} />
    </div>
  )
}

