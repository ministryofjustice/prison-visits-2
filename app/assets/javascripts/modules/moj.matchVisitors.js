(function() {
  'use strict';

  moj.Modules.MatchVisitors = {

    init: function() {
      var self = this;

      this.$el = $('.js-visitorList');
      this.$noAdultMessage = $('.js-noAdults');
      this.$notAllMessage = $('.js-notAllProcessed');
      this.totalVisitors = this.$el.find('select').length;

      this.$el.on('change', 'select', function() {
        var contactData = $(this).find(':selected').data('contact'),
          parent = self.findParent(this),
          adding = this.value == '0' ? true : false;
        self.updateSelectLists();
        self.setNoContactCheckbox(this, adding);
        self.processVisitor(parent);
        self.checkStatus();
        if (self.isBanned(contactData)) {
          self.setBanned(parent, self.isBanned(contactData));
          self.setBannedUntil(parent, contactData.banned_until);
        }
      });

      this.$el.on('change', 'input[id*="not_on_list"]', function() {
        var $this = $(this),
          parent = self.findParent($this),
          isChecked = $this.is(':checked');
        self.processVisitor(parent);
        self.checkStatus();
      });

      this.$el.on('change', 'input[type="checkbox"][id*="banned"]', function() {
        var $this = $(this),
          parent = self.findParent($this),
          isChecked = $this.is(':checked');
        self.processBanned(parent, isChecked);
        self.checkStatus();
      });
    },

    // Find the parent list item
    findParent: function(el) {
      return $(el).parents('li');
    },

    // Set visitor as processed to true or false
    processVisitor: function(el) {
      var select = false,
        noContact = false;
      select = $(el).find('select option:selected').val();
      noContact = $(el).find('input[id*="not_on_list"]').is(':checked');

      if (select == '0' && noContact == false) {
        $(el).attr('data-processed', false);
      } else {
        $(el).attr('data-processed', true);
      }
    },

    // Return the number of processed visitors
    processedNumber: function() {
      return this.$el.find('[data-processed="true"]').length;
    },

    // Set the visitor banned true/false
    processBanned: function(el, banned) {
      $(el).attr('data-banned', banned);
    },

    // Return visitor banned true/false
    isVisitorBanned: function(el) {
      return $(el).attr('data-banned') == 'true';
    },

    // Check the status of adult and processed visitors
    checkStatus: function() {
      this.checkAdultStatus();
      this.checkTotalStatus();
    },

    // Check the total number of adults and show/hide warning
    checkAdultStatus: function() {
      function isBigEnough(value) {
        return function(element, index, array) {
          return (element >= value);
        }
      }
      var adultNumber = this.getAges().filter(isBigEnough(18));
      var noAdults = adultNumber < 1 ? true : false;

      if (noAdults && this.processedNumber() >= 1) {
        this.showMessage(this.$noAdultMessage);
      } else {
        this.hideMessage(this.$noAdultMessage);
      }
    },

    // Check the total number of visitors processed and show/hide warning
    checkTotalStatus: function() {
      var unprocessed = this.processedNumber() < this.totalVisitors ? true : false;

      if (unprocessed) {
        this.showMessage(this.$notAllMessage);
      } else {
        this.hideMessage(this.$notAllMessage);
      }
    },

    // Get the ages of all selected NOMIS contacts
    getAges: function() {
      var self = this,
        ages = [];
      $.each(this.getListItems(), function(i, obj) {
        var data = $(obj).data('visitor'),
          dob = data.dob.split('-'),
          age = self.calcAge(new Date(dob[0], dob[1], dob[2]));
        ages.push(age);
      });
      return ages;
    },

    // Calculate the age from a date of birth
    calcAge: function(dob) {
      var ageDifMs = new Date() - dob.getTime(), //Date.now() - dob.getTime(),
        ageDate = new Date(ageDifMs);
      return Math.abs(ageDate.getUTCFullYear() - 1970);
    },

    // Build array of all list items of selected visitors
    getListItems: function() {
      var self = this,
        arr = $('select option:selected').map(function() {
          var parent = self.findParent(this);

          if (this.value != 0 && !self.isVisitorBanned(parent)) {
            return parent;
          }
        }).get();
      return arr;
    },

    // Build an array of chosen visitor values (IDs)
    getChosenValues: function() {
      var self = this,
        arr = $('select').map(function() {
          if (this.value !== '0') {
            return this.value
          }
        }).get();
      return arr;
    },

    // Enable/disable visitor options in the contact list
    updateSelectLists: function() {
      var self = this,
        options = this.$el.find('select').not(this).find('option').not(':first');

      $.each(options, function(i, obj) {
        var contact = $(obj).data('contact');

        if ($.inArray(contact.uid, self.getChosenValues()) !== -1) {
          $(obj).prop('disabled', 'disabled');
        } else {
          $(obj).prop('disabled', null);
        }
      });
    },

    // Find the relating checkbox
    getNoContactCheckbox: function(el) {
      var parent = this.findParent(el);
      return parent.find('input[id*="not_on_list"]');
    },

    // Enable/disable the 'not on contact list' checkbox
    setNoContactCheckbox: function(el, disable) {
      var checkbox = this.getNoContactCheckbox(el);
      checkbox.prop('disabled', !disable);
      if (!disable) {
        checkbox.prop('checked', disable);
      }
    },

    // Return true/false
    isBanned: function(contact) {
      return contact.banned == 'true';
    },

    // Auto check the banned checkbox
    setBanned: function(el, selected) {
      el.find('input[type="checkbox"][id*="banned"]').prop('checked', selected).trigger('change');
    },

    // Set the banned until date input values
    setBannedUntil: function(el, date) {
      var dateObj = date ? date.split('-') : [null, null, null];
      el.find('input[id*="banned_until_day"]').val(dateObj[2]);
      el.find('input[id*="banned_until_month"]').val(dateObj[1]);
      el.find('input[id*="banned_until_year"]').val(dateObj[0]);
    },

    // Show the element
    showMessage: function(el) {
      el.show().removeClass('visuallyhidden');
      return el;
    },

    // Hide the element
    hideMessage: function(el) {
      el.hide();
      return el;
    }

  };
}());