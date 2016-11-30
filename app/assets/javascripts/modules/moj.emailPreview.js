(function () {
  'use strict';

  moj.Modules.EmailPreview = {
    el: '.js-EmailPreview',

    init: function () {
      this.bindEvents();
    },

    bindEvents: function () {
      $(this.el).find('.js-LinkPreview').click($.proxy(this.handleClick, this));
    },

    handleClick: function(event) {
      event.preventDefault();

      // not all browsers support PUT and DELETE
      // The form contains _method input which will be 
      // picked up by Rack::MethodOverride and translated into 
      // the corresponding HTTP verb.
      var ajaxOptions = {
        url:    event.target.href,
        method: 'POST', 
        data:   $(this.el).serialize()
      };

      $.ajax(ajaxOptions).done(function(data) {
        var emailPreviewWindow = window.open("", "_blank")
        emailPreviewWindow.document.write(data);
      }).fail(function(xhr) {
        alert(xhr.responseText);
      });
    }
  };
}());
