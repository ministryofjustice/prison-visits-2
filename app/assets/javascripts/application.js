// Vendor assets
//= require jquery
//= require jquery_ujs
//= require vendor/chosen.jquery

// GOVUK modules
//= require govuk_toolkit
//= require govuk/selection-buttons
//= require moj
//= require handlebars
//= require lodash
//= require jquery-ui-autocomplete
//= require vendor/modernizr.custom.85598
//= require dest/respond.min
//= require jquery-ui/datepicker

// MOJ elements
//= require src/moj.TimeoutPrompt

// Candidates for re-usable components
//= require modules/moj.analytics
//= require modules/moj.autocomplete
//= require modules/moj.hijacks
//= require modules/moj.submit-once
//= require modules/moj.Conditional
//= require modules/moj.RevealAdditional
//= require modules/moj.checkbox-summary
//= require modules/moj.datepicker
//= require modules/moj.RevealNextRow
//= require modules/moj.emailPreview
//= require modules/moj.multiSelect

(function () {
  'use strict';
  delete moj.Modules.devs;
  var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio'], label input[type='checkbox']");
  moj.init();

}());
