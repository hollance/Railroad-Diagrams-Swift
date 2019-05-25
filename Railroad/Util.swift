/* Export an image to a PNG file */

#if os(iOS)

import UIKit

func savePNG(_ image: UIImage, _ filename: String) {
  let dirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
  let path = (dirs[0] as NSString).appendingPathComponent(filename)
  if let data = image.pngData() {
    do {
      try data.write(to: URL(fileURLWithPath: path))
      print("Image saved to: \(path)")
    } catch {
      print("Error saving image to: \(path), error: \(error)")
    }
  }
}

#else

import AppKit

func savePNG(_ image: NSImage, _ filename: String) {
  let path = (NSTemporaryDirectory() as NSString).appendingPathComponent(filename)

  image.lockFocus()
  let bitmapRep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
  image.unlockFocus()

  do {
    if let bitmapRep = bitmapRep {
      if let data = bitmapRep.representation(using: .png, properties: [:]) {
        try data.write(to: URL(fileURLWithPath: path))
        print("Image saved to: \(path)")
        return
      }
    }
    print("Error saving image to: \(path)")
  } catch {
    print("Error saving image to: \(path), error: \(error)")
  }
}

#endif
