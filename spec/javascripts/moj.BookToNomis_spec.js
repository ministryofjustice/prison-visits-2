describe('Show or hide the visit reference', function() {

  beforeEach(function() {
    loadFixtures('process_form.html');
    moj.Modules.MatchVisitors.init();
    moj.Modules.Rejection.init();
    moj.Modules.BookToNomis.init();
    $('#visit_visitors_attributes_0_nomis_id').val(null).trigger('change');
  });

  describe('On init', function(){

    beforeEach(function(){
      spyOn(moj.Modules.BookToNomis, 'cacheEls');
      spyOn(moj.Modules.BookToNomis, 'bindEvents');
      moj.Modules.BookToNomis.init();
    });

    it('should call `this.cacheEls`', function() {
      expect(moj.Modules.BookToNomis.cacheEls).toHaveBeenCalled();
    });

    it('should call `this.bindEvents`', function() {
      expect(moj.Modules.BookToNomis.bindEvents).toHaveBeenCalled();
    });

    it('should render the reference number in the DOM', function(){
      expect('#booktonomis-message').toBeInDOM();
    });

    it('should hide the reference number on the page', function(){
      moj.Modules.BookToNomis.render();
      expect('#booktonomis-message').not.toBeVisible();
    });

  });

  describe('Selecting a visit date', function(){

    beforeEach(function(){
      $('#visit_slot_granted_2017-05-27t09151115').val('2017-05-27T09:15/11:15').trigger('click');
      $('#visit_visitors_attributes_0_nomis_id').val('13428').trigger('change');
    });

    it('should show the reference number on the page', function(){
      $('.js-BookToNomis').click().trigger('change');
      expect('#booktonomis-message').toBeVisible();
    });
  });

});