// Tiny classlist joiner for conditional Tailwind classes.
export function cx(...parts: Array<string | false | null | undefined>): string {
  return parts.filter(Boolean).join(' ')
}
