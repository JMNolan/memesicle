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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fromAlbumButton: UIBarButtonItem!
    @IBOutlet weak var fromCameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var keyboardHeight: CGFloat = 0.0
    let imagePicker = UIImagePickerController()
    var activeField: UITextField!
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func save(){
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, selectedImage: imagePickerView.image!, memeImage: generateMemeImage())
    }
    
    func generateMemeImage() -> UIImage{
        toolbar.isHidden = true
        shareButton.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        toolbar.isHidden = false
        shareButton.isHidden = false
        return memeImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.unsubscribeToKeyboardNotifications()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        
        activeField = textField
        keyboardActive = true
        becomeFirstResponder()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        
//        activeField = nil
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
//        if activeField == bottomText{
//            imagePickerView.image = generateMemeImage()
//            save()
//            topText.text = ""
//            bottomText.text = ""
//        }
        return true
    }
    
    @objc func keyboardWillShow (notification: NSNotification){
        if activeField == bottomText{
            keyboardHeight = getKeyboardHeight(notification: notification)
            scrollView.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide (notification: NSNotification){
        if keyboardActive == false{
            scrollView.frame.origin.y += keyboardHeight
        }
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
    
    @IBAction func shareImageButton(_ sender: UIButton){
        let image = generateMemeImage()
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        //UIActivityViewControllerCompletionWithItemsHandler = {(activityViewController!, completed: Bool)
        }
    }
    
    func noCamera(){
        let noCameraAlert = UIAlertController(title: "No Camera", message: "Sorry this device has no camera.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        noCameraAlert.addAction(okAction)
        present(noCameraAlert, animated: true, completion: nil)
    }
}

