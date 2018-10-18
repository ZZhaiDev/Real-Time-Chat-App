//
//  LoginController+handlers.swift
//  Real-Time-Chat-App
//
//  Created by Zijia Zhai on 10/15/18.
//  Copyright © 2018 cognitiveAI. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result: AuthDataResult?, error) in
            if error != nil{
                print(error!)
                return
            }
            
            guard let uid = result?.user.uid else{
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("images/\(imageName).png")
            print("111111")
            if let uploadData = self.profileImageView.image!.jpegData(compressionQuality: 0.8) {
                print(uploadData.description)
                print(uploadData)
                print("1111112")
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    print("1111113")
                    if let error = error {
                        print("1111114")
                        print(error)
                        return
                    }
                    print("1111115")
                    storageRef.downloadURL(completion: { (url, err) in
                        if err != nil{
                            print(err!)
                            return
                        }
                        if let profileImageUrl = url?.absoluteString{
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserIntoDatabase(uid: uid, values: values as [String : AnyObject])
                        }
                    })
                })
            }
        }
    }
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]){
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err!)
                return
            }
            print("Saved user successfully into Direbase DB")
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @objc func handleSelectedProfileImageView(){
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
