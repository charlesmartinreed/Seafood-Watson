//
//  ViewController.swift
//  Seafood
//
//  Created by Charles Martin Reed on 8/9/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import VisualRecognitionV3

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //for IBM Watson
    let apikey = "Q4z8KGuXyyCLSECS7lwFjquo8cJO8MeaVtqrYi2wgaJl"
    let version = "2018-08-09"

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    //creating an empty array for the classification images returned by Watson
    var classificationResults: [String] = []
    
    //add UIImage picker controller
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //set imagePicker delegate
        imagePicker.delegate = self
        
    }

    //happens when the user picks an image from the library or camera roll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //show the image on the screen
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            //attempt a visual recognition of the image using your API key and the version (today's date)
            let visualRecognition = VisualRecognition(version: version, apiKey: apikey)
            
            //compressing the image down to 1% of its original size
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            //URL to documents directory
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            //preparing the image to be passed over to BlueMix and Watson
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileURL, options: [])
            print(fileURL)
            
            visualRecognition.classify(image: image, success: { (classifiedImages) in
                //holds the classes for our classified images after processing
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                //wipe out the previous results so we don't end up with false positives during our for-in loop
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                //array should now contain all the classifications for the image being evaluated
                print(self.classificationResults)
                
                if self.classificationResults.contains("hotdog") {
                    //best practice for updating the UI is getting back to the main thread so we're calling Grand Dispatch to handle this.
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hot dog confirmed!"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not dog! :("
                    }
                }
            })
            
            
        } else {
            
            print("There was an error picking the image")
        }
    }
    
    
   
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        //set the imagePicker and present it
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    

}

