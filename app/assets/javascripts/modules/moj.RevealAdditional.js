(function () {
  'use strict';

  moj.Modules.RevealAdditional = {
    el: '.js-RevealAdditional',

    init: function () {
      this.cacheEls();
      this.bindEvents();
    },

    bindEvents: function () {
      this.$actuators.on('change', this.actuate);
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function () {
      this.$actuators = $(this.el);
    },

    render: function () {
      this.$actuators.each(this.actuate);
    },

    actuate: function () {
      var $el = $(this);
      var $targets = $($el.data('targetEls'));
      var $numToShow = parseInt($el.val(), 10);
      $targets.each(function(i, el) {
        if (i < $numToShow) {
          $(el).show();
        } else {
          $(el).hide();
          $(el).find('input').val('');
        }
      });
    }
  };
}());
