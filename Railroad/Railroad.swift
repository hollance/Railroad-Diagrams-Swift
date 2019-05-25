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
  Color.blue,
  Color.red,
  Color.yellow,
  Color.green,
  Color.purple
]

private func debugRect(_ context: CGContext, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ type: Int) {
  if debugDraw {
    context.saveGState()
    context.setLineWidth(1)
    context.setStrokeColor(debugColors[type].cgColor)
    context.stroke(CGRect(x: x + 0.5, y: y + 0.5, width: width - 1, height: height - 1))
    context.restoreGState()
  }
}

/* Helper code for doing trig. */

private let π = CGFloat.pi

private func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
  return π * degrees / 180.0
}

private func radiansToDegrees(_ radians: CGFloat) -> CGFloat {
  return radians * 180.0 / π
}

// MARK: Styling of the elements

public enum BoxShape {
  case none                                  // useful for comments
  case rectangle
  case roundedSides
  case roundedCorners(cornerRadius: CGFloat)
  case pointySides(angle: CGFloat)           // larger angle = more pointy
}

public struct TextStyle {
  public var font = Font.systemFont(ofSize: 18)
  public var color = Color.black
  public var padding = EdgeInsets(top: 6, left: 18, bottom: 6, right: 18)

  public init() { }
}

public struct BoxStyle {
  public var shape = BoxShape.rectangle
  public var borderSize: CGFloat = 1
  public var borderColor = Color.black
  public var backgroundColor = Color.white
  public var textStyle = TextStyle()

  public init() { }
}

public struct DecorationStyle {
  public var margin = EdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
  public var padding = EdgeInsets(top: 18, left: 12, bottom: 30, right: 12)
  public var borderSize: CGFloat = 3
  public var borderColor = Color(white: 0, alpha: 0.35)
  public var backgroundColor = Color.clear

  public var textStyle: TextStyle = {
    var style = TextStyle()
    style.font = Font.boldSystemFont(ofSize: 12)
    style.color = Color(white: 0, alpha: 0.35)
    style.padding = EdgeInsets(top: 0, left: 0, bottom: 6, right: 9)
    return style
  }()

  public init() { }
}

public enum Alignment {
  case left
  case center
  case right
  case fill
}

public enum CapStyle {
  case filledCircle
  case strokedCircle
  case verticalBars
}

public struct DiagramStyle {
  public var margin = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  public var backgroundColor = Color.white
  public var capStyle = CapStyle.filledCircle

  public var trackColor = Color.black
  public var trackLineWidth: CGFloat = 2

  /* Tip: The arrow size should be odd/even if trackLineWidth is odd/even. */
  public var arrowHeads = true
  public var arrowSize: CGFloat = 10

  /* The length of the line segments before and after boxes. */
  public var horizontalSpacing: CGFloat = 24

  /* How far apart the boxes are in vertical groups. */
  public var verticalSpacing: CGFloat = 24

  /* What happens to the elements in a Parallel grouping. */
  public var forwardAlignment = Alignment.left

  /* What happens to the elements in a Loop grouping. */
  public var backwardAlignment = Alignment.center

  public init() { }
}

// MARK: - Styling helper methods

extension BoxShape {
  private func pathForRectangle(rect: CGRect) -> CGPath {
    let path = CGMutablePath()
    path.addRect(rect)
    return path
  }

  private func pathForRoundedCorners(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
    let x1 = rect.origin.x
    let y1 = rect.origin.y
    let x2 = x1 + rect.size.width
    let y2 = y1 + rect.size.height

    let path = CGMutablePath()
    path.move(to: CGPoint(x: x1, y: y2 - cornerRadius))
    path.addArc(tangent1End: CGPoint(x: x1, y: y1), tangent2End: CGPoint(x: x2, y: y1), radius: cornerRadius)
    path.addArc(tangent1End: CGPoint(x: x2, y: y1), tangent2End: CGPoint(x: x2, y: y2), radius: cornerRadius)
    path.addArc(tangent1End: CGPoint(x: x2, y: y2), tangent2End: CGPoint(x: x1, y: y2), radius: cornerRadius)
    path.addArc(tangent1End: CGPoint(x: x1, y: y2), tangent2End: CGPoint(x: x1, y: y1), radius: cornerRadius)
    path.closeSubpath()
    return path
  }

