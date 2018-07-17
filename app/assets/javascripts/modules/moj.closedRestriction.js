// General utilities for MOJ
// Dependencies: moj, jQuery

(function () {
  'use strict';

  moj.Modules.closedRestriction = {

    el: '.js-closedRestriction',

    init: function () {
      this.cacheEls();
      this.bindEvents();
    },

    cacheEls: function(){
      this.$el = $(this.el);
      this.$closedEl = $('#closed-visits');
      this.$optOutEl = $('#opt-out-check');
      this.$visitClosedEl = $('#visit_closed');
    },

    bindEvents: function(){
      moj.Events.on('render', $.proxy(this.render, this));
    },

    render: function($el){
      var self = this;
      this.$el.each(function(i,el){
        var $el = $(el);
        self.addEl($el);
        $el.is(':checked')? self.toggleEls(false) : self.toggleEls(true);
      });
    },

    addEl: function($el){
      var self = this,
        name = $el.attr('name');
      $('input[name="'+name+'"]').on('change', function(e){
        $el.is(':checked')? self.toggleEls(false) : self.toggleEls(true);
      });
    },

    toggleEls: function(status) {
      if(status){
        this.$closedEl.hide().addClass('visually-hidden');
        this.$optOutEl.show().removeClass('visually-hidden');
      } else {
        this.$closedEl.show().removeClass('visually-hidden');
        this.$optOutEl.hide().addClass('visually-hidden');
      }
      this.$closedEl.attr('aria-expanded', !status).attr('aria-hidden', status);
      this.$visitClosedEl.prop('checked', !status);
    }

  };
}());
