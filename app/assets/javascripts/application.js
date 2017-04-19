// Vendor assets
//= require jquery
//= require jquery_ujs
//= require handlebars
//= require lodash
//= require vendor/chosen.jquery
//= require vendor/jquery.tablesorter

// GOVUK modules
//= require govuk_toolkit
//= require vendor/polyfills/bind
//= require govuk/selection-buttons
//= require moj
//= require jquery-ui-autocomplete
//= require modernizr-custom
//= require dest/respond.min
//= require jquery-ui/datepicker

// MOJ elements
//= require src/moj.TimeoutPrompt

// Candidates for re-usable components
//= require mapshim
//= require modules/moj.analytics
//= require modules/moj.AsyncGA
//= require modules/moj.autocomplete
//= require modules/moj.clearRadioButtons
//= require modules/moj.hijacks
//= require modules/moj.submit-once
//= require modules/moj.Conditional
//= require modules/moj.RevealAdditional
//= require modules/moj.checkbox-summary
//= require modules/moj.datepicker
//= require modules/moj.emailPreview
//= require modules/moj.multiSelect
//= require modules/moj.tableSorter

(function() {
  'use strict';
  delete moj.Modules.devs;
  if($("label input[type='radio'], label input[type='checkbox']").length > 0) {
    var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio'], label input[type='checkbox']");
  }
  moj.init();

}());