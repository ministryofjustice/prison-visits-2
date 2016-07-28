(function () {
  'use strict';

  moj.Modules.AutoRefresh = {
    el: '.js-AutoRefresh',

    init: function () {
      this.cacheEls();
      this.bindEvents();
    },

    bindEvents: function () {
      var self = this;
      if (this.$el.length){
        self.render();
      };
    },

    cacheEls: function () {
      this.$el = $(this.el);
    },

    render: function(){
     var time = new Date().getTime();
     $(document.body).bind("mousemove keypress", function(e) {
       time = new Date().getTime();
     });
     function refresh() {
       /* If the time passed is greater than 3 minutes
          then reload the page, else keep checking
          every 10 seconds
       */
       if(new Date().getTime() - time >= 180000){
         window.location.reload(true);
       } else {
         setTimeout(refresh, 10000);
       }
     }
     setTimeout(refresh, 10000);
    }

  };
}());
