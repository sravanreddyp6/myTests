var downloadPdf = function (pdfExistenceUrl, retryInterval, maxRetries, onSuccess, onError) {
    if (!pdfExistenceUrl) {
        // Signify that the callout was not successful
        return;
    }
    if (!retryInterval) {
        retryInterval = 6000;
    }
    if (!maxRetries) {
        maxRetries = 20;
    }
    if (!onSuccess) {
        onSuccess = function (pdfLocation) {
            window.location = pdfLocation;
        }
    }
    if (!onError) {
        onError = function () {
            alert("The paper form generation is taking too long, please try refreshing the page and generating a new one.");
        }
    }
    var retryTimes = 0;

    var checkStopInterval = function () {
        if (retryTimes >= maxRetries) {
            clearInterval(interval);
            onError();
        }
    };
    var callbackHandler = function (result) {
        retryTimes = retryTimes + 1;
        if (!result.pdfLocation) {
            checkStopInterval();
            return;
        }
        clearInterval(interval);
        onSuccess(result.pdfLocation);
    };
    var interval = setInterval(function () {
        jQuery.ajax({
            type: "GET",
            url: pdfExistenceUrl,
            dataType: "jsonp",
            jsonp: "callbackFn",
            success: callbackHandler,
        });
    }, retryInterval);
}