  private func pathForRoundedSides(rect: CGRect) -> CGPath {
    let radius = rect.size.height/2
    let x1 = rect.origin.x + radius
    let y1 = rect.origin.y
    let x2 = rect.origin.x + rect.size.width - radius
    let y2 = rect.midY

    let path = CGMutablePath()
    path.move(to: CGPoint(x: x1, y: y1))
    path.addArc(center: CGPoint(x: x2, y: y2), radius: radius, startAngle: -π/2, endAngle: π/2, clockwise: false)
    path.addArc(center: CGPoint(x: x1, y: y2), radius: radius, startAngle: π/2, endAngle: -π/2, clockwise: false)
    path.closeSubpath()
    return path
  }

  private func pathForPointySides(rect: CGRect, angle: CGFloat) -> CGPath {
    let inset = sin(degreesToRadians(angle)) * rect.size.height/2

    let x1 = rect.origin.x
    let x2 = x1 + inset
    let x4 = x1 + rect.size.width
    let x3 = x4 - inset

    let y1 = rect.origin.y
    let y2 = rect.midY
    let y3 = y1 + rect.size.height

    let path = CGMutablePath()
    path.move(to: CGPoint(x: x2, y: y1))
    path.addLine(to: CGPoint(x: x3, y: y1))
    path.addLine(to: CGPoint(x: x4, y: y2))
    path.addLine(to: CGPoint(x: x3, y: y3))
    path.addLine(to: CGPoint(x: x2, y: y3))
    path.addLine(to: CGPoint(x: x1, y: y2))
    path.addLine(to: CGPoint(x: x2, y: y1))
    path.closeSubpath()
    return path
  }

  func pathForRect(rect: CGRect) -> CGPath {
    switch self {
    case .none:
      fatalError("BoxShape.None has no path")

    case .rectangle:
      return pathForRectangle(rect: rect)

    case .roundedSides:
      return pathForRoundedSides(rect: rect)

    case .roundedCorners(let cornerRadius):
      return pathForRoundedCorners(rect: rect, cornerRadius: cornerRadius)

    case .pointySides(let angle):
      return pathForPointySides(rect: rect, angle: angle)
    }
  }

  func hasPath() -> Bool {
    switch self {
    case .none:
      return false
    default:
      return true
    }
  }
}

extension TextStyle {
  func attribs() -> [NSAttributedString.Key: AnyObject] {
    let paragraphStyle = NSMutableParagraphStyle()      // for multiline text
    paragraphStyle.alignment = NSTextAlignment.center

    return [ NSAttributedString.Key.font: font,
             NSAttributedString.Key.foregroundColor: color,
             NSAttributedString.Key.paragraphStyle: paragraphStyle ]
  }
}

