
import CoreGraphics

/* For supporting both iOS and OS X. */

#if os(iOS)
  import UIKit
  public typealias Color = UIColor
  public typealias Image = UIImage
  public typealias EdgeInsets = UIEdgeInsets
  public typealias Font = UIFont
#else
  import AppKit
  public typealias Color = NSColor
  public typealias Image = NSImage
  public typealias EdgeInsets = NSEdgeInsets
  public typealias Font = NSFont
#endif

/* Helper code for debug drawing. */

private func randomCGFloat() -> CGFloat {
  return CGFloat(arc4random())/0xffffffff
}

private extension Color {
  class func randomColor() -> Color {
    return Color(red: randomCGFloat(), green: randomCGFloat(), blue: randomCGFloat(), alpha: 1.0)
  }
}

private let debugDraw = false

private let debugColors = [
  Color.blueColor(),
  Color.redColor(),
  Color.yellowColor(),
  Color.greenColor(),
  Color.purpleColor() ]

private func debugRect(context: CGContextRef, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, type: Int) {
  if debugDraw {
    CGContextSaveGState(context)
    CGContextSetLineWidth(context, 1)
    CGContextSetStrokeColorWithColor(context, debugColors[type].CGColor)
    CGContextStrokeRect(context, CGRectMake(x + 0.5, y + 0.5, width - 1, height - 1))
    CGContextRestoreGState(context)
  }
}

/* Helper code for doing trig. */

private let π = CGFloat(M_PI)

private func degreesToRadians(degrees: CGFloat) -> CGFloat {
  return π * degrees / 180.0
}

private func radiansToDegrees(radians: CGFloat) -> CGFloat {
  return radians * 180.0 / π
}

// MARK: Styling of the elements

public enum BoxShape {
  case None                                  // useful for comments
  case Rectangle
  case RoundedSides
  case RoundedCorners(cornerRadius: CGFloat)
  case PointySides(angle: CGFloat)           // larger angle = more pointy
}

public struct TextStyle {
  public var font = Font.systemFontOfSize(18)
  public var color = Color.blackColor()
  public var padding = EdgeInsets(top: 6, left: 18, bottom: 6, right: 18)

  public init() { }
}

public struct BoxStyle {
  public var shape = BoxShape.Rectangle
  public var borderSize: CGFloat = 1
  public var borderColor = Color.blackColor()
  public var backgroundColor = Color.whiteColor()
  public var textStyle = TextStyle()

  public init() { }
}

public struct DecorationStyle {
  public var margin = EdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
  public var padding = EdgeInsets(top: 18, left: 12, bottom: 30, right: 12)
  public var borderSize: CGFloat = 3
  public var borderColor = Color(white: 0, alpha: 0.35)
  public var backgroundColor = Color.clearColor()

  public var textStyle: TextStyle = {
    var style = TextStyle()
    style.font = Font.boldSystemFontOfSize(12)
    style.color = Color(white: 0, alpha: 0.35)
    style.padding = EdgeInsets(top: 0, left: 0, bottom: 6, right: 9)
    return style
  }()

  public init() { }
}

public enum Alignment {
  case Left
  case Center
  case Right
  case Fill
}

public enum CapStyle {
  case FilledCircle
  case StrokedCircle
  case VerticalBars
}

public struct DiagramStyle {
  public var margin = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  public var backgroundColor = Color.whiteColor()
  public var capStyle = CapStyle.FilledCircle

  public var trackColor = Color.blackColor()
  public var trackLineWidth: CGFloat = 2

  /* Tip: The arrow size should be odd/even is trackLineWidth is odd/even. */
  public var arrowHeads = true
  public var arrowSize: CGFloat = 10

  /* The length of the line segments before and after boxes. */
  public var horizontalSpacing: CGFloat = 24

  /* How far apart the boxes are in vertical groups. */
  public var verticalSpacing: CGFloat = 24

  /* What happens to the elements in a Parallel grouping. */
  public var forwardAlignment = Alignment.Left

  /* What happens to the elements in a Loop grouping. */
  public var backwardAlignment = Alignment.Center

  public init() { }
}

// MARK: - Styling helper methods

