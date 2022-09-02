//
//  ViewController.swift
//  RouxSwiftHelloWorld
//
//  Created by H. Cole Wiley on 5/12/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import GLKit

class ViewController: GLKViewController, ScandyCoreDelegate {
    func onTrackingDidUpdate(_ confidence: Double, withTracking is_tracking: Bool) {
        // NOTE: this is a very active callback, so don't log it as it will slow everything to a crawl
        // DispatchQueue.main.async {
        // print("tracking updated. confidence: \(confidence) is_tracking: \(is_tracking)")
        // }
    }
    
    func onVolumeMemoryDidUpdate(_ percent_full: Double) {
        // NOTE: this is a very active callback, so don't log it as it will slow everything to a crawl
        // DispatchQueue.main.async {
        // print("volume updated: \(percent_full)")
        // }
    }
    
    func onVisualizerReady(_ createdVisualizer: Bool) {
        DispatchQueue.main.async {
            print("visualizer ready: \(createdVisualizer)")}
    }
    
    func onScannerReady(_ status: ScandyCoreStatus) {
        DispatchQueue.main.async {
            print("scanner ready: \(status)")
            if(status == self.SUCCESS){
                if( self.requestCamera() ) {
                    ScandyCore.startPreview()
                    self.setResolution();
                }
            }
        }
    }
    
    func onPreviewStart(_ status: ScandyCoreStatus) {
        DispatchQueue.main.async {
            print("preview started: \(status)")
            if(status == self.SUCCESS){
                self.renderPreviewScreen();
            }
        }
    }
    
    func onScannerStart(_ status: ScandyCoreStatus) {
        DispatchQueue.main.async {
            print("scanner started: \(status)")
            if(status == self.SUCCESS){
                self.renderScanningScreen();
            }
        }
    }
    
    func onScannerStop(_ status: ScandyCoreStatus) {
        DispatchQueue.main.async {
            print("scanner stopped: \(status)")
            if(status == self.SUCCESS){
                ScandyCore.generateMesh();}
        }
    }
    
    func onGenerateMesh(_ status: ScandyCoreStatus) {
        DispatchQueue.main.async {
            print("generate mesh: \(status)")
            if(status == self.SUCCESS){
                self.renderMeshScreen();
            }
        }
    }
    
    func onSaveMesh(_ status: ScandyCoreStatus) {
        DispatchQueue.main.async {
            if(status == self.SUCCESS){
                print("mesh saved: \(status)")
                let alertController = UIAlertController(title: "Mesh Saved", message:
                    "file saved to \(self.meshPath)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
                    ScandyCore.startPreview();
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func onLoadMesh(_ status: ScandyCoreStatus) {
        DispatchQueue.main.async {
            print("mesh loaded: \(status)")}
    }
    
    func onClientConnected(_ host: String!) {
        DispatchQueue.main.async {
            print("client connected: \(String(describing: host))")}
    }
    
    func onClientDisconnected(_ host: String!) {
        DispatchQueue.main.async {
            print("client disconnected: \(String(describing: host))")}
    }
    
    func onHostDiscovered(_ host: String!) {
        DispatchQueue.main.async {
            print("host discovered: \(String(describing: host))")}
    }
    
    //MARK: Global variables
    var v2Enabled = true;
    var meshPath = ""
    var SUCCESS = ScandyCoreStatus(rawValue: 0)
    
    //MARK: Properties
    @IBOutlet weak var stopScanButton: UIButton!
    @IBOutlet weak var startScanButton: UIButton!
    @IBOutlet weak var saveMeshButton: UIButton!
    @IBOutlet weak var startPreviewButton: UIButton!
    @IBOutlet weak var scanSizeLabel: UILabel!
    @IBOutlet weak var scanSizeSlider: UISlider!
    @IBOutlet weak var v2ModeSwitch: UISwitch!
    @IBOutlet weak var v2ModeLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func startScanningPressed(_ sender: Any) {
        ScandyCore.startScanning();
    }
    
    @IBAction func scanSizeChanged(_ sender: Any) {
        setResolution();
    }
    
    @IBAction func toggleV2(_ sender: Any) {
        v2Enabled = v2ModeSwitch.isOn;
        ScandyCore.uninitializeScanner();
        ScandyCore.toggleV2Scanning(v2ModeSwitch.isOn);
        ScandyCore.initializeScanner();
    }
    
    @IBAction func stopScanningPressed(_ sender: Any) {
        ScandyCore.stopScanning();
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
        meshPath = fileURL.path;
        print("saving file to \(meshPath)");
        ScandyCore.saveMesh(meshPath);
    }
    
    @IBAction func startPreviewPressed(_ sender: Any) {
        ScandyCore.startPreview();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ScandyCore.setDelegate(self)    //So we can use event listeners
        ScandyCore.setLicense()         //Searches main bundle for ScandyCoreLicense.txt
        ScandyCore.initializeScanner()  //Initialize scanner (true depth by default)
        //        ScandyCore.initializeScanner(ScandyCoreScannerType(rawValue: 5))  //Initialize as true depth scanner - same as calling intializeScanner()
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
    
    func setResolution(){
        if(v2Enabled){
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
    
    
    func renderPreviewScreen(){
        scanSizeLabel.isHidden = false;
        scanSizeSlider.isHidden = false;
        v2ModeSwitch.isHidden = false;
        v2ModeLabel.isHidden = false;
        startScanButton.isHidden = false;
        
        stopScanButton.isHidden = true;
        startPreviewButton.isHidden = true;
        saveMeshButton.isHidden = true;
    }
    
    func renderScanningScreen(){
        stopScanButton.isHidden = false;
        
        startScanButton.isHidden = true;
        scanSizeLabel.isHidden = true;
        scanSizeSlider.isHidden = true;
        v2ModeSwitch.isHidden = true;
        v2ModeLabel.isHidden = true;
    }
    
    func renderMeshScreen(){
        startPreviewButton.isHidden = false;
        saveMeshButton.isHidden = false;
        
        scanSizeLabel.isHidden = true;
        scanSizeSlider.isHidden = true;
        startScanButton.isHidden = true;
        stopScanButton.isHidden = true;
        v2ModeSwitch.isHidden = true;
        v2ModeLabel.isHidden = true;
    }
    
}

