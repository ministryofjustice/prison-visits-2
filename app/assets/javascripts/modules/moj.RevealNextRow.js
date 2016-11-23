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
        e.preventDefault();
        e.stopPropagation();
        var $this = $(this);
        $this.find('.icon').toggleClass('icon-closed, icon-open');
        self.section = $this.data('section');
        self.toggleNextRow(self);
      });
    },

    toggleNextRow: function(self){
      self.$nextRow.toggleClass('show');
      self.$nextRow.attr('aria-hidden', function (i, attr) {
          var state = (attr == 'true') ? 'false' : 'true';
          if(state === 'false'){
            self.triggerAnalytics(self);
          }
          return state;
      });
      self.$nextRow.attr('aria-expanded', function (i, attr) {
          return attr == 'true' ? 'false' : 'true'
      });
    },

    triggerAnalytics: function(self){
      var gaParams = {
        'category': pvb.prison+' '+self.section+' - more information',
        'action': 'click',
        'label': pvb.user_email
      };
      moj.Modules.Analytics.send(gaParams);
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
