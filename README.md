# Networking via SDK - Mirror Device

This feature allows two devices to be connected. One device captures the scan while the other device renders the preview. This branch demonstrates how to implement the mirror device. See `demo/networking-scanning-device` to see how to set up the scanning device.

## Terminology

**Scanning Device**: The device which does the scanning.
- runs SLAM & reconstruction pipeline
- sends the scan preview screen
- receives scan commands

**Mirror Device**: The device which renders scan preview and controls the scan process.
- receives scan view
- sends scan commands (start, stop, set scan size, etc.)

## Setting Up Mirror Device


1. Receive scan view
The main purpose a mirror device is to receive the scan screen from the scanning device, so we must also configure that.

Swift:

```
ScandyCore.setReceiveRenderedStream(true);
```

Obj-c:

```
[ScandyCore setReceiveRenderedStream:true];
```

2. Send scan commands
 When we configure the mirror device to send network commands, calls to the following functions will be sent to the scanning device: `startScanning`, `stopScanning`, `generateMesh`, `setScanSize`, `setVoxelSize`, and `setNoiseFilter`. Again we have to explicitly tell the mirror device to send these.

Swift:

```
ScandyCore.setSendNetworkCommands(true);
```

Obj-c:

```
[ScandyCore setSendNetworkCommands:true];
```

_NOTE:_ `startPreview` does not get sent over the network because the preview must be started on the mirror device.

3. Initialize
This device needs to initialize the Roux backend but must set the scanner type to `ScandyCoreScannerType::NETWORK` to tell it not to use data generated from the scanning device.

Swift:

```
ScandyCore.initializeScanner(ScandyCoreScannerType(rawValue: 4));
```

Obj-c:

```
[ScandyCore initializeScanner:ScandyCoreScannerType::NETWORK];
```

## Connecting the Devices

First, both devices must be on the same wifi network.

From the mirror device we need to get the IP address so we know which IP to look for the scanning device in. On mirror device call:

Swift:

```
ScandyCore.getIPAddress()
```

Obj-c:

```
[ScandyCore getIPAddress];
```

We can then use that IP address to tell the scanning device to send the rendered scan preview to the mirror device.

Swift:

```
ScandyCore.setServerHost(mirror_ip)
```

Obj-c:

```
[ScandyCore setServerHost:mirror_ip];
```