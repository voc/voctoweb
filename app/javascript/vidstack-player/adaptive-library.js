import * as dashjs from "dashjs";
import { isDASHProvider } from "vidstack";

// Hand Vidstack the bundled dash.js instead of letting it fetch the library
// from a public CDN (jsdelivr) at runtime; same IP-leak fix as tng. Only DASH
// is supported, HLS sources are never passed to this player.
export function useLocalAdaptiveLibrary(provider) {
  if (isDASHProvider(provider)) {
    provider.library = () => Promise.resolve({ default: dashjs });
  }
}
