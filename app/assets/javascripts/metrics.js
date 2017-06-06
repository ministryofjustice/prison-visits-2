if (typeof Array.prototype.forEach != 'function') {
  Array.prototype.forEach = function(callback){
    for (var i = 0; i < this.length; i++){
      callback.apply(this, [this[i], i, this]);
    }
  };
}
//= require metrics/moj.metrics
//= require metrics/moj.visit-counts
//= require metrics/moj.timely-visits-counts
//= require metrics/moj.rejection-percentages
(function () {
  'use strict';
  moj.initMetrics();
}());
