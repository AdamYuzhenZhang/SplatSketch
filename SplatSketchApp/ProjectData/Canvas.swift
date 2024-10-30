//
//  Canvas.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation
import PencilKit

class Canvas {
    let name: String
    let canvasView = PKCanvasView()
    
    init (name: String) {
        self.name = name
    }
}