extension DiagramStyle {
  func alignmentForDirection(direction: Direction) -> Alignment {
    if direction == .forward {
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
    return Int(ceil(trackLineWidth)) % 2 == 0 ? 0 : -0.5
  }

  /* For drawing curves in a Parallel and Loop. */
  var radius: CGFloat {
    return floor(horizontalSpacing / 2)
  }

  func pathForArrowHead() -> CGPath {
    let x1 = CGFloat(0)
    let x2 = self.arrowSize

    let y1 = -self.arrowSize / 2
    let y2 = CGFloat(0)
    let y3 = self.arrowSize / 2

    let path = CGMutablePath()
    path.move(to: CGPoint(x: x1, y: y1))
    path.addLine(to: CGPoint(x: x2, y: y2))
    path.addLine(to: CGPoint(x: x1, y: y3))
    path.addLine(to: CGPoint(x: x1, y: y1))
    path.closeSubpath()
    return path
  }
}

// MARK: - Drawing helper functions

/* This allows us to use NSString drawing in our own CGContextRef. */
func setUpNSStringDrawingContext(context: CGContext) {
  #if os(iOS)
    UIGraphicsPushContext(context)
  #else
    NSGraphicsContext.saveGraphicsState()
  let nscg = NSGraphicsContext(cgContext: context, flipped: true)
  NSGraphicsContext.current = nscg
  #endif
}

func tearDownNSStringDrawingContext() {
  #if os(iOS)
    UIGraphicsPopContext()
  #else
    NSGraphicsContext.restoreGraphicsState()
  #endif
}

func fillRect(_ context: CGContext, _ rect: CGRect, _ color: Color) {
  context.setFillColor(color.cgColor)
  context.fill(rect)
}

func strokeRect(_ context: CGContext, _ rect: CGRect, _ borderSize: CGFloat, _ color: Color) {
  context.setLineWidth(borderSize)
  context.setStrokeColor(color.cgColor)
  context.stroke(rect.insetBy(dx: borderSize / 2, dy: borderSize / 2))
}

func drawChildElement(_ element: Element, _ context: CGContext, _ diagramStyle: DiagramStyle, _ direction: Direction) {
  context.saveGState()
  context.translateBy(x: element.x, y: element.y)
  element.drawIntoContext(context: context, diagramStyle: diagramStyle, direction: direction)
  context.restoreGState()
}

func drawHorizontalTrack(_ context: CGContext, _ startX: CGFloat, _ endX: CGFloat, _ y: CGFloat, _ diagramStyle: DiagramStyle) {
  let half = ceil(diagramStyle.trackLineWidth / 2)
  let rect = CGRect(x: startX, y: y - half, width: endX - startX, height: diagramStyle.trackLineWidth)
  context.setFillColor(diagramStyle.trackColor.cgColor)
  context.fill(rect)
}

func drawArrowHead(_ context: CGContext, _ x: CGFloat, _ y: CGFloat, _ diagramStyle: DiagramStyle, _ direction: Direction) {
  let arrowHead = diagramStyle.pathForArrowHead()
  context.saveGState()
  context.setFillColor(diagramStyle.trackColor.cgColor)
  context.translateBy(x: x, y: y + diagramStyle.oddLineAdjust)
  if direction == .backward {
    context.translateBy(x: diagramStyle.arrowSize, y: 0)
    context.scaleBy(x: -1, y: 1)
  }
  context.addPath(arrowHead)
  context.fillPath()
  context.restoreGState()
}

// MARK: - Elements

enum Direction {
  case forward
  case backward
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
  func drawIntoContext(context: CGContext, diagramStyle: DiagramStyle, direction: Direction) {
    // subclass should override
  }
}

/*
 * A box with text. These are the main building blocks of railroad diagrams.
 */
public final class Box: Element {
  private let text: String
  private let style: BoxStyle

  private var textSize = CGSize.zero
  private var boxWidth: CGFloat = 0

  public init(text: String, style: BoxStyle = BoxStyle()) {
    self.text = text
    self.style = style
  }

  override func measure(diagramStyle: DiagramStyle) {
    let textPadding = style.textStyle.padding
    textSize = text.size(withAttributes: style.textStyle.attribs())
    boxWidth = ceil(textSize.width) + textPadding.left + textPadding.right
    height = ceil(textSize.height) + textPadding.top + textPadding.bottom

    switch style.shape {
    case .roundedSides:
      boxWidth = max(boxWidth, height)
    default:
      break
    }

    width = boxWidth + diagramStyle.lefthandTrackLength + diagramStyle.righthandTrackLength
    connectY = floor(height / 2)
  }

  override func drawIntoContext(context: CGContext, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 2)

    // Adjust position or width based on the alignment settings.
    var boxX = diagramStyle.lefthandTrackLength
    switch diagramStyle.alignmentForDirection(direction: direction) {
    case .left:
      break
    case .center:
      boxX += floor((width - diagramStyle.lefthandTrackLength - diagramStyle.righthandTrackLength - boxWidth)/2)
    case .right:
      boxX = width - boxWidth - diagramStyle.righthandTrackLength
    case .fill:
      boxWidth = width - diagramStyle.lefthandTrackLength - diagramStyle.righthandTrackLength
    }

