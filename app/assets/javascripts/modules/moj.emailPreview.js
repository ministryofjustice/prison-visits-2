(function () {
  'use strict';

  moj.Modules.EmailPreview = {
    el: '.js-EmailPreview',

    init: function () {
      this.bindEvents();
    },

    bindEvents: function () {
      $(this.el).find('.js-LinkPreview').click($.proxy(this.handleClick, this));
    },

    handleClick: function(event) {
      event.currentTarget.search = $(this.el).serialize();
    }
  };
}());
