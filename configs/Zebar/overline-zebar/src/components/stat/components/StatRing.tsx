import { cn } from "../../../utils/cn";
import Ring from "./Ring";
import { systemStatThresholds } from "../defaults/thresholds";
import { LabelType } from "../types/labelType";
import { Thresholds } from "../types/thresholds";

interface StatRingProps {
  Icon: React.ReactNode;
  stat: string;
  threshold?: Thresholds;
}

export function StatRing({
  Icon,
  stat,
  threshold = systemStatThresholds,
}: StatRingProps) {
  function getNumbersFromString(str: string) {
    const numbers = str.match(/-?\d+/g)?.map(Number);
    return numbers && numbers.length > 0 ? numbers[0] : NaN;
  }

  function getThresholdLabel(value: number) {
    const range = threshold.find((r) => value >= r.min && value <= r.max);
    return range ? range.label : LabelType.DEFAULT;
  }

  const statAsInt = getNumbersFromString(stat);
  const thresholdLabel = getThresholdLabel(statAsInt);

  return (
    <div
      className={cn(
        "flex items-center justify-center gap-1.5",
        thresholdLabel === LabelType.DEFAULT && "text-text",
        thresholdLabel === LabelType.WARNING && "text-warning",
        thresholdLabel === LabelType.DANGER && "text-danger"
      )}
    >
      {Icon}
      <Ring
        className="w-3.5 h-3.5"
        percentage={statAsInt}
        strokeColor={cn(
          thresholdLabel === LabelType.DEFAULT && "stroke-success",
          thresholdLabel === LabelType.WARNING && "stroke-warning",
          thresholdLabel === LabelType.DANGER && "stroke-danger"
        )}
      />
    </div>
  );
}
