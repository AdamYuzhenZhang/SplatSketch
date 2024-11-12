//
//  SIMD+Extensions.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/23/24.
//

import simd

extension matrix_float4x4 {
    init(translation t: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.3 = SIMD4(t.x, t.y, t.z, 1.0)
    }
    
    init(scale s: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.0.x = s.x
        self.columns.1.y = s.y
        self.columns.2.z = s.z
    }
    
    init(rotationX angle: Float) {
        self = matrix_identity_float4x4
        self.columns.1.y = cos(angle)
        self.columns.1.z = sin(angle)
        self.columns.2.y = -sin(angle)
        self.columns.2.z = cos(angle)
    }
    
    init(rotationY angle: Float) {
        self = matrix_identity_float4x4
        self.columns.0.x = cos(angle)
        self.columns.0.z = sin(angle)
        self.columns.2.x = -sin(angle)
        self.columns.2.z = cos(angle)
    }
    init(rotationZ angle: Float) {
        self = matrix_identity_float4x4
        self.columns.0.x = cos(angle)
        self.columns.0.y = sin(angle)
        self.columns.1.x = -sin(angle)
        self.columns.1.y = cos(angle)
    }
    
    func rotationMatrix() -> matrix_float3x3 {
        let col0 = SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z)
        let col1 = SIMD3<Float>(columns.1.x, columns.1.y, columns.1.z)
        let col2 = SIMD3<Float>(columns.2.x, columns.2.y, columns.2.z)
        return matrix_float3x3(columns: (col0, col1, col2))
    }
}

extension SIMD3 where Scalar == Float {
    func normalized() -> SIMD3<Float> {
        return simd_normalize(self)
    }
}
