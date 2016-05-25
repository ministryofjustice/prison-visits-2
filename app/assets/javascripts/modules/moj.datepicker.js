(function () {

  'use strict';

  moj.Modules.Datepicker = {
    el: '.js-Datepicker',

    init: function () {
      this.cacheEls();
      this.render();
    },

    cacheEls: function () {
      this.$el = $(this.el);
    },

    render: function(){
      var options = {};
      var additionalOptions = this.$el.data('datepicker');
      jQuery.extend(options, additionalOptions);
      this.$el.datepicker(options);
    }
  };
}());
