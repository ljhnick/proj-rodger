//
//  ViewController.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 3/21/22.
//

import UIKit

class WorldViewController: UIViewController {

    var gravity = true
    
    
    @IBAction func changeGravity(_ sender: Any) {
        gravity.toggle()
        
        App.state.scene.physicsWorld.gravity = (gravity) ? CGVector(dx: 0, dy: -9.8) : CGVector.zero
    }
    
    @IBAction func addVelocity(_ sender: UIButton) {
        App.state.addVelocity.toggle()
        sender.tintColor = (App.state.addVelocity) ? .systemRed : .systemBlue
    }
    
    @IBAction func makeStable(_ sender: UIButton) {
        App.state.makeStable.toggle()
        sender.tintColor = (App.state.makeStable) ? .systemRed : .systemBlue
    }
    
    @IBAction func changeBoundary(_ sender: Any) {
        App.state.scene.physicsBody = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        App.state.worldViewController = self
    }

}