    // For boxes with pointy sides we want to draw the track going partially
    // under the box, which looks better (but only if not drawing arrowheads).
    var under = CGFloat(0)
    switch style.shape {
    case .pointySides:
      under = boxWidth/2
    default:
      break
    }

    // Draw the incoming track.
    var lineX = boxX
    if diagramStyle.arrowHeads && direction == .forward {
      lineX -= diagramStyle.arrowSize
    } else {
      lineX += under
    }

    drawHorizontalTrack(context, 0, lineX, connectY, diagramStyle)

    // Draw the outgoing track.
    lineX = boxX + boxWidth
    if diagramStyle.arrowHeads && direction == .backward {
      lineX += diagramStyle.arrowSize
    } else {
      lineX -= under
    }

    drawHorizontalTrack(context, lineX, width, connectY, diagramStyle)

    // Draw the arrow head.
    if diagramStyle.arrowHeads {
      let arrowX = (direction == .backward) ? boxX + boxWidth : boxX - diagramStyle.arrowSize
      drawArrowHead(context, arrowX, connectY, diagramStyle, direction)
    }

    // Draw the box shape.
    if style.shape.hasPath() {
      context.setFillColor(style.backgroundColor.cgColor)
      context.setStrokeColor(style.borderColor.cgColor)

      let halfBorder = style.borderSize / 2
      let boxRect = CGRect(x: boxX + halfBorder, y: halfBorder, width: boxWidth - style.borderSize, height: height - style.borderSize)
      context.setLineWidth(style.borderSize)

      let path = style.shape.pathForRect(rect: boxRect)
      context.addPath(path)
      context.drawPath(using: .fillStroke)
    }

    // Draw the text.
    let textRect = CGRect(
      x: boxX + floor((boxWidth - textSize.width) / 2),
      y: floor((height - textSize.height) / 2),
      width: textSize.width,
      height: textSize.height)

    debugRect(context, textRect.origin.x, textRect.origin.y, textRect.size.width, textRect.size.height, 4)

    text.draw(in: textRect, withAttributes: style.textStyle.attribs())
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

  public func add(_ element: Element) {
    elements.append(element)
  }

