// Timeout prompt for MOJ
// Dependencies: moj, jQuery, lodash

_.templateSettings.interpolate = /{{([\s\S]+?)}}/g;

(function () {

  'use strict';

  window.moj = window.moj || { Modules: {} };

  var TimeoutPrompt = function($el, options) {
    this.init($el, options);
    return this;
  };

  TimeoutPrompt.prototype = {

    defaults: {
      timeoutMinutes: 17,
      respondMinutes: 3,
      exitPath: '/abandon',
      template: '.TimeoutPrompt-template'
    },

    timeout: null,
    respond: null,

    init: function ($el, options) {
      this.settings = $.extend({}, this.defaults, options);
      this.settings.timeoutDuration = this.convertToMinutes(this.settings.timeoutMinutes);
      this.settings.respondDuration = this.convertToMinutes(this.settings.respondMinutes);
      this.cacheEls($el);
      this.startTimeout();
    },

    convertToMinutes: function(num) {
      return num * 1000 * 60;
    },

    cacheEls: function($el) {
      this.$el = $el;
      this.$template = $el.find(this.settings.template);
      this.$alert = $(this.getTemplate(this.$template));
    },

    bindEvents: function() {
      this.$el.find('.TimeoutPrompt-extend').on('click', $.proxy(this.removeAlert, this));
    },

    startTimeout: function () {
      this.timeout = setTimeout(
        $.proxy(
          this.showAlert,
          this,
          this.settings.respondDuration
        ),
        this.settings.timeoutDuration
      );
    },

    getTemplate: function($tmpl) {
      var template;

      if ($tmpl.length) {
        template = _.template($tmpl.html());

        return template({
          respondTime: this.settings.respondMinutes
        });
      }
    },

    showAlert: function (ms) {
      this.$alert.appendTo(this.$el).focus();
      this.respond = setTimeout($.proxy(this.redirect, this), ms, this.settings.exitPath);
      this.bindEvents();
    },

    redirect: function (path) {
      window.location.href = path;
    },

    removeAlert: function () {
      this.$alert.remove();
      clearTimeout(this.timeout);
      this.refreshSession();
    },

    refreshSession: function () {
      var self = this;
      $.ajax({
        url: $('#logo img').attr('src'),
        cache: false
      }).done(function () {
        self.startTimeout(self.settings.timeoutDuration);
        clearTimeout(self.respond);
      });
    }
  };

  moj.Modules._TimeoutPrompt = TimeoutPrompt;

  moj.Modules.TimeoutPrompt = {
    init: function() {
      return $('.TimeoutPrompt').each(function() {
        $(this).data('TimeoutPrompt', new TimeoutPrompt($(this), $(this).data()));
      });
    }
  };

}());
