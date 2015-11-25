/*jslint unparam: true */

// Selectbox Autocomplete module for MOJ
// Dependencies: moj, jQuery, jQuery UI

(function (window, $) {

  'use strict';

  var MojAutocomplete = function(el, options){
    // avoid applying twice
    if(!el.data('moj.autocomplete')){ // TODO: find a better way...
      // set settings
      this.settings = $.extend({}, this.defaults, options);
      // cache element
      this.$select = el;
      // build new elements
      this._create();

      el.data('moj.autocomplete', true);
    }
  };

  MojAutocomplete.prototype = {
    // default config
    defaults: {
      copyAttr: true,
      autocomplete: {
        delay: 0,
        minLength: 0,
        autoFocus: true
      }
    },

    _create: function(){
      // create and hide el
      this.$wrapper = $('<span>').addClass('moj-autocomplete').insertAfter(this.$select);
      // build autocomplete field
      this._createAutocomplete();
      // hide original select el
      this.$select.hide();
    },

    _createAutocomplete: function(){
      var selected = this.$select.children(':selected'),
          val = selected.val() ? selected.text() : '',
          key, value, i, attrs, raw_attrs;

      this.$text = $( '<input>' ).attr('type', 'text') // give it a field type
                                  .val(val) // set value if already selected
                                  .data('select', this.$select); // assoc select with this input

      // if required, copy across attributes - useful for using [placeholder]
      if (this.settings.copyAttr) {
        attrs = {};
        raw_attrs = this.$select[0].attributes;

        for (i=0; i < raw_attrs.length; i++) {
          key = raw_attrs[i].nodeName;
          value = raw_attrs[i].nodeValue;
          if ( key !== 'name' && key !== 'id' && key !== 'class' && typeof this.$select.attr(key) !== 'undefined' ) {
            attrs[key] = value;
          }
        }
        this.$text.attr(attrs);
      }

      this.settings.autocomplete.source = $.proxy(this, '_source'); // use source method from class
      // add autocomplete functionality to text field
      this.$text.autocomplete(this.settings.autocomplete);

      // Our items have HTML tags.  The default rendering uses text()
      // to set the content of the <a> tag.  We need html().
      this.$text.data('ui-autocomplete')._renderItem = function(ul, item) {
        var label = $('<a>').html(item.label);
        if (item.value === -1) {
          label.addClass('ui-menu-noresults');
        }
        return $('<li>').append(label).appendTo(ul);
      };

      // set callbacks for autocomplete
      this.$text.on({
        autocompleteselect: this._autocompleteselect,
        autocompletechange: this._autocompletechange,
        autocompletesearch: this._autocompletesearch,
        autocompletefocus: this._autocompletefocus
      });

      // append input to wrapper
      this.$wrapper.append(this.$text);
    },

    _source: function(request, response){
      var term = this.stripFormal(request.term),
          matcher = new RegExp('^' + term, 'i');

      if (this._hasMatches(request.term)) {
        response(
          this.$select.children('option').map(function() {
            var text = $( this ).text();
            if (this.value && (!request.term || matcher.test(text))){
              return {
                label: request.term !== '' ? text.replace(new RegExp('^(?![^&;]+;)(?!<[^<>]*)(' + term + ')(?![^<>]*>)(?![^&;]+;)', 'gi'), '<strong>$1</strong>') : text,
                value: text,
                option: this
              };
            }
          })
        );
      } else {
        response([{ label: 'Prison not found', value: -1}]);
      }
    },

    stripFormal: function (term) {
      var matcher = term.match(/^(hmp?|yoi)? ?/i);
      if (matcher[0].length) {
        term = term.replace(matcher[0], '');
      }
      return $.ui.autocomplete.escapeRegex(term);
    },

    _hasMatches: function (term) {
      var matched = false,
          matcher = new RegExp('^' + this.stripFormal(term) + '[a-z]*', 'i');

      this.$select.children('option').each(function() {
        // if a match is found, select it and change to proper case in text field
        if (matcher.test($(this).text().toLowerCase())) {
          matched = true;
        }
      });

      return matched;
    },

    _autocompletefocus: function(event, ui) {
      // don't select 'no results' as value
      if (ui.item.value === -1) {
        event.preventDefault();
      }
    },

    _autocompleteselect: function(event, ui) {
      // don't input '-1' (no results) into text box
      if (ui.item.value === -1) {
        event.preventDefault();
      } else {
        ui.item.option.selected = true;
      }
    },

    _autocompletechange: function(event, ui) {
      var $text = $(this),
          $select = $text.data('select'),
          value = $text.val(),
          valueLowerCase = value.toLowerCase(),
          valid = false;

      // Selected an item, nothing to do
      if (ui.item && ui.item.value !== -1) {
        return;
      }

      // Search for a match (case-insensitive)
      $select.children('option').each(function() {
        // if a match is found, select it and change to proper case in text field
        if ($(this).text().toLowerCase() === valueLowerCase) {
          this.selected = valid = true;
          $text.val($(this).text());
          return false;
        }
      });

      // Found a match, nothing to do
      if (valid) {
        return;
      }

      // Remove invalid value
      $text.val('').attr('title', value + ' didn\'t match any item');
      // clear value from select
      $select.val('');
      // remove value from autocomplete obj
      $text.data('ui-autocomplete').term = '';
    },

    // stop first item being selected when no value has been entered
    _autocompletesearch: function() {
      if($(this).val() === '') {
        $(this).data('ui-autocomplete').options.autoFocus = false;
      } else {
        $(this).data('ui-autocomplete').options.autoFocus = true;
      }
    }
  };

  $.fn.mojAutocomplete = function(options) {
    return this.each(function(){
      new MojAutocomplete($(this), options);
    });
  };

  // attach to window so doesn't have to be used as a jQuery plugin
  window.MojAutocomplete = MojAutocomplete;
}(window, jQuery));


(function(){
  'use strict';

  // Add module to MOJ namespace
  moj.Modules.autocomplete = {
    init: function () {
      // auto initate plugin if class is present
      $('.js-autocomplete').mojAutocomplete($(this).data());
    }
  };
}());