extension BoxShape {
  private func pathForRectangle(rect: CGRect) -> CGPathRef {
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, rect)
    return path
  }

  private func pathForRoundedCorners(rect: CGRect, cornerRadius: CGFloat) -> CGPathRef {
    let x1 = rect.origin.x
    let y1 = rect.origin.y
    let x2 = x1 + rect.size.width
    let y2 = y1 + rect.size.height

    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, x1, y2 - cornerRadius)
    CGPathAddArcToPoint(path, nil, x1, y1, x2, y1, cornerRadius)
    CGPathAddArcToPoint(path, nil, x2, y1, x2, y2, cornerRadius)
    CGPathAddArcToPoint(path, nil, x2, y2, x1, y2, cornerRadius)
    CGPathAddArcToPoint(path, nil, x1, y2, x1, y1, cornerRadius)
    CGPathCloseSubpath(path)
    return path
  }

  private func pathForRoundedSides(rect: CGRect) -> CGPathRef {
    let radius = rect.size.height/2
    let x1 = rect.origin.x + radius
    let y1 = rect.origin.y
    let x2 = rect.origin.x + rect.size.width - radius
    let y2 = CGRectGetMidY(rect)

    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, x1, y1)
    CGPathAddArc(path, nil, x2, y2, radius, -π/2, π/2, false)
    CGPathAddArc(path, nil, x1, y2, radius, π/2, -π/2, false)
    CGPathCloseSubpath(path)
    return path
  }

  private func pathForPointySides(rect: CGRect, angle: CGFloat) -> CGPathRef {
    let inset = sin(degreesToRadians(angle)) * rect.size.height/2

    let x1 = rect.origin.x
    let x2 = x1 + inset
    let x4 = x1 + rect.size.width
    let x3 = x4 - inset

    let y1 = rect.origin.y
    let y2 = CGRectGetMidY(rect)
    let y3 = y1 + rect.size.height

    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, x2, y1)
    CGPathAddLineToPoint(path, nil, x3, y1)
    CGPathAddLineToPoint(path, nil, x4, y2)
    CGPathAddLineToPoint(path, nil, x3, y3)
    CGPathAddLineToPoint(path, nil, x2, y3)
    CGPathAddLineToPoint(path, nil, x1, y2)
    CGPathAddLineToPoint(path, nil, x2, y1)
    CGPathCloseSubpath(path)
    return path
  }

  func pathForRect(rect: CGRect) -> CGPathRef {
    switch self {
    case .None:
      fatalError("BoxShape.None has no path")

    case .Rectangle:
      return pathForRectangle(rect)

    case .RoundedSides:
      return pathForRoundedSides(rect)

    case .RoundedCorners(let cornerRadius):
      return pathForRoundedCorners(rect, cornerRadius: cornerRadius)

    case .PointySides(let angle):
      return pathForPointySides(rect, angle: angle)
    }
  }

  func hasPath() -> Bool {
    switch self {
    case .None:
      return false
    default:
      return true
    }
  }
}

extension TextStyle {
  func attribs() -> [NSObject: AnyObject] {
    let paragraphStyle = NSMutableParagraphStyle()      // for multiline text
    #if os(iOS)
    paragraphStyle.alignment = NSTextAlignment.Center
    #else
    paragraphStyle.alignment = NSTextAlignment.CenterTextAlignment
    #endif

    return [ NSFontAttributeName: font,
      NSForegroundColorAttributeName: color,
      NSParagraphStyleAttributeName: paragraphStyle ]
  }
}

extension DiagramStyle {
  func alignmentForDirection(direction: Direction) -> Alignment {
    if direction == .Forward {
      return forwardAlignment
    } else {
      return backwardAlignment
    }
  }

  var lefthandTrackLength: CGFloat {
    return horizontalSpacing + (arrowHeads ? arrowSize : 0)
  }

  var righthandTrackLength: CGFloat {
    return horizontalSpacing
  }

  /* This keeps lines with an odd width sharp. */
  var oddLineAdjust: CGFloat {
    return ceil(trackLineWidth) % 2 == 0 ? 0 : -0.5
  }

  /* For drawing curves in a Parallel and Loop. */
  var radius: CGFloat {
    return floor(horizontalSpacing / 2)
  }

  func pathForArrowHead() -> CGPathRef {
    let x1 = CGFloat(0)
    let x2 = self.arrowSize

    let y1 = -self.arrowSize / 2
    let y2 = CGFloat(0)
    let y3 = self.arrowSize / 2

    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, x1, y1)
    CGPathAddLineToPoint(path, nil, x2, y2)
    CGPathAddLineToPoint(path, nil, x1, y3)
    CGPathAddLineToPoint(path, nil, x1, y1)
    CGPathCloseSubpath(path)
    return path
  }
}

// MARK: - Drawing helper functions

/* This allows us to use NSString drawing in our own CGContextRef. */
func setUpNSStringDrawingContext(context: CGContextRef) {
  #if os(iOS)
    UIGraphicsPushContext(context)
  #else
    NSGraphicsContext.saveGraphicsState()
    let nscg = NSGraphicsContext(CGContext: context, flipped: true)
    NSGraphicsContext.setCurrentContext(nscg)
  #endif
}

