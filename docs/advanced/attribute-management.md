# Attribute Management

## Overview

deck.gl layers' public API were designed to follow a Reactive programming
paradigm.
The challenge is that in the "reactive" model, every change to application state
causes everything to be re-rendered. This is not an issue for UI rendering for
general purpose apps, but for high performance, graphics intensive and sometime
 3D contents to be rendered by WebGL, huge memory buffers (so called "vertex attributes",
or just "attributes" for short) must be prepared and transferred to the GPUs
before any draw calls got executed on the GPUs.

## WebGL Performance Challenges

Creating and transferring new WebGL buffers before every draw call would result in
unacceptable performance even for moderately complex models. Just like in React
(which "renders" to the browser's slow-updating DOM), the challenge becomes to
detect which part of the visualization is changed to limit both attributes recalculation
and re-rendering to the minimum.

Since the length of attributes are usually proportional of to the number of
data elements being visualized (hundreds of thousands or even multiple millions of
elements are not uncommon in big data visualizations), efficient attribute
updates is critical.

deck.gl alleviates the burden of layer developers by providing an
 `AttributeManager` class to manage the lifecycle of those WebGL
attributes. Note that it is completely possible for a layer to use custom
code to manage attribute updates, however most layers rely on
the AttributeManager class to handle WebGL buffer management for them.

## Automatic Attribute Generation

Automated attribute generation and management is suitable when a set of
vertex shader attributes are generated by iteration over a data array,
and updates to these attributes are needed either when the data itself
changes, or when other data relevant to the calculations change.

- First the application registers descriptions of its dynamic vertex
  attributes using AttributeManager.add().
- Then, when any change that affects attributes is detected by the
  application, the app will call AttributeManager.invalidate().
- Finally before it renders, it calls AttributeManager.update() to
  ensure that attributes are automatically rebuilt if anything has been
  invalidated.

The application provided update functions describe how attributes
should be updated from a data array and are expected to traverse
that data array (or iterable) and fill in the attribute's typed array.

Note that the attribute manager intentionally does not do advanced
change detection, but instead makes it easy to build such detection
by offering the ability to "invalidate" each attribute separately.

### Accessors, Shallow Comparisons and updateTriggers

The layer will expect each object to provide a number of "attributes" that it
can use to set the GL buffers. By default, the layer will look for these
attributes to be available as fields directly on the objects during iteration
over the supplied data set. To gain more control of attribute access and/or
to do on-the-fly calculation of attributes.

**Note**: A layer only renders when a property change is detected. For
performance reasons, property change detection uses shallow compare,
which means that mutating an element inside a buffer or a mutable data array
does not register as a property change, and thus does not trigger a re-render.
To force trigger a render after mutating buffers, simply increment the
`renderCount` property. To force trigger a buffer update after mutating data,
increment the `updateCount` property.


## Advanced Topics

### Manual Buffer Management

While most apps rely on their layers to automatically generate
appropriate WebGL buffers from their props, it is possible for applications
to take control of buffer generation and supply the buffers as properties.

While this allows for ultimate performance and control of updates, as well
as potential sharing of buffers between layers,
the application will need to generate attributes in exactly the format that the
layer shaders expect, creating a strong coupling between the application
and the layer.

**Note:** The application can provide some buffers and let others be managed
by the layer. As an example management of the `instancePickingColors` buffer is
normally left to the layer.


## More information

### Introduction to Vertex Attributes

deck.gl layers use the WebGL technology to render visualization elements.
To have the WebGL drawing command work, multiple things need to be
provided and configured beforehand and the geometric description of the
to-be-rendered element is one of them. In WebGL, all geometry elements are
made of a set of vertices, and each vertex has multiple attributes to
determine how it will be rendered to the screen. These attributes
are called **vertex attributes** and are provided by users using JavaScript
typed arrays (e.g. `Float32Array` or `Uint8Array`).

During rendering, these vertex attributes will become available in vertex
shaders executing on the GPU.

Part of designing a new WebGL layer is creating an elegant mapping from a
set of data properties in JavaScript to a set of WebGL vertex attributes,
and then implement the code that generates the typed arrays that represent
the geometry so that GPU calls can be performed efficiently later when
drawing the layer.


### Introduction to Instanced Vertex Attributes

Even for high performance rendering API like WebGL, setting up draw calls
and dispatching them to GPUs quick become a performance bottleneck for
visualizing big data. Therefore, each deck.gl layer aspires to use as few
GPU draw calls as possible to draw all everything contained in the data.

Here the [`Instanced Rendering`](https://developer.mozilla.org/en-US/docs/Web/API/ANGLE_instanced_arrays)
 comes into play. While some vertex attributes will still describe the geometry
 of each object (or instance), some vertex attributes will describe what is
 different between each object or instance. The latter kind of attributes are
 called instanced attributes.

**Note:** While "instanced rendering" is technically an "extension" to WebGL,
(meaning that it is not guaranteed to be present in all browsers),
today the feature is supported by wide range of systems.
[WebGL Stats](http://webglstats.com/) for statistics on how big a percentage
of systems support various WebGL features, particularly the
`ANGLE_instanced_arrays` extension. In WebGL 2.0,  instanced rendering becomes
a core feature that needs to be implemented by all vendors.


### Learning More

While you can certainly start consulting detailed WebGL/OpenGL resources
to learn more about vertex attributes, be aware that many available resources
can get quite technical, involving more concepts than you may need at this
point.

If you are new to these concepts, we have found that a great way to learn more
is simply to copy an existing deck.gl layer and start extending/modifying
its functionality.