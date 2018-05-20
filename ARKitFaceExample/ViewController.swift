/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSessionDelegate {
    
    // MARK: Outlets

    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var blurView: UIVisualEffectView!

    var location = CGPoint(x: 187.0, y: 406.0)
    var clicklocation = CGPoint(x: 187.0, y: 406.0)
    var y = 0.0
    var x = 0.0
    var prey = 0.0
    var prex = 0.0
    @IBOutlet var cursor: UIImageView!
    @IBOutlet weak var clickPlace: UIImageView!
    
    
    func click(to1: Float, to2:Float) {
        x = Double((to1 + 0.1)*375/0.2)
        y = Double(812-((to2 + 0.1)*812/0.26))
        if y < 0 {
            y = 0
        }
        else if y > 812 {
            y = 812
        }
        else{
            clicklocation.y = CGFloat(y)
        }
        
        if x < 0 {
            x = 0
        }
        else if x > 375 {
            x = 375
        }
        else{
            clicklocation.x = CGFloat(x)
        }
        
        
        clicklocation.x = CGFloat(x)
        clicklocation.y = CGFloat(y)
        
        clickPlace.center = clicklocation
    }
    func move(to1: Float, to2:Float){
        //to1 -0.1~0.1
        //to2 -0.1~0.15
        x = Double((to1 + 0.1)*375/0.2)
        y = Double(812-((to2 + 0.1)*812/0.26))
        
        
        if y < 0 {
            y = 0
        }
        else if y > 812 {
            y = 812
        }
        else{
            location.y = CGFloat(y)
        }
        
        if x < 0 {
            x = 0
        }
        else if x > 375 {
            x = 375
        }
        else{
            location.x = CGFloat(x)
        }
    
        
        location.x = CGFloat(x)
        location.y = CGFloat(y)
        
        cursor.center = location
    }
    func movevertical(to: Float){
        //-0.3~0.2 map 0~812
        prey = Double(location.y)
        y = Double(((to + 0.3) * 812)/0.5)
        if y < 0 {
            y = 0
        }
        else if y > 812 {
            y = 812
        }
        if abs(prey - y) <= 12{
            
        }
        else{
            location.y = CGFloat(y)
        }
        
        cursor.center = location
        //print(cursor.center)
    }
    func movehorizontal(to: Float){
        //-0.35~0.35 map 0~375
        prex = Double(location.x)
        x = Double(375 - ((to + 0.35) * 375 / 0.7))
        if x < 0 {
            x = 0
        }
        else if x > 375 {
            x = 375
        }
        if abs(prex - x) <= 7{
            
        }
        else{
            location.x = CGFloat(x)
        }
        location.x = CGFloat(x)
        cursor.center = location
        
    }
    
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()

    // MARK: Properties

    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }

    var nodeForContentType = [VirtualContentType: VirtualFaceNode]()
    
    let contentUpdater = VirtualContentUpdater()
    
    var selectedVirtualContent: VirtualContentType = .overlayModel {
        didSet {
            // Set the selected content based on the content type.
            contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]
        }
    }

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cursor.center = CGPoint(x: 187.0, y: 406.0)
        print(cursor.center)
        
        sceneView.delegate = contentUpdater
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        createFaceGeometry()
        

        // Set the initial face content, if any.
        contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
            AR experiences typically involve moving the device without
            touch input for some time, so prevent auto screen dimming.
        */
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.pause()
    }
    
    // MARK: - Setup
    
    /// - Tag: CreateARSCNFaceGeometry
    func createFaceGeometry() {
        // This relies on the earlier check of `ARFaceTrackingConfiguration.isSupported`.
        let device = sceneView.device!
        let maskGeometry = ARSCNFaceGeometry(device: device)!
        let glassesGeometry = ARSCNFaceGeometry(device: device)!

        nodeForContentType = [
            .faceGeometry: Mask(geometry: maskGeometry),
            .overlayModel: GlassesOverlay(geometry: glassesGeometry),
            .blendShapeModel: RobotHead()
        ]
        let myMask = nodeForContentType[.faceGeometry] as! Mask
        myMask.viewController = self
    }
    
    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false
        statusViewController.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        blurView.isHidden = true
        
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        statusViewController.showMessage("STARTING A NEW SESSION")
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Interface Actions

    /// - Tag: restartExperience
    func restartExperience() {
        // Disable Restart button for a while in order to give the session enough time to restart.
        statusViewController.isRestartExperienceButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.statusViewController.isRestartExperienceButtonEnabled = true
        }

        resetTracking()
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        /*
         Popover segues should not adapt to fullscreen on iPhone, so that
         the AR session's view controller stays visible and active.
        */
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
         All segues in this app are popovers even on iPhone. Configure their popover
         origin accordingly.
        */
        guard let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton else { return }
        popoverController.delegate = self
        popoverController.sourceRect = button.bounds

        // Set up the view controller embedded in the popover.
        let contentSelectionController = popoverController.presentedViewController as! ContentSelectionController

        // Set the initially selected virtual content.
        contentSelectionController.selectedVirtualContent = selectedVirtualContent

        // Update our view controller's selected virtual content when the selection changes.
        contentSelectionController.selectionHandler = { [unowned self] newSelectedVirtualContent in
            self.selectedVirtualContent = newSelectedVirtualContent
        }
    }
}
