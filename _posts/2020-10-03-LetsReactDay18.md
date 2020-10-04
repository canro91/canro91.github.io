---
layout: post
title: Let's React. Day 18 of 30
tags: letsX react
---

After doing [Let's Go]({% post_url 2020-07-05-LetsGoStudyPlan %}), I moved on to React. I decided to _"be fluent"_ in React in 30 days. I'm using the same approach from Let's Go. This is getting my hands dirty with examples and walk-throughs, instead of reading books from cover to cover and passively watching videos.

This is some of my progress after 18 days.

* React is a UI library. It doesn't do a lot of things
* React isn't running in the background to update your UI
* There's no such a thing like views (html files) and code-behind (js files)
* React encourages to separate your application into small components
* A component uses props and state. Think props as input values and state as the internals. React updates the UI every time state is changed
* Each component should have a single `render` method. It should return only one JSX element. Think JSX as html templates inside JavaScript
* You can pass functions to components, not only strings and primitive values
* Prefer function-based components over class-based components
* Use `const [value, func] = React.useState(initialValue)` to change state inside function-components to change state. See [A Simple Intro to React Hooks](https://daveceddia.com/intro-to-hooks/)
* Instead of having a single big state object, separate state into multiple states variables. Group them if they change together. See [Should I use one or many state variables?](https://reactjs.org/docs/hooks-faq.html#should-i-use-one-or-many-state-variables)
* Use `React.UseEffect(func, [variables])` to call your API endpoints. It runs after the first render and after every state change. If you want this effect to be called only once, pass an empty array. See: [Fix useEffect re-running on every render](https://daveceddia.com/useeffect-triggers-every-change) and [Five common mistakes writing react components (with hooks) in 2020](https://www.lorenzweiss.de/common_mistakes_react_hooks/)

### Hello, world!

```javascript
import React from 'react';
import ReactDOM from 'react-dom';

const HelloWorld = () => (
  <h1>Hello, World</h1>
);

ReactDOM.render(<HelloWorld />, document.getElementById('root'));
```

### How to call an API from a component

```javascript
const CallAPI = () => {
  const [value, setValue] = React.useState(initialValue);

  const fetchData = () => {
    fetch(someApiUrl)
    .then(response => response.json())
    .then(data => {
      const mappedValue = mapToValue(data);
      setValue(mappedValue);
      onSuccess();
    })
    .catch(error => console.error(error));
  };

  React.UseEffect(() => {
    fetchData();
  }, []);

  return (
    <SomeChildComponent values={stateValue} />
  );
}
```

You can find the videos and tutorials I've used so far in [LetsReact](https://github.com/canro91/LetsReact)

[![canro91/LetsReact - GitHub](https://gh-card.dev/repos/canro91/LetsReact.svg)](https://github.com/canro91/LetsReact)

_Happy coding!_
