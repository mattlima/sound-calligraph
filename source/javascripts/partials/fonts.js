
try_startup = function(){
    if(typeof(window.__c) != "undefined" && window.fonts_ready){
        window.__c.init();
    }
}



WebFontConfig = {
  google: { families: [ 'Volkhov:400,700,400italic:latin', 'Cardo:400,700,400italic:latin', 'Noto+Serif:400,700,400italic:latin' ] },
  active: function() { window.fonts_ready = true; window.try_startup(); }
};
(function() {
  var wf = document.createElement('script');
  wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
    '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
  wf.type = 'text/javascript';
//     wf.async = 'true';
  var s = document.getElementsByTagName('script')[0];
  s.parentNode.insertBefore(wf, s);
})();
