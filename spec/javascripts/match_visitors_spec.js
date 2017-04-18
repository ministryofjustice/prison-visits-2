describe('Match visitors', function() {

  beforeEach(function() {
    loadFixtures('match_visitor.html');
    moj.Modules.MatchVisitors.init();
  });

  describe('Visitor selection', function() {

    beforeEach(function() {
      $('.js-contactList:first').val('12588').trigger('change');
    });

    it('should disabled an already selected visitor', function() {
      expect($('.js-contactList').eq(1).find('option[value="12588"]')).toBeDisabled();
    });

    it('should disabled not on contact list checkbox', function() {
      expect($('.js-contactList').eq(0).parents('li').find('input[id*="not_on_list"]')).toBeDisabled();
    });

    it('should uncheck not on contact list checkbox', function() {
      expect($('.js-contactList').eq(0).parents('li').find('input[id*="not_on_list"]')).not.toBeChecked();
    });

    it('should uncheck not on contact list checkbox', function() {
      expect($('.js-contactList').eq(0).find('input[id*="not_on_list"]')).not.toBeChecked();
    });

    it('should set the processed data attribute to true', function() {
      var listItem = $('.js-contactList').eq(0).parents('li');
      expect(listItem.data('processed')).toBe(true);
    });

    it('should set the banned data attribute to true', function() {
      var listItem = $('.js-contactList').eq(0).parents('li');
      expect(listItem.data('banned')).toBe(true);
    });

    describe('Visitor unselection', function() {

      beforeEach(function() {
        $('.js-contactList:first').val('0').trigger('change');
      });

      it('should not disabled visitors when selection cleared', function() {
        expect($('.js-contactList').eq(1).find('option[value="12588"]')).not.toBeDisabled();
      });

      it('should set the processed data attribute to false', function() {
        var listItem = $('.js-contactList').eq(0).parents('li');
        expect(listItem.data('processed')).toBe(false);
      });

    });

  });

  describe('Methods', function() {

    it('findParent should return the parent <li> element', function() {
      var item = $('.js-contactList').eq(0),
        itemParent = item.parents('li'),
        parent = moj.Modules.MatchVisitors.findParent(item);
      expect(parent.html()).toBe(itemParent.html());
    });

    it('hideMessage should hide an element', function() {
      var html = $('.js-noAdults');
      expect(moj.Modules.MatchVisitors.hideMessage(html)).toBeHidden();
    });

    it('showMessage should show an element', function() {
      var html = $('.js-noAdults').hide();
      expect(moj.Modules.MatchVisitors.showMessage(html)).not.toBeHidden();
    });

  });

});