//
//  textFieldDelegate.swift
//  ImagePicker
//
//  Created by John Nolan on 1/10/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import Foundation
import UIKit

class textFieldDelegate: NSObject, UITextFieldDelegate{
    
    var activeField: UITextField!
    
    func textFieldDidBeginEditing(textField: UITextField){
        
        activeField = textField
        
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        
        activeField = textField
        textField.resignFirstResponder()
        
    }
    
}

