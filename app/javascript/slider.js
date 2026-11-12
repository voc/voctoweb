$(function() {
  var initialPromotedHtml;

  function restorePromoted() {
    if(!initialPromotedHtml) {
      initialPromotedHtml = $('.promoted').html();
    }
    else {
      $('.promoted').html(initialPromotedHtml);
    }
  }

  function initSliders() {
    var $slider = $('.promoted .slider, .related .slider');
    var numberOfSlides = $slider.find('> .slide').length;
    var doAutoTransition = numberOfSlides > 5;
    //console.log('numberOfSlides=', numberOfSlides, 'doAutoTransition=', doAutoTransition);

    $slider.bxSlider({
      slideWidth: 200,
      minSlides: 1,
      maxSlides: 5,
      slideMargin: 35,

      captions: true,

      // Slides will automatically transition
      auto: doAutoTransition,
      pause: 3000,     // The amount of time (in ms) between each auto transition
      autoHover: true, // Auto show will pause when mouse hovers over slider
      moveSlides: 1    // The number of slides to move on transition.
    });
  }

  $(document).on('turbolinks:load', function() {
    restorePromoted();
    initSliders();
  });

  $(document).on('ready resize turbolinks:load', function() {
    $('.bx-viewport').css({
      'left': '50%',
      'margin-left': -parseInt($('.bx-wrapper').css('max-width')) / 2
    });
  });
});
