
function mwRandom(max){
   return Math.floor(Math.random() * max);
}

function mwInit() {
   console.debug("Initialiszing testing mode.");
   var test_controller = {
      enabled: true,
      pjs: null,
      max_blink: 4000,
      min_blink: 1000,
      debug: false,
      blinkEvent: function blinkEvent_f(controller) {
         window.setTimeout(function(){
            if (controller.enabled)
               controller.pjs.mwBlinkEvent(mwRandom(256));
            controller.blinkEvent(controller);
         },mwRandom(controller.max_blink-controller.min_blink)+controller.min_blink);
      },
      dataEvent: function dataEvent_f(controller) {
         window.setInterval(function() {
            if (controller.enabled) {
               controller.pjs.mwEvent(
                  mwRandom(100)
                  ,mwRandom(100)
                  ,mwRandom(2097152)
                  ,mwRandom(2097152)
                  ,mwRandom(2097152)
                  ,mwRandom(2097152)
                  ,mwRandom(2097152)
                  ,mwRandom(2097152)
                  ,mwRandom(2097152)
                  ,mwRandom(2097152)
               );
            }
         },1000);
      },
      init: function init_f(controller) {
         controller.enabled = true;
         if (controller.pjs===null) {
            controller.pjs = Processing.getInstanceById('mindwave');
            if (controller.pjs.hasOwnProperty('mwEvent'))
               controller.dataEvent(controller);
            if (controller.pjs.hasOwnProperty('mwBlinkEvent'))
               controller.blinkEvent(controller);
         }
      }
   };
   test_controller.init(test_controller);
}
