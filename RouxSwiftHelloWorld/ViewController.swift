//
//  ViewController.swift
//  RouxSwiftHelloWorld
//
//  Created by H. Cole Wiley on 5/12/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    
    //MARK: Properties
    @IBOutlet weak var stopScanButton: UIButton!
    @IBOutlet weak var startScanButton: UIButton!
    @IBOutlet weak var saveMeshButton: UIButton!
    @IBOutlet weak var startPreviewButton: UIButton!
    
    //MARK: Actions
    @IBAction func startScanningPressed(_ sender: Any) {
        print("start scanning pressed");
        startScanning();
    }
    
    @IBAction func stopScanningPressed(_ sender: Any) {
        print("stop scanning pressed");
        startScanButton.isHidden = true;
        stopScanButton.isHidden = true;
        stopScanning();
        ScandyCore.generateMesh();
    }
    
    @IBAction func saveMeshPressed(_ sender: Any) {
        let date = Date();
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss";
        let id = formatter.string(from: date);
        // NOTE: You can change this to: obj, ply, or stl
        let filetype = "ply";
        let filename = "rouxiosexample_\(id).\(filetype)";
        let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let documentsURL = URL(fileURLWithPath: documentspath);
        let fileURL = documentsURL.appendingPathComponent(filename);
        let filepath = fileURL.absoluteString;
        print("saving file to \(filepath)");
        let alertController = UIAlertController(title: "Mesh Saved", message:
               "file saved to \(filepath)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func startPreviewPressed(_ sender: Any) {
        print("start preview pressed");
//      ScandyCore.reset();
//      ScandyCore.setLicense();
        turnOnScanner();
    }

    
    override func viewDidLoad() {
    super.viewDidLoad()
    // Set the ScandyCoreLicense.txt
    let status = ScandyCore.setLicense()
    print("license status: ", status)
    // call our function to start ScandyCore
    turnOnScanner();
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

  
  func turnOnScanner() {
//    scanSizeLabel.isHidden = false;
//    scanSizeSlider.isHidden = false;
    startScanButton.isHidden = false;
    stopScanButton.isHidden = true;
    
    startPreviewButton.isHidden = true;
    saveMeshButton.isHidden = true;

    if( requestCamera() ) {
      /*
       This is a little ugly, we could make this ScandyCoreScannerType into
       a better Swift class, but it works for now.
       */
      let scanner_type: ScandyCoreScannerType = ScandyCoreScannerType(rawValue: 5);
      ScandyCore.initializeScanner(scanner_type)
      ScandyCore.startPreview()
      // Set the voxel size to some custom thing
      let mm = 1.5
      ScandyCore.setVoxelSize(mm * 1e-3)
    }
  }
    
 func startScanning() {
    //Render our buttons
    stopScanButton.isHidden = false;
    startScanButton.isHidden = true;
    //scanSizeLabel.isHidden = true;
    //scanSizeSlider.isHidden = true;
    //Make sure the preview is running
    //if(ScandyCore.isRunning()){
    ScandyCore.startScanning();
   // };
  }
    
func stopScanning() {
    stopScanButton.isHidden = true;
    saveMeshButton.isHidden = false;
    startPreviewButton.isHidden = false;

    //Make sure the preview is running
    //if(ScandyCore.isRunning()){
    ScandyCore.stopScanning();
   // };
 }


}

