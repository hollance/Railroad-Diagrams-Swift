import UIKit
import Railroad

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    savePNG(test1(), "test1.png")
    savePNG(test2(), "test2.png")
    savePNG(test3(), "test3.png")
    savePNG(test4(), "test4.png")
    savePNG(json_object(), "json_object.png")
    savePNG(json_number(), "json_number.png")
  }
}