  override func measure(diagramStyle: DiagramStyle) {
    for element in elements {
      element.measure(diagramStyle: diagramStyle)
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
      element.layout(diagramStyle: diagramStyle, direction: direction)
      localX += element.width
    }

    // If this series is inside a parallel and there is still room left over,
    // then we have to distribute that difference amongst the child elements,
    // according to the alignment rules.
    let diff = width - localX
    if diff > 0 {
      switch diagramStyle.alignmentForDirection(direction: direction) {
      case .left:
        elements.last!.width += diff
      case .right:
        elements.first!.width += diff
        for element in elements.dropFirst() {
          element.x += diff
        }
      case .center, .fill:
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

  override func drawIntoContext(context: CGContext, diagramStyle: DiagramStyle, direction: Direction) {
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

  public func add(_ element: Element) {
    elements.append(element)
  }

  override func measure(diagramStyle: DiagramStyle) {
    if elements.count > 0 {
      for (index, element) in elements.enumerated() {
        element.measure(diagramStyle: diagramStyle)
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
      element.layout(diagramStyle: diagramStyle, direction: direction)
      localY += element.height + diagramStyle.verticalSpacing
    }
  }

  override func drawIntoContext(context: CGContext, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 1)

    let radius = diagramStyle.radius
    let margin = radius

    context.saveGState()
    context.translateBy(x: diagramStyle.oddLineAdjust, y: diagramStyle.oddLineAdjust)

    context.setStrokeColor(diagramStyle.trackColor.cgColor)
    context.setLineWidth(diagramStyle.trackLineWidth)

    // Draw the vertical track going up from the center line.
    if indexOfCenterElement > 0 {
      let lineY = elements.first!.y + elements.first!.connectY + radius

      context.move(to: CGPoint(x: margin, y: connectY))
      context.addArc(center: CGPoint(x: margin, y: connectY - radius), radius: radius, startAngle: π/2, endAngle: 0, clockwise: true)
      context.addLine(to: CGPoint(x: radius + margin, y: lineY))
      context.strokePath()

      context.move(to: CGPoint(x: width - margin, y: connectY))
      context.addArc(center: CGPoint(x: width - margin, y: connectY - radius), radius: radius, startAngle: π/2, endAngle: π, clockwise: false)
      context.addLine(to: CGPoint(x: width - radius - margin, y: lineY))
      context.strokePath()
    }

    // Draw the vertical track going down from the center line.
    if indexOfCenterElement < elements.count - 1 {
      let lineY = elements.last!.y + elements.last!.connectY - radius

      context.setLineWidth(diagramStyle.trackLineWidth)

      context.move(to: CGPoint(x: margin, y: connectY))
      context.addArc(center: CGPoint(x: margin, y: connectY + radius), radius: radius, startAngle: -π/2, endAngle: 0, clockwise: false)
      context.addLine(to: CGPoint(x: radius + margin, y: lineY))
      context.strokePath()

      context.move(to: CGPoint(x: width - margin, y: connectY))
      context.addArc(center: CGPoint(x: width - margin, y: connectY + radius), radius: radius, startAngle: -π/2, endAngle: -π, clockwise: true)
      context.addLine(to: CGPoint(x: width - radius - margin, y: lineY))
      context.strokePath()
    }

    // Draw the curly bits connecting the child elements to the vertical tracks.
    for (index, element) in elements.enumerated() {
      let lineY = element.y + element.connectY

      if index < indexOfCenterElement {
        context.move(to: CGPoint(x: element.x, y: lineY))
        context.addArc(center: CGPoint(x: element.x, y: lineY + radius), radius: radius, startAngle: -π/2, endAngle: π, clockwise: true)
        context.strokePath()

        context.move(to: CGPoint(x: element.x + element.width, y: lineY))
        context.addArc(center: CGPoint(x: element.x + element.width, y: lineY + radius), radius: radius, startAngle: -π/2, endAngle: 0, clockwise: false)
        context.strokePath()

      } else if index > indexOfCenterElement {
        context.move(to: CGPoint(x: radius + margin, y: lineY - radius))
        context.addArc(center: CGPoint(x: element.x, y: lineY - radius), radius: radius, startAngle: π, endAngle: π/2, clockwise: true)
        context.strokePath()

        context.move(to: CGPoint(x: element.x + element.width, y: lineY))
        context.addArc(center: CGPoint(x: element.x + element.width, y: lineY - radius), radius: radius, startAngle: π/2, endAngle: 0, clockwise: true)
        context.strokePath()

      } else {
        context.move(to: CGPoint(x: 0, y: lineY))
        context.addLine(to: CGPoint(x: element.x, y: lineY))
        context.strokePath()

        context.move(to: CGPoint(x: element.x + element.width, y: lineY))
        context.addLine(to: CGPoint(x: width, y: lineY))
        context.strokePath()
      }
    }

    context.restoreGState()

    // Draw the child elements last so they go on top of everything.
    for element in elements {
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
    forward.measure(diagramStyle: diagramStyle)
    width = max(width, forward.width)
    height += forward.height + diagramStyle.verticalSpacing

    connectY = forward.connectY

    backward.measure(diagramStyle: diagramStyle)
    width = max(width, backward.width)
    height += backward.height

    width += diagramStyle.horizontalSpacing * 2
  }

  override func layout(diagramStyle: DiagramStyle, direction: Direction) {
    forward.x = diagramStyle.horizontalSpacing
    forward.y = 0
    forward.width = width - diagramStyle.horizontalSpacing*2
    forward.layout(diagramStyle: diagramStyle, direction: .forward)

    backward.x = forward.x
    backward.y = forward.height + diagramStyle.verticalSpacing
    backward.width = forward.width
    backward.layout(diagramStyle: diagramStyle, direction: .backward)
  }

  override func drawIntoContext(context: CGContext, diagramStyle: DiagramStyle, direction: Direction) {
    debugRect(context, 0, 0, width, height, 3)

    let radius = diagramStyle.radius
    let lineY1 = forward.y + forward.connectY
    let lineY2 = backward.y + backward.connectY

    drawHorizontalTrack(context, 0, forward.x, forward.y + forward.connectY, diagramStyle)
    drawHorizontalTrack(context, forward.x + forward.width, width, forward.y + forward.connectY, diagramStyle)

    context.saveGState()
    context.translateBy(x: diagramStyle.oddLineAdjust, y: diagramStyle.oddLineAdjust)

    context.setStrokeColor(diagramStyle.trackColor.cgColor)
    context.setLineWidth(diagramStyle.trackLineWidth)

    context.move(to: CGPoint(x: forward.x, y: lineY1))
    context.addArc(center: CGPoint(x: forward.x, y: lineY1 + radius), radius: radius, startAngle: -π/2, endAngle: -π, clockwise: true)
    context.addArc(center: CGPoint(x: backward.x, y: lineY2 - radius), radius: radius, startAngle: π, endAngle: π/2, clockwise: true)
    context.strokePath()

    context.move(to: CGPoint(x: forward.x + forward.width, y: lineY1))
    context.addArc(center: CGPoint(x: forward.x + forward.width, y: lineY1 + radius), radius: radius, startAngle: -π/2, endAngle: 0, clockwise: false)
    context.addArc(center: CGPoint(x: backward.x + backward.width, y: lineY2 - radius), radius: radius, startAngle: 0, endAngle: π/2, clockwise: false)
    context.strokePath()

    context.restoreGState()

    drawChildElement(forward, context, diagramStyle, .forward)
    drawChildElement(backward, context, diagramStyle, .backward)
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

  override func drawIntoContext(context: CGContext, diagramStyle: DiagramStyle, direction: Direction) {
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

  private var textSize = CGSize.zero

  public init(element: Element, text: String = "", style: DecorationStyle = DecorationStyle()) {
    self.element = element
    self.text = text
    self.style = style
  }

  override func measure(diagramStyle: DiagramStyle) {
    if text == "" {
      textSize = CGSize.zero
    } else {
      textSize = text.size(withAttributes: style.textStyle.attribs())
    }

    let textPadding = style.textStyle.padding
    width = ceil(textSize.width) + textPadding.left + textPadding.right
    height = ceil(textSize.height) + textPadding.top + textPadding.bottom

    element.measure(diagramStyle: diagramStyle)
    width = max(element.width, width)
    height = max(element.height, height)

    width += style.margin.left + style.margin.right + style.padding.left + style.padding.right
    height += style.margin.top + style.margin.bottom + style.padding.top + style.padding.bottom

    connectY = element.connectY + style.margin.top + style.padding.top
  }

  override func layout(diagramStyle: DiagramStyle, direction: Direction) {
    element.x = style.margin.left + style.padding.left
    element.y = style.margin.top + style.padding.top
    element.layout(diagramStyle: diagramStyle, direction: direction)
  }

  override func drawIntoContext(context: CGContext, diagramStyle: DiagramStyle, direction: Direction) {
    let rect = CGRect(x: style.margin.left, y: style.margin.top, width: width - style.margin.left - style.margin.right, height: height - style.margin.top - style.margin.bottom)

    fillRect(context, rect, style.backgroundColor)
    strokeRect(context, rect, style.borderSize, style.borderColor)

    drawChildElement(element, context, diagramStyle, direction)

    if text != "" {
      let textRect = CGRect(
        x: width - style.margin.right - style.textStyle.padding.right - ceil(textSize.width),
        y: height - style.margin.bottom - style.textStyle.padding.bottom - ceil(textSize.height),
        width: textSize.width,
        height: textSize.height)

      text.draw(in: textRect, withAttributes: style.textStyle.attribs())
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

    element.measure(diagramStyle: style)
    element.x = style.margin.left + capSize + style.horizontalSpacing
    element.y = style.margin.top
    element.layout(diagramStyle: style, direction: .forward)

    let width = element.width + capSize*2 + style.horizontalSpacing*2 + style.margin.left + style.margin.right
    let height = element.height + style.margin.top + style.margin.bottom
    assert(width > 0)
    assert(height > 0)

    let context = createContextWithWidth(width: width, height: height, scale: scale)

    setUpNSStringDrawingContext(context: context)
    context.setLineCap(CGLineCap.square)

    drawChildElement(element, context, style, .forward)

    let lineY = element.y + element.connectY
    let capY = lineY - ceil(capSize / 2)
    let capX1 = element.x - capSize - style.horizontalSpacing
    let capX2 = element.x + element.width + style.horizontalSpacing

    drawHorizontalTrack(context, capX1 + capSize, element.x, lineY, style)
    drawHorizontalTrack(context, element.x + element.width, capX2, lineY, style)

    context.setFillColor(style.trackColor.cgColor)
    context.setStrokeColor(style.trackColor.cgColor)
    context.setLineWidth(style.trackLineWidth)

    switch style.capStyle {
    case .filledCircle:
      context.fillEllipse(in: CGRect(x: capX1, y: capY, width: capSize, height: capSize))
      context.fillEllipse(in: CGRect(x: capX2, y: capY, width: capSize, height: capSize))

    case .strokedCircle:
      context.strokeEllipse(in: CGRect(x: capX1, y: capY, width: capSize, height: capSize))
      context.strokeEllipse(in: CGRect(x: capX2, y: capY, width: capSize, height: capSize))

    case .verticalBars:
      context.move(to: CGPoint(x: capX1, y: lineY - capSize))
      context.addLine(to: CGPoint(x: capX1, y: lineY + capSize))
      context.strokePath()

      context.move(to: CGPoint(x: capX1 + capSize, y: lineY - capSize))
      context.addLine(to: CGPoint(x: capX1 + capSize, y: lineY + capSize))
      context.strokePath()

      context.move(to: CGPoint(x: capX2, y: lineY - capSize))
      context.addLine(to: CGPoint(x: capX2, y: lineY + capSize))
      context.strokePath()

      context.move(to: CGPoint(x: capX2 + capSize, y: lineY - capSize))
      context.addLine(to: CGPoint(x: capX2 + capSize, y: lineY + capSize))
      context.strokePath()
    }

    tearDownNSStringDrawingContext()

    return imageFromContext(context: context, scale: scale)
  }

  private func createContextWithWidth(width: CGFloat, height: CGFloat, scale: CGFloat) -> CGContext {
    let contextWidth = Int(width * scale)
    let contextHeight = Int(height * scale)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    let context = CGContext(data: nil, width: contextWidth, height: contextHeight, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!

    // Scale the context and flip it vertically so (0,0) is at top-left.
    context.scaleBy(x: CGFloat(scale), y: CGFloat(-scale))
    context.translateBy(x: 0, y: CGFloat(-height))

    context.setFillColor(style.backgroundColor.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))

    return context
  }

  private func imageFromContext(context: CGContext, scale: CGFloat) -> Image {
    let cgImage = context.makeImage()!
    #if os(iOS)
    return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    #else
    return NSImage(cgImage: cgImage, size: NSZeroSize)
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

  public func createBox(_ text: String) -> Box {
    return Box(text: text, style: defaultBoxStyle)
  }
}

// MARK: - Declarative API

/* This DSL is based on https://github.com/tabatkins/railroad-diagrams */

private let textStyle: TextStyle = {
  var textStyle = TextStyle()
  textStyle.font = Font.systemFont(ofSize: 14)
  textStyle.padding = EdgeInsets(top: 4, left: 6, bottom: 6, right: 4)
  return textStyle
}()

private let terminalStyle: BoxStyle = {
  var style = BoxStyle()
  style.shape = .roundedSides
  style.textStyle = textStyle
  return style
}()

private let nonTerminalStyle: BoxStyle = {
  var style = BoxStyle()
  style.shape = .rectangle
  style.textStyle = textStyle
  return style
}()

private let commentStyle: BoxStyle = {
  var style = BoxStyle()
  style.shape = .none

  #if os(iOS)
  style.textStyle.font = UIFont.italicSystemFont(ofSize: 12)
  #else
  let systemFont = NSFont.systemFont(ofSize: 12)
  style.textStyle.font = NSFontManager.shared.convert(systemFont, toHaveTrait: .italicFontMask)
  #endif

  return style
}()

private let specialStyle: BoxStyle = {
  var style = BoxStyle()
  style.shape = .pointySides(angle: 30)
  style.textStyle = textStyle
  style.textStyle.padding.left = 10
  style.textStyle.padding.right = 10
  return style
}()

private let captureStyle: DecorationStyle = {
  var style = DecorationStyle()
  style.margin = EdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
  style.padding = EdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
  style.textStyle.font = Font.boldSystemFont(ofSize: 10)
  style.textStyle.padding = EdgeInsets(top: 0, left: 0, bottom: 3, right: 5)
  return style
}()

/* A box with rounded sides. */
public func terminal(_ text: String) -> Element {
  return Box(text: text, style: terminalStyle)
}

/* A box with straight sides. */
public func nonTerminal(_ text: String) -> Element {
  return Box(text: text, style: nonTerminalStyle)
}

/* Text with no box around it; you use this inside repeats. */
public func comment(_ text: String) -> Element {
  return Box(text: text, style: commentStyle)
}

/* For things like \s, \w, and so on. */
public func characterClass(_ text: String) -> Element {
  return nonTerminal(text)
}

/* For literal text strings inside the regexp. */
public func literal(_ text: String) -> Element {
  return terminal(text)
}

/* For start-of-line, etc. */
public func special(_ text: String) -> Element {
  return Box(text: text, style: specialStyle)
}

/* Concatenation of two or more elements. */
public func sequence(_ elements: Element...) -> Element {
  return Series(elements: elements)
}

/*
 * ? in the regex
 *
 * The drawSkipBelow parameter determines whether the skip line is drawn above
 * or below the element; the element itself is always in the center line.
 */
public func optional(_ element: Element, _ drawSkipBelow: Bool = false) -> Element {
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
public func choice(_ elements: Element...) -> Element {
  return Parallel(elements: elements)
}

/*
 * | in the regex
 *
 * The centerIndex parameter determines which element is drawn on the center
 * line.
 */
public func choice(_ centerIndex: Int, _ elements: Element...) -> Element {
  let p = Parallel(elements: elements)
  p.indexOfCenterElement = centerIndex
  return p
}

public func skip() -> Element {
  return Skip()
}

/* + in the regex */
public func oneOrMore(_ element: Element, _ loop: Element = skip()) -> Element {
  return Loop(forward: element, backward: loop)
}

/* * in the regex */
public func zeroOrMore(_ element: Element, _ loop: Element = skip(), _ drawSkipBelow: Bool = false) -> Element {
  return optional(oneOrMore(element, loop), drawSkipBelow)
}

/* A capture group in the regex. */
public func capture(_ element: Element, _ text: String) -> Element {
  return Decoration(element: element, text: text, style: captureStyle)
}

/* Draws a railroad diagram as a UIImage. */
public func diagram(_ elements: Element...) -> Image {
  var diagramStyle = DiagramStyle()
  diagramStyle.backgroundColor = Color.clear
  diagramStyle.trackLineWidth = 2
  diagramStyle.horizontalSpacing = 12
  diagramStyle.verticalSpacing = 9

  let diagram = Diagram(style: diagramStyle)
  let series = Series(elements: elements)
  return diagram.renderImage(element: series, scale: 2)
}

/* Alternative DSL from: https://code.google.com/p/html-railroad-diagram/ */

/* each(a, b, c)  produces (A -> B -> C) */
public func each(_ elements: Element...) -> Element {
  return Series(elements: elements)
}

/* Like | in EBNF (choose 1 of) */
public func or(_ elements: Element...) -> Element {
  return Parallel(elements: elements)
}

/* Like ? in EBNF (0 or 1 occurences) */
public func maybe(_ element: Element) -> Element {
  return optional(element)
}

/* Like + in EBNF (1 or more repetitions) */
public func many(_ element: Element, _ loop: Element = Skip()) -> Element {
  return Loop(forward: element, backward: loop)
}

/* Like * in EBNF (0 or more repetitions) */
public func any(_ element: Element, _ loop: Element = Skip()) -> Element {
  return maybe(many(element, loop))
}
