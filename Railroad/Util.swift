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

func savePNG(image: NSImage, filename: String) {
  let path = NSTemporaryDirectory().stringByAppendingPathComponent(filename)

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
