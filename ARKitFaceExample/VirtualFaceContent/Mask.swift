/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An `SCNNode` subclass demonstrating a basic use of `ARSCNFaceGeometry`.
*/

import ARKit
import SceneKit
import UIKit

class Mask: SCNNode, VirtualFaceContent {
    
    var cursorMovingType = -1
    var faceOrigin: SCNNode?
    var sampleVector: Array<Array<Float>>?
    init(geometry: ARSCNFaceGeometry, movingType: Int) {
        let material = geometry.firstMaterial!
        
        material.diffuse.contents = UIColor.lightGray
        material.lightingModel = .physicallyBased
        
        super.init()
        self.geometry = geometry
        self.cursorMovingType = movingType
        
        faceOrigin = loadedContentForAsset(named: "coordinateOrigin")
        addChildNode(faceOrigin!)
        faceOrigin?.position.z = 0.05;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    // MARK: VirtualFaceContent
    var i = 1
    var preX = Float(0.0)
    var preY = Float(0.0)
    var vectorX = Float(0.0)
    var vectorY = Float(0.0)
    var state: Int = 0
    var buffer: Array<Float>?
    var startPosX: Float = Float(0.0)
    var startPosY: Float = Float(0.0)
    
    
    var viewController: ViewController!
    
    func maskDirectMapping(anchor: ARFaceAnchor) {
        faceOrigin?.position.y = 0.0
        let faceGeometry = geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
        let nosePos: SCNVector3 = faceOrigin!.worldPosition
        let facePos: SCNVector3 = self.worldPosition
        let vector: SCNVector3 = SCNVector3(
            nosePos.x - facePos.x,
            nosePos.y - facePos.y,
            nosePos.z - facePos.z
        )
        
        /* Calculate the fromula */
        let newX = nosePos.x
        let newY = nosePos.y
        
        let alpha: Float = 0.8
        let updateX = (1 - alpha) * newX + (alpha) * self.preX
        let updateY = (1 - alpha) * newY + (alpha) * self.preY
        DispatchQueue.main.async{
            self.viewController.move(
                to1: updateX, to2: updateY,
                x1: -0.038, x2: 0.033, y1: 0.13, y2: 0.19
            )
        }
        // update newX and newY
        preX = updateX
        preY = updateY
        i += 1
    }
    
    func cursorRayMapping(anchor: ARFaceAnchor) {
        faceOrigin?.position.y = 0.0
        let faceGeometry = geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
        let nosePos: SCNVector3 = faceOrigin!.worldPosition
        let facePos: SCNVector3 = self.worldPosition
        let vector: SCNVector3 = SCNVector3(
            nosePos.x - facePos.x,
            nosePos.y - facePos.y,
            nosePos.z - facePos.z
        )
        /* Calculate the fromula */
        let t = (-facePos.z) / vector.z
        let newX = facePos.x + vector.x * t
        let newY = facePos.y + vector.y * t
        
        // print(newX, newY)
        
        vectorX = (newX - preX)
        vectorY = (newY - preY)
        
        let alpha: Float = 0.8
        let updateX = (1 - alpha) * newX + (alpha) * self.preX
        let updateY = (1 - alpha) * newY + (alpha) * self.preY
        DispatchQueue.main.async{
            self.viewController.move(
                to1: updateX, to2: updateY,
                x1: -0.24, x2: 0.16, y1: 0.003, y2: 0.24
            )
        }
        
        // update newX and newY
        preX = updateX
        preY = updateY
        i += 1
    }
    
    func cursorSpeedMapping(anchor: ARFaceAnchor) {
        faceOrigin?.position.y = 0.025
        
        let faceGeometry = geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
        let nosePos: SCNVector3 = faceOrigin!.worldPosition
        var facePos: SCNVector3 = self.worldPosition
        facePos.y += 0.025
        
        let vector: SCNVector3 = SCNVector3(
            nosePos.x - facePos.x,
            nosePos.y - facePos.y,
            nosePos.z - facePos.z
        )
        
        /* Calculate the fromula */
        let t = (-facePos.z) / vector.z
        let newX = facePos.x + vector.x * t
        let newY = facePos.y + vector.y * t
        
        //print(newX, newY)
        
        vectorX = (newX - preX)
        vectorY = (newY - preY)
        
        //print(vectorX, vectorY)
        
        
        let alpha: Float = 0.8
        let updateX = (1 - alpha) * newX + (alpha) * self.preX
        let updateY = (1 - alpha) * newY + (alpha) * self.preY
        DispatchQueue.main.async{
            self.viewController.move(
                to1: updateX, to2: updateY,
                x1: -0.12, x2: 0.12, y1: 0.03, y2: 0.25
            )
        }
        
        // update newX and newY
        preX = updateX
        preY = updateY
        i += 1
    }
    
    /// - Tag: SCNFaceGeometryUpdate
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        if self.cursorMovingType == 0 {
            maskDirectMapping(anchor: anchor)
        } else if self.cursorMovingType == 1 {
            cursorRayMapping(anchor: anchor)
        } else {
            cursorSpeedMapping(anchor: anchor)
        }
    }
}
