//
//  InterfaceController.swift
//  iOS+watchOS-swift-carthage WatchKit Extension
//
//  Created by Jérôme Duquennoy on 04/08/2018.
//  Copyright © 2018 fr.duquennoy. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
