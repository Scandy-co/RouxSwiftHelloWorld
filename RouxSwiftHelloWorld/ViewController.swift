//
//  ViewController.swift
//  RouxSwiftHelloWorld
//  Network demo
//
//  Created by H. Cole Wiley on 5/12/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    //MARK: Global variables
    var SCAN_MODE_V2 = true;
    var NETWORK_SCANNER: ScandyCoreScannerType =  ScandyCoreScannerType(rawValue: 4);
    
    //MARK: Properties
    @IBOutlet weak var selectDeviceType: UISegmentedControl!
    @IBOutlet weak var IPAddressLabel: UILabel!
    
    //Mirror Device UI
    @IBOutlet weak var mirrorDeviceView: UIView!
    @IBOutlet weak var stopScanButton: UIButton!
    @IBOutlet weak var startScanButton: UIButton!
    @IBOutlet weak var scanSizeLabel: UILabel!
    @IBOutlet weak var scanSizeSlider: UISlider!
    @IBOutlet weak var v2ModeSwitch: UISwitch!
    @IBOutlet weak var v2ModeLabel: UILabel!
    @IBOutlet weak var connectToMirrorDeviceButton: UIButton!
    
    //Scanning Device UI
    @IBOutlet weak var scanningDeviceView: UIView!
    @IBOutlet weak var IPAddressInputLabel: UILabel!
    @IBOutlet weak var IPAddressInput: UITextField!
    @IBOutlet weak var changeHostButton: UIButton!
    @IBOutlet weak var saveMeshButton: UIButton!
    @IBOutlet weak var startPreviewButton: UIButton!
    
    
    //MARK: Actions
    @IBAction func selectDeviceTypeToggled(_ sender: Any) {
        ScandyCore.uninitializeScanner();
        let deviceType = selectDeviceType.selectedSegmentIndex;
        switch(deviceType){
        case 0:
            //Mirror Device
            initializeMirrorDevice();
        case 1:
            //Scanning Device
            initializeScanningDevice();
        default:
            return;
        }
    }
    //MARK: Mirror Device Actions
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
        ScandyCore.initializeScanner(NETWORK_SCANNER)
        ScandyCore.startPreview()
    }
    
    @IBAction func stopScanningPressed(_ sender: Any) {
        print("stop scanning pressed");
        stopScanning();
        ScandyCore.generateMesh();
    }
    
    //MARK: Mirror Device Actions
    @IBAction func connectToMirrorDeviceButtonPressed(_ sender: Any) {
        view.endEditing(true);
        let ip_address = IPAddressInput.text! as String;
        let discovered_hosts = ScandyCore.getDiscoveredHosts() as! [String];
        if(discovered_hosts.contains(ip_address)){
            ScandyCore.connect(toCommandHost: ip_address);
            ScandyCore.setServerHost(ip_address);
            IPAddressLabel.text = "Connected to: \(ip_address)";
            renderPreviewScreen(device_type: "scanner");
        } else {
            let alertController = UIAlertController(title: "Host Not Found", message:
                "Could not find mirror device at \(ip_address). Please try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
            IPAddressInput.text = "";
        }
    }
    
    //    @IBAction func saveMeshPressed(_ sender: Any) {
    //        let date = Date();
    //        let formatter = DateFormatter();
    //        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss";
    //        let id = formatter.string(from: date);
    //        // NOTE: You can change this to: obj, ply, or stl
    //        let filetype = "ply";
    //        let filename = "rouxiosexample_\(id).\(filetype)";
    //        let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
    //        let documentsURL = URL(fileURLWithPath: documentspath);
    //        let fileURL = documentsURL.appendingPathComponent(filename);
    //        let filepath = fileURL.path;
    //        print("saving file to \(filepath)");
    //        let alertController = UIAlertController(title: "Mesh Saved", message:
    //            "file saved to \(filepath)", preferredStyle: .alert)
    //        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
    //        ScandyCore.saveMesh(filepath);
    //        self.present(alertController, animated: true, completion: nil)
    //
    //    }
    
    //    @IBAction func startPreviewPressed(_ sender: Any) {
    //        print("start preview pressed");
    //    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        ScandyCore.setLicense();
        initializeMirrorDevice();
    }
    
    func initializeMirrorDevice(){
        mirrorDeviceView.isHidden = false;
        scanningDeviceView.isHidden = true;
        renderPreviewScreen(device_type: "mirror");
        if( requestCamera() ) {
            ScandyCore.setReceiveRenderedStream(true);
            ScandyCore.setSendNetworkCommands(true);
            ScandyCore.initializeScanner(NETWORK_SCANNER);
            let IPAddress = ScandyCore.getIPAddress() as String;
            IPAddressLabel.text = "IP Address: " + IPAddress;
            ScandyCore.setServerHost(IPAddress);
            setResolution();
            ScandyCore.startPreview();
        }
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
    
    func initializeScanningDevice(){
        mirrorDeviceView.isHidden = true;
        scanningDeviceView.isHidden = false;
        if( requestCamera() ) {
            ScandyCore.setSendRenderedStream(true);
            ScandyCore.setReceiveNetworkCommands(true);
            ScandyCore.initializeScanner();
            IPAddressLabel.text = "Connected to: ";
            renderConnectToDeviceScreen();
        }
    }
    
    func renderConnectToDeviceScreen(){
        IPAddressInput.isHidden = false;
        IPAddressInputLabel.isHidden = false;
        connectToMirrorDeviceButton.isHidden = false;
        
        changeHostButton.isHidden = true;
        saveMeshButton.isHidden = true;
        startPreviewButton.isHidden = true;
    }
    
    func startScanning() {
        renderScanningScreen();
        ScandyCore.startScanning();
    }
    
    func stopScanning() {
        renderMeshScreen();
        ScandyCore.stopScanning();
        let alertController = UIAlertController(title: "Scanning Complete", message:
            "Mesh has been generated on scanning device.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
            ScandyCore.startPreview();
            self.renderPreviewScreen(device_type: "mirror");
        }))
        self.present(alertController, animated: true)
    }
    
    func renderPreviewScreen(device_type: String){
        switch(device_type){
        case "mirror":
            scanSizeLabel.isHidden = false;
            scanSizeSlider.isHidden = false;
            v2ModeSwitch.isHidden = false;
            v2ModeLabel.isHidden = false;
            startScanButton.isHidden = false;
            
            stopScanButton.isHidden = true;
            startPreviewButton.isHidden = true;
            saveMeshButton.isHidden = true;
            return
        case "scanner":
            changeHostButton.isHidden = true;
            saveMeshButton.isHidden = true;
            startPreviewButton.isHidden = true;
            IPAddressInputLabel.isHidden = true;
            IPAddressInput.isHidden = true;
            connectToMirrorDeviceButton.isHidden = true;
            return
        default:
            return;
        }
    }
    
    func renderScanningScreen(){
        //Render our buttons
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

