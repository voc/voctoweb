import { Search } from "lucide-react";

// Plain GET form → /search?q=…. Works without JS (full navigation, SSR'd) and
// with JS alike; no client wiring needed for the basic case.
export function SearchForm({ defaultValue = "" }: { defaultValue?: string }) {
	return (
		<form
			method="get"
			action="/search"
			className="flex max-w-xl items-center gap-2 rounded-lg border border-border bg-card px-3 py-2 focus-within:ring-2 focus-within:ring-primary"
		>
			<Search size={18} aria-hidden className="shrink-0 text-muted-foreground" />
			<input
				type="search"
				name="q"
				defaultValue={defaultValue}
				placeholder="Search talks…"
				aria-label="Search talks"
				className="w-full bg-transparent outline-none placeholder:text-muted-foreground"
			/>
			<button
				type="submit"
				className="shrink-0 rounded-md bg-primary px-3 py-1 text-sm font-medium text-primary-foreground"
			>
				Search
			</button>
		</form>
	);
}
