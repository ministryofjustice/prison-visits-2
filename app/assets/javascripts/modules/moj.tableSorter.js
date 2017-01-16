// General utilities for MOJ
// Dependencies: moj, jQuery

(function (document){

  'use strict';

  moj.Modules.tableSorter = {
    init: function () {

      $('.tablesorter').tablesorter({
        cssAsc: 'tablesorter-header-asc',
        cssDesc: 'tablesorter-header-desc',
        cssNone: 'tablesorter-header-none'
      });

    }
  };

}(document));
