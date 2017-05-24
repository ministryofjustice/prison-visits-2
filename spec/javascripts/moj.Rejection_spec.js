describe('Check if a visit will be rejected', function() {

  beforeEach(function() {
    loadFixtures('process_form.html');
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

    it('should hide the rejection warning message', function(){
      expect($('#rejection-message')).toBeHidden();
    });

    it('js-Rejection data attribute element should be on the page', function(){
      var $el = $('#visit_rejection_attributes_reasons_prisoner_details_incorrect'),
        dataEl = moj.Modules.Rejection.conditionals($el.data('rejectionEl'));
      expect(dataEl).toBeInDOM();
    });

  });

  describe('On selecting a rejection reason', function() {

    beforeEach(function() {
      moj.Modules.Rejection.init();
      $('#visit_rejection_attributes_reasons_prisoner_details_incorrect').trigger('click');
    });

    it('should check the prisoner details incorrect checkbox', function(){
      expect($('#visit_rejection_attributes_reasons_prisoner_details_incorrect')).toBeChecked();
    });

    it('should show the rejection warning message', function() {
      expect($('#rejection-message')).toBeVisible();
    });

    it('should add checked element to the `selected` array', function(){
      expect(moj.Modules.Rejection.selected).toContain($('#visit_rejection_attributes_reasons_prisoner_details_incorrect'));
    });

    describe('and then unselecting a checkbox', function(){

      beforeEach(function(){
        $('#visit_rejection_attributes_reasons_prisoner_details_incorrect').trigger('click');
      });

      it('should hide the rejection warning message', function(){
        expect($('#rejection-message')).toBeHidden();
      });

      it('should remove the element from the `selected` array', function(){
        expect(moj.Modules.Rejection.selected).not.toContain($('#visit_rejection_attributes_reasons_prisoner_details_incorrect'));
      });

    });

    afterEach(function(){
      moj.Modules.Rejection.selected = [];
    });

  });

  describe('Methods', function(){

    describe('isChecked', function(){

      it('should return a boolean state of a checkbox', function(){
        var el = $('#visit_rejection_attributes_reasons_prisoner_details_incorrect');
        expect(moj.Modules.Rejection.isChecked(el)).toBe(false);
      });

    });

    describe('addToSelected', function(){

      it('should add element to the `selected` array', function(){
        var el = $('#visit_rejection_attributes_reasons_prisoner_details_incorrect');
        moj.Modules.Rejection.addToSelected(el);
        expect(moj.Modules.Rejection.selected).toContain(el);
      });

    });

    describe('removeFromSelected', function(){

      it('should remove element from the `selected` array', function(){
        var el = $('#visit_rejection_attributes_reasons_prisoner_details_incorrect');
        moj.Modules.Rejection.addToSelected(el);
        expect(moj.Modules.Rejection.selected).toContain(el);
        moj.Modules.Rejection.removeFromSelected(el);
        expect(moj.Modules.Rejection.selected).not.toContain(el);
      });

    });

    describe('conditionals', function(){

      it('should return an element object', function(){
        var el = $('#visit_rejection_attributes_reasons_prisoner_details_incorrect').data('rejectionEl');
        expect(typeof(moj.Modules.Rejection.conditionals(el))).toBe('object');
      });

    });

  });

});