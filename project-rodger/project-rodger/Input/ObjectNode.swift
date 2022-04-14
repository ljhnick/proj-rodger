//
//  ObjectNode.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/17/22.
//

import ARKit
import SpriteKit
import SceneKit

class ObjectNode: SKNode {
    var linkChildren = [LinkNode]()
    
    func update() {
        for link in linkChildren {
            link.update()
        }
    }
    
    func addALink(_ link: LinkNode) {
        linkChildren.append(link)
    }
    
    
}
