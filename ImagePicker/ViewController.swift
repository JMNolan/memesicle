//
//  ViewController.swift
//  ImagePicker
//
//  Created by John Nolan on 1/2/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topText: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    //formatting the text boxes used to create the meme
    let memeTextAttributes: [String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: (UIFont.init(name: "HelveticaNeue-CondensedBlack", size: 40))!,
        NSAttributedStringKey.strokeWidth.rawValue: 0,
        NSAttributedStringKey.backgroundColor.rawValue: UIColor.clear
    ]
    
    //property template for generating new meme images
    struct Meme {
        let topText: String
        let bottomtext: String
        let selectedImage: UIImage
        let memeImage: UIImage
        
        init (topText: String, bottomText: String, selectedImage: UIImage, memeImage: UIImage){
            self.topText = topText
            self.bottomtext = bottomText
            self.selectedImage = selectedImage
            self.memeImage = memeImage
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
        }
        dismiss(animated: true, completion: nil)
    }
    
    //get the height of the keyboard to determine how far up to move the view when editing the bottom text field
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //get notifications to use as a trigger for moving the view up when editing the bottom text in the meme
    func subscribeToKeyboardShowNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func subscribeToKeyboardHideNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //no longer needed once text is entered completely
    func unsubscribeToKeyboardShowNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeToKeyboardHideNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func save(){
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, selectedImage: imagePickerView.image!, memeImage: generateMemeImage())
    }
    
    func generateMemeImage() -> UIImage{
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memeImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topText.text = "TOP"
        topText.textAlignment = .center
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.text = "BOTTOM"
        bottomText.textAlignment = .center
        bottomText.defaultTextAttributes = memeTextAttributes

        imagePicker.delegate = self
        //cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.subscribeToKeyboardShowNotifications()
        self.subscribeToKeyboardHideNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeToKeyboardShowNotifications()
        self.unsubscribeToKeyboardHideNotifications()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow (notification: NSNotification){
        
        imagePickerView.frame.origin.y -= (getKeyboardHeight(notification: notification))
    }
    
    @objc func keyboardWillHide (notification: NSNotification){
        imagePickerView.frame.origin.y += (getKeyboardHeight(notification: notification))
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
}

