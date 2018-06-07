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
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button4: UIButton!
    @IBOutlet weak var Button5: UIButton!
    @IBOutlet weak var Button6: UIButton!
    @IBOutlet weak var Button7: UIButton!
    @IBOutlet weak var Button8: UIButton!
    @IBOutlet weak var Button9: UIButton!
    @IBOutlet weak var Button10: UIButton!
    @IBOutlet weak var Button11: UIButton!
    @IBOutlet weak var Button12: UIButton!
    @IBOutlet weak var Button13: UIButton!
    @IBOutlet weak var Button14: UIButton!
    @IBOutlet weak var Button15: UIButton!
    @IBOutlet weak var Button16: UIButton!
    @IBOutlet weak var Button17: UIButton!
    @IBOutlet weak var Button18: UIButton!
    @IBOutlet weak var Button19: UIButton!
    @IBOutlet weak var Button20: UIButton!
    @IBOutlet weak var Button21: UIButton!
    @IBOutlet weak var Button22: UIButton!
    @IBOutlet weak var Button23: UIButton!
    @IBOutlet weak var Button24: UIButton!
    @IBOutlet weak var Button25: UIButton!
    @IBOutlet weak var Button28: UIButton!
    @IBOutlet weak var Button26: UIButton!
    @IBOutlet weak var Button27: UIButton!
    @IBOutlet weak var StartButton: UIButton!
    
    var buttonArray : Array<UIButton> = []
    
    var location = CGPoint(x: 187.0, y: 406.0)
    var clicklocation = CGPoint(x: 187.0, y: 406.0)
    var y = 0.0
    var x = 0.0
    var prey = 0.0
    var prex = 0.0
    //var taskorder = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,28]
    var taskorder = [1,4,25,28]
    var noworder = 0
    var state = 0
    var timer = Timer()
    var counter = 0.0
    var time : Array<Double> = []
    var missData : Array<Int> = []
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
    func move(to1: Float, to2:Float, x1: Float, x2: Float, y1: Float, y2: Float){
        //to1 -0.1~0.1
        //to2 -0.1~0.15
        
        x = Double((to1 - x1)*375/(x2 - x1))
        y = Double(812-((to2 - y1)*812/(y2 - y1)))
        
        
        if y < 0 {
            y = 0
        } else if y > 812 {
            y = 812
        } else{
            location.y = CGFloat(y)
        }
        
        if x < 0 {
            x = 0
        } else if x > 375 {
            x = 375
        } else{
            location.x = CGFloat(x)
        }
    
        
        location.x = CGFloat(x)
        location.y = CGFloat(y)
        
        cursor.center = location
    }
    
    
    
    
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: " ",
                         modifierFlags: [],
                         action: #selector(self.clickbutton),
                         discoverabilityTitle: "Click"),
            UIKeyCommand(input: "E",
                         modifierFlags: [],
                         action: #selector(self.end),
                         discoverabilityTitle: "Task end")
        ]
    }
    @objc func end(){
        print(time)
        print(missData)
    }
    @objc func UpdateTimer() {
        counter = counter + 0.001
    }
    @objc func clickbutton() {
        //print(x,y)
        let r = 22.0
        let alpha = 15.0
        if state == 0{
            if( distance(p: x-alpha, b: Double(StartButton.center.x)) > r || distance(p: y-alpha, b: Double(StartButton.center.y)) > r ){
                //print("out")
            }else{
                state = 1
                //print("in")
                StartButton.isHidden = true
                buttonArray[taskorder[noworder]-1].isHidden = false
                timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
            }
            
        }
        else if(state == 1){
            if(distance(p: x-alpha, b: Double(buttonArray[taskorder[noworder]-1].center.x)) > r || distance(p: y-alpha, b: Double(buttonArray[taskorder[noworder]-1].center.y)) > r){
                print("miss")
                missData.append(taskorder[noworder])
            }
            else{
                //print("hit")
                timer.invalidate()
                time.append(counter)
                counter = 0.0
                StartButton.isHidden = false
                buttonArray[taskorder[noworder]-1].isHidden = true
                noworder += 1
                state = 0
                
            }
        }
        else{
            
        }
        if noworder == taskorder.count{
            state = 2
            StartButton.setTitle("END", for: .normal)
            print(time)
            print(missData)
        }
        
    }
    
    
    
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
    func distance(p: Double,b: Double) -> Double {
        let dis = abs(p - b)
        return dis
    }
    func taskStart() {
        for i in taskorder{
            let r = 22.0
            if state == 0{
                if( distance(p: x, b: Double(StartButton.center.x)) > r || distance(p: y, b: Double(StartButton.center.y)) > r ){
                    print("out")
                }else{
                    state = 1
                    print("in")
                    StartButton.isHidden = true
                    buttonArray[i-1].isHidden = false
                }
            }
            
        }
    }
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cursor.center = CGPoint(x: 187.0, y: 406.0)
        print(cursor.center)
        /*cursor.layer.borderWidth = 1
        cursor.layer.masksToBounds = false
        cursor.layer.borderColor = UIColor.black.cgColor
        cursor.layer.cornerRadius = cursor.frame.height/2
        cursor.clipsToBounds = true
        */
        let yourImage: UIImage = UIImage(named: "Cursor.png")!
        cursor.image = yourImage
        
        StartButton.layer.borderWidth = 1
        StartButton.layer.borderColor = UIColor.black.cgColor
        
        sceneView.delegate = contentUpdater
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        buttonArray.append(Button1)
        buttonArray.append(Button2)
        buttonArray.append(Button3)
        buttonArray.append(Button4)
        buttonArray.append(Button5)
        buttonArray.append(Button6)
        buttonArray.append(Button7)
        buttonArray.append(Button8)
        buttonArray.append(Button9)
        buttonArray.append(Button10)
        buttonArray.append(Button11)
        buttonArray.append(Button12)
        buttonArray.append(Button13)
        buttonArray.append(Button14)
        buttonArray.append(Button15)
        buttonArray.append(Button16)
        buttonArray.append(Button17)
        buttonArray.append(Button18)
        buttonArray.append(Button19)
        buttonArray.append(Button20)
        buttonArray.append(Button21)
        buttonArray.append(Button22)
        buttonArray.append(Button23)
        buttonArray.append(Button24)
        buttonArray.append(Button25)
        buttonArray.append(Button26)
        buttonArray.append(Button27)
        buttonArray.append(Button28)
        
        
        
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
            .faceGeometry: Mask(geometry: maskGeometry, movingType: 0),
            .overlayModel: Mask(geometry: maskGeometry, movingType: 1),
            .blendShapeModel: Mask(geometry: maskGeometry, movingType: 2)
        ]
        
        var myMask = nodeForContentType[.faceGeometry] as! Mask
        myMask.viewController = self
        
        myMask = nodeForContentType[.overlayModel] as! Mask
        myMask.viewController = self
        
        myMask = nodeForContentType[.blendShapeModel] as! Mask
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
