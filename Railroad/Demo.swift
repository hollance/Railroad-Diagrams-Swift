
/* Export an image to a PNG file */
#if os(iOS)
import UIKit

func savePNG(image: UIImage, filename: String) {
  if let dirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true) as? [String] {
    let path = dirs[0].stringByAppendingPathComponent(filename)
    if !UIImagePNGRepresentation(image).writeToFile(path, atomically: true) {
      println("Error saving image to: \(path)")
    } else {
      println("Image saved to: \(path)")
    }
  }
}
#else
import AppKit

func savePNG(image: NSImage, path: String) {
  image.lockFocus()
  let bitmapRep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
  image.unlockFocus()

  if let bitmapRep = bitmapRep {
    if let data = bitmapRep.representationUsingType(.NSPNGFileType, properties: [:]) {
      if data.writeToFile(path, atomically: true) {
        println("Image saved to: \(path)")
        return
      }
    }
  }
  println("Error saving image to: \(path)")
}
#endif

import Railroad

func test1() -> Image {
  var commentStyle = BoxStyle()
  commentStyle.shape = .None

  #if os(iOS)
  commentStyle.textStyle.font = Font.italicSystemFontOfSize(18)
  #else
  commentStyle.textStyle.font = NSFontManager.sharedFontManager().fontWithFamily("Verdana", traits: .ItalicFontMask, weight: 0, size: 18)!
  #endif

  var boxStyle = BoxStyle()
  boxStyle.shape = .RoundedSides
  boxStyle.textStyle.color = Color.darkGrayColor()
  boxStyle.borderColor = Color.grayColor()
  boxStyle.textStyle.font = Font.systemFontOfSize(24)

  var decorationStyle = DecorationStyle()
  decorationStyle.backgroundColor = Color(white: 1, alpha: 0.2)

  var diagramStyle = DiagramStyle()
  diagramStyle.backgroundColor = Color(white: 0.0, alpha: 0.1)
  diagramStyle.margin = EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

  let box = Box(text: "Happy birthday", style: boxStyle)
  let comment = Box(text: "at least 3 times", style: commentStyle)
  let loop = Loop(forward: box, backward: comment)
  let decoration = Decoration(element: loop, text: "to you!", style: decorationStyle)

  return Diagram(style: diagramStyle).renderImage(decoration, scale: 1)
}

func test2() -> Image {
  var myDiagramStyle = DiagramStyle()
  myDiagramStyle.backgroundColor = Color(white: 0.0, alpha: 0.1)
  myDiagramStyle.margin = EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

  var myBoxStyle = BoxStyle()
  myBoxStyle.shape = .RoundedCorners(cornerRadius: 12)
  myBoxStyle.borderSize = 1
  myBoxStyle.backgroundColor = Color.yellowColor()
  myBoxStyle.borderColor = Color.redColor()

  var myBoxStyle2 = BoxStyle()
  myBoxStyle2.shape = .PointySides(angle: 30)
  myBoxStyle2.textStyle.color = Color.darkGrayColor()
  myBoxStyle2.borderColor = Color.grayColor()

  var myBoxStyle3 = BoxStyle()
  myBoxStyle3.shape = .RoundedSides
  myBoxStyle3.textStyle.color = Color.darkGrayColor()
  myBoxStyle3.borderColor = Color.grayColor()
  //myBoxStyle3.textInsets = EdgeInsets(top: 50, left: 10, bottom: 50, right: 10)

  let group1 = Parallel()
  group1.add(Box(text: "He\nllo\naapjes", style: myBoxStyle3))
  group1.add(Box(text: "world!"))

  let chain3 = Series()
  chain3.add(Box(text: "a"))
  chain3.add(Box(text: "b"))

  let loop1 = Loop(forward: chain3, backward: Box(text: "YO!"))

  let chain2 = Series()
  chain2.add(loop1)
  chain2.add(Box(text: "lol\nyeah"))

  let group2 = Parallel()
  group2.add(Box(text: "Hello"))
  group2.add(Box(text: "world!"))
  group2.add(Box(text: "yeah!"))
  group2.indexOfCenterElement = 2
  chain2.add(group2)

  group1.add(chain2)
  group1.add(Skip())

  let chain1 = Series()
  chain1.add(Box(text: "A", style: myBoxStyle))
  chain1.add(Box(text: "B", style: myBoxStyle2))
  chain1.add(group1)
  chain1.add(Box(text: "cde", style: myBoxStyle3))

  let diagram = Diagram(style: myDiagramStyle)
  return diagram.renderImage(chain1, scale: 1)
}

