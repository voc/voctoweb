import type { ComponentProps } from "react";
import { cx } from "#/lib/cx.ts";

// Surface primitive using the card color role. Composable: pass children and
// extra classes; it stays a plain <div> so it works for links, articles, etc.
export function Card({ className, ...props }: ComponentProps<"div">) {
	return (
		<div
			className={cx(
				"group overflow-hidden rounded-xl border border-border bg-card text-card-foreground shadow-sm transition-shadow hover:shadow-md",
				className,
			)}
			{...props}
		/>
	);
}
