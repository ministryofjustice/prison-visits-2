# MOJ Timeout Prompt

Displays an alert on the page after a certain amount of time. The user can extend the time fom the alert. If no action is taken, the user is redirected to an exit page.

## Build

### Requirements

* Node
* Grunt CLI

```
npm install
```

## Running tests

```bash
npm test
```

## Suggested use

Include into your project using [Bower](http://bower.io).

    bower install moj-timeoutprompt --save

Then include the module into your page or build process.

**Note** when using outside of the moj JavaScript namespace, you will need to manually trigger initialisation of this module.

```javascript
moj.Modules.TimeoutPrompt().init();
```

### Required files

    lodash.js
    moj.TimeoutPrompt.js

### Mark-up

Place the template in the DOM where you would like the alert to be displayed. Lodash.js then appends `TimeoutPrompt-alert` to the `TimeoutPrompt` element to display it to the user.

```html
<div class="TimeoutPrompt">
  <script class="TimeoutPrompt-template" type="text/html">
    <div class="TimeoutPrompt-alert" role="alertdialog" aria-labelledby="timeoutTitle" aria-describedby="timeoutDesc" tabindex="0">
      <h2 id="timeoutTitle">Your session will will expire in {{ respondTime }} minutes</h2>
      <p id="timeoutDesc">Would you like to continue?</p>
      <button class="TimeoutPrompt-extend">Yes</button>
    </div>
  </script>
</div>
```

### Template parameters

`respondTime` - duration in minutes in which the alert will be shown before redirecting.

### Options

Options are applied using `data-*` attributes on the root element. Eg…

```html
<div class="TimeoutPrompt" data-timeout-minutes="5">
```

Setting         | Type    | Default    | Description
--------------- | ------- | ---------- | -------------------------------------
timeout-minutes | integer | 17         | minutes before the alert is displayed
respond-minutes | integer | 3          | minutes before redirect once the alert has displayed
exit-path       | string  | '/abandon' | path to be redirected to after respond-time
