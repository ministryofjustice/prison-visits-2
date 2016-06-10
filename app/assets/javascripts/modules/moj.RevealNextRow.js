// RevealNextRow for MOJ
// Dependancies: moj, jQuery

(function () {

  'use strict';

  var RevealNextRow = function(el, options){
    this.$el = el;
    this.init();
  };

  RevealNextRow.prototype = {

    init: function() {
      this.cacheEls();
      this.bindEvents();
    },

    cacheEls: function(){
      this.$nextRow = this.$el.closest('tr').next();
    },

    bindEvents: function() {
      var self = this;
      this.$el.on('click', function(e){
        $(this).find('.icon').toggleClass('icon-closed, icon-open');
        self.showNextRow(self);
      });
    },

    showNextRow: function(self){
      self.$nextRow.toggleClass('show');
    }

  };

  $.fn.RevealNextRow = function(options) {
    return this.each(function(){
      new RevealNextRow($(this), options);
    });
  };

  moj.Modules.RevealNextRow = {
    init: function () {
      return $('.js-RevealNextRow').each(function() {
        $(this).data('RevealNextRow', new RevealNextRow($(this), $(this).data()));
      });
    }
  };

}());
