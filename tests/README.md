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

- `logInAs(user)`: Log in as a particular user, afterwards you can expect to end up at the
ESD Home Page. This method will take into account multiple scenarios, including initial password
change bypass and wrong passwords.
Please see [User Management](#user-management) for more information.
- `fillInputText(label, value)`: Fill a Visualforce `inputText` or `inputField`
that has label `label` with `value`.
- `getOutputText(label)`: Get the value from a Visualforce `outputText` or
`outputField` with label `label`.
- `getSelectOptions(label)`: Get all the options from a `select` tag with label `label`.
- `getSelectOptionsBySelector(selector)`: Get all the options from a `select` tag with
selector `selector`. Use this only when `getSelectOptions` is not viable (e.g. when there
are multiple elements with the same label on the page).
- `chooseSelectOption(label, optionValue)`: Choose the option `optionValue` from
a `select` tag with label `label`.
- `selectCheckbox(label, selected)`: Select a checkbox with label `label`. `selected`
is optional - if it is `undefined` or `true`, the checkbox will be selected, if it is `false`,
the checkbox will be unselected.
- `selectLookup(label)`: Click on a lookup icon that Visualforce generated for certain
elements (e.g. when we need to look up a user).
- `switchToNextWindow()`: Sometimes VF will create a new window (e.g. when we look up a
user). You can use this function to switch between windows in that case.
- `waitForActionStatusDisappearance(actionStatusId, timeout)`: Wait for an
`apex:actionStatus` to disappear.

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

What if you want a result to be reused multiple times throughout the chain? One way to handle this
is to declare a variable before the chain and refer to it throughout:

```
var a;

client.
  .then(function () {
    a = "Hello World";
  })
  .then(function () {
    console.log(a);  # print out Hello World
  })
  .then(function () {
    console.log(a + ";");  # print out Hello World;
  });
```

### User Management

When we're running regression tests, we want to be able to test using users with the same role,
profile, permission set and public group as real users in production. Because of this,
the framework has a built in user management module that (most of the time) will just work out of
the box. The only thing you need to do is to add a user to the `configs/users.json`
(following the existing examples there) and the script will make sure that user is created with the
correct permissions/groups/roles before running your test. Please note existing users will not
be modified, therefore you should never modified the users specified in the
`configs/users.json` manually, as it will lead to inconsistent results down the road.
In order to get access to these user accounts in your test suites, it is as simple as doing:

```
var users = require("../users.js").accounts;
```

From there you can refer to the user account by their name,
e.g. `users['CM_Referral_Intaker']`. You can also get all the properties defined in the
`users.json` file like so:

```
users['CM_Referral_Intaker'].password
```

This will come in handy when you need to e-sign a document, for example.

There is also a custom command called `logInAs(user)` that lets you log in as a user defined
in the `users.json` file. In order to user this, simple pass in a user object like so:

```
client.logInAs(users['CM_Referral_Intaker']).then(...);
```

## FAQ

- My suite exits way too fast and doesn't seem to do anything!

Make sure that you're returning a Promise in your test case, a.k.a:

```
testSuite("Sample Suite", suiteTimeout, {
  "should do the right thing": function(client, done) {
    return client
      .logInAs(users["CM_Tier_I"])
      .url()
      .then(function (url) {
        assert.include(url.value, 'Home');
      });
  }
});

```

If you don't have that `return` statement, the script will exit almost immediately and will do
nothing, so make sure it's there.

- How to refer to elements by their IDs?

First off, I'd recommend to always use the custom commands in the [Documentation](#documentation)
as much as you can. However, there will be situations where that is impossible and we have to refer
to some elements by their IDs directly. The issue arises where Visualforce generated IDs are not
guaranteed to be the same across multiple sandboxes, and so we cannot pass in the full IDs into
Webdriver's methods. For example, let's take a look at `click`:

```
# Do NOT do this!
client.click("j_id0:referralForm:referralDetailBlock:ReferralDetailHeader:referrerPhone").then(...);

# Instead you can use a partial selector in this situation:
client.click("[id$=referrerPhone]").then(...);
```

This is fairly similar to how we use JQuery selectors on the client side, so hopefully it won't be
too hard. WebdriverIO also supported multiple ways of specifying selectors (not just CSS selector),
and you can find them all [here](http://webdriver.io/guide/usage/selectors.html).