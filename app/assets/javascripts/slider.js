$(function() {
  function updateOpacity($slideElement) {
    $slideElement
      .siblings('.slide')
        .css('opacity', 0)
      .end()
      .css('opacity', 0.75)
      .nextWrap()
      .css('opacity', 0.85)
      .nextWrap()
      .css('opacity', 1)
      .nextWrap()
      .css('opacity', 0.85)
      .nextWrap()
      .css('opacity', 0.75)
  }

  $('.promoted .slider').bxSlider({
    slideWidth: 200,
    minSlides: 1,
    maxSlides: 5,
    slideMargin: 35,

    captions: true,

    auto: true,      // Slides will automatically transition
    pause: 3000,     // The amount of time (in ms) between each auto transition
    autoHover: true, // Auto show will pause when mouse hovers over slider
    moveSlides: 1,   // The number of slides to move on transition.
    onSlideBefore: updateOpacity,
    onSliderLoad: function() {
      var
        first = $('.promoted .slider .slide:not(.bx-clone)').first(),
        $first = $(first);

      updateOpacity($first);
    }
  });
});