func tearDownNSStringDrawingContext() {
  #if os(iOS)
    UIGraphicsPopContext()
  #else
    NSGraphicsContext.restoreGraphicsState()
  #endif
}

func fillRect(context: CGContextRef, var rect: CGRect, color: Color) {
  CGContextSetFillColorWithColor(context, color.CGColor)
  CGContextFillRect(context, rect)
}

func strokeRect(context: CGContextRef, rect: CGRect, borderSize: CGFloat, color: Color) {
  CGContextSetLineWidth(context, borderSize)
  CGContextSetStrokeColorWithColor(context, color.CGColor)
  CGContextStrokeRect(context, CGRectInset(rect, borderSize / 2, borderSize / 2))
}

func drawChildElement(element: Element, context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
  CGContextSaveGState(context)
  CGContextTranslateCTM(context, element.x, element.y)
  element.drawIntoContext(context, diagramStyle: diagramStyle, direction: direction)
  CGContextRestoreGState(context)
}

func drawHorizontalTrack(context: CGContextRef, startX: CGFloat, endX: CGFloat, y: CGFloat, diagramStyle: DiagramStyle) {
  let half = ceil(diagramStyle.trackLineWidth / 2)
  let rect = CGRect(x: startX, y: y - half, width: endX - startX, height: diagramStyle.trackLineWidth)
  CGContextSetFillColorWithColor(context, diagramStyle.trackColor.CGColor)
  CGContextFillRect(context, rect)
}

func drawArrowHead(context: CGContextRef, x: CGFloat, y: CGFloat, diagramStyle: DiagramStyle, direction: Direction) {
  let arrowHead = diagramStyle.pathForArrowHead()
  CGContextSaveGState(context)
  CGContextSetFillColorWithColor(context, diagramStyle.trackColor.CGColor)
  CGContextTranslateCTM(context, x, y + diagramStyle.oddLineAdjust)
  if direction == .Backward {
    CGContextTranslateCTM(context, diagramStyle.arrowSize, 0)
    CGContextScaleCTM(context, -1, 1)
  }
  CGContextAddPath(context, arrowHead)
  CGContextFillPath(context)
  CGContextRestoreGState(context)
}

// MARK: - Elements

enum Direction {
  case Forward
  case Backward
}

/*
 * A railroad diagram consists of elements.
 *
 * Rendering the diagram happens in three passes:
 *   1. measuring each individual element (recursively)
 *   2. layout to move elements to their final positions
 *   3. drawing
 *
 * Note: You cannot use the same element instance more than once in the same
 * diagram!
 */
public class Element {
  /* Coordinates of the top-left corner in the parent's coordinate system.
     These are filled in by the layout step. */
  var x: CGFloat = 0
  var y: CGFloat = 0

  /* These are filled in by the measuring step. */
  var width: CGFloat = 0
  var height: CGFloat = 0

  /* The local y-coordinate of where the incoming and outgoing tracks connect.
     Filled in by the measuring step. */
  var connectY: CGFloat = 0

  init() { }

  func measure(diagramStyle: DiagramStyle) {
    // subclass should override
  }

  func layout(diagramStyle: DiagramStyle, direction: Direction) {
    // subclass may override
  }

  /* Note: Before an element is drawn, the context is translated so that (0,0)
     is the top-left corner of the element. */
  func drawIntoContext(context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
    // subclass should override
  }
}

/*
 * A box with text. These are the main building blocks of railroad diagrams.
 */
public final class Box: Element {
  private let text: String
  private let style: BoxStyle

  private var textSize = CGSizeZero
  private var boxWidth: CGFloat = 0

  public init(text: String, style: BoxStyle = BoxStyle()) {
    self.text = text
    self.style = style
  }

  override func measure(diagramStyle: DiagramStyle) {
    let textPadding = style.textStyle.padding
    textSize = text.sizeWithAttributes(style.textStyle.attribs())
    boxWidth = ceil(textSize.width) + textPadding.left + textPadding.right
    height = ceil(textSize.height) + textPadding.top + textPadding.bottom

    switch style.shape {
    case .RoundedSides:
      boxWidth = max(boxWidth, height)
    default:
      break
    }

    width = boxWidth + diagramStyle.lefthandTrackLength + diagramStyle.righthandTrackLength
    connectY = floor(height / 2)
  }

  override func drawIntoContext(context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 2)

    // Adjust position or width based on the alignment settings.
    var boxX = diagramStyle.lefthandTrackLength
    switch diagramStyle.alignmentForDirection(direction) {
    case .Left:
      break
    case .Center:
      boxX += floor((width - diagramStyle.lefthandTrackLength - diagramStyle.righthandTrackLength - boxWidth)/2)
    case .Right:
      boxX = width - boxWidth - diagramStyle.righthandTrackLength
    case .Fill:
      boxWidth = width - diagramStyle.lefthandTrackLength - diagramStyle.righthandTrackLength
    }

