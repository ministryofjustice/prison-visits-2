(function () {
  'use strict';

  moj.Modules.BookToNomis = {
    el: '.js-BookToNomis',

    selected: [],

    init: function () {
      this.cacheEls();
      this.bindEvents();
    },

    bindEvents: function () {
      this.$el.on('change deselect', $.proxy(this.render, this));
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function () {
      this.$el = $(this.el);
      this.$conditionalEl = this.$el.data('el');
    },

    render: function () {
      var $el = $('#'+this.$conditionalEl);
      if(moj.Modules.Rejection.isRejected() || this.$el.length > 0 && !this.$el.is(':checked')){
        $el.hide();
        $el.attr('aria-expanded', 'false').attr('aria-hidden', 'true');
      } else {
        $el.show();
        $el.attr('aria-expanded', 'true').attr('aria-hidden', 'false');
      }
    }

  };
}());
