# Railroad Diagrams in Swift

Library for drawing railroad diagrams in Swift. You give it a tree structure that represents the diagram and it outputs a `UIImage` or `NSImage`.

This is something I did for fun back in the Swift 1.0 days and recently ported to Swift 5. The code is probably quite smelly. I'm not actively maintaining this project, but wanted to share it anyway in case someone finds it useful.

## Why railroad diagrams?

Railroad diagrams are useful for visualizing regular expressions, parser syntax, etc. Here is an example of a regex:

![regexp1.png](Examples/regexp1.png)

This image was generated using the following code: 

```swift
func digit() -> Element {
  return characterClass("digit")
}

let image = diagram(
  special("Start of Line"),
  optional(choice(literal("+"), literal("-")), false),
  capture(
    choice(
      sequence(oneOrMore(digit()), optional(literal("."), false), zeroOrMore(digit())),
      sequence(literal("."), oneOrMore(digit()))
    ),
    "Capture 1"),
  optional(capture(
    sequence(
      choice(literal("e"), literal("E")),
      optional(choice(literal("+"), literal("-"))),
      oneOrMore(digit())
    ),
    "Capture 2"), false),
  special("End of Line")
)
```

Note that this library does not actually parse regexes -- it only provides an API for creating the diagrams.

There are actually three different APIs: a low-level API where you create the different elements yourself and hook them up into a tree structure, and two different DSLs (like the one above) that are a lot easier to read.

Here is another example, rendered in a different style:

![test3.png](Examples/test3.png)

## Features and limitations

Features:

- Text inside a box can be multi-line text.
- The elements can be styled in different ways (shape, font, color, padding, line width).

Future enhancements:

- Decoration could do with more configuration options.

Limitations:

- There is no wrap-around for very long diagrams to make them fit on a page.

## How to use this

Open the project in Xcode 10.2 or higher, build and run. This will save a bunch of PNG files with various diagrams and test cases to your temp folder.

All the code is in the **Railroad.swift** file.

License: public domain.
