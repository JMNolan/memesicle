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
    @IBOutlet weak var fromAlbumButton: UIBarButtonItem!
    @IBOutlet weak var fromCameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyboardHeight: CGFloat = 0.0
    let imagePicker = UIImagePickerController()
    var activeTextField: UITextField!
    var keyboardActive: Bool!
    var originalBottomInset: CGFloat!

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
    
//    func save(){
//        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, selectedImage: imagePickerView.image!, memeImage: generateMemeImage())
//    }
    
    //create a meme using the information on the screen after hiding the toolbar and buttons on the screen. Then add the buttons and toolbar back after the meme is generated
    func generateMemeImage() -> UIImage{
        toolbar.isHidden = true
        //shareButton.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        toolbar.isHidden = false
        //shareButton.isHidden = false
        return memeImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //format the two text fields
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        topText.delegate = self
        bottomText.delegate = self
        imagePicker.delegate = self
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
        //set active text field to make sure view only shifts when the keyboard is being used on the bottom text field and make keyboard appear
        activeTextField = textField
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField){
//    }
    
    //keyboard disappears when the user presses enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    //moves the view up when the keyboard appears to keep the text field visible
    @objc func keyboardWillShow (notification: NSNotification){
        originalBottomInset = scrollView.contentInset.bottom
        if activeTextField == bottomText{
            scrollView.contentInset.bottom = keyboardHeight
            keyboardHeight = getKeyboardHeight(notification: notification)
        }
    }
    
    //moves the view down when the keyboard is dismissed to show the full view again
    @objc func keyboardWillHide (notification: NSNotification){
        scrollView.contentInset.bottom = originalBottomInset
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
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
        }else{
            //handles the possibility that the device has no camera when the user presses the camera button
            noCamera()
        }
    }
    
    //user presses share button to show options for sharing or saving in several ways
    @IBAction func shareImageButton(_ sender: UIButton){
        let image = generateMemeImage()
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = {(activity, success, items, error) in
            activityViewController.dismiss(animated: true, completion: nil)
        }

    }
    
    //give the user a message if the device has not camera
    func noCamera(){
        let noCameraAlert = UIAlertController(title: "No Camera", message: "Sorry this device has no camera.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        noCameraAlert.addAction(okAction)
        present(noCameraAlert, animated: true, completion: nil)
    }
}

