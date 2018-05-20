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
        if self.state == 0 {
            if vectorY < 0 && vectorY < -0.002 {
                state = 1
                self.buffer = Array()
                self.startPosX = newX
                self.startPosY = newY
            }
        } else if self.state == 1 {
            if self.buffer?.count == 60 {
                if let buffer = self.buffer {
                    var summary: Float = 0.0
                    for elemt in buffer {
                        if elemt < 0 {
                            summary -= elemt
                        } else {
                            summary += elemt
                        }
                    }
                    print(summary, buffer, startPosX, startPosY)
                    DispatchQueue.main.async{
                        
                        self.viewController.click(to1: self.startPosX, to2: self.startPosY)
                    }
                }
                self.state = 0
            } else {
                let scale: Float = 10000
                self.buffer?.append(vectorY * scale)
            }
        }
        
        
        
        preX = newX
        preY = newY
        
        
        //print(i)
        if(i%1 == 0){
            DispatchQueue.main.async{
                self.viewController.move(to1: newX, to2: newY)
            }
        }
        
        
        
        //print(anchor.transform)
        i += 1
    }
}
