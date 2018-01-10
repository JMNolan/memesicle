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
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imagePicker = UIImagePickerController()
    
    //formatting the text boxes used to create the meme
    let memeTextAttributes: [String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: (UIFont.init(name: "HelveticaNeue-CondensedBlack", size: 40))!,
        NSAttributedStringKey.strokeWidth.rawValue: -4,
        NSAttributedStringKey.backgroundColor.rawValue: UIColor.clear,
        
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
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePickerView.image = image
        imagePickerView.contentMode = .scaleAspectFit
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
        
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .center
        bottomText.textAlignment = .center

        imagePicker.delegate = self
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
        scrollView.frame.origin.y -= getKeyboardHeight(notification: notification)
        print(getKeyboardHeight(notification: notification))
    }
    
    @objc func keyboardWillHide (notification: NSNotification){
        print(getKeyboardHeight(notification: notification))
        scrollView.frame.origin.y += getKeyboardHeight(notification: notification)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
        }else{
            noCamera()
        }
    }
    
    func noCamera(){
        let noCameraAlert = UIAlertController(title: "No Camera", message: "Sorry this device has no camera.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        noCameraAlert.addAction(okAction)
        present(noCameraAlert, animated: true, completion: nil)
    }
}

