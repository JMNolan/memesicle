//
//  ViewController.swift
//  Memesicle
//
//  Created by John Nolan on 1/2/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var fromCameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var keyboardHeight: CGFloat = 0.0
    let imagePicker = UIImagePickerController()
    var activeTextField: UITextField!
    var keyboardActive: Bool!

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
        shareButton.isEnabled = true
        bottomText.isEnabled = true
        topText.isEnabled = true
        imagePickerView.image = image
        imagePickerView.contentMode = .scaleAspectFit
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        dismiss(animated: true, completion: nil)
    }
    
    //get the height of the keyboard to determine how far up to move the view when editing the bottom text field
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //get notifications to use as a trigger for moving the view up when editing the bottom text in the meme
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //no longer needed once text is entered completely
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // dismiss the image picker after user selects image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //create a meme using the information on the screen after hiding the toolbar and buttons on the screen. Then add the buttons and toolbar back after the meme is generated
    func generateMemeImage() -> UIImage{
        toolbar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        toolbar.isHidden = false
        return memeImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //format the two text fields
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        topText.text = ""
        bottomText.text = ""
        topText.delegate = self
        bottomText.delegate = self
        imagePicker.delegate = self
        topText.isEnabled = false
        bottomText.isEnabled = false        
        //check for a camera on the device and disable the camera button if there is not one
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            fromCameraButton.isEnabled = false
        }
        
        //enable or disable the share button according to whether or not the user has selected an image
        if imagePickerView.image == nil{
            shareButton.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //prepare for the keyboard to appear and give the app access to that info
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //turn off access to the keyboard info
        self.unsubscribeToKeyboardNotifications()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        //set active text field to make sure view only shifts when the keyboard is being used on the bottom text field
        activeTextField = textField
    }
    
    //keyboard disappears when the user presses enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    //moves the view up when the keyboard appears to keep the text field visible
    @objc func keyboardWillShow (notification: NSNotification){
        if activeTextField == bottomText{
            view.frame.origin.y -= getKeyboardHeight(notification: notification)
        }
    }
    
    //moves the view down when the keyboard is dismissed to show the full view again
    @objc func keyboardWillHide (notification: NSNotification){
        if activeTextField == bottomText{
        view.frame.origin.y += getKeyboardHeight(notification: notification)
        }
    }
    
    //user presses album button and selects a photo from their library
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    //user presses camera button to take a picture with device camera to use that picture as the base of their meme
    @IBAction func pickAnImageFromCamera(_ sender: Any){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
    }
    
    //returns the app back to original state to begin making a new meme
    @IBAction func cancelEverything(_ sender: UIBarButtonItem) {
        imagePickerView.image = nil
        topText.text = nil
        bottomText.text = nil
        topText.isEnabled = false
        bottomText.isEnabled = false
        shareButton.isEnabled = false
    }
    
    //user presses share button to show options for sharing or saving in several ways
    @IBAction func shareImageButton(_ sender: UIBarButtonItem){
        let image = generateMemeImage()
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = {(activity, success, items, error) in
            activityViewController.dismiss(animated: true, completion: nil)
        }
    }
    
}

