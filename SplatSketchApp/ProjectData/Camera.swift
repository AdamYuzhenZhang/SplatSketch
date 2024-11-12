import Foundation
import simd
import Combine

class Camera: ObservableObject {
    // Position and orientation variables
    @Published var position: SIMD3<Float> = SIMD3(0, 0, -8)
    @Published var lookAtTarget: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    //@Published var zoom: Float = 1.0
    @Published var fovy: Float = 60 * (.pi / 180)
    @Published var aspectRatio: Float = 16.0 / 9.0
    
    let worldUp: SIMD3<Float> = SIMD3(0, 1, 0)
    
    func updateFromCameraData(_ cameraData: CameraData) {
        self.position = cameraData.position
        self.lookAtTarget = cameraData.lookAtTarget
        self.rotation = cameraData.rotation
        self.fovy = cameraData.fovy
        self.aspectRatio = cameraData.aspectRatio
    }
    
    func pan(deltaX: Float, deltaY: Float) {
        let right = simd_normalize(simd_cross(forwardVector(), worldUp))
        let up = simd_normalize(simd_cross(right, forwardVector()))
        
        position += -right * deltaX * 0.01 - up * deltaY * 0.01
        lookAtTarget += -right * deltaX * 0.01 - up * deltaY * 0.01
    }
    
    func zoom(delta: Float) {
        // Adjust the zoom level
        let zoomAmount = delta * 2
        let forward = forwardVector()
        position -= forward * zoomAmount
        //print(delta)
    }
    
    func rotate(deltaX: Float, deltaY: Float) {
        let radius = simd_length(position - lookAtTarget)
        let angleX = deltaY * -0.005
        let angleY = deltaX * 0.005
        
        let direction = simd_normalize(position - lookAtTarget)
        let rotationX = rotationMatrix(angle: angleX, axis: simd_cross(worldUp, direction))
        let rotationY = rotationMatrix(angle: angleY, axis: worldUp)
        
        // Apply rotations and extract the resulting direction vector
        let rotatedDirection = rotationY * (rotationX * SIMD4(direction, 0))
        let newDirection = SIMD3<Float>(rotatedDirection.x, rotatedDirection.y, rotatedDirection.z)
        
        position = lookAtTarget + radius * newDirection
        
    }
    
    func forwardVector() -> SIMD3<Float> {
        return simd_normalize(lookAtTarget - position)
    }
    
    func viewMatrixOrig() -> matrix_float4x4 {
        var matrix = matrix_identity_float4x4
        // Apply scaling (zoom)
        //matrix = matrix_multiply(matrix, matrix_float4x4(scale: SIMD3(repeating: zoom)))
        // Apply rotation around Y and X axes
        matrix = matrix_multiply(matrix, matrix_float4x4(rotationY: rotation.y))
        matrix = matrix_multiply(matrix, matrix_float4x4(rotationX: rotation.x))
        // Apply translation
        matrix = matrix_multiply(matrix, matrix_float4x4(translation: position))
        return matrix
    }
    
    func viewMatrix() -> matrix_float4x4 {
        let forward = forwardVector()
        let right = simd_normalize(simd_cross(forward, worldUp))
        let up = simd_cross(forward, right)
        
        let translation = matrix_float4x4(
                SIMD4(1, 0, 0, 0),
                SIMD4(0, 1, 0, 0),
                SIMD4(0, 0, 1, 0),
                SIMD4(-position.x, -position.y, -position.z, 1)
            )
        let rotation = matrix_float4x4(
                SIMD4(right.x, up.x, -forward.x, 0),
                SIMD4(right.y, up.y, -forward.y, 0),
                SIMD4(right.z, up.z, -forward.z, 0),
                SIMD4(0, 0, 0, 1)
            )
        let viewMatrix = rotation * translation
        //let matrix2 = viewMatrixOrig()
        //print("NewViewMatrix")
        //print(viewMatrix)
        //print("OriginalMatrix")
        //print(matrix2)
        
        return viewMatrix
    }
    
    var viewProjectionMatrix: matrix_float4x4 {
        return projectionMatrix * viewMatrix()
    }
    
    // Projection Matrix computed from fovy and aspectRatio
    var projectionMatrix: matrix_float4x4 {
        return matrix_perspective_right_hand(fovyRadians: fovy, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)
    }
    
    func rotationMatrix(angle: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
        let normalizedAxis = simd_normalize(axis)
        let x = normalizedAxis.x, y = normalizedAxis.y, z = normalizedAxis.z
        let cosA = cos(angle)
        let sinA = sin(angle)
        
        return matrix_float4x4(
            SIMD4(cosA + (1 - cosA) * x * x,
                  (1 - cosA) * x * y - sinA * z,
                  (1 - cosA) * x * z + sinA * y,
                  0),
            SIMD4((1 - cosA) * y * x + sinA * z,
                  cosA + (1 - cosA) * y * y,
                  (1 - cosA) * y * z - sinA * x,
                  0),
            SIMD4((1 - cosA) * z * x - sinA * y,
                  (1 - cosA) * z * y + sinA * x,
                  cosA + (1 - cosA) * z * z,
                  0),
            SIMD4(0, 0, 0, 1)
        )
    }
}

