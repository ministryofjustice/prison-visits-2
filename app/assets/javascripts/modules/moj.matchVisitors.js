(function() {
  'use strict';

  moj.Modules.MatchVisitors = {

    notContactCheckbox: 'input[id*="not_on_list"]',
    bannedCheckbox: 'input[type="checkbox"][id*="banned"]',

    init: function() {
      var self = this;

      this.$el = $('.js-visitorList.nomis-enabled');
      this.$noAdultMessage = this.$el.find('.js-noAdults');
      this.$notAllMessage = this.$el.find('.js-notAllProcessed');
      this.totalVisitors = this.$el.find('select').length;

      this.$el.on('change', 'select', function() {
        var contactData = $(this).find(':selected').data('contact'),
          parent = self.findParent(this),
          adding = this.value == '0' ? true : false;
        self.toggleSelectOptions(this);
        self.toggleCheckbox(this, adding);
        self.processVisitor(parent, !adding);
        self.checkStatus();
        if (self.isBanned(contactData)) {
          self.setBanned(parent, self.isBanned(contactData));
        }
      });

      this.$el.on('change', this.notContactCheckbox, function() {
        var $this = $(this),
          parent = self.findParent($this),
          isChecked = $this.is(':checked');
        self.processVisitor(parent, isChecked);
        self.checkStatus();
      });

      this.$el.on('change', this.bannedCheckbox, function() {
        var $this = $(this),
          parent = self.findParent($this),
          isChecked = $this.is(':checked');
        self.setVisitorBanned(parent, isChecked);
        self.checkStatus();
      });
    },

    findParent: function(el) {
      return $(el).parents('li');
    },

    processVisitor: function(el, processed) {
      var select = false,
        noContact = false;
      select = $(el).find('select option:selected').val();
      noContact = $(el).find(this.notContactCheckbox).is(':checked');

      if (select == '0' && noContact == false) {
        $(el).attr('data-processed', false);
      } else {
        $(el).attr('data-processed', true);
      }
    },

    getProcessed: function() {
      return this.$el.find('[data-processed="true"]').length;
    },

    setVisitorBanned: function(el, banned) {
      $(el).attr('data-banned', banned);
    },

    isBanned: function(el) {
      return $(el).attr('data-banned') == 'true';
    },

    checkStatus: function() {
      this.checkAdultStatus();
      this.checkTotalStatus();
    },

    checkAdultStatus: function() {
      function isBigEnough(value) {
        return function(element, index, array) {
          return (element >= value);
        }
      }
      var adultNumber = this.getAges().filter(isBigEnough(18));
      var noAdults = adultNumber < 1 ? true : false;

      if (noAdults && this.getProcessed() >= 1) {
        this.showEl(this.$noAdultMessage);
      } else {
        this.hideEl(this.$noAdultMessage);
      }
    },

    checkTotalStatus: function() {
      var unprocessed = this.getProcessed() < this.totalVisitors ? true : false;

      if (unprocessed) {
        this.showEl(this.$notAllMessage);
      } else {
        this.hideEl(this.$notAllMessage);
      }
    },

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

    calcAge: function(dob) {
      var ageDifMs = new Date() - dob.getTime(), //Date.now() - dob.getTime(),
        ageDate = new Date(ageDifMs);
      return Math.abs(ageDate.getUTCFullYear() - 1970);
    },

    getListItems: function() {
      var self = this,
        arr = $('select option:selected').map(function() {
          var parent = self.findParent(this);

          if (this.value != 0 && !self.isBanned(parent)) {
            return parent;
          }
        }).get();
      return arr;
    },

    getVisitorIDs: function() {
      var self = this,
        arr = $('select').map(function() {
          if (this.value !== '0') {
            return this.value
          }
        }).get();
      return arr;
    },

    toggleSelectOptions: function(el) {
      var self = this,
        options = this.$el.find('select').not(el).find('option').not(':first');

      $.each(options, function(i, obj) {
        var contact = $(obj).data('contact');

        if ($.inArray(contact.uid, self.getVisitorIDs()) !== -1) {
          $(obj).prop('disabled', 'disabled');
        } else {
          $(obj).prop('disabled', null);
        }
      });
    },

    getCheckbox: function(el) {
      var parent = this.findParent(el);
      return parent.find(this.notContactCheckbox);
    },

    toggleCheckbox: function(el, disable) {
      var checkbox = this.getCheckbox(el);
      checkbox.prop('disabled', !disable);
      if (!disable) {
        checkbox.prop('checked', disable);
      }
    },

    isBanned: function(contact) {
      return contact.banned == 'true';
    },

    setBanned: function(el, selected) {
      el.find(this.bannedCheckbox).prop('checked', selected).trigger('change');
    },

    showEl: function(el) {
      el.show().removeClass('visuallyhidden');
    },

    hideEl: function(el) {
      el.hide().addClass('visuallyhidden');
    }

  };
}());