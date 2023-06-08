//
//  Camera.swift
//  TakeHome
//
//  
//  edit by adam sun on 05/24/23
//  This is the main class that handles camera setup and object detection tasks.

import AVFoundation
import VideoToolbox
import Vision
import CoreMedia

class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    // Singleton instance
    static let shared = Camera()
    
    // Variables for ML and Vision tasks
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    lazy var objectDectectionModel = { return try? YOLOv3TinyFP16() }()//ini yolo3 model
    
    // Variables for capturing and processing images
    let captureSession = AVCaptureSession()
    let captureQueue = DispatchQueue(label: "camera_capture")
    @Published var image: CGImage? = nil
    @Published var processingTime: TimeInterval = 0.0
    private var startTime: DispatchTime?
    @Published var debugString: String = "camera init"
    @Published var detectedObjects: [DetectedObject] = [] {
        didSet {// Check detection updates for testing purposes
            //print("UI should be updated with \(detectedObjects.count) objects.")
        }//didSet
    }//detectedObjects
    
    // Initialize the Camera
    private override init() {
        super.init()
        Task {
            do {
                try await getAuthorized() // Request camera access
                try setUpModel() //set up yolo3 model
                try setupInput() // Set up camera input
                try setupOutput() // Set up camera output
                captureQueue.async {//start capture image, in async thread
                    self.captureSession.startRunning()
                }//capture
            }//do
            catch{
                print("camera init failed: \(error)")
                DispatchQueue.main.async {// Update debug string on the main thread (required by SwiftUI)
                    self.debugString = "camera init failed: \(error)"
                }//catch
            }//catch
        }//task
    }//init
    
    /// Function to request camera access from user's device
    func getAuthorized() async throws {
        let authorized = await withCheckedContinuation({ continuation in
            if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                AVCaptureDevice.requestAccess(for: .video) { authorized in
                    continuation.resume(returning: authorized)
                }
            }//if
            else {
                continuation.resume(returning: true)
            }//else
        })//let
        if !authorized {
            throw "camera not authorized"
        }//if
    }//get_authorized
    
    /// Function to set up camera input format
    func setupInput() throws {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw "no back camera"
        }//guard
        let captureInput = try AVCaptureDeviceInput(device: device)
        captureSession.addInput(captureInput)
    }//setup_input
    
    /// Function to set up camera output format
    func setupOutput() throws {
        let captureOuptut = AVCaptureVideoDataOutput()
        captureOuptut.setSampleBufferDelegate(self, queue: captureQueue)
        captureSession.addOutput(captureOuptut)
    }//setup_output
    
    /// Function to capture output from camera and calculate processing time
    ///  This is a build-in function in AVCaptureOutput
    /// - Parameter value:
    ///      -output: AVCaptureOutput
    ///      -sampleBuffer: CMSampleBuffer
    ///      -connection: AVCaptureConnection
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }//guard let
        if startTime == nil {
            startTime = DispatchTime.now()
        }//if
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(imageBuffer, options: nil, imageOut: &cgImage)
        DispatchQueue.main.async {
            self.image = cgImage
        }//DispatchQueue
        guard let request = self.request else {
            return
        }//guard let
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, options: [:])
        
        do {
            try imageRequestHandler.perform([request])
        }//do
        catch {
            print("Failed to perform Vision request: \(error)")
        }
    }//captureOutput
    
    ///set up yolo3 model into the project
    func setUpModel() {
        guard let objectDectectionModel = objectDectectionModel else { fatalError("fail to load the model") }
        if let visionModel = try? VNCoreMLModel(for: objectDectectionModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
            request?.model.featureProvider = ThresholdProvider(iouThreshold: 0.5,
                                                               confidenceThreshold: 0.5)
            
        }//if let
        else {
            fatalError("fail to create vision model")
        }//else
        
    }//setUpModel
    
    /// This function is called when a Vision request has been completed.
    ///
    /// It processes the `VNRequest`'s results, converting them into `DetectedObject` instances, and updates the `Camera`'s `detectedObjects` property. These detected objects represent the objects identified by the Vision model in a frame of the camera's input.
    ///
    /// In addition to updating the `detectedObjects` property, it also updates the time taken to process the frame. This is done in an asynchronous block on the main thread to ensure thread safety as the `detectedObjects` and `processingTime` properties are published properties and might be observed by the UI.
    ///
    /// Finally, it prints the detected objects for logging or debugging purposes.
    ///
    /// - Parameters:
    ///   - request: The `VNRequest` that was completed.
    ///   - error: An optional `Error` that might have occurred during the request. If present, it indicates that the request failed.
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            return
        }//else
        
        var detectedObjects: [DetectedObject] = []
        
        for result in results {
            let boundingBox = result.boundingBox
            let identifier = result.labels.first?.identifier ?? ""
            
            let detectedObject = DetectedObject(boundingBox: boundingBox, identifier: identifier)
            detectedObjects.append(detectedObject)
        }//for
        //transfer data to uiview
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.detectedObjects = detectedObjects
            self.updateProcessingTime()
        }//DispatchQueue
        
        printDetectedObjects(detectedObjects)
        //print("visionrequest func is working")
    }//visionRequestDidComplete
    
    ///print detected objects in console
    /// - Parameters:
    ///   - objects: [DetectedObject] the list of DetectedObjects
    func printDetectedObjects(_ objects: [DetectedObject]) {
        for object in objects {
            print("Detected object: \(object.identifier), bounding box: \(object.boundingBox)")
        }//for
    }//printDetectedObjects
    
    ///calculate the processing time
    func updateProcessingTime() {
        guard let startTime = startTime else {
            return
        }//guard let
        
        let endTime = DispatchTime.now()
        let elapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        processingTime = elapsedTime
        
        self.startTime = nil
    }//updateProcessingTime
    
    //update thresholds value input for model
    func updateThresholds(iou: Float, confidence: Float) {
        guard let model = request?.model else { return }
        model.featureProvider = ThresholdProvider(iouThreshold: iou, confidenceThreshold: confidence)
    }//updateThresholds
}//camera

    ///struct object class for DetectedObject
struct DetectedObject: Identifiable {
        let id = UUID()
        let boundingBox: CGRect
        let identifier: String
}//DetectedObject

/// In Vision framework, it is uable to change the iou & confidenceThresholds directly,
/// We have to make a MLFeatureProvider class in order to change the value.
class ThresholdProvider: NSObject, MLFeatureProvider {

    var iouThreshold: Float
    var confidenceThreshold: Float
    
    var featureNames: Set<String> {
        return ["iouThreshold", "confidenceThreshold"]
    }//featureNames

    init(iouThreshold: Float, confidenceThreshold: Float) {
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }//init

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "iouThreshold" {
            return MLFeatureValue(double: Double(iouThreshold))
        } else if featureName == "confidenceThreshold" {
            return MLFeatureValue(double: Double(confidenceThreshold))
        }
        return nil
    }//featureValue
}//ThresholdProvider
