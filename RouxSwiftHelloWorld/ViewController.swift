//
//  ViewController.swift
//  RouxSwiftHelloWorld
//  Network demo - Mirror Device
//
//  Created by H. Cole Wiley on 5/12/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    //MARK: Global variables
    var SCAN_MODE_V2 = true;
    
    //MARK: Properties
    @IBOutlet weak var stopScanButton: UIButton!
    @IBOutlet weak var startScanButton: UIButton!
    @IBOutlet weak var saveMeshButton: UIButton!
    @IBOutlet weak var startPreviewButton: UIButton!
    @IBOutlet weak var scanSizeLabel: UILabel!
    @IBOutlet weak var scanSizeSlider: UISlider!
    @IBOutlet weak var v2ModeSwitch: UISwitch!
    @IBOutlet weak var v2ModeLabel: UILabel!
    @IBOutlet weak var connectToDeviceButton: UIButton!
    @IBOutlet weak var IPAddressLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func startScanningPressed(_ sender: Any) {
        print("start scanning pressed");
        startScanning();
    }
    
    @IBAction func scanSizeChanged(_ sender: Any) {
        setResolution();
    }
    
    @IBAction func toggleV2(_ sender: Any) {
        SCAN_MODE_V2 = v2ModeSwitch.isOn;
        ScandyCore.uninitializeScanner();
        ScandyCore.toggleV2Scanning(v2ModeSwitch.isOn);
        let scanner_type: ScandyCoreScannerType = ScandyCoreScannerType(rawValue: 4);
        ScandyCore.initializeScanner(scanner_type)
        ScandyCore.startPreview()
    }
    
    @IBAction func stopScanningPressed(_ sender: Any) {
        print("stop scanning pressed");
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
        let filepath = fileURL.path;
        print("saving file to \(filepath)");
        let alertController = UIAlertController(title: "Mesh Saved", message:
            "file saved to \(filepath)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        ScandyCore.saveMesh(filepath);
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func startPreviewPressed(_ sender: Any) {
        print("start preview pressed");
        turnOnScanner();
    }
    
    @IBAction func connectToScanningDevicePressed(_ sender: Any) {
        print("connect to scanning device pressed")
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
        renderPreviewScreen();
        
        if( requestCamera() ) {
            //Default to scan mode v2
            ScandyCore.toggleV2Scanning(SCAN_MODE_V2);
            ScandyCore.initializeScanner(ScandyCoreScannerType(rawValue: 4))
            ScandyCore.setReceiveRenderedStream(true)
            ScandyCore.setSendNetworkCommands(true)
            let IPAddress = ScandyCore.getIPAddress() as String;
            IPAddressLabel.text = "IP Address: " + IPAddress;
            ScandyCore.startPreview()
            setResolution();
        }
    }
    
    func setResolution(){
        if(SCAN_MODE_V2){
            let minRes = 0.0005; // == 0.5 mm
            let maxRes = 0.006 // == 4 mm
            let range = maxRes - minRes;
            // normalize the scan size based on default slider value range [0, 1]
            //Make sure we are passing a Double to setVoxelSize
            let voxelRes : Double = (range * Double(scanSizeSlider.value)) + minRes;
            ScandyCore.setVoxelSize(voxelRes);
            scanSizeLabel.text =  String(format: "Resolution: %.1f mm", voxelRes*1000);
        } else {
            // the minimum size of scan volume's dimensions in meters
            let minSize = 0.2;
            // the maximum size of scan volume's dimensions in meters
            let maxSize = 5.0;
            let range = maxSize - minSize;
            //Make sure we are passing a Double to setScanSize
            let scan_size : Double = (range * Double(scanSizeSlider.value)) + minSize;
            ScandyCore.setScanSize(scan_size);
            scanSizeLabel.text = String(format: "Scan Size: %.3f m", scan_size);
        }
    }
    
    func startScanning() {
        renderScanningScreen();
        ScandyCore.startScanning();
    }
    
    func stopScanning() {
        renderMeshScreen();
        ScandyCore.stopScanning();
    }
    
    func renderPreviewScreen(){
        scanSizeLabel.isHidden = false;
        scanSizeSlider.isHidden = false;
        v2ModeSwitch.isHidden = false;
        v2ModeLabel.isHidden = false;
        startScanButton.isHidden = false;
        connectToDeviceButton.isHidden = false;
        
        stopScanButton.isHidden = true;
        startPreviewButton.isHidden = true;
        saveMeshButton.isHidden = true;
    }
    
    func renderScanningScreen(){
        //Render our buttons
        stopScanButton.isHidden = false;
        
        connectToDeviceButton.isHidden = true;
        startScanButton.isHidden = true;
        scanSizeLabel.isHidden = true;
        scanSizeSlider.isHidden = true;
        v2ModeSwitch.isHidden = true;
        v2ModeLabel.isHidden = true;
    }
    
    func renderMeshScreen(){
        startPreviewButton.isHidden = false;
        saveMeshButton.isHidden = false;
        
        connectToDeviceButton.isHidden = true;
        scanSizeLabel.isHidden = true;
        scanSizeSlider.isHidden = true;
        startScanButton.isHidden = true;
        stopScanButton.isHidden = true;
        v2ModeSwitch.isHidden = true;
        v2ModeLabel.isHidden = true;
    }
    
}

