// Closure to protect local variable "var hash"
(function(ns) {

  ns.replaceHash = function(newhash) {
    if ((''+newhash).charAt(0) !== '#')
      newhash = '#' + newhash;

    if(window.history && window.history.replaceState) {
      history.replaceState({url: window.location.href}, '', newhash);
    }
    else
    {
      window.location.hash = newhash;
    }
  }

})(window.location);
