/*global ga */
(function() {
  'use strict';

  moj.Modules.GAEvent = {
    el: '.js-GAEvent',

    init: function () {
      this.bindEvents();
    },

    bindEvents: function () {
      $(this.el).click($.proxy(this.handleClick, this));
    },

    handleClick: function(event){
      var eventData = $(event.currentTarget).data('eventData')
      GOVUK.analytics.trackEvent(eventData.category, eventData.action, {
        label: eventData.label,
        nonInteraction: true
      })
    }
  };

}());
