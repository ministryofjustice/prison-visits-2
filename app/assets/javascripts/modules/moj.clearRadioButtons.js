// General utilities for MOJ
// Dependencies: moj, jQuery

(function(document) {

  'use strict';

  moj.Modules.clearRadioButtons = {
    el: '.js-clearRadioButtons',

    init: function() {
      this.bindEvents();
    },

    bindEvents: function() {
      $(this.el).find('.js-clearRadioButton').click($.proxy(this.handleClick, this));
    },

    handleClick: function(e) {
      e.preventDefault();
      e.stopPropagation();
      var targetEls = $(e.currentTarget).data('target');

      $('[name="' + targetEls + '"]').each(function(i, obj) {
        $(obj).prop('checked', false)
          .parent('label')
          .removeClass('selected');
        $(obj).trigger('change');
      });
    }
  };

}(document));