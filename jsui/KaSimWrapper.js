var processMessageCallback = null;
var inputFile = null;
var customArgs = "";
var file_content_fun = null;
var setFileContentFun = function (f) {
    file_content_fun = f;
}

var Simulator = (function () {

    return {

        simulate: function(progStr, processMessageCallbackPar) {

            try {

                // extract simulation parameters from program and assign to global:
                var regex = /^%simulate: (.+)/m;
                var matches = regex.exec(progStr);                
                if (matches.length >= 2) {
                    customArgs = matches[1];
                } else {
                    customArgs = "";
                }


                // comment out simulation directive and assign to global:
                inputFile = progStr.replace(regex, "# " + matches[0]);

                // will start simulation and callback until complete.
                processMessageCallback = processMessageCallbackPar;
                
                processMessageCallback({ msg: "Simulating...", isComplete: false });


                // invoke js simulator.
                importScripts("https://raw.github.com/NicolasOury/KaSimJS/master/KaSim.js");

                // now done - need to provide the final "isComplete" callback here.
                // note that any errors result in exceptions, which are handled below.
                var message = { msg: "Simulation complete. ", isComplete: true };
                processMessageCallback(message);

                return false;
            }
            catch (e) {
                var message = { isComplete: true, msg: file_content_fun("stderr") };
                self.postMessage(message);
            }
        },
        
        stop: function () {},
    };

    })();