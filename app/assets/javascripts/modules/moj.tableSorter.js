// General utilities for MOJ
// Dependencies: moj, jQuery

(function (document){

  'use strict';

  moj.Modules.tableSorter = {
    init: function () {

      $('.tablesorter').tablesorter({
        cssIcon: 'icon-closed',
        cssIconAsc: 'icon-closed',
        cssIconDesc: 'icon-closed'
      });

    }
  };

}(document));
