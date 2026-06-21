import { Link } from "@tanstack/react-router";
import { Card } from "#/components/ui/Card.tsx";

type TalkItem = {
	id: number;
	slug: string | null;
	title: string | null;
	thumbUrl: string | null;
};

// A single talk as a thumbnail card linking to its page. Reused by the
// conference grid and the home sections.
export function TalkCard({ slug, title, thumbUrl }: Omit<TalkItem, "id">) {
	return (
		<Link
			to="/v/$slug"
			params={{ slug: slug ?? "" }}
			className="block rounded-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
		>
			<Card className="h-full">
				<div className="aspect-video bg-muted">
					{thumbUrl && (
						<img
							src={thumbUrl}
							alt=""
							loading="lazy"
							className="h-full w-full object-cover transition-transform duration-200 group-hover:scale-105"
						/>
					)}
				</div>
				<div className="line-clamp-2 p-3 text-sm font-medium leading-snug">
					{title}
				</div>
			</Card>
		</Link>
	);
}

// Responsive auto-filling grid of talk cards.
export function TalkGrid({ talks }: { talks: TalkItem[] }) {
	return (
		<ul className="grid grid-cols-[repeat(auto-fill,minmax(220px,1fr))] gap-4">
			{talks.map((t) => (
				<li key={t.id}>
					<TalkCard slug={t.slug} title={t.title} thumbUrl={t.thumbUrl} />
				</li>
			))}
		</ul>
	);
}