/*
import Foundation
import simd
import Combine

class Camera: ObservableObject {
    // Position and orientation variables
    @Published var position: SIMD3<Float> = SIMD3(0, 0, -8)
    //@Published var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var lookAtTarget: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var zoom: Float = 1.0
    @Published var fovy: Float = 60 * (.pi / 180)
    @Published var aspectRatio: Float = 16.0 / 9.0
    
    let worldUp: SIMD3<Float> = SIMD3(0, 1, 0)
    
    func pan(deltaX: Float, deltaY: Float) {
        let right = simd_normalize(simd_cross(forwardVector(), worldUp))
        let up = simd_normalize(simd_cross(right, forwardVector()))
        
        position += right * deltaX * 0.01 - up * deltaY * 0.01
        lookAtTarget += right * deltaX * 0.01 - up * deltaY * 0.01
        // Adjust the camera position based on pan
        //position.x += deltaX * 0.01
        //position.y -= deltaY * 0.01
    }
    
    func zoom(delta: Float) {
        // Adjust the zoom level
        let zoomAmount = delta * 2
        let forward = forwardVector()
        position += forward * zoomAmount
        //print(delta)
    }
    
    func rotate(deltaX: Float, deltaY: Float) {
        let radius = simd_length(position - lookAtTarget)
        let angleX = deltaY * 0.005
        let angleY = deltaX * 0.005
        
        let direction = simd_normalize(position - lookAtTarget)
        let rotationX = rotationMatrix(angle: angleX, axis: simd_cross(worldUp, direction))
        let rotationY = rotationMatrix(angle: angleY, axis: worldUp)
        
        // Apply rotations and extract the resulting direction vector
        let rotatedDirection = rotationY * (rotationX * SIMD4(direction, 0))
        let newDirection = SIMD3<Float>(rotatedDirection.x, rotatedDirection.y, rotatedDirection.z)
        
        position = lookAtTarget + radius * newDirection
        
        // Adjust the rotation around the Y-axis
        //rotation.y -= deltaX * 0.005
        //rotation.x += deltaY * 0.005
    }
    
    func forwardVector() -> SIMD3<Float> {
        return simd_normalize(lookAtTarget - position)
        /*
        // Start with the forward direction in camera space (negative Z axis)
        var forward = SIMD3<Float>(0, 0, -1)
        
        // Create rotation matrices
        let rotationXMatrix = matrix_float4x4(rotationX: rotation.x)
        let rotationYMatrix = matrix_float4x4(rotationY: rotation.y)
        
        // Apply rotations
        let rotationMatrix = rotationYMatrix * rotationXMatrix
        let transformedForward = rotationMatrix * SIMD4(forward, 0)
        forward = SIMD3<Float>(transformedForward.x, transformedForward.y, transformedForward.z)
        
        
        // Normalize the vector
        return simd_normalize(forward)
         */
    }
    
    /*
    func viewMatrix() -> matrix_float4x4 {
        var matrix = matrix_identity_float4x4
        // Apply scaling (zoom)
        //matrix = matrix_multiply(matrix, matrix_float4x4(scale: SIMD3(repeating: zoom)))
        // Apply rotation around Y and X axes
        matrix = matrix_multiply(matrix, matrix_float4x4(rotationY: rotation.y))
        matrix = matrix_multiply(matrix, matrix_float4x4(rotationX: rotation.x))
        // Apply translation
        matrix = matrix_multiply(matrix, matrix_float4x4(translation: position))
        return matrix
    }
    */
    func viewMatrix() -> matrix_float4x4 {
        let forward = forwardVector()
        let right = simd_normalize(simd_cross(worldUp, forward))
        let up = simd_cross(forward, right)
        
        var viewMatrix = matrix_identity_float4x4
        viewMatrix.columns.0 = SIMD4(right, 0)
        viewMatrix.columns.1 = SIMD4(up, 0)
        viewMatrix.columns.2 = SIMD4(-forward, 0)
        viewMatrix.columns.3 = SIMD4(-position, 1)
        
        return viewMatrix
    }
    
    var viewProjectionMatrix: matrix_float4x4 {
        return projectionMatrix * viewMatrix()
    }
    
    // Projection Matrix computed from fovy and aspectRatio
    var projectionMatrix: matrix_float4x4 {
        return matrix_perspective_right_hand(fovyRadians: fovy, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)
    }
    
    func rotationMatrix(angle: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
        let normalizedAxis = simd_normalize(axis)
        let x = normalizedAxis.x, y = normalizedAxis.y, z = normalizedAxis.z
        let cosA = cos(angle)
        let sinA = sin(angle)
        
        return matrix_float4x4(
            SIMD4(cosA + (1 - cosA) * x * x,
                  (1 - cosA) * x * y - sinA * z,
                  (1 - cosA) * x * z + sinA * y,
                  0),
            SIMD4((1 - cosA) * y * x + sinA * z,
                  cosA + (1 - cosA) * y * y,
                  (1 - cosA) * y * z - sinA * x,
                  0),
            SIMD4((1 - cosA) * z * x - sinA * y,
                  (1 - cosA) * z * y + sinA * x,
                  cosA + (1 - cosA) * z * z,
                  0),
            SIMD4(0, 0, 0, 1)
        )
    }
}

*/
