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
Please see [User Management](#markdown-header-user-management) for more information.
- `fillInputText(label, value)`: Fill a Visualforce `inputText` or `inputField`
that has label `label` with `value`.
- `getOutputText(label)`: Get the value from a Visualforce `outputText` or
`outputField` with label `label`.
- `getSelectOptions(label)`: Get all the options from a `select` tag with label `label`.
- `getSelectOptionsBySelector(selector)`: Get all the options from a `select` tag with
selector `selector`. Use this only when `getSelectOptions` is not viable (e.g. when there
are multiple elements with the same label on the page).
- `getCheckboxOutput(label)`: Get whether a checkbox output with Visualforce `apex:outputField`
with label `label` is checked or not. If it is, the function returns true, otherwise it returns false.
- `getCheckboxOutputs(label1, label2, ...)`: A helper to get multiple checkbox output
values. It returns a list of Booleans, directly corresponding to the checkboxess labels passed in.
For example: if we have 2 checkboxes: Checkbox 1 (checked) and Checkbox 2 (unchecked), calling
`getCheckboxes("Checkbox 1", "Checkbox 2")` will return `[true, false]`.
- `getCheckboxInput(label)`: Get whether a checkbox input with label `label` is checked or
not. If it is, the function returns true, otherwise it returns false.
- `getCheckboxInputs(label1, label2, ...)`: same as `getCheckboxOutputs`, but on
input fields instead of output fields.
- `chooseSelectOption(label, optionValue)`: Choose the option `optionValue` from
a `select` tag with label `label`.
- `selectCheckbox(label)`: Select a checkbox with label `label`.
- `unselectCheckbox(label)`: Unselect a checkbox with label `label`.
- `selectCheckboxes(label1, label2, ...)`: A helper to select multiple checkboxes at the
same time. Example usage: `selectCheckboxes("Checkbox 1", "Checkbox 2")` will select
the checkboxes with labels Checkbox 1 and Checkbox 2.
- `unselectCheckboxes(label1, label2, ...)`: Same as `selectCheckboxes`, but it
unselects the checkboxes instead.
- `selectLookup(label)`: Click on a lookup icon that Visualforce generated for certain
elements (e.g. when we need to look up a user).
- `switchToNextWindow()`: Sometimes VF will create a new window (e.g. when we look up a
user). You can use this function to switch between windows in that case.
- `tableToJSON(selector)`: Turns a table with selector `selector` to a JSON object. Please
read more about [handing table](#markdown-header-handling-table).
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

### Handling Table

Table handling is tricky in Visualforce pages, since the rows and columns are given unique (but not
easily predictable across sandboxes) Ids - making it harder to write correct selectors for them.
Because of this issue, I've written the `tableToJSON` custom command to handle simple tables.
Call this method with a selector to the `table` element, and it will return a JSON string
representation of that table, with the keys being the column names and the values being the content
of the cells in the table. For example, this table (with id `sample-table`):

Name       | Value
---------- | -------
Record 1   | Value 1
Record 2   | Value 2

will be transformed into the JSON object
`[{"Name": "Record 1", "Value": "Value 1"}, {"Name": "Record 2", "Value": "Value 2"}]`.

Of course, this method only returns the content of the table. In case you want to interact with a
certain cell in the table, please use the `nth-child` selector in the CSS specification. For
example, to click on a link in the table at row 5 (excluding the header row) and column 3, you can
do:

`return client.click("table#id tbody tr:nth-child(5) td:nth-child(3) a");`

Please note that the `nth-child` selector uses a 1-based indexing system - so the first row has
index 1, second row has index 2, and so on.

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