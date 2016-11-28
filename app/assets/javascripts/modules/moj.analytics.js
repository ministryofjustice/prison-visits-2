(function () {
  'use strict';

  moj.Modules.Analytics = {
    send: function(gaParams){
      ga('send', 'event', gaParams.category, gaParams.action, gaParams.label);
    }
  };
}());
