// General utilities for MOJ
// Dependencies: moj, jQuery

(function (document){

  'use strict';

  moj.Modules.hijacks = {
    init: function () {

      $(document)

        // Open browser print dialog
        .on('click', '.print-link', function (e) {
          e.preventDefault();
          window.print();
        })

        // Open external links in a new window (add rel="ext" to the link)
        .on('click', 'a[rel*=external], a[rel*=help]', function (e) {
          e.preventDefault();
          window.open($(this).attr('href'));
        });

    }
  };

}(document));
