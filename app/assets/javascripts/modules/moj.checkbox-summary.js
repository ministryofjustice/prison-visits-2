(function () {
  'use strict';

  window.moj = window.moj || { Modules: {}, Events: $({}) };

  var CheckboxSummary = function($el, options) {
    this.init($el, options);
    return this;
  };

  CheckboxSummary.prototype = {
    init: function ($el, options) {
      var sum;
      this.cacheEls($el);
      this.bindEvents();
      this.settings = $.extend({}, this.defaults, options);
      if (sum = this.$summaries.first().text()) {
        this.settings.original = sum;
      }
    },

    defaults: {
      glue: ', ',
      strip: '+',
      sub: ' ',
      original: ''
    },

    bindEvents: function () {
      this.$checkboxes.on('change deselect', $.proxy(this.summarise, this));
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function ($el) {
      this.$el = $el;
      this.$checkboxes = $el.find('[type=checkbox]');
      this.$summaries = $el.find('.CheckboxSummary-summary');
    },

    render: function () {
      this.$checkboxes.each($.proxy(this.summarise, this));
    },

    getChecked: function ($el) {
      return $el.filter(function() {
        return $(this).is(':checked');
      });
    },

    stripChars: function(string) {
      var reg = new RegExp('[' + this.settings.strip + ']', 'ig');
      return string.replace(reg, this.settings.sub);
    },

    summary: function($el) {
      return $.makeArray($el.map(function() {
        return $(this).val();
      }));
    },

    summaryText: function(array) {
      if (array.length) {
        return this.stripChars(array.join(this.settings.glue));
      } else {
        return this.settings.original;
      }
    },

    summarise: function () {
      var summary = this.summary(this.getChecked(this.$checkboxes)),
          text = this.summaryText(summary);

      this.$summaries.text(text);
    }
  };

  moj.Modules._CheckboxSummary = CheckboxSummary;

  moj.Modules.CheckboxSummary = {
    init: function() {
      return $('.CheckboxSummary').each(function() {
        $(this).data('CheckboxSummary', new CheckboxSummary($(this), $(this).data()));
      });
    }
  };
}());
