(function() {
  'use strict';

  moj.Modules.MatchVisitors = {

    enabled: true,

    init: function() {
      this.cacheEls();
      this.bindEvents();
      this.onRender();
    },

    cacheEls: function() {
      this.notContactCheckbox = 'input[id*="not_on_list"]';
      this.bannedCheckbox = 'input[type="checkbox"][id*="banned"]';

      this.$el = $('.js-visitorList');
      this.$notAllMessage = this.$el.find('.js-notAllProcessed');
      this.totalVisitors = this.$el.find('select').length;
      this.restrictionTemplate = '<div class="restriction push-top--half">' +
          '<span class="restriction__date"></span>: ' +
          '<span class="bold-small restriction__type"></span> ' +
          '<div class="restriction__details"></div>' +
        '</div>';
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
          option = $obj.find('option[data-contact]'),
          contact = option.data('contact'),
          val = $obj.val(),
          parent = self.findParent(obj);

        if(val == contact.id && val != ''){
          self.toggleSelectOptions($obj);
          self.toggleCheckbox($obj, val == '');
          option.prop('disabled', null);
        }

        self.processVisitor(parent, !val == '');
        self.checkRestrictions(this, contact);
        self.checkStatus();
      });

    },

    changeSelect: function(e) {
      var el = e.currentTarget,
        contactData = $(el).find(':selected').data('contact'),
        adding = el.value == '',
        parent = this.findParent(el);

      this.toggleSelectOptions(el);
      this.toggleCheckbox(el, adding);
      this.processVisitor(parent, !adding);
      if (this.isContactBanned(contactData)) {
        this.setBanned(parent, this.isContactBanned(contactData));
      }
      this.checkRestrictions(el, contactData);
      this.checkStatus();
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
        $(el).data('valid', false);
      } else {
        $(el).attr('data-processed', true);
        $(el).data('valid', !noContact);
      }
    },

    getProcessed: function() {
      return this.$el.find('[data-processed="true"]').length;
    },

    setVisitorBanned: function(el, banned) {
      $(el).data('banned', banned);
    },

    isVisitorBanned: function(el) {
      return $(el).data('banned');
    },

    checkStatus: function() {
      this.checkLeadVisitorStatus();
      this.checkTotalVisitors();
    },

    checkLeadVisitorStatus: function() {
      var visitor = this.getLeadVisitor(),
        visitorValid = !this.isVisitorBanned(visitor) && visitor.data('valid')? true : false;

      if (visitorValid) {
        moj.Modules.Rejection.hideRejection();
      } else {
        moj.Modules.Rejection.showRejection();
      }
      moj.Modules.BookToNomis.render();
    },

    checkTotalVisitors: function() {
      var unprocessed = this.getProcessed() < this.totalVisitors;

      if (unprocessed && this.enabled) {
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
        options = this.$el.find('select').not(el).find('option[data-contact]').not(':selected');

      $.each(options, function(i, obj) {
        var contact = obj.value? $(obj).data('contact') : null;
        if (contact && $.inArray(contact.id.toString(), self.getVisitorIDs()) !== -1) {
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
      var isBanned = contact? contact.banned == 'true' : false;
      return isBanned;
    },

    isContactRestricted: function(contact) {
      return contact && contact.restrictions && contact.restrictions.length > 0
    },

    setBanned: function(el, selected) {
      el.find(this.bannedCheckbox).prop('checked', selected).trigger('change');
    },

    showEl: function(el) {
      el.show().removeClass('visuallyhidden');
    },

    hideEl: function(el) {
      el.hide().addClass('visuallyhidden');
    },

    getLeadVisitor: function(){
      return this.$el.find('.visitor-contact-list li').eq(0);
    },

    resetContact: function(el){
      var notOnList = this.getCheckbox(el);
      el.val(null).trigger('change');
    },

    check: function(){
      if(moj.Modules.Rejection.isRejected()){
        this.enabled = false;
        this.hideEl(this.$notAllMessage);
      } else {
        this.enabled = true;
        this.checkLeadVisitorStatus();
        this.checkTotalVisitors();
      }
    },

    checkRestrictions: function(el, contactData) {
      this.isContactRestricted(contactData)? this.showRestrictions($(el), contactData) : this.hideRestrictions($(el));
    },

    showRestrictions: function(el, data) {
      var $restrictionsEl = el.parents('li').find('.js-restrictions'),
        $restrictionsListEl = $restrictionsEl.find('.js-restrictions-list').empty();
      for(var i=0;i<data.restrictions.length;i++){
        var contact = data.restrictions[i].attributes,
          date = contact.expiry_date? this.formatDate(contact.effective_date)+' to '+ this.formatDate(contact.expiry_date): this.formatDate(contact.effective_date),
          $restrictionItem = $(this.restrictionTemplate).clone();
        $restrictionItem.find('.restriction__date').text(date);
        $restrictionItem.find('.restriction__type').text(contact.type.attributes.desc);
        $restrictionItem.find('.restriction__details').text(contact.comment_text);
        $restrictionItem.appendTo($restrictionsListEl);
      }
      $restrictionsEl.removeClass('visuallyhidden')

    },

    hideRestrictions: function($el) {
      $el.parents('li').find('.js-restrictions').addClass('visuallyhidden')
    },

    formatDate: function(str) {
      var date = new Date(str);
      return date.getDate()+'/'+('0' + (date.getMonth() + 1)).slice(-2)+'/'+date.getFullYear();
    }

  };

}());
