// General utilities for MOJ
// Dependencies: moj, jQuery

(function (){

  'use strict';


  moj.Modules.restrictionOverride = {

    el: '.js-restrictionOverride',

    overrides: [],

    init: function () {
      this.cacheEls();
      this.bindEvents();
    },

    cacheEls: function(){
      this.$el = $(this.el);
    },

    bindEvents: function(){
      this.$el.on('change deselect', $.proxy(this.triggerChange, this));
      moj.Events.on('render', $.proxy(this.render, this));
    },

    render: function(){
      var self = this;
      // this.$el.each(function(i,el){
      //   var $el = $(el);
      // });
      this.toggleOverrides();
    },

    triggerChange: function(e){
      var $el = $(e.currentTarget);
      this.checkOverride($el);
    },

    checkOverride: function($el){
      var dataOverride = $el.data('override'),
        name = $el.attr('name');

      $el.is(':checked')? this.removeOverride(dataOverride) : this.addOverride(dataOverride);
      this.toggleOverrides();
    },

    addOverride: function(override){
      this.overrides.push(override);
    },

    removeOverride: function(override){
      this.overrides.splice(this.overrides.indexOf(override),1);
    },

    getDistinctValues: function(array) {
      return _.uniq(array  );
    },

    toggleOverrides: function(){
      var self = this;

      $.each($('#js-OverrideMessage li'), function(i,obj){
        var $obj = $(obj),
          id = $obj.attr('id');
        self.overrides.indexOf(id) >= 0? self.toggleEl($obj, false) : self.toggleEl($obj, true);
      });
      this.overrides.length > 0? this.toggleEl($('#js-OverrideMessage'), false) : this.toggleEl($('#js-OverrideMessage'), true);
    },

    toggleCheckboxSelection: function(event){
      var $el = $(event.currentTarget);

      return $el.is(':checked')? this.checked($el) : this.unchecked($el);
    },

    checked: function($el){
      console.log('select');
      this.toggleEl(this.getEl($el), true);
    },

    unchecked: function($el){
      console.log('unselect');
      this.toggleEl(this.getEl($el), false);
    },

    getEl: function($el){
      return $('#'+$el.data('rejection-override-el'));
    },

    toggleEl: function($el, status){
      status? $el.hide() : $el.show().removeClass('visually-hidden');
      $el.attr('aria-expanded', !status).attr('aria-hidden', status);
      $el.find('input[type="checkbox"]').prop('checked', !status);
    }

  };

}());
