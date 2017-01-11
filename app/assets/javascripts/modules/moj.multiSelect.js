(function () {
  'use strict';

  moj.Modules.MultiSelect = {
    init: function(){
      $(".js-MultiSelect").chosen({
        inherit_select_classes: true,
        width: 'none' // this breaks it on purpose so css takes over for responsive design
      });
    }
  };
}());
