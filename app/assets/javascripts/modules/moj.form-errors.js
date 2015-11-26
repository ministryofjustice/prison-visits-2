(function () {
  'use strict';

  document.addEventListener(
    'invalid',
    function(e){
      if (e.target.tagName !== 'INPUT') { return; }

      var payload = {
        event: {
          type: 'invalid',
          pathname: document.location.pathname,
          element: e.target.name
        }
      };

      var csrf_param = $('meta[name=csrf-param]').attr('content');
      var csrf_token = $('meta[name=csrf-token]').attr('content');
      payload[csrf_param] = csrf_token;

      $.post('/frontend_events', payload);
    },
    true
  );
}());
