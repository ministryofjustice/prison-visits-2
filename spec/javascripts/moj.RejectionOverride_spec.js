describe('Override a rejection reason', function() {

  var $prisoner_details_incorrect;

  beforeEach(function() {
    loadFixtures('process_form.html');
    $prisoner_details_incorrect = $('#prisoner_banned');
  });

  describe('On init', function(){

    beforeEach(function(){
      spyOn(moj.Modules.restrictionOverride, 'cacheEls');
      spyOn(moj.Modules.restrictionOverride, 'bindEvents');
      moj.Modules.restrictionOverride.overrides = [];
      moj.Modules.restrictionOverride.init();
      moj.Modules.restrictionOverride.render();
    });

    it('should call `this.cacheEls`', function() {
      expect(moj.Modules.restrictionOverride.cacheEls).toHaveBeenCalled();
    });

    it('should call `this.bindEvents`', function() {
      expect(moj.Modules.restrictionOverride.bindEvents).toHaveBeenCalled();
    });

    it('should hide the warning message and all list items', function(){
      expect($('#js-OverrideMessage')).not.toBeVisible();
      expect($('#prisoner-banned')).not.toBeVisible();
      expect($('#prisoner-details-incorrect')).not.toBeVisible();
    });

  });

  describe('when unselecting a rejection tickbox', function(){

    beforeEach(function(){
      moj.Modules.restrictionOverride.overrides = [];
      moj.Modules.restrictionOverride.init();
      moj.Modules.restrictionOverride.render();
      $prisoner_details_incorrect.click();
    });

    it('should untick the tickbox', function(){
      expect($prisoner_details_incorrect).not.toBeChecked();
    });

    it('should show the warning message', function(){
      expect($('#js-OverrideMessage')).toBeVisible();
    });

    it('should list the prisoner details incorrect message', function(){
      expect($('#prisoner-details-incorrect')).not.toBeVisible();
      expect($('#prisoner-banned')).toBeVisible();
    });

  });

});
