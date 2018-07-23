(function () {
  'use strict';

  moj.Modules.Rejection = {
    el: '.js-Rejection',
    rejectionEl: 'rejection-message',
    successEl: 'nomis-opt-out',

    init: function () {
      this.selected = [];
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
        moj.Modules.MatchVisitors.check();
      });
    },

    toggleCheckboxSelection: function(e) {
      var $el = $(e.currentTarget);
      if (!e.type == 'undefined' && e.type === 'change') {
        $('input[name="' + $el.attr('name') + '"]').not($el).trigger('deselect');
      }
      this.addRemove($el);
      this.actuate($(e.currentTarget));
      moj.Modules.MatchVisitors.check();
    },

    addRemove: function($el){
      this.isChecked($el)? this.addToSelected($el) : this.removeFromSelected($el);
    },

    isRejected: function(){
      return this.selected.length > 0;
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
      if(this.isRejected()){
        this.showRejection();
      } else {
        this.hideRejection();
      }
    },

    conditionals: function(string) {
      return $(string ? '#' + string.split(',').join(',#') : null);
    },

    showRejection: function(){
      this.show($('#'+this.rejectionEl));
      this.hide($('#'+this.successEl));
    },

    hideRejection: function(){
      this.hide($('#'+this.rejectionEl));
      this.show($('#'+this.successEl));
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
