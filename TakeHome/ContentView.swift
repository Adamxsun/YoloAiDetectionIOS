//
//  ContentView.swift
//  TakeHome
//
//  
//  edit by adam sun on 05/24/23
// The main SwiftUI view that displays the camera feed and handles user interactions.

import SwiftUI

struct ContentView: View {
    // References to Camera singleton and state variables for modal view and thresholds
    @StateObject var camera = Camera.shared
    @State private var showingModal = false
    @State private var iouThreshold: Float = 0.5
    @State private var confidenceThreshold: Float = 0.5
    
    // Label for image
    private let label = Text("Camera Image")
    // Color options for rectangle
    let colors = [Color.red, Color.green, Color.blue, Color.yellow, Color.orange, Color.purple, Color.pink, Color.gray]
    // Main SwiftUI body
    var body: some View {
        VStack {
            // Display image from camera if available
            if let image = camera.image {
                GeometryReader { geometry in
                    Image(image, scale: 1.0, orientation: .up, label: label)
                        .resizable()
                        .frame(height: 300)
                        .overlay( // Overlay is used because the default camera is on the top layer, and we can't draw anything on it.
                            ZStack {
                                // For each object detected by the model, draw a rectangle and a name label
                                ForEach(camera.detectedObjects.indices, id: \.self) { index in
                                    let detectedObject = camera.detectedObjects[index]
                                    let boundingBox = detectedObject.boundingBox
                                    let rect = CGRect(
                                        x: boundingBox.origin.x * geometry.size.width,
                                        y: geometry.size.height - (boundingBox.origin.y * geometry.size.height) - (boundingBox.size.height * geometry.size.height),
                                        width: boundingBox.size.width * geometry.size.width,
                                        height: boundingBox.size.height * geometry.size.height
                                    )
                                    //draw rectangleS for object from yolo3
                                    Rectangle()
                                        .strokeBorder(colors[index % colors.count], lineWidth: 2)
                                        .frame(width: rect.size.width, height: rect.size.height)
                                        .position(x: rect.midX, y: rect.midY)
                                    //name of the object
                                    HStack {
                                        Text(detectedObject.identifier)
                                            .font(.system(size: 12))
                                            .foregroundColor(.white)
                                        Text(String(format: "%.2f s", self.camera.processingTime))
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    }
                                    .padding(4)
                                    .background(colors[index % colors.count])
                                    .cornerRadius(4)
                                    .position(x: rect.minX + 10, y: rect.minY + 20) // Adjust the y position
                                }//foreach
                            }//ZStack
                        )//overlay
                }//GeometryReader
            }//if let
            else
            {
                // Display debug string if no image is available
                Text(camera.debugString)
            }//else
            Spacer()
            Button(action: {
                        // Show modal view when button is pressed
                           showingModal = true
                       }) {
                           Text("Change Thresholds")
                       }
        }//VStack
        .background(Color.clear)
        // Full screen modal for threshold adjustments
        .fullScreenCover(isPresented: $showingModal) {
                   VStack {
                       HStack {
                           Text("Change Thresholds")
                               .font(.largeTitle)
                           Spacer()
                       }
                       .padding()
                       sliderInputView(value: $iouThreshold, label: "IOU Threshold")
                       sliderInputView(value: $confidenceThreshold, label: "Confidence Threshold")
                       Button(action: {
                           // Update thresholds and dismiss modal when button is pressed
                           camera.updateThresholds(iou: iouThreshold, confidence: confidenceThreshold)
                           showingModal = false
                       }) {
                           Text("OK")
                       }
                       .padding()
                       Spacer()
                   }//VStack
               }//fullScreenCover
    }//body
    
    /// Helper function to create slider input view
    ///
    /// - Parameters:
    ///   - value: Binding<Float>
    ///   - label: String
    ///
    /// - Returns: View
    func sliderInputView(value: Binding<Float>, label: String) -> some View {
            VStack {
                Text(label)
                Slider(value: value, in: 0...1, step: 0.01)
                Text("\(value.wrappedValue)")
            }
            .padding()
    }//sliderInputView
}//ContentView
