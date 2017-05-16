(function() {
  'use strict';

  moj.Modules.Sentry = {
    el: '.js-Sentry',
    init: function() {
      this.raven = Raven;
      this.sentry_js_dsn = $(this.el).data('sentry-js-dsn');
      this.raven.config(this.sentry_js_dsn).install();
      var self = this;

      // Capture any uncaught errors
      window.onerror = function(error) {
        self.raven.captureException(error);
      }
    }
  }
}());
