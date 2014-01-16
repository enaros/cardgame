require.config({
    paths: {
        // "moment": "moment.min",
        // "d3": "d3.v3",
        // "jquery": "jquery-2.0.3",
    },
    shim: {
        d3: {
            exports: 'd3'
        }
    }
});

define('jquery-private', ['jquery'], function (jq) {
    return jq.noConflict(true);
});

require(["script"], function(LPCurve) {
    
});