/* 
 * A diagram that I found online:
 * http://stackoverflow.com/questions/6216771/what-are-these-diagrams-called-answer-railroad-diagrams
 */
func test3() -> Image {
  let strokeColor = Color(red: 0.10, green: 0.41, blue: 1.0, alpha: 1.0)
  let fillColor = strokeColor.colorWithAlphaComponent(0.15)

  var boxStyle = BoxStyle()
  boxStyle.shape = .RoundedSides
  boxStyle.borderColor = strokeColor
  boxStyle.backgroundColor = fillColor
  boxStyle.textStyle.color = Color(red: 0.05, green: 0.2, blue: 0.5, alpha: 1.0)

  let factory = BoxFactory(style: boxStyle)

  let chain6 = Series()
  chain6.add(factory.createBox("VALUES"))
  chain6.add(factory.createBox("("))
  chain6.add(Loop(forward: factory.createBox("expr"), backward: factory.createBox(",")))
  chain6.add(factory.createBox(")"))

  let group6 = Parallel()
  group6.add(chain6)
  group6.add(factory.createBox("select-stmt"))

  let chain5 = Series()
  chain5.add(factory.createBox("("))
  chain5.add(Loop(forward: factory.createBox("column-name"), backward: factory.createBox(",")))
  chain5.add(factory.createBox(")"))

  let group5 = Parallel()
  group5.add(chain5)
  group5.add(Skip())

  let chain7 = Series()
  chain7.add(group5)
  chain7.add(group6)

  let chain8 = Series()
  chain8.add(factory.createBox("DEFAULT"))
  chain8.add(factory.createBox("VALUES"))

  let group7 = Parallel()
  group7.add(chain7)
  group7.add(chain8)

  let chain4 = Series()
  chain4.add(factory.createBox("database-\nname"))
  chain4.add(factory.createBox("."))

  let group4 = Parallel()
  group4.add(chain4)
  group4.add(Skip())

  let group3 = Parallel()
  group3.add(factory.createBox("ROLLBACK"))
  group3.add(factory.createBox("ABORT"))
  group3.add(factory.createBox("REPLACE"))
  group3.add(factory.createBox("FAIL"))
  group3.add(factory.createBox("IGNORE"))

  let chain3 = Series()
  chain3.add(factory.createBox("OR"))
  chain3.add(group3)

  let group2 = Parallel()
  group2.add(Skip())
  group2.add(chain3)

  let chain2 = Series()
  chain2.add(factory.createBox("INSERT"))
  chain2.add(group2)

  let group1 = Parallel()
  group1.add(chain2)
  group1.add(factory.createBox("REPLACE"))

  let chain1 = Series()
  chain1.add(group1)
  chain1.add(factory.createBox("INTO"))
  chain1.add(group4)
  chain1.add(factory.createBox("table-name"))
  chain1.add(group7)

  var diagramStyle = DiagramStyle()
  diagramStyle.trackColor = strokeColor

  let diagram = Diagram(style: diagramStyle)
  return diagram.renderImage(chain1, scale: 1)
}

/*
 * Based on the example from http://www.xanthir.com/etc/railroad-diagrams/generator.html
 */
func test4() -> Image {
  return diagram(
    optional(terminal("+"), false),
    choice(
      nonTerminal("name-start char"),
      nonTerminal("escape")
    ),
    capture(
      zeroOrMore(
        choice(1,
          nonTerminal("name char"),
          nonTerminal("escape")
        ),
        comment("yay"),
        false
      ),
      "capture 2"
    ),
    capture(
      oneOrMore(terminal("x"), comment("5 times")),
      "capture 1"
    )
  )
}

/*
 * Examples from http://html-railroad-diagram.googlecode.com/svn/trunk/examples/railroad.html
 */
func json_object() -> Image {
  return diagram(
    terminal("{"),
    any(
      each(nonTerminal("string"), terminal(":"), nonTerminal("value")),
      terminal(",")),
    terminal("}"))
}

func json_number() -> Image {
  return diagram(
    maybe(terminal("-")),
    or(
      terminal("0"),
      each(terminal("digit\n1-9"), any(terminal("digit")))),
    maybe(
      each(terminal("."), any(terminal("digit")))),
    maybe(
      each(
        or(terminal("e"), terminal("E")),
        maybe(or(terminal("+"), terminal("-"))),
        many(terminal("digit")))))
}
