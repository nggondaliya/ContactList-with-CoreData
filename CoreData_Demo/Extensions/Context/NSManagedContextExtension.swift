//
//  NSManagedContextExtension.swift
//  CoreData_Demo
//
//  Created by Nirav Gondaliya on 02/03/21.
//  Copyright © 2021 Nirav Gondaliya. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord

extension NSManagedObjectContext{
    func saveToDb(showError:Bool,completionHandler:((Bool,NSError?)->())?=nil) {
        self.mr_saveToPersistentStore { (contextDidSave, dbError) in
            if !contextDidSave && dbError != nil{
                    print("Error occured while storing data!")
                if let completionHandler = completionHandler {
                    completionHandler(false, dbError as NSError?)
                }
            }else{
                if let completionHandler = completionHandler {
                    completionHandler(true, nil)
                }
            }
        }
    }
}
