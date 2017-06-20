/*global ga */
(function() {
  'use strict';

  moj.Modules.AsyncGA = {
    el: '.js-AsyncGA',
    init: function() {
      GOVUK.Analytics.load();

      // Use document.domain in dev, preview and staging so that tracking works
      // Otherwise explicitly set the domain as www.gov.uk (and not gov.uk).
      var cookieDomain = (document.domain === 'www.gov.uk') ? '.www.gov.uk' : document.domain;
      var gaTrackingId = $(this.el).data('ga-tracking-id');

      // Configure profiles and make interface public
      // for custom dimensions, virtual pageviews and events
      GOVUK.analytics = new GOVUK.Analytics({
        universalId: gaTrackingId,
        cookieDomain: cookieDomain
      });

      this.hitTypePage  = $(this.el).data('hit-type-page');
      if (this.hitTypePage) {
        GOVUK.analytics.trackPageview(location.pathname + '#' + this.hitTypePage);
      } else {
        GOVUK.analytics.trackPageview();
      }
    },
  };

}());
