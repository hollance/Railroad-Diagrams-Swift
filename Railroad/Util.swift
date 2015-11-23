/* Export an image to a PNG file */

#if os(iOS)
import UIKit

func savePNG(image: UIImage, _ filename: String) {
  let dirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true)
  let path = (dirs[0] as NSString).stringByAppendingPathComponent(filename)
  if let data = UIImagePNGRepresentation(image) {
    if !data.writeToFile(path, atomically: true) {
      print("Error saving image to: \(path)")
    } else {
      print("Image saved to: \(path)")
    }
  }
}
#else
import AppKit

func savePNG(image: NSImage, _ filename: String) {
  let path = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(filename)

  image.lockFocus()
  let bitmapRep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
  image.unlockFocus()

  if let bitmapRep = bitmapRep {
    if let data = bitmapRep.representationUsingType(.NSPNGFileType, properties: [:]) {
      if data.writeToFile(path, atomically: true) {
        print("Image saved to: \(path)")
        return
      }
    }
  }
  print("Error saving image to: \(path)")
}
#endif
