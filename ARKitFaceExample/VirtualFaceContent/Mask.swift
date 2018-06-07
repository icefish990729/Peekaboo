/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An `SCNNode` subclass demonstrating a basic use of `ARSCNFaceGeometry`.
*/

import ARKit
import SceneKit
import UIKit

class Mask: SCNNode, VirtualFaceContent {
    
    var faceOrigin: SCNNode?
    var sampleVector: Array<Array<Float>>?
    init(geometry: ARSCNFaceGeometry) {
        let material = geometry.firstMaterial!
        
        material.diffuse.contents = UIColor.lightGray
        material.lightingModel = .physicallyBased
        
        super.init()
        self.geometry = geometry
        
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
    /// - Tag: SCNFaceGeometryUpdate
    func update(withFaceAnchor anchor: ARFaceAnchor) {
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
        
        
        let t = (-facePos.z)/vector.z
        let newX = facePos.x + vector.x * t
        let newY = facePos.y + vector.y * t
        let newZ = 0
        
        vectorX = (newX - preX)
        vectorY = (newY - preY)
        
        //print(newX, newY, "/",preX, preY, "/",vectorX, vectorY)
        //print(vectorX, vectorY)
        
        let alpha: Float = 0.7
        let updateX = (1 - alpha) * newX + (alpha) * self.preX
        let updateY = (1 - alpha) * newY + (alpha) * self.preY
        DispatchQueue.main.async{
            self.viewController.move(to1: updateX, to2: updateY)
        }
        
        // update newX and newY
        preX = updateX
        preY = updateY
        i += 1
    }
}