    // For boxes with pointy sides we want to draw the track going partially
    // under the box, which looks better (but only if not drawing arrowheads).
    var under = CGFloat(0)
    switch style.shape {
    case .PointySides:
      under = boxWidth/2
    default:
      break
    }

    // Draw the incoming track.
    var lineX = boxX
    if diagramStyle.arrowHeads && direction == .Forward {
      lineX -= diagramStyle.arrowSize
    } else {
      lineX += under
    }

    drawHorizontalTrack(context, 0, lineX, connectY, diagramStyle)

    // Draw the outgoing track.
    lineX = boxX + boxWidth
    if diagramStyle.arrowHeads && direction == .Backward {
      lineX += diagramStyle.arrowSize
    } else {
      lineX -= under
    }

    drawHorizontalTrack(context, lineX, width, connectY, diagramStyle)

    // Draw the arrow head.
    if diagramStyle.arrowHeads {
      let arrowX = (direction == .Backward) ? boxX + boxWidth : boxX - diagramStyle.arrowSize
      drawArrowHead(context, arrowX, connectY, diagramStyle, direction)
    }

    // Draw the box shape.
    if style.shape.hasPath() {
      CGContextSetFillColorWithColor(context, style.backgroundColor.CGColor)
      CGContextSetStrokeColorWithColor(context, style.borderColor.CGColor)

      let halfBorder = style.borderSize / 2
      let boxRect = CGRectMake(boxX + halfBorder, halfBorder, boxWidth - style.borderSize, height - style.borderSize)
      CGContextSetLineWidth(context, style.borderSize)

      let path = style.shape.pathForRect(boxRect)
      CGContextAddPath(context, path)
      CGContextDrawPath(context, kCGPathFillStroke)
    }

    // Draw the text.
    var textRect = CGRect(
      x: boxX + floor((boxWidth - textSize.width) / 2),
      y: floor((height - textSize.height) / 2),
      width: textSize.width,
      height: textSize.height)

    debugRect(context, textRect.origin.x, textRect.origin.y, textRect.size.width, textRect.size.height, 4)

    text.drawInRect(textRect, withAttributes: style.textStyle.attribs())
  }
}

/*
 * A sequence of elements.
 */
public final class Series: Element {
  private(set) var elements: [Element]

  public override convenience init() {
    self.init(elements: [])
  }

  public init(elements: [Element]) {
    self.elements = elements
  }

  public func add(element: Element) {
    elements.append(element)
  }

  override func measure(diagramStyle: DiagramStyle) {
    for element in elements {
      element.measure(diagramStyle)
      width += element.width
      connectY = max(element.connectY, connectY)
    }

    // For this row, we have to find the largest connectY, and move all the
    // other elements down by the difference. That happens in the layout step,
    // but it also effects our height, which we need to calculate here (we can't
    // modify our height in the layout step, that messes up everything).
    for element in elements {
      let diff = connectY - element.connectY
      height = max(height, element.height + diff)
    }
  }

  override func layout(diagramStyle: DiagramStyle, direction: Direction) {
    var localX: CGFloat = 0
    for element in elements {
      element.x = localX
      element.y = connectY - element.connectY
      element.layout(diagramStyle, direction: direction)
      localX += element.width
    }

    // If this series is inside a parallel and there is still room left over,
    // then we have to distribute that difference amongst the child elements,
    // according to the alignment rules.
    let diff = width - localX
    if diff > 0 {
      switch diagramStyle.alignmentForDirection(direction) {
      case .Left:
        elements.last!.width += diff
      case .Right:
        elements.first!.width += diff
        for element in dropFirst(elements) {
          element.x += diff
        }
      case .Center, .Fill:
        let diffPerElement = floor(diff / CGFloat(elements.count))
        var addX = CGFloat(0)
        for element in elements {
          element.x += addX
          element.width += diffPerElement
          addX += diffPerElement
        }
        elements.last!.width += diff - addX  // compensate for rounding off
        break
      }
    }
  }

  override func drawIntoContext(context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 0)

    for element in elements {
      drawChildElement(element, context, diagramStyle, direction)
    }
  }
}

/*
 * A group of elements that you can choose from. Drawn as a column.
 */
public final class Parallel: Element {

  /* Determines which of the elements follows the "center line". */
  public var indexOfCenterElement = 0

  private(set) var elements: [Element]

  public override convenience init() {
    self.init(elements: [])
  }

  public init(elements: [Element]) {
    self.elements = elements
  }

