var processMessageCallback = null;
var inputFile = null;
var numEventsStr = null;

var Simulator = (function () {

    return {

        simulate: function(progStrPar, eventsPar, processMessageCallbackPar) {

            try {
                // will start simulation and callback until complete.
                processMessageCallback = processMessageCallbackPar;
                inputFile = progStrPar;
                numEventsStr = eventsPar.toString();

                importScripts("https://raw.github.com/NicolasOury/KaSimJS/master/KaSim.js");

                // need to provide the final "isComplete" callback here:
                var message = { isComplete: true };
                processMessageCallback(message);

                return false;
            }
            catch (e) {
                var message = { isComplete: true, errMsg: e.message };
                self.postMessage(message);
            }
        },
        
        stop: function () {},
    };

    })();