(function() {
  'use strict';

  moj.Modules.MatchVisitors = {

    init: function() {
      this.cacheEls();
      this.bindEvents();
    },

    cacheEls: function() {
      this.notContactCheckbox = 'input[id*="not_on_list"]';
      this.bannedCheckbox = 'input[type="checkbox"][id*="banned"]';

      this.$el = $('.js-visitorList.nomis-enabled');
      this.$noAdultMessage = this.$el.find('.js-noAdults');
      this.$notAllMessage = this.$el.find('.js-notAllProcessed');
      this.totalVisitors = this.$el.find('select').length;
    },

    bindEvents: function() {
      this.$el.find('select').on('change', $.proxy(this.changeSelect, this));
      this.$el.find(this.notContactCheckbox).on('change', $.proxy(this.changeNotOnList, this));
      this.$el.find(this.bannedCheckbox).on('change', $.proxy(this.changeBanned, this));
    },

    changeSelect: function(e) {
      var el = e.currentTarget,
        contactData = $(el).find(':selected').data('contact'),
        adding = el.value == '0',
        parent = this.findParent(el);

      this.toggleSelectOptions(el);
      this.toggleCheckbox(el, adding);
      this.processVisitor(parent, !adding);
      this.checkStatus();
      if (this.isVisitorBanned(contactData)) {
        this.setBanned(parent, this.isVisitorBanned(contactData));
      }
    },

    changeNotOnList: function(e) {
      var el = $(e.currentTarget),
        parent = this.findParent(el),
        isChecked = el.is(':checked');

      this.processVisitor(parent, isChecked);
      this.checkStatus();
    },

    changeBanned: function(e) {
      var el = $(e.currentTarget),
        parent = this.findParent(el),
        isChecked = el.is(':checked');

      this.setVisitorBanned(parent, isChecked);
      this.checkStatus();
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

    isVisitorBanned: function(el) {
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
      var noAdults = adultNumber < 1;

      if (noAdults && this.getProcessed() >= 1) {
        this.showEl(this.$noAdultMessage);
      } else {
        this.hideEl(this.$noAdultMessage);
      }
    },

    checkTotalStatus: function() {
      var unprocessed = this.getProcessed() < this.totalVisitors;

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

        if (this.value != 0 && !self.isVisitorBanned(parent)) {
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