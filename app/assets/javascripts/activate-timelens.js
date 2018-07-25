$(document).on("turbolinks:load", function() {
    $(".timelens:empty").each(function() {
        const t = this;
        timelens(this, {
            timeline: this.dataset.timeline,
            thumbnails: this.dataset.thumbnails,
            seek: function(position) {
                location.href =
                    "/v/" + t.dataset.slug + "#t=" + Math.round(position);
            }
        });
    });
});
