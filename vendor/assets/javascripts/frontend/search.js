$(function() {
	var
		$search = $('.search'),
		$results = $('.results'),
		$statistics = $results.find('.statistics'),
		$paging = $results.find('.paging'),
		$pagingPostfix = $paging.find('.postfix'),
		$pagingTemplate = $paging.find('.template').detach(),
		$template = $results.find('> ol > li.template').detach(),
		$noresults = $results.find('> ol > li.no-results').detach(),
		baseUrl = window.location.protocol+'//'+window.location.host+window.location.pathname,
		baseTitleTpl = $search.data('titletpl'),
		pageNr = 0,
		perPage = 15;

	$search
		.find('input.text')
		.focus()
	.end()
	.on('click', '.submit', function(e, triggerOrigin, displayPage) {
		e.preventDefault();
		var
			$submit = $(this),
			$form = $submit.closest('form'),
			$input = $form.find('input.text'),
			term = $input.val(),
			lterm = term.toLowerCase(),
			title = baseTitleTpl.replace('#', $input.val());

		displayPage = displayPage || 0;

		document.title = title;
		if(window.history && window.history.pushState)
			window.history.pushState({}, title, '?' + (displayPage > 0 ? 'p='+displayPage+'&' : '') + 'q='+encodeURIComponent(term));

		$input.blur();
		$('#media-search input[name=q]').val(term);
		$.ajax({
			dataType: $.support.cors ? 'json' : 'jsonp',
			url: window.location.protocol+'//koeln.media.ccc.de/search/api/term',
			type: 'post',
			data: {
				term: lterm,
				displayPage: displayPage,
				perPage: perPage
			},
			success: function(res) {
				var
					conferenceSearchBase = $template.find('.conference-search').data('titletpl'),
					eventSearchBase = $template.find('.event-search').data('titletpl'),
					$h1 = $search.find('form h1'),
					$list = $results
						.find('> ol')
						.attr('start', displayPage * perPage + 1)
						.find('> li')
							.remove()
						.end();

				$h1.text($h1.data('resulttpl').replace('#', $input.val()));

				$statistics
					.find('.start')
						.text(displayPage * perPage + 1)
					.end()
					.find('.end')
						.text(displayPage * perPage + res.hits.hits.length)
					.end()
					.find('.total')
						.text(res.hits.total)
					.end()
					.find('.runtime')
						.text(res.took);

				$paging.toggleClass('visible', res.hits.total > res.hits.hits.length);
				if(res.hits.total > res.hits.hits.length) {
					$paging.find('li.page').remove();
					var
						maxpages = res.hits.total / perPage,
						npages = Math.min(Math.max(10, displayPage+3), Math.ceil(maxpages));

					for (var i = 0; i < npages; i++) {
						$pagingTemplate
							.clone()
							.removeClass('template')
							.toggleClass('active', i == displayPage)
							.find('a')
								.attr('href', '?p='+i+'&q='+encodeURIComponent(term))
								.data('page', i)
							.end()
							.find('.number')
								.text(i+1)
							.end()
							.insertBefore($pagingPostfix);
					}

					$paging
						.find('.next')
							.toggleClass('visible', displayPage < maxpages-1)
							.find('> a')
								.attr('href', '?p='+(displayPage+1)+'&q='+encodeURIComponent(term))
								.data('page', displayPage+1)
							.end()
						.end()
						.find('.prev')
							.toggleClass('visible', displayPage > 0)
							.find('> a')
								.attr('href', '?p='+(displayPage-1)+'&q='+encodeURIComponent(term))
								.data('page', displayPage-1)
				}

				if(res.hits.hits.length == 0) {
					$noresults.appendTo($list);
				}
				else {
					jQuery.each(res.hits.hits, function(idx, hit) {
						var
							quality = hit._score * 100 / res.hits.max_score,
							logourl = hit._source.conference.logo;

						if(logourl.match(/\.(png|jpg|jpeg|gif)$/)) {
							logourl = logourl.replace('http://static.media.ccc.de/media/', '/images/logos/');
							logourl = logourl.substr(0, logourl.lastIndexOf('.')) + '.png';
						}
						else {
							logourl = '/images/logos/unknown.png';
						}


						var $item = $template
							.clone()
							.appendTo($list)
							.attr('data-quality', quality) // .data() does not show up in the DOM and this is mainly for debugging
							.addClass(
								quality > 80 ? 'high' :
								quality > 50 ? 'medium' :
								quality > 30 ? 'low' :
								'nonsense'
							)
							.removeClass('template')
							.find('h3 .number')
								.text(displayPage * perPage + 1 + idx)
							.end()
							.find('h3 .t')
								.text(hit._source.event.title)
							.end()
							.find('img.conference-logo')
								.attr('alt', hit._source.conference.title)
								.attr('src', logourl)
							.end()
							.find('a.conference-url')
								.attr('href', hit._source.event.frontend_link)
							.end()
							.find('.recording_length .t')
								.text(Math.round(parseInt(hit._source.event.length) / 60)+' min')
							.end()
							.find('.date .t')
								.text(hit._source.event.date)
							.end()
							.find('.persons .t')
								.html(personlinks(hit._source.event.persons))
							.end()
							.find('.persons.fa')
								.addClass(hit._source.event.persons.length > 1 ? 'fa-group' : 'fa-user')
							.end();
					});
				}

				$form.addClass('fullsize');
				window.scrollTo(0, 0);
				if(triggerOrigin == 'param') {
					$results.removeClass('initial');
				}

				else if($form.hasClass('initial'))
				{
					$form.add($results).css({opacity: 0}).removeClass('initial').animate({
						opacity: 1
					})
				}
			}
		});

		if(triggerOrigin == 'param') {
			$form.removeClass('initial');
		}
		else if($form.hasClass('initial'))
		{
			$form.animate({
				opacity: 0
			}, {
				duration: 0.75
			})
		}
	})
	.on('click', '.paging a', function(e) {
		e.preventDefault();
		$search
			.find('.submit')
			.trigger('click', ['param', $(this).data('page')]);
	});

	var param = $.url().param();
	if(param.q) {
		$search
			.find('input.text')
			.val(param.q)
		.end()
			.find('.submit')
			.trigger('click', ['param', param.p]);
	}

	function personlinks(persons) {
		if(persons.length == 0) {
			return 'n/a';
		} else if(persons.length < 3) {
			return linkify_personnames(persons).join(' and ')
		} else {
			return linkify_personnames(persons.slice(0, -2)).join(', ') + ', ' + linkify_personnames(persons.slice(-2)).join(' and ')
		}
	}

	function linkify_personnames(personnames)
	{
		for (var i = 0; i < personnames.length; i++) {
			personnames[i] = $('<a />')
				.attr({
					href: baseUrl+'?q='+encodeURIComponent(personnames[i]),
					title: 'Search for "'+personnames[i]+'"'
				})
				.text(personnames[i])
				.prop('outerHTML');
		};

		return personnames;
	}

});
