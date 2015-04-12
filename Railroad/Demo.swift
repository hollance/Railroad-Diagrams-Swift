//import Railroad

#if os(OSX)
import Cocoa
#endif

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
  decorationStyle.borderSize = 2

  var diagramStyle = DiagramStyle()
  diagramStyle.backgroundColor = Color(white: 0.0, alpha: 0.1)
  diagramStyle.margin = EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  diagramStyle.trackLineWidth = 1
  diagramStyle.arrowSize = 9

  let box = Box(text: "Happy birthday", style: boxStyle)
  let comment = Box(text: "at least 3 times", style: commentStyle)
  let loop = Loop(forward: box, backward: comment)
  let decoration = Decoration(element: loop, text: "to you!", style: decorationStyle)

  return Diagram(style: diagramStyle).renderImage(decoration, scale: 2)
}

func test2() -> Image {
  var myDiagramStyle = DiagramStyle()
  myDiagramStyle.backgroundColor = Color(white: 0.0, alpha: 0.1)
  myDiagramStyle.margin = EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  myDiagramStyle.trackLineWidth = 3

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
  return diagram.renderImage(chain1, scale: 2)
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

/* Edge cases */

func edge_case_empty_toplevel() -> Image {
  // Note: a Series or Parallel with no items as the top-level will trigger an 
  // assertion, because it results in a bitmap with 0 height. However, it will
  // work OK if the DiagramStyle has a non-zero margin.

  var diagramStyle = DiagramStyle()
  diagramStyle.margin = EdgeInsets(top: 10, left: 1, bottom: 10, right: 1)

  let series = Series()
  return Diagram(style: diagramStyle).renderImage(series, scale: 1)
}

func edge_case_box_toplevel() -> Image {
  let box = Box(text: "Box")
  return Diagram().renderImage(box, scale: 1)
}

func edge_case_box_no_text() -> Image {
  let box = Box(text: "")
  return Diagram().renderImage(box, scale: 1)
}

func edge_case_series_one_element() -> Image {
  let box = Box(text: "Box")
  let series = Series(elements: [box])
  return Diagram().renderImage(series, scale: 1)
}

func edge_case_empty_series_parallel() -> Image {
  // It's OK to have empty Series and Parallel, just not at the top-level.
  let box = Box(text: "Box")
  let series = Series(elements: [box, Series(), Parallel()])
  return Diagram().renderImage(series, scale: 1)
}

func edge_case_series_with_skip() -> Image {
  let series = Series(elements: [Skip()])
  return Diagram().renderImage(series, scale: 1)
}

func edge_case_parallel_one_item() -> Image {
  let box = Box(text: "Box")
  let parallel = Parallel(elements: [box])
  return Diagram().renderImage(parallel, scale: 1)
}

func edge_case_parallel_with_skip() -> Image {
  let parallel = Parallel(elements: [Skip()])
  return Diagram().renderImage(parallel, scale: 1)
}

func edge_case_parallel_two_skips() -> Image {
  let parallel = Parallel(elements: [Skip(), Skip()])
  return Diagram().renderImage(parallel, scale: 1)
}

func edge_case_loop_two_skips() -> Image {
  let loop = Loop(forward: Skip(), backward: Skip())
  return Diagram().renderImage(loop, scale: 1)
}

func edge_case_series_with_one_element_inside_parallel1() -> Image {
  let box1 = Box(text: "Box1 with long text")
  let box2 = Box(text: "Box2")
  let series = Series(elements: [box2])
  let parallel = Parallel(elements: [box1, series])
  return Diagram().renderImage(parallel, scale: 1)
}

func edge_case_series_with_one_element_inside_parallel2() -> Image {
  let box1 = Box(text: "Box1 with long text")
  let box2 = Box(text: "Box2")
  let series = Series(elements: [box1])
  let parallel = Parallel(elements: [series, box2])
  return Diagram().renderImage(parallel, scale: 1)
}