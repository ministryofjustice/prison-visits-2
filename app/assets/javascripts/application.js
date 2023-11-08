// Vendor assets
//= require jquery2
//= require jquery_ujs
//= require chosen-js/chosen.jquery
//= require vendor/jquery.tablesorter
//= require raven-3.24.2.min.js

// GOVUK modules
//= require govuk_toolkit
//= require vendor/polyfills/bind
//= require moj
//= require lodash
//= require jquery-ui-autocomplete
//= require modernizr-custom
//= require dest/respond.min
//= require jquery-ui/datepicker

// Raven / Sentry
//= require modules/moj.sentry

// Candidates for re-usable components
//= require mapshim
//= require filtershim
//= require modules/moj.analytics
//= require modules/moj.AsyncGA
//= require modules/moj.GAEvent
//= require modules/moj.clearRadioButtons
//= require modules/moj.hijacks
//= require modules/moj.submit-once
//= require modules/moj.Conditional
//= require modules/moj.datepicker
//= require modules/moj.emailPreview
//= require modules/moj.multiSelect
//= require modules/moj.tableSorter
//= require modules/moj.Rejection
//= require modules/moj.restrictionOverrides
//= require modules/moj.matchVisitors
//= require modules/moj.autocomplete
//= require modules/moj.searchPlaceholder
//= require modules/moj.closedRestriction

(function() {
  'use strict';
  delete moj.Modules.devs;

  moj.Modules.Sentry.capture(function() {
    var selectionButtons = new GOVUK.SelectionButtons("input[type='radio'], input[type='checkbox']");
    var showHideContent = new GOVUK.ShowHideContent();
    showHideContent.init();
    moj.init();
  });


}());
