#!/usr/bin/env sh
# Sync the Drizzle schema FROM the (Rails-owned) database. The generated dir is
# machine-owned. Two post-pull fixups normalize known drizzle-kit introspection
# quirks against this DB, so the output actually compiles and serializes:
set -e

pnpm drizzle-kit pull

F=src/db/generated/schema.ts

# 1) Empty-string varchar defaults introspect as `.default(')` — invalid TS.
sed -i "s/\.default(')/.default(\"\")/g" "$F"

# 2) bigserial PKs come back as `mode: "bigint"` → JS bigint, which can't be
#    JSON-serialized across TanStack server fns (and mismatches the integer FK
#    columns for relations). IDs are small; number mode is safe.
sed -i 's/bigserial({ mode: "bigint" })/bigserial({ mode: "number" })/g' "$F"

# 3) We only ever pull (Rails owns the schema), so drizzle-kit's migration
#    baseline + snapshot are dead weight. Keep schema.ts; drop the rest.
#    (Empty generated relations.ts too — we maintain our own src/db/relations.ts.)
rm -f src/db/generated/relations.ts
rm -f src/db/generated/*.sql
rm -rf src/db/generated/meta
pnpm exec biome check --write --unsafe "$F" >/dev/null 2>&1 || true

echo "✓ schema pulled + normalized → $F"
