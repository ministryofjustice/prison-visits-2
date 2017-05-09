// Vendor assets
//= require jquery
//= require jquery_ujs
//= require vendor/chosen.jquery
//= require vendor/jquery.tablesorter

// GOVUK modules
//= require govuk_toolkit
//= require vendor/polyfills/bind
//= require govuk/selection-buttons
//= require moj
//= require lodash
//= require modernizr-custom
//= require dest/respond.min
//= require jquery-ui/datepicker

// MOJ elements

// Candidates for re-usable components
//= require mapshim
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

(function() {
  'use strict';
  delete moj.Modules.devs;
  var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio'], label input[type='checkbox']");
  moj.init();

}());