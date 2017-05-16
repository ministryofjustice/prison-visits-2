(function() {
  'use strict';

  moj.Modules.MatchVisitors = {

    init: function() {
      this.cacheEls();
      this.bindEvents();
      this.onRender();
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

    onRender: function(){
      var self = this;

      $.each(this.$el.find('select'), function(i,obj){
        var $obj = $(obj),
          option = $obj.find('option:selected'),
          contact = option.data('contact'),
          val = $obj.val(),
          parent = self.findParent(obj);

        if(val == contact.uid && val != ''){
          self.toggleSelectOptions($obj);
          self.toggleCheckbox($obj, val == '');
          option.prop('disabled', null);
        }

        self.processVisitor(parent, !val == '');
      });

      this.checkStatus();
    },

    changeSelect: function(e) {
      var el = e.currentTarget,
        contactData = $(el).find(':selected').data('contact'),
        adding = el.value == '',
        parent = this.findParent(el);

      this.toggleSelectOptions(el);
      this.toggleCheckbox(el, adding);
      this.processVisitor(parent, !adding);
      this.checkStatus();
      if (this.isContactBanned(contactData)) {
        this.setBanned(parent, this.isContactBanned(contactData));
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

      if (select == '' && noContact == false) {
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
        moj.Modules.Rejection.addToSelected(this.$el);
      } else {
        this.hideEl(this.$noAdultMessage);
        moj.Modules.Rejection.removeFromSelected(this.$el);
      }
      moj.Modules.Rejection.actuate(this.$el);
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
      $.each(this.getSelectedVisitors(), function(i, obj) {
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

    getSelectedVisitors: function() {
      var self = this,
        listItemsArray = this.$el.find('select option:selected').map(function() {
          var parent = self.findParent(this);

          if (this.value != '' && !self.isVisitorBanned(parent)) {
            return parent;
          }
        }).get();
      return listItemsArray;
    },

    getVisitorIDs: function() {
      var self = this,
        visitorIDArray = $('select').map(function() {
          if (this.value !== '') {
            return this.value
          }
        }).get();
      return visitorIDArray;
    },

    toggleSelectOptions: function(el) {
      var self = this,
        options = this.$el.find('select').not(el).find('option').not(':first').not(':selected');

      $.each(options, function(i, obj) {
        var contact = $(obj).data('contact');
        if ($.inArray(contact.uid.toString(), self.getVisitorIDs()) !== -1) {
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

    isContactBanned: function(contact) {
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
