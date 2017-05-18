// Vendor assets
//= require jquery
//= require jquery_ujs
//= require vendor/chosen.jquery
//= require vendor/jquery.tablesorter
//= require raven-3.14.2.min.js

// GOVUK modules
//= require govuk_toolkit
//= require vendor/polyfills/bind
//= require details.polyfill
//= require moj
//= require lodash
//= require jquery-ui-autocomplete
//= require modernizr-custom
//= require dest/respond.min
//= require jquery-ui/widgets/datepicker

// Raven / Sentry
//= require modules/moj.sentry

// Candidates for re-usable components
//= require mapshim
//= require filtershim
//= require modules/moj.analytics
//= require modules/moj.AsyncGA
//= require modules/moj.clearRadioButtons
//= require modules/moj.hijacks
//= require modules/moj.submit-once
//= require modules/moj.Conditional
//= require modules/moj.datepicker
//= require modules/moj.emailPreview
//= require modules/moj.multiSelect
//= require modules/moj.tableSorter
//= require modules/moj.matchVisitors
//= require modules/moj.Rejection
//= require modules/moj.autocomplete

(function() {
  'use strict';
  delete moj.Modules.devs;
  var selectionButtons = new GOVUK.SelectionButtons("input[type='radio'], input[type='checkbox']");
  moj.init();

}());