  public func add(element: Element) {
    elements.append(element)
  }

  override func measure(diagramStyle: DiagramStyle) {
    if elements.count > 0 {
      for (index, element) in enumerate(elements) {
        element.measure(diagramStyle)
        width = max(width, element.width)
        height += element.height + diagramStyle.verticalSpacing
        if index < indexOfCenterElement {
          connectY = height
        }
      }

      width += diagramStyle.horizontalSpacing * 3
      height -= diagramStyle.verticalSpacing  // no space below last element

      connectY += elements[indexOfCenterElement].connectY
    }
  }

  override func layout(diagramStyle: DiagramStyle, direction: Direction) {
    var localY: CGFloat = 0
    for element in elements {
      element.x = floor(diagramStyle.horizontalSpacing * 1.5)
      element.y = localY
      element.width = width - diagramStyle.horizontalSpacing * 3
      element.layout(diagramStyle, direction: direction)
      localY += element.height + diagramStyle.verticalSpacing
    }
  }

  override func drawIntoContext(context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 1)

    let radius = diagramStyle.radius
    let margin = radius

    CGContextSaveGState(context)
    CGContextTranslateCTM(context, diagramStyle.oddLineAdjust, diagramStyle.oddLineAdjust)

    CGContextSetStrokeColorWithColor(context, diagramStyle.trackColor.CGColor)
    CGContextSetLineWidth(context, diagramStyle.trackLineWidth)

    // Draw the vertical track going up from the center line.
    if indexOfCenterElement > 0 {
      let lineY = elements.first!.y + elements.first!.connectY + radius

      CGContextMoveToPoint(context, margin, connectY)
      CGContextAddArc(context, margin, connectY - radius, radius, π/2, 0, 1)
      CGContextAddLineToPoint(context, radius + margin, lineY)
      CGContextStrokePath(context)

      CGContextMoveToPoint(context, width - margin, connectY)
      CGContextAddArc(context, width - margin, connectY - radius, radius, π/2, π, 0)
      CGContextAddLineToPoint(context, width - radius - margin, lineY)
      CGContextStrokePath(context)
    }

    // Draw the vertical track going down from the center line.
    if indexOfCenterElement < elements.count - 1 {
      let lineY = elements.last!.y + elements.last!.connectY - radius

      CGContextSetLineWidth(context, diagramStyle.trackLineWidth)

      CGContextMoveToPoint(context, margin, connectY)
      CGContextAddArc(context, margin, connectY + radius, radius, -π/2, 0, 0)
      CGContextAddLineToPoint(context, radius + margin, lineY)
      CGContextStrokePath(context)

      CGContextMoveToPoint(context, width - margin, connectY)
      CGContextAddArc(context, width - margin, connectY + radius, radius, -π/2, -π, 1)
      CGContextAddLineToPoint(context, width - radius - margin, lineY)
      CGContextStrokePath(context)
    }

    // Draw the curly bits connecting the child elements to the vertical tracks.
    for (index, element) in enumerate(elements) {
      let lineY = element.y + element.connectY

      if index < indexOfCenterElement {
        CGContextMoveToPoint(context, element.x, lineY)
        CGContextAddArc(context, element.x, lineY + radius, radius, -π/2, π, 1)
        CGContextStrokePath(context)

        CGContextMoveToPoint(context, element.x + element.width, lineY)
        CGContextAddArc(context, element.x + element.width, lineY + radius, radius, -π/2, 0, 0)
        CGContextStrokePath(context)

      } else if index > indexOfCenterElement {
        CGContextMoveToPoint(context, radius + margin, lineY - radius)
        CGContextAddArc(context, element.x, lineY - radius, radius, π, π/2, 1)
        CGContextStrokePath(context)

        CGContextMoveToPoint(context, element.x + element.width, lineY)
        CGContextAddArc(context, element.x + element.width, lineY - radius, radius, π/2, 0, 1)
        CGContextStrokePath(context)

      } else {
        CGContextMoveToPoint(context, 0, lineY)
        CGContextAddLineToPoint(context, element.x, lineY)
        CGContextStrokePath(context)

        CGContextMoveToPoint(context, element.x + element.width, lineY)
        CGContextAddLineToPoint(context, width, lineY)
        CGContextStrokePath(context)
      }
    }

    CGContextRestoreGState(context)

    // Draw the child elements last so they go on top of everything.
    for (index, element) in enumerate(elements) {
      drawChildElement(element, context, diagramStyle, direction)
    }
  }
}

/*
 * This is like a Parallel, except that it can have only two children, and the
 * bottom one loops back to the top one.
 */
public final class Loop: Element {
  private let forward: Element
  private let backward: Element

