//
//  ViewController.swift
//  RouxSwiftHelloWorld
//
//  Created by H. Cole Wiley on 5/12/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
  var context: EAGLContext?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    let status = ScandyCore.setLicense()
    print("license status: ", status)
    
    startPreview()
  }
  
  func requestCamera() -> Bool {
    if ( ScandyCore.hasCameraPermission() )
    {
      print("user has granted permission to camera!")
      return true
    } else {
      print("user has denied permission to camera")
    }
    return false
  }

  
  func startPreview() {
    if( requestCamera() ) {
      /*
       This is a little ugly, we could make this ScandyCoreScannerType into
       a better Swift class, but it works for now.
       */
      var scanner_type: ScandyCoreScannerType = ScandyCoreScannerType(rawValue: 5);
      ScandyCore.initializeScanner(scanner_type)
      ScandyCore.startPreview()
    }
  }


}

