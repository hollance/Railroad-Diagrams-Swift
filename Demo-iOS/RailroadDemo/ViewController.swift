//
//  ViewController.swift
//  RailroadDemo
//
//  Created by Matthijs on 06-04-15.
//  Copyright (c) 2015 Hollance. All rights reserved.
//

import UIKit
import Railroad

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    savePNG(test1(), "test1.png")
    savePNG(test2(), "test2.png")
    savePNG(test3(), "test3.png")
    savePNG(test4(), "test4.png")
    savePNG(json_object(), "json_object.png")
    savePNG(json_number(), "json_number.png")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