  public init(forward: Element, backward: Element) {
    self.forward = forward
    self.backward = backward
  }

  override func measure(diagramStyle: DiagramStyle) {
    forward.measure(diagramStyle)
    width = max(width, forward.width)
    height += forward.height + diagramStyle.verticalSpacing

    connectY = forward.connectY

    backward.measure(diagramStyle)
    width = max(width, backward.width)
    height += backward.height

    width += diagramStyle.horizontalSpacing * 2
  }

  override func layout(diagramStyle: DiagramStyle, direction: Direction) {
    forward.x = diagramStyle.horizontalSpacing
    forward.y = 0
    forward.width = width - diagramStyle.horizontalSpacing*2
    forward.layout(diagramStyle, direction: .Forward)

    backward.x = forward.x
    backward.y = forward.height + diagramStyle.verticalSpacing
    backward.width = forward.width
    backward.layout(diagramStyle, direction: .Backward)
  }

  override func drawIntoContext(context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 3)

    let radius = diagramStyle.radius
    let lineY1 = forward.y + forward.connectY
    let lineY2 = backward.y + backward.connectY

    drawHorizontalTrack(context, 0, forward.x, forward.y + forward.connectY, diagramStyle)
    drawHorizontalTrack(context, forward.x + forward.width, width, forward.y + forward.connectY, diagramStyle)

    CGContextSaveGState(context)
    CGContextTranslateCTM(context, diagramStyle.oddLineAdjust, diagramStyle.oddLineAdjust)

    CGContextSetStrokeColorWithColor(context, diagramStyle.trackColor.CGColor)
    CGContextSetLineWidth(context, diagramStyle.trackLineWidth)

    CGContextMoveToPoint(context, forward.x, lineY1)
    CGContextAddArc(context, forward.x, lineY1 + radius, radius, -π/2, -π, 1)
    CGContextAddArc(context, backward.x, lineY2 - radius, radius, π, π/2, 1)
    CGContextStrokePath(context)

    CGContextMoveToPoint(context, forward.x + forward.width, lineY1)
    CGContextAddArc(context, forward.x + forward.width, lineY1 + radius, radius, -π/2, 0, 0)
    CGContextAddArc(context, backward.x + backward.width, lineY2 - radius, radius, 0, π/2, 0)
    CGContextStrokePath(context)

    CGContextRestoreGState(context)

    drawChildElement(forward, context, diagramStyle, .Forward)
    drawChildElement(backward, context, diagramStyle, .Backward)
  }
}

/*
 * An empty track. It makes a group of elements optional and should only be
 * used inside a Parallel as the first or the last element, or inside a Loop.
 */
public final class Skip: Element {
  public override init() { }

  override func measure(diagramStyle: DiagramStyle) {
    height = diagramStyle.arrowHeads ? diagramStyle.arrowSize : diagramStyle.trackLineWidth
    connectY = floor(height / 2)
  }

  override func drawIntoContext(context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 4)

    let lineY = floor(height/2)
    drawHorizontalTrack(context, 0, width, lineY, diagramStyle)

    if diagramStyle.arrowHeads {
      drawArrowHead(context, floor(width/2), lineY, diagramStyle, direction)
    }
  }
}

/*
 * A decorative frame that gets drawn around an element.
 */
public final class Decoration: Element {
  private let element: Element
  private let text: String
  private let style: DecorationStyle

  private var textSize = CGSizeZero

  public init(element: Element, text: String = "", style: DecorationStyle = DecorationStyle()) {
    self.element = element
    self.text = text
    self.style = style
  }

  override func measure(diagramStyle: DiagramStyle) {
    if text == "" {
      textSize = CGSize.zeroSize
    } else {
      textSize = text.sizeWithAttributes(style.textStyle.attribs())
    }

    let textPadding = style.textStyle.padding
    width = ceil(textSize.width) + textPadding.left + textPadding.right
    height = ceil(textSize.height) + textPadding.top + textPadding.bottom

    element.measure(diagramStyle)
    width = max(element.width, width)
    height = max(element.height, height)

    width += style.margin.left + style.margin.right + style.padding.left + style.padding.right
    height += style.margin.top + style.margin.bottom + style.padding.top + style.padding.bottom

    connectY = element.connectY + style.margin.top + style.padding.top
  }

  override func layout(diagramStyle: DiagramStyle, direction: Direction) {
    element.x = style.margin.left + style.padding.left
    element.y = style.margin.top + style.padding.top
    element.layout(diagramStyle, direction: direction)
  }

