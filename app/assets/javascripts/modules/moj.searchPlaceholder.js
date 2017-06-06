// General utilities for MOJ
// Dependencies: moj, jQuery

(function(document) {

  'use strict';

  moj.Modules.searchPlaceholder = {
    el: '.js-searchPlaceholder',

    init: function() {
      this.bindEvents();
    },

    bindEvents: function() {
      $(this.el).find('input').on('blur', this.handleBlur);
    },

    handleBlur: function(e) {
      if($(this).val() === ''){
        $(this).parent().removeClass('focus');
      } else {
        $(this).parent().addClass('focus');
      }
    }
  };

}(document));