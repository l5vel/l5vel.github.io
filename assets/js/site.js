/* L5VEL — small progressive enhancements. No dependencies. */
(function () {
    'use strict';

    /* Nav gains a solid background once the hero has scrolled past. */
    var nav = document.getElementById('siteNav');
    var hero = document.querySelector('.hero');

    if (nav && hero && 'IntersectionObserver' in window) {
        new IntersectionObserver(function (entries) {
            nav.classList.toggle('is-scrolled', !entries[0].isIntersecting);
        }, { rootMargin: '-80px 0px 0px 0px' }).observe(hero);
    } else if (nav) {
        nav.classList.add('is-scrolled');
    }

    /* Respect reduced-motion: don't loop the hero behind the headline. */
    var heroVideo = document.getElementById('heroVideo');
    var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

    if (heroVideo && reduceMotion.matches) {
        heroVideo.removeAttribute('autoplay');
        heroVideo.removeAttribute('loop');
        heroVideo.pause();
    }

    /* Only one clip plays at a time — six autoplaying cards is chaos. */
    var clips = document.querySelectorAll(
        '.video-thumbnail video, .vision-card-video video,' +
        '.prod-hero-media video, .prod-video-media video'
    );

    Array.prototype.forEach.call(clips, function (clip) {
        clip.addEventListener('play', function () {
            Array.prototype.forEach.call(clips, function (other) {
                if (other !== clip && !other.paused) {
                    other.pause();
                }
            });
        });
    });

    /* Keep the copyright year current. */
    var year = document.getElementById('year');
    if (year) {
        year.textContent = new Date().getFullYear();
    }

    /* Direct links into a reference disclosure reveal the requested content. */
    function revealReferenceTarget() {
        var id;
        try {
            id = decodeURIComponent(window.location.hash.slice(1));
        } catch (error) {
            return;
        }
        var target = document.getElementById(id);
        var parent = target;
        var opened = false;
        while (parent) {
            if (parent.tagName === 'DETAILS' && parent.classList.contains('reference-details')) {
                if (!parent.open) {
                    parent.open = true;
                    opened = true;
                }
            }
            parent = parent.parentElement;
        }
        if (opened) {
            target.scrollIntoView();
        }
    }
    revealReferenceTarget();
    window.addEventListener('hashchange', revealReferenceTarget);
}());