  override func drawIntoContext(context: CGContextRef, diagramStyle: DiagramStyle, direction: Direction) {
    var rect = CGRectMake(style.margin.left, style.margin.top, width - style.margin.left - style.margin.right, height - style.margin.top - style.margin.bottom)

    fillRect(context, rect, style.backgroundColor)
    strokeRect(context, rect, style.borderSize, style.borderColor)

    drawChildElement(element, context, diagramStyle, direction)

    if text != "" {
      var textRect = CGRect(
        x: width - style.margin.right - style.textStyle.padding.right - ceil(textSize.width),
        y: height - style.margin.bottom - style.textStyle.padding.bottom - ceil(textSize.height),
        width: textSize.width,
        height: textSize.height)

      text.drawInRect(textRect, withAttributes: style.textStyle.attribs())
    }

    let lineY = element.y + element.connectY
    drawHorizontalTrack(context, 0, element.x, lineY, diagramStyle)
    drawHorizontalTrack(context, element.x + element.width, width, lineY, diagramStyle)
  }
}

/*
 * The top-level class. You create a Diagram object and then tell it to draw
 * an element, usually a Series or Parallel containing other elements.
 */
public final class Diagram {
  let style: DiagramStyle

  public init(style: DiagramStyle = DiagramStyle()) {
    self.style = style
  }
}

/*
 * Rendering to an UIImage or NSImage.
 */
extension Diagram {
  public func renderImage(element: Element, scale: CGFloat) -> Image {
    let capSize = style.arrowSize

    element.measure(style)
    element.x = style.margin.left + capSize + style.horizontalSpacing
    element.y = style.margin.top
    element.layout(style, direction: .Forward)

    var width = element.width + capSize*2 + style.horizontalSpacing*2 + style.margin.left + style.margin.right
    var height = element.height + style.margin.top + style.margin.bottom
    assert(width > 0)
    assert(height > 0)

    let context = createContextWithWidth(width, height: height, scale: scale)

    setUpNSStringDrawingContext(context)
    CGContextSetLineCap(context, kCGLineCapSquare)

    drawChildElement(element, context, style, .Forward)

    let lineY = element.y + element.connectY
    let capY = lineY - ceil(capSize / 2)
    let capX1 = element.x - capSize - style.horizontalSpacing
    let capX2 = element.x + element.width + style.horizontalSpacing

    drawHorizontalTrack(context, capX1 + capSize, element.x, lineY, style)
    drawHorizontalTrack(context, element.x + element.width, capX2, lineY, style)

    CGContextSetFillColorWithColor(context, style.trackColor.CGColor)
    CGContextSetStrokeColorWithColor(context, style.trackColor.CGColor)
    CGContextSetLineWidth(context, style.trackLineWidth)

    switch style.capStyle {
    case .FilledCircle:
      CGContextFillEllipseInRect(context, CGRectMake(capX1, capY, capSize, capSize))
      CGContextFillEllipseInRect(context, CGRectMake(capX2, capY, capSize, capSize))

    case .StrokedCircle:
      CGContextStrokeEllipseInRect(context, CGRectMake(capX1, capY, capSize, capSize))
      CGContextStrokeEllipseInRect(context, CGRectMake(capX2, capY, capSize, capSize))

    case .VerticalBars:
      CGContextMoveToPoint(context, capX1, lineY - capSize)
      CGContextAddLineToPoint(context, capX1, lineY + capSize)
      CGContextStrokePath(context)

      CGContextMoveToPoint(context, capX1 + capSize, lineY - capSize)
      CGContextAddLineToPoint(context, capX1 + capSize, lineY + capSize)
      CGContextStrokePath(context)

      CGContextMoveToPoint(context, capX2, lineY - capSize)
      CGContextAddLineToPoint(context, capX2, lineY + capSize)
      CGContextStrokePath(context)

      CGContextMoveToPoint(context, capX2 + capSize, lineY - capSize)
      CGContextAddLineToPoint(context, capX2 + capSize, lineY + capSize)
      CGContextStrokePath(context)
    }

    tearDownNSStringDrawingContext()

    return imageFromContext(context, scale: scale)
  }

  private func createContextWithWidth(width: CGFloat, height: CGFloat, scale: CGFloat) -> CGContextRef {
    let contextWidth = Int(width * scale)
    let contextHeight = Int(height * scale)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
    let context = CGBitmapContextCreate(nil, contextWidth, contextHeight, 8, 0, colorSpace, bitmapInfo)

    // Scale the context and flip it vertically so (0,0) is at top-left.
    CGContextScaleCTM(context, CGFloat(scale), CGFloat(-scale))
    CGContextTranslateCTM(context, 0, CGFloat(-height))

    CGContextSetFillColorWithColor(context, style.backgroundColor.CGColor)
    CGContextFillRect(context, CGRectMake(0, 0, width, height))

    return context
  }

