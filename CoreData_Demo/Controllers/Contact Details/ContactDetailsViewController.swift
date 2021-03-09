//
//  ContactDetailsViewController.swift
//  CoreData_Demo
//
//  Created by Nirav Gondaliya on 02/03/21.
//  Copyright © 2021 Nirav Gondaliya. All rights reserved.
//

import UIKit
import MagicalRecord
import MessageUI

class ContactDetailsViewController: UIViewController {

    var contact = TblUser()
    
    @IBOutlet weak var lblNameSortForm: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblOcupation: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var tblDetails: UITableView!
    
    var phoneArray : [String]?
    var emailArray : [String]?
    var combinedArray : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (contact.profileImage != nil) {
            self.imgUser.image = UIImage(data: contact.profileImage!)
            self.lblNameSortForm.isHidden = true
        }
    }
    
    func initialSetup() {

        self.lblNameSortForm.text = contact.fname![contact.fname!.startIndex].uppercased() + contact.lname![contact.lname!.startIndex].uppercased()
        self.lblFullName.text = contact.fname! + " " + contact.lname!
        self.lblOcupation.text = contact.company ?? ""
        
        phoneArray = contact.phones as? [String]
        emailArray = contact.emails as? [String]
        combinedArray = phoneArray! + emailArray!

        self.tblDetails.register(UINib(nibName: "ContactDetailCell", bundle: nil), forCellReuseIdentifier: "ContactDetailCell")
        self.tblDetails.dataSource = self
        self.tblDetails.delegate = self
        
        self.tblDetails.reloadData()
    }
    
    @IBAction func onClickBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBtnEdit(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete contact?", message: "", preferredStyle: .actionSheet)
        
        let btnDelete = UIAlertAction(title: "Delete",
                                      style: .destructive) { (action) in
                                        self.deleteContact()
        }
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(btnDelete)
        alert.addAction(btnCancel)
        
        self.present(alert, animated: true)
    }
    
    @IBAction func onClickBtnMessage(_ sender: UIButton) {
        if phoneArray?.count ?? 0 > 0 {
            sendText(phoneNumbers: phoneArray!)
        }
    }
    
    func deleteContact() {
        self.contact.mr_deleteEntity()
        NSManagedObjectContext.mr_default().saveToDb(showError: true) { (status, err) in
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: Table Delegate & DataSource
extension ContactDetailsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return combinedArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailCell") as! ContactDetailCell
        let detail = combinedArray?[indexPath.row]
        
        if indexPath.row < self.phoneArray?.count ?? 0 {
            cell.lblTitle.text = "mobile"
        }else {
            cell.lblTitle.text = "mail"
        }
        
        cell.lblSubTitle.text = detail
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.phoneArray?.count ?? 0 {
            self.makeAPhoneCall(number: combinedArray![indexPath.row])
        }else {
            self.sendEmail(recipient: combinedArray![indexPath.row])
        }
    }
}

//MARK:
extension ContactDetailsViewController : MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    func makeAPhoneCall(number: String) {
        guard let url = URL(string: "tel://\(number)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func sendText(phoneNumbers: [String]) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.recipients = phoneNumbers
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
    
    
    private func sendEmail(recipient: String) {
    
       if MFMailComposeViewController.canSendMail() {
            
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
        
            mailComposerVC.setToRecipients([recipient])
            mailComposerVC.setSubject("I want to hire Johnny Perdomo")
            mailComposerVC.setMessageBody("Johnny Perdomo is an awesome iOS developer, if I had my own tech company I would hire him on the spot. He would be the perfect candidate for the job because he’s a very skilled engineer, a talented designer, and always goes above and beyond when given tasks to do. He’s also a very productive programmer, getting more done in less time while developing safe, powerful code!", isHTML: false)
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    private func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
