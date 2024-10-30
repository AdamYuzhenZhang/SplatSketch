//
//  DrawingView.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/23/24.
//

import Foundation

import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    //@ObservedObject var camera: Camera
    @Environment(AppManager.self) var appManager
    // @Binding var canvasView: PKCanvasView
    // @Binding var strokesDescription: String
    
    @State private var canvasView = PKCanvasView()
    
    //var strokesDescription: String
    
    let toolPicker = PKToolPicker()
    
    
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
    
    // Store the stoke data
    @State private var strokesData: [Data] = []
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        //canvasView.allowsFingerDrawing = false
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
    
    func saveDrawing() {
        // Serialize the drawing
        let drawingData = canvasView.drawing.dataRepresentation()
        
        // Save to a file
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("SplatDrawing").appendingPathExtension("drawing")
        
        do {
            try drawingData.write(to: fileURL)
            print("Drawing saved successfully.")
        } catch {
            print("Error saving drawing: \(error.localizedDescription)")
        }
    }
    
    func loadDrawing() {
        // Load from a file
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("SplatDrawing").appendingPathExtension("drawing")
        
        do {
            let drawingData = try Data(contentsOf: fileURL)
            let drawing = try PKDrawing(data: drawingData)
            canvasView.drawing = drawing
            print("Drawing loaded successfully.")
        } catch {
            print("Error loading drawing: \(error.localizedDescription)")
        }
    }
    
    func saveStrokesToFile() {
        // Access the strokes from the canvasView's drawing
        let strokes = canvasView.drawing.strokes
        
        // Serialize the strokes
        var strokesDataArray: [Data] = []
        for stroke in strokes {
            if let strokeData = try? NSKeyedArchiver.archivedData(withRootObject: stroke, requiringSecureCoding: true) {
                strokesDataArray.append(strokeData)
            } else {
                print("Failed to archive a stroke.")
            }
        }
        
        // Serialize the strokesDataArray
        if let dataToSave = try? NSKeyedArchiver.archivedData(withRootObject: strokesDataArray, requiringSecureCoding: true) {
            // Save the data to a file in the Documents directory
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("StrokesData").appendingPathExtension("dat")
            
            do {
                try dataToSave.write(to: fileURL)
                print("Strokes saved to file at \(fileURL)")
            } catch {
                print("Error saving strokes to file: \(error.localizedDescription)")
            }
        } else {
            print("Failed to archive strokes data array.")
        }
    }
    
    func printStroks() {
        // Access the strokes from the canvasView's drawing
        let strokes = canvasView.drawing.strokes
        var descriptions: [String] = []
        // Generate the strokes description
        for (index, stroke) in strokes.enumerated() {
            print(stroke)
            let description = self.strokeDescription(stroke, index: index)
            descriptions.append(description)
        }
        // Update the parent's strokesDescription variable
        DispatchQueue.main.async {
            // self.strokesDescription = descriptions.joined(separator: "\n")
        }
        
    }
    
    /*
    func loadStrokesFromFile() {
        // Load the data from the file
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("StrokesData").appendingPathExtension("dat")
        
        do {
            let data = try Data(contentsOf: fileURL)
            if let strokesDataArray = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Data] {
                var strokes: [PKStroke] = []
                for strokeData in strokesDataArray {
                    if let stroke = try NSKeyedUnarchiver.unarchivedObject(ofClass: PKStroke.self, from: strokeData) {
                        strokes.append(stroke)
                    } else {
                        print("Failed to unarchive a stroke.")
                    }
                }
                // Create a new PKDrawing with the strokes
                let drawing = PKDrawing(strokes: strokes)
                canvasView.drawing = drawing
                print("Strokes loaded from file.")
            } else {
                print("Failed to unarchive strokes data array.")
            }
        } catch {
            print("Error loading strokes from file: \(error.localizedDescription)")
        }
    }
     */
    
    func exportDrawingAsImage() {
        let drawing = canvasView.drawing
        let image = drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        
        // Convert the UIImage to PNG data
        if let pngData = image.pngData() {
            // Save the PNG data to a file in the Documents directory
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "MyDrawing.png"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                try pngData.write(to: fileURL)
                print("Drawing exported as PNG file at \(fileURL)")
            } catch {
                print("Error saving PNG file: \(error.localizedDescription)")
            }
        } else {
            print("Failed to convert image to PNG data.")
        }
    }
    
    func strokeDescription(_ stroke: PKStroke, index: Int) -> String {
        var description = "----------------------- \nStroke \(index + 1) -- "
        
        // Ink
        let ink = stroke.ink
        description += "Ink Type: \(ink.inkType.rawValue), "
        
        // Ink Color components
        if let colorComponents = ink.color.cgColor.components {
            let red = colorComponents[0]
            let green = colorComponents.count > 1 ? colorComponents[1] : red
            let blue = colorComponents.count > 2 ? colorComponents[2] : red
            let alpha = colorComponents.count > 3 ? colorComponents[3] : 1.0
            description += String(format: "Ink Color: RGBA(%.2f, %.2f, %.2f, %.2f), ", red, green, blue, alpha)
        } else {
            description += "Ink Color: Unknown, "
        }
        
        // Mask
        if let mask = stroke.mask {
            description += "Mask: \(mask), "
        } else {
            description += "Mask: None, "
        }
        
        // Masked Path Ranges
        let ranges = stroke.maskedPathRanges
        description += "Masked Path Ranges: \(ranges), "
        
        // Path
        let path = stroke.path
        description += "Path Points: \(path.count), "
        
        // Render Bounds
        let bounds = stroke.renderBounds
        description += "Render Bounds: \(bounds), "
        
        // Transform
        let transform = stroke.transform
        description += "Transform: \(transform), "
        
        // Random Seed
        let randomSeed = stroke.randomSeed
        description += "Random Seed: \(randomSeed)"
        
        return description
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
            super.init()
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            
        }

        
    }
}
