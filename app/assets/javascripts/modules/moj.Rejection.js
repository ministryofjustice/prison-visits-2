(function () {
  'use strict';

  moj.Modules.Rejection = {
    el: '.js-Rejection',

    selected: [],

    init: function () {
      this.cacheEls();
      this.bindEvents();
    },

    bindEvents: function () {
      this.$conditionals.on('change deselect', $.proxy(this.toggleCheckboxSelection, this));
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function () {
      this.$conditionals = $(this.el);
    },

    render: function () {
      var self = this;
      this.$conditionals.each(function(i,el){
        var $el = $(el);
        self.addRemove($el);
        self.actuate($el);
      });
    },

    toggleCheckboxSelection: function(e) {
      var $el = $(e.currentTarget);
      if (!e.type == 'undefined' && e.type === 'change') {
        $('input[name="' + $el.attr('name') + '"]').not($el).trigger('deselect');
      }
      this.addRemove($el);
      this.actuate($(e.currentTarget));
    },

    addRemove: function($el){
      this.isChecked($el)? this.addToSelected($el) : this.removeFromSelected($el);
    },

    isChecked: function($el){
      return $el.prop('checked');
    },

    addToSelected: function(el){
      this.selected.push(el);
    },

    removeFromSelected: function(el){
      this.selected = this.selected.filter(function(obj) {
        return obj[0] !== el[0];
      });
    },

    actuate: function($el){
      var $conditionalEl = this.conditionals($el.data('rejectionEl'));
      var $conditionalOppositeEl = this.conditionals($el.data('rejectionEl')+'-opposite');

      if(this.selected.length > 0){
        this.show($conditionalEl);
        this.hide($conditionalOppositeEl);
      } else {
        this.hide($conditionalEl);
        this.show($conditionalOppositeEl);
      }
    },

    conditionals: function(string) {
      return $(string ? '#' + string.split(',').join(',#') : null);
    },

    show: function($el){
      $el.show();
      $el.attr('aria-expanded', 'true').attr('aria-hidden', 'false');
    },

    hide: function($el){
      $el.hide();
      $el.attr('aria-expanded', 'false').attr('aria-hidden', 'true');
    }
  };
}());
