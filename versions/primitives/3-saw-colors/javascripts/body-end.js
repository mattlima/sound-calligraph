(function() {
  $('[data-slider]').on('change.fndtn.slider', function(e) {
    var $t, d, val;
    $t = $(e.target);
    d = $t.data();
    val = $t.attr('data-slider');
    if (d.valueScale != null) {
      console.log("scale: " + val + " * " + d.valueScale + " = " + (val *= parseFloat(d.valueScale)));
    }
    switch (d.mooogTargetType) {
      case "send":
        return M.track(d.mooogNodeTarget).send(d.mooogParamTarget).param("gain", val);
      default:
        return M.node(d.mooogNodeTarget).param(d.mooogParamTarget, val);
    }
  });

}).call(this);
