// Age labels for MOJ
// Dependancies: moj, jQuery

(function () {

  'use strict';

  var AgeLabel = function($el, options) {
    this.init($el, options);
    return this;
  };

  AgeLabel.prototype = {

    defaults: {
      threshold: 18,
      labelUnder: 'Child',
      labelOver: 'Adult'
    },

    init: function($el, options) {
      this.settings = $.extend({}, this.defaults, options);
      this.cacheEls($el);
      this.bindEvents();
      this.updateLabel();
    },

    cacheEls: function($el) {
      this.$date = $el.find('.AgeLabel-date');
      this.$label = $el.find('.AgeLabel-label');
    },

    bindEvents: function() {
      this.$date.on('change', 'input', $.proxy(this.updateLabel, this));
    },

    getDate: function() {
      var year = this.$date.find('.year').val(),
          month = this.$date.find('.month').val(),
          day = this.$date.find('.day').val();

      if (year!=='' && month !== '' && day !== '') {
        return new Date(year, month-1, day);
      }
    },

    updateLabel: function() {
      var type,
          date = this.getDate();

      if (date) {
        this.$label.hide();

        type = this.getYearsBetween(date) >= this.settings.threshold ? 'Over' : 'Under';

        this.$label
          .show()
          .removeClass('under over')
          .addClass(type.toLowerCase())
          .text(this.settings['label' + type]);
      }
    },

    getYearsBetween: function(from, to) {
      var diff;
      to = to || new Date();
      diff = to.getTime() - from.getTime();
      return Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25));
    }

  };

  moj.Modules._AgeLabel = AgeLabel;

  moj.Modules.AgeLabel = {
    init: function() {
      return $('.AgeLabel').each(function() {
        $(this).data('AgeLabel', new AgeLabel($(this), $(this).data()));
      });
    }
  };

}());
