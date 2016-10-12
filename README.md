# TemplateKit
[React](http://facebook.github.io/react/)-inspired framework for building component-based user interfaces in Swift.

## Example
#### Component.xml
```html
<template>
  <style>
    #container > .button {
      color: #000;
    }
    
    #container > .button-selected {
      color: #f00;
    }
  </style>
  <box id="container">
    <text text="$properties.title" />
    <text text="Click me!" onTap="handleClick" classNames="$textClasses" />
  </box>
</template>
```
#### Component.swift
```swift
struct ComponentState: State {
  var selected: Bool?
}

struct ComponentProperties: Properties {
  var core = CoreProperties()
  var title: String? = "This is a default title"
}

class MyComponent: CompositeComponent<ComponentState, ComponentProperties, UIView> {
  // Stored properties on the component are made available to template.
  var textClasses: String?
 
  // As are functions, referenced by their selector name.
  @objc func handleClick() {
    updateComponentState { state in
      state.selected = !state.selected
    }
  }
 
  override func render() -> Element {
    textClasses = state.selected ? "button" : "button-selected"
  
    return render("http://localhost:8000/Component.xml")
  }
}
```
#### ViewController.swift
```swift
override func viewDidLoad() {
  super.viewDidLoad()
 
  UIKitRenderer.render(component(MyComponent.self), container: self.view, context: self) { component in
    self.component = component
  }
}
```

See the included [Example](https://github.com/mcudich/TemplateKit/tree/master/Example) project for more examples of how to use TemplateKit.

## Why?

#### Swift
Because you like writing your apps completely in Swift. TemplateKit is fully native and compiled.

#### Declarative Style
Writing user interfaces in a declarative style makes it easier to reason about how model data and user actions affect what gets rendered. Out-of-the-box support for XML. Extensible if you want to add your own template format (e.g., protocol buffers).

#### Components
Components make it easy to encapsulate application functionality into re-usable building blocks. These blocks can then be composed to create more complex interfaces.

#### Layout
Flexbox-based layout primitives allow developers to use the the same expressive layout system available in modern browsers.

#### Asynchronous Rendering & Performance
All layout computation, text sizing, tree diffing, image decoding is performed in the background. This keeps the main thread available for responding to user actions. Only the absolute minimum set of changes needed to update the view hierarchy are actually flushed to the rendered views.

#### CSS
Use stylesheets to style components, just like you do on the web.

#### Live Reloading
Automatically reload changes to user interfaces without having to re-build binaries or restart your application. Usable in both development and production environments.

#### Extensible
Add custom components, custom native views, custom template loading schemes and more.

#### Easy to try
Plug it in anywhere you want to render a view in your application. Plays nicely with the rest of your app.

## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "mcudich/TemplateKit"
```
Make sure to add `TemplateKit.framework`, `CSSLayout.framework`, and `CSSParser.framework` to "Linked Frameworks and Libraries" and "copy-frameworks" Build Phases.

## How does it work?
At its core, TemplateKit is comprised of `Element` and `Node` instances. Elements are used to describe trees of nodes, which can be anything that implements the `Node` interface. Nodes are used to vend out and manage view hierarchies.

Out of the box, there are several `Node` implementations that make it easy to set up UI hierarchies: `CompositeComponent`, `ViewNode`, and a set of native controls like buttons, text labels, text fields and so on.

Building a component is as simple as subclassing `CompositeComponent`, overriding its `render()` function, and deciding the set of properties it might accept and use as part of rendering. `render()` simply needs to return a `Template`, which can be constructed programmatically, or via an XML document. When it comes time to render your component into a view, you simply call `UIKitRenderer.render`, and pass in the view that should contain your component's rendered output. This will in turn call `render()` on your component instance, compute the layout and styles for the view tree, build this tree and then apply the layout and styles to it as appropriate.

When it comes time to update your component's state, you can call `updateComponentState` from within your component implementation. This function receives a function that is passed the current state value (each `CompositeComponent` can declare a `State` type, in the same way it declares a `Properties` type). This function in turn enqueues an update to the component, which will cause it to re-render, taking into account whatever changes were made to the state. This update is intelligent, and compares the current incarnation of the rendered view tree against the proposed element tree. Only the deltas between these two are flushed out to the view layer.

## Opaque Views
If there are parts of your UI that are easier to deal with as plain `UIViews`, TemplateKit provides a simple abstraction `Node` called `ViewNode` that allows you to include these "opaque" views as part of any TemplateKit-managed tree. TemplateKit stays out of the way, and simply sets the `frame` of these views for you, so they sit nicely within in whatever UI tree you've composed.

## Collections
TemplateKit provides `UITableView` and `UICollectionView` subclasses which are able to load, and asynchronously size and render `CompositeComponents` into cells with just a little bit of configuration. Tables and collections can be used via `Table` and `Collection` components, or simply wrapped as `ViewNode` instances.

## How's this different from React Native?
TemplateKit is implemented in Swift (and a bit of C). If you like writing entirely in Swift, then this framework might be for you.

React Native relies on an incredibly well-tested library (React), and has been shipipng in some incredibly popular apps for some time now. This means it probably has way fewer rough edges, has sorted out many performance issues TemplateKit has yet to face, and so on.

## Inspiration
- [React](https://github.com/facebook/react)
- [AsyncDisplayKit](https://github.com/facebook/AsyncDisplayKit)

## See Also
If TemplateKit isn't exactly what you're looking for, check out these other great projects!
- [Few.swift](https://github.com/joshaber/Few.swift)
- [Render](https://github.com/alexdrone/Render)
- [React Native](https://facebook.github.io/react-native/)
- [LayoutKit](https://github.com/linkedin/LayoutKit)
- [ComponentKit](https://github.com/facebook/componentkit)
- [HubFramework](https://github.com/spotify/HubFramework)