  private func imageFromContext(context: CGContextRef, scale: CGFloat) -> Image {
    let cgImage = CGBitmapContextCreateImage(context)
    #if os(iOS)
    return UIImage(CGImage: cgImage, scale: scale, orientation: .Up)!
    #else
    return NSImage(CGImage: cgImage, size: NSZeroSize)
    #endif
  }
}

/*
 * This is a convenience class for making Box instances that all use the
 * same style.
 */
public final class BoxFactory {
  let defaultBoxStyle: BoxStyle

  public init(style: BoxStyle) {
    self.defaultBoxStyle = style
  }

  public func createBox(text: String) -> Box {
    return Box(text: text, style: defaultBoxStyle)
  }
}

// MARK: - Declarative API

/* This DSL is based on https://github.com/tabatkins/railroad-diagrams */

private let terminalStyle: BoxStyle = {
  var style = BoxStyle()
  style.shape = .RoundedSides
  return style
}()

/* A box with rounded sides. */
public func terminal(text: String) -> Element {
  return Box(text: text, style: terminalStyle)
}

private let nonTerminalStyle: BoxStyle = {
  var style = BoxStyle()
  style.shape = .Rectangle
  return style
}()

/* A box with straight sides. */
public func nonTerminal(text: String) -> Element {
  return Box(text: text, style: nonTerminalStyle)
}

private let commentStyle: BoxStyle = {
  var style = BoxStyle()
  style.shape = .None

  #if os(iOS)
  style.textStyle.font = UIFont.italicSystemFontOfSize(18)
  #else
  let systemFont = NSFont.systemFontOfSize(18)
  style.textStyle.font = NSFontManager.sharedFontManager().convertFont(systemFont, toHaveTrait: .ItalicFontMask)
  #endif

  return style
}()

/* Text with no box around it; you use this inside repeats. */
public func comment(text: String) -> Element {
  return Box(text: text, style: commentStyle)
}

/* Concatenation of two or more elements. */
public func sequence(elements: Element...) -> Element {
  return Series(elements: elements)
}

/*
 * ? in the regex
 *
 * The drawSkipBelow parameter determines whether the skip line is drawn above
 * or below the element; the element itself is always in the center line.
 */
public func optional(element: Element, _ drawSkipBelow: Bool = true) -> Element {
  let p = Parallel()
  if drawSkipBelow {
    p.add(element)
    p.add(Skip())
  } else {
    p.add(Skip())
    p.add(element)
    p.indexOfCenterElement = 1
  }
  return p
}

/* | in the regex */
public func choice(elements: Element...) -> Element {
  return Parallel(elements: elements)
}

/*
 * | in the regex
 *
 * The centerIndex parameter determines which element is drawn on the center
 * line.
 */
public func choice(centerIndex: Int, elements: Element...) -> Element {
  let p = Parallel(elements: elements)
  p.indexOfCenterElement = centerIndex
  return p
}

/* + in the regex */
public func oneOrMore(element: Element, _ repeat: Element = Skip()) -> Element {
  return Loop(forward: element, backward: repeat)
}

/* * in the regex */
public func zeroOrMore(element: Element, _ repeat: Element = Skip(), _ drawSkipBelow: Bool = true) -> Element {
  return optional(oneOrMore(element, repeat), drawSkipBelow)
}

/* A capture group in the regex. */
public func capture(element: Element, text: String) -> Element {
  return Decoration(element: element, text: text)
}

/* Draws a railroad diagram as a UIImage. */
public func diagram(elements: Element...) -> Image {
  var diagramStyle = DiagramStyle()
  diagramStyle.backgroundColor = Color.clearColor()
  diagramStyle.margin = EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

  let diagram = Diagram(style: diagramStyle)
  let series = Series(elements: elements)
  return diagram.renderImage(series, scale: 1)
}

/* Alternative DSL from: https://code.google.com/p/html-railroad-diagram/ */

/* each(a, b, c)  produces (A -> B -> C) */
public func each(elements: Element...) -> Element {
  return Series(elements: elements)
}

/* Like | in EBNF (choose 1 of) */
public func or(elements: Element...) -> Element {
  return Parallel(elements: elements)
}

/* Like ? in EBNF (0 or 1 occurences) */
public func maybe(element: Element) -> Element {
  return optional(element)
}

/* Like + in EBNF (1 or more repetitions) */
public func many(element: Element, _ repeat: Element = Skip()) -> Element {
  return Loop(forward: element, backward: repeat)
}

/* Like * in EBNF (0 or more repetitions) */
public func any(element: Element, _ repeat: Element = Skip()) -> Element {
  return maybe(many(element, repeat))
}
