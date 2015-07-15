# Regression Tests

## Overview

Our regression test suite runs on top of NodeJS, Selenium and WebdriverIO to automate Google Chrome
and run our test cases. It uses GulpJS as the task runner and Mocha/Chai as the test runner.

## How to run

Please refer to [this documentation](https://wiki.thementornetwork.com/display/IEADD/Regression+Tests+Set+Up)
for details on how to set up and run the test suite in Windows.

## Documentation

We use [WebdriverIO](http://webdriver.io/) to communicate with Selenium; therefore you can use the
WebdriverIO [API](http://webdriver.io/api.html) as a great starting point to automate the browser.
I've also included many helper functions to help us interface with Visualforce a little bit easier,
a lot of them allow you to fill in/get value out of Visualforce using labels instead of the DOM IDs.
If possible, please use these functions because it matches better with our users' experience.

- `fillInputText(label, value)`: Fill a Visualforce `inputText` or `inputField`
that has label `label` with `value`.
- `getOutputText(label)`: Get the value from a Visualforce `outputText` or
`outputField` with label `label`.
- `getSelectOptions(label)`: Get all the options from a `select` tag with label `label`.
- `chooseSelectOption(label, optionValue)`: Choose the option `optionValue` from
a `select` tag with label `label`.
- `selectLookup(label)`: Click on a lookup icon that Visualforce generated for certain
elements (e.g. when we need to look up a user).
- `switchToNextWindow()`: Sometimes VF will create a new window (e.g. when we look up a
user). You can use this function to switch between windows in that case.

A note of caution: NodeJS (and Javascript in general) is inherently a single thread, asynchronous
language. This means that a lot of the time, code are run on a callback basis - and after awhile,
we can run into [Callback Hell](http://callbackhell.com/). Modern Javascript libraries (WebdriverIO
in this case) use a technique called Promises to get rid of this problem. Basically, Promises will
reduce the following code:

```
step1(function (value1) {
    step2(value1, function(value2) {
        step3(value2, function(value3) {
            step4(value3, function(value4) {
                // Do something with value4
            });
        });
    });
});
```

into:

```
step1()
.then(promisedStep2)
.then(promisedStep3)
.then(promisedStep4)
.then(function (value4) {
    // Do something with value4
})
.catch(function (error) {
    // Handle any error from all above steps
})
.done();
```

If you're interested in Promises in general, [this article](http://www.html5rocks.com/en/tutorials/es6/promises/)
is a good starting point. However, for our purposes of writing regression tests, most of the time
we won't have delve too deep into the Promise specification. What you do need to know is Promise
Chaining. Basically, instead of assigning the value returned from a function to a variable, you
have to pass that value into a `then` function. In other words, *don't* do this:

```
var firstName = client.getOutputText("First Name");
assert.equals("Susan", firstName);
```

This will *not* work, because `getOutputText` returns a Promise, not the actual value. Instead,
do this:

```
client
  .getOutputText("First Name")
  .then(function (firstName) {
    assert.equals("Susan", firstName);
  });
```

As a side effect of this, most of the time your code in a test case should just be a long chain
of method calls starting from `client` like this:

```
return client
  .url()
  .then(...)
  .click(...)
  .click(...)
  .getSelectOptions(...)
  .then(...);
```

If instead, you find your code looks like this:

```
client
  .url()
  .then(...);
var a = "";
a += "Hello World";
client.getSelectOptions(...);
```

In other words, your chain is broken up in the middle, there's a very high likelihood that the code
will not work the way you think it does! Javascript is an async language, it's almost a certainty
that the code in the middle will run _before_ anything else. If you need to pass results between
functions, you can do the following instead:

```
client.
  .then(function () {
    var a = "";
    a += "Hello World";
    return a;
  })
  .then(function (resultFromLastFunction) {
    console.log(resultFromLastFunction);  // it will print out Hello World here
  });
```

Whatever you `return` from your last function will be passed in as a parameter in your next
function in the Promise chain!