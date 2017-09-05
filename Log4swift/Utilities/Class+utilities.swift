//
//  ClassInfo.swift
//  Log4swift
//
//  Created by Igor Makarov on 17/05/2017.
//  Copyright © 2017 jerome. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

internal struct ClassInfo {
  let classObject: AnyClass
  
  init(_ classObject: AnyClass) {
    self.classObject = classObject
  }
  
  var superclassInfo: ClassInfo? {
    if let superclassObject: AnyClass = class_getSuperclass(self.classObject) {
      return ClassInfo(superclassObject)
    }
    return nil
  }

  public func isSubclass(of cls: ClassInfo) -> Bool {
    if let superclass = self.superclassInfo {
      return superclass.classObject == cls.classObject || superclass.isSubclass(of: cls)
    }
    return false
  }
  
  public var subclasses: [ClassInfo] {
    var subclassList = [ClassInfo]()
    
    var count = UInt32(0)
    let classList = objc_copyClassList(&count)!
    
    for i in 0..<Int(count) {
      let classInfo = ClassInfo(classList[i])
      if classInfo.isSubclass(of: self) {
        subclassList.append(classInfo)
      }
    }
    
    return subclassList
  }
}

