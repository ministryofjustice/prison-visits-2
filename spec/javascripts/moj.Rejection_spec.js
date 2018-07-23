describe('Check if a visit will be rejected', function() {

  var $prisoner_details_incorrect;

  beforeEach(function() {
    loadFixtures('process_form.html');
    $prisoner_details_incorrect = $('#prisoner_details_incorrect');
  });

  describe('On init', function(){

    beforeEach(function(){
      spyOn(moj.Modules.Rejection, 'cacheEls');
      spyOn(moj.Modules.Rejection, 'bindEvents');
      moj.Modules.Rejection.selected = [];
      moj.Modules.Rejection.init();
    });

    it('should call `this.cacheEls`', function() {
      expect(moj.Modules.Rejection.cacheEls).toHaveBeenCalled();
    });

    it('should call `this.bindEvents`', function() {
      expect(moj.Modules.Rejection.bindEvents).toHaveBeenCalled();
    });

    it('should show the rejection warning message', function(){
      expect($('#rejection-message')).toBeVisible();
    });

    it('js-Rejection data attribute element should be on the page', function(){
      var dataEl = moj.Modules.Rejection.conditionals($prisoner_details_incorrect.data('rejectionEl'));
      expect(dataEl).toBeInDOM();
    });

  });

  describe('On selecting a rejection reason', function() {

    beforeEach(function() {
      moj.Modules.Rejection.init();
      moj.Modules.MatchVisitors.init();
      $prisoner_details_incorrect.trigger('click');
    });

    it('should check the prisoner details incorrect checkbox', function(){
      expect($prisoner_details_incorrect).toBeChecked();
    });

    it('should show the rejection warning message', function() {
      expect($('#rejection-message')).toBeVisible();
    });

    it('should add checked element to the `selected` array', function(){
      expect(moj.Modules.Rejection.selected).toContain($prisoner_details_incorrect);
    });

    describe('and then unselecting a checkbox', function(){

      beforeEach(function(){
        $('#visitors-fixture li:eq(0) select').val('12588').trigger('change');
        $prisoner_details_incorrect.trigger('click');
      });

      it('should show the rejection warning message', function(){
        expect($('#rejection-message')).toBeVisible();
      });

      it('should remove the element from the `selected` array', function(){
        expect(moj.Modules.Rejection.selected).not.toContain($prisoner_details_incorrect);
      });

    });

    afterEach(function(){
      moj.Modules.Rejection.selected = [];
    });

  });

  describe('On rejecting the lead visitor', function(){

    beforeEach(function(){
      moj.Modules.Rejection.selected = [];
      moj.Modules.MatchVisitors.init();
      $('#visitors-fixture li:eq(0) select').val('12588').trigger('change');
    });

    it('should show the rejection warning message', function(){
      expect($('#rejection-message')).toBeVisible();
    });

    describe('unchecking the banned checkbox', function(){

      it('should hide the rejection warning message', function(){
        $('#visit_visitors_attributes_0_banned').prop('checked', null).trigger('change');
        expect($('#rejection-message')).toBeHidden();
      });

    });

  });

  describe('Methods', function(){

    describe('isChecked', function(){

      it('should return a boolean state of a checkbox', function(){
        expect(moj.Modules.Rejection.isChecked($prisoner_details_incorrect)).toBe(false);
      });

    });

    describe('addToSelected', function(){

      it('should add element to the `selected` array', function(){
        var el = $('#prisoner_details_incorrect');
        moj.Modules.Rejection.addToSelected($prisoner_details_incorrect);
        expect(moj.Modules.Rejection.selected).toContain(el);
      });

    });

    describe('removeFromSelected', function(){

      it('should remove element from the `selected` array', function(){
        moj.Modules.Rejection.addToSelected($prisoner_details_incorrect);
        expect(moj.Modules.Rejection.selected).toContain($prisoner_details_incorrect);
        moj.Modules.Rejection.removeFromSelected($prisoner_details_incorrect);
        expect(moj.Modules.Rejection.selected).not.toContain($prisoner_details_incorrect);
      });

    });

    describe('conditionals', function(){

      it('should return an element object', function(){
        var rejectionEl = $prisoner_details_incorrect.data('rejectionEl');
        expect(typeof(moj.Modules.Rejection.conditionals(rejectionEl))).toBe('object');
      });

    });

  });

});
