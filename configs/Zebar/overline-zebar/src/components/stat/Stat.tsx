import { StatInline } from "./components/StatInline";
import { StatRing } from "./components/StatRing";
import { systemStatThresholds, weatherThresholds } from "./defaults/thresholds";
import { Thresholds } from "./types/thresholds";

interface StatProps {
  Icon: React.ReactNode;
  stat: string;
  threshold?: Thresholds;
  type: "ring" | "inline";
}

export default function Stat(props: StatProps) {
  const { type, ...p } = props;
  switch (type) {
    case "ring":
      return (
        <StatRing {...p} threshold={p.threshold ?? systemStatThresholds} />
      );
    case "inline":
      return <StatInline {...p} threshold={p.threshold ?? weatherThresholds} />;
    default:
      return null;
  }
}
