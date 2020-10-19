---
layout: post
title: Let's React. Day 27 of 30
tags: letsX react
---

Up to [Day 18](https://canro91.github.io/2020/10/03/LetsReactDay18/) of learning React in 30, I worked with function-based components and Hooks. Recently, I switched to manage state with Redux.

I found Redux the most challenging subject so far. _store, actions, reducers, thunks, sagas, dispatching_. Some tutorials cover Redux differently from others. A bit confusing some times. 

These are some of the questions I asked so far.

## Where should I put my state?

**Local state is fine**. And probably you don't need Redux. See [You Might Not Need Redux](https://medium.com/@dan_abramov/you-might-not-need-redux-be46360cf367)

An alternative to passing props down to a component hierachy is to make some of your components receive a `children` props and pass state directly to child components. See [Dam Abramov Tweet](https://twitter.com/dan_abramov/status/1021850499618955272) on response to [Redux vs. The React Context API](https://daveceddia.com/context-api-vs-redux/)

Notice from the snippet below, how you don't need to pass `user` props through the `Nav` and `Body` components to use it inside `UserAvatar` and `UserStats`.

```javascript
class App extends React.Component {
  state = {
    user: {
      avatar:
        "https://www.gravatar.com/avatar/5c3dd2d257ff0e14dbd2583485dbd44b",
      name: "Dave",
      followers: 1234,
      following: 123
    }
  };

  render() {
    const { user } = this.state;

    return (
      <div className="app">
        <Nav>
          <UserAvatar user={user} size="small" />
        </Nav>
        <Body
          sidebar={<UserStats user={user} />}
          content={<Content />}
        />
      </div>
    );
  }
}
```

## What should I put into Redux store? Should I put everything into a Redux store?

Ask yourself if other component will need that state too. Otherwise, you can keep it inside a component. See [Do I have to put all my state into Redux?](https://redux.js.org/faq/organizing-state#do-i-have-to-put-all-my-state-into-redux-should-i-ever-use-reacts-setstate)

## Where should I call my API's?

Don't try to make your API calls from your reducers. Use actions. You can use thunks. A fancy word to name methods that make asynchronous work and dispatch some other actions.

As an alternative, you can use sagas. I knew sagas from a different context. But, they're listeners to actions. See [Trying to put API calls in the correct place](https://github.com/reduxjs/redux/issues/291) and [Where should I put synchronous side effects linked to actions in redux?](https://stackoverflow.com/questions/32982237/where-should-i-put-synchronous-side-effects-linked-to-actions-in-redux/33036344)

## Why can't I put async on my reducers?

You want your reducers to be pure. You should only change state inside reducers. See [Reducers Must Not Have Side Effects](https://redux.js.org/style-guide/style-guide#reducers-must-not-have-side-effects)

## You can't put a button inside an anchor tag

You can, but it isn't sematically valid. If you're working with Bootstrap and need to style your anchor tags, you can use `LinkContainer` from [react-router-bootstrap](https://github.com/react-bootstrap/react-router-bootstrap)

## A simple counter example

### Step 1: Create the store and the reducer

```javascript
// index.js

import React from 'react';
import ReactDOM from 'react-dom';
import { createStore } from 'redux';
import { Provider } from 'react-redux';
import { INCREMENT, DECREMENT } from './actions';
import App from './App';

const initialState = {
  count: 0
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case INCREMENT:
      return { count: state.count + 1 };

    case DECREMENT:
      return { count: state.count - 1 };

    default:
      return state;
  }
}

const store = createStore(reducer);

ReactDOM.render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>,
  document.getElementById('root')
);
```

### Step 2: Create the action types and action creators

```javascript
// actions.js

export const INCREMENT = 'INCREMENT';
export const DECREMENT = 'DECREMENT';

export const increment = () => {
    return { type: INCREMENT };
}

export const decrement = () => {
    return { type: DECREMENT };
}
```

### Step 3: Connect your component and receive props

To connect your component to Redux, you need to pull from the state what your component needs. To achieve this you need a `mapStateToProps` method.

Once you connect your component to Redux, you can use `dispatch` to update state. Receive `dispatch` from `props` and use `dispatch({ type: INCREMENT });`

But, you can choose to abstract the creation of actions, too. For example, you can use `dispatch(increment());`

Even, you can choose to pass custom functions instead of using `dispatch` inside your components. You need a `mapDispatchToProps` method when connecting your component to the store.

```javascript
import React from 'react';
import { increment, decrement } from './actions';
import { connect } from 'react-redux';

const App = ({ count, increment, decrement }) => {

    return (
        <div>
            <h2>Counter</h2>
            <div>
                <button onClick={() => decrement()}>-</button>
                <span>{count}</span>
                <button onClick={() => increment()}>+</button>
            </div>
        </div>
    );
}

// Connect the store with the component
const mapStateToProps = (state) => {
    return {
        count: state.count
    }
}

// It override dispatch with these custom functions
const mapDispatchToProps = {
    increment,
    decrement
};
export default connect(mapStateToProps, mapDispatchToProps)(Counter);
```

You can find the videos and tutorials I’ve used so far in [LetsReact](https://github.com/canro91/LetsReact)

[![canro91/LetsReact - GitHub](https://gh-card.dev/repos/canro91/LetsReact.svg)](https://github.com/canro91/LetsReact)

_Happy coding!_
