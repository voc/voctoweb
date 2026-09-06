// Must be the first import in any entry point. ES module evaluation order:
// ALL of a module's own imports run fully (in declaration order) before ANY
// of its own top-level statements do - regardless of source order. So doing
// `import jquery from 'jquery'; window.jQuery = jquery;` directly in an entry
// point runs the assignment dead last, after every sibling import (bxslider,
// bootstrap, jquery-ujs, ...) has already evaluated expecting a global jQuery
// to exist. Pulling it into its own leading dependency fixes that: this
// module's body (the assignment) completes before the entry point moves on
// to evaluate its next listed import.
import jquery from 'jquery';
window.jQuery = jquery;
window.$ = jquery;
