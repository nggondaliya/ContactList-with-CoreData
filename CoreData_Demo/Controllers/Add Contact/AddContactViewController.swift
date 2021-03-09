//
//  AddContactViewController.swift
//  CoreData_Demo
//
//  Created by Nirav Gondaliya on 02/03/21.
//  Copyright © 2021 Nirav Gondaliya. All rights reserved.
//

import UIKit
import MagicalRecord

class AddContactViewController: UIViewController {

    let defaultContext = NSManagedObjectContext.mr_default()
    
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var txtCompany: UITextField!
    
    @IBOutlet var stackPhones: UIStackView!
    @IBOutlet var stackEmails: UIStackView!
    @IBOutlet weak var btnAddPhoto: UIButton!
    @IBOutlet weak var imgUser: UIImageView!

    let imagePicker = UIImagePickerController()
    
    var phoneArray : [String] = []
    var emailArray : [String] = []
    
    enum TextFieldType {
        case phone
        case email
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onClickBtnDone(_ sender: Any) {
        self.validateData()
    }
    
    @IBAction func onClickBtnCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onClickBtnAddPhone(_ sender: UIButton) {
        self.addTextField(type: .phone)
    }
    
    @IBAction func onClickBtnAddEmail(_ sender: UIButton) {
        self.addTextField(type: .email)
    }
    
    @IBAction func onClickBtnAddPhoto(_ sender: UIButton) {
        self.takePhotoFromGallary()
    }
    
    func saveData() {

        let userData = TblUser.mr_createEntity(in: defaultContext)
        userData?.fname = self.txtFName.text ?? ""
        userData?.lname = self.txtLName.text ?? ""
        userData?.company = self.txtCompany.text ?? ""
        userData?.emails = self.emailArray as NSObject
        userData?.phones = self.phoneArray as NSObject
        
        if (imgUser.image != nil) {
            userData?.profileImage = imgUser.image?.pngData()
        }
        
        defaultContext.mr_saveToPersistentStore { (status, err) in
            self.dismiss(animated: true)
        }
    }
    
    func addTextField(type : TextFieldType) {
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: .zero, height: 40))
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)

        switch type {
        case .phone:
            textField.placeholder = "987 987 9898"
            textField.keyboardType = .phonePad
            self.stackPhones.addArrangedSubview(textField)
            break
        
        case .email:
            textField.placeholder = "xyz@apple.com"
            textField.keyboardType = .emailAddress
            self.stackEmails.addArrangedSubview(textField)
            break
        }
        
        textField.becomeFirstResponder()
    }
}

//MARK: UIImagePickerControllerDelegate
extension AddContactViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func takePhotoFromGallary() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .savedPhotosAlbum
            
            self.present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        self.imgUser.image = image
    }
}

//MARK: Data Validation
extension AddContactViewController {
    
    func validateData() {
        
        guard !self.txtFName.text!.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.showAlert(message: "Please enter first name.")
            return
        }
        
        guard !self.txtLName.text!.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.showAlert(message: "Please enter last name.")
            return
        }
        
        self.phoneArray = []
        
        for view in self.stackPhones.arrangedSubviews {
            if let textField = view as? UITextField {
                
                if ((textField.text ?? "").isEmpty)  {
                    
                }else if isValidPhoneNumber(textField.text ?? "") {
                    self.phoneArray.append(textField.text!)
                    
                }else {
                    self.showAlert(message: "Please enter valid 10 digit phone number.")
                    return
                }
            }
        }
        
        if self.phoneArray.count < 1 {
            self.showAlert(message: "Please enter phone number")
            return
        }
        
        self.emailArray = []
        
        for view in self.stackEmails.arrangedSubviews {
            if let textField = view as? UITextField {
                
                if ((textField.text ?? "").isEmpty)  {
                    
                }else if isValidEmail(textField.text ?? "") {
                    self.emailArray.append(textField.text!)
                    
                }else {
                    self.showAlert(message: "Please enter valid email address.")
                    return
                }
            }
        }
        
        //Save data
        saveData()
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        
        if phoneNumber.count < 10 {
            return false
        }
        
        let regex = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        let result =  phoneTest.evaluate(with: phoneNumber)
        return result
    }
    
    func isValidEmail(_ email: String) -> Bool {
        
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) == nil {
                return false
            }
        } catch {
            return false
        }
        return true
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "OK", style: .default)
        alert.addAction(btnOk)
        
        self.present(alert, animated: true)
    }
}


