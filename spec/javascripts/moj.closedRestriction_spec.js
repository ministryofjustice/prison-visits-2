describe('Closed visit restrictions', function() {

  beforeEach(function() {
    loadFixtures('process_form.html');
    moj.Modules.MatchVisitors.init();
    moj.Modules.Rejection.init();
    moj.Modules.closedRestriction.init();
  });

  describe('on init', function(){

    beforeEach(function(){
      spyOn(moj.Modules.closedRestriction, 'cacheEls');
      spyOn(moj.Modules.closedRestriction, 'bindEvents');
      moj.Modules.closedRestriction.init();
    });

    it('should call `this.cacheEls`', function() {
      expect(moj.Modules.closedRestriction.cacheEls).toHaveBeenCalled();
    });

    it('should call `this.bindEvents`', function() {
      expect(moj.Modules.closedRestriction.bindEvents).toHaveBeenCalled();
    });

    it('should render the reference number in the DOM', function(){
      expect('#closed-visits').toBeInDOM();
    });

    it('should hide the reference number on the page', function(){
      moj.Modules.closedRestriction.render();
      expect('#closed-visits').not.toBeVisible();
    });

  });

  describe('selecting a closed visit date', function(){

    beforeEach(function(){
      moj.Modules.closedRestriction.init();
      moj.Modules.closedRestriction.render();
      $('#visit_slot_granted_2017-05-27t09151115').click().trigger('change');
    });

    it('should show the closed visit copy', function(){
      expect('#closed-visits').toBeVisible();
    });

    it('should show tick the closed visit checkbox', function(){
      expect('#visit_closed').toBeChecked();
    });


    describe('then selecting a non-closed visit date', function(){

      beforeEach(function(){
        $('#visit_slot_granted_2017-05-20t14001600').click().trigger('change');
      });

      it('should hide the closed visit copy', function(){
        expect('#closed-visits').not.toBeVisible();
      });

      it('should show untick the closed visit checkbox', function(){
        expect('#visit_closed').not.toBeChecked();
      });

    });

  });

});