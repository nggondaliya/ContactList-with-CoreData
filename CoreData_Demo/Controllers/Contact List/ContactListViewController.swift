//
//  ContactListViewController.swift
//  CoreData_Demo
//
//  Created by Nirav Gondaliya on 02/03/21.
//  Copyright © 2021 Nirav Gondaliya. All rights reserved.
//

import UIKit

class ContactListViewController: UIViewController{
    
    var contacts : [TblUser] {
        get {
            return (TblUser.mr_findAll() as? [TblUser])!.sorted { (a, b) -> Bool in
                return a.fname! < b.fname!
            }
        }
    }
    var filteredContacts: [TblUser] = []
    var namesArray = [String]()
    var contactNamesDictionary = [String: [String]]()
    var indexLettersInContactsArray = [String]()
    
    let indexLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    @IBOutlet weak var tblList: UITableView!
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createNameDictionary()
    }
    
    func initialSetup() {
        
        self.tblList.delegate = self
        self.tblList.dataSource = self
        self.tblList.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false

            self.tblList.tableHeaderView = controller.searchBar

            return controller
        })()
    }
    
    func createNameDictionary() {
    
        namesArray.removeAll()
        for i in contacts {
            let fullName = (i.fname ?? "") + " " + (i.lname ?? "")
            namesArray.append(fullName)
        }
        
        contactNamesDictionary.removeAll()
        for name in namesArray {
            
            let firstLetter = "\(name[name.startIndex])"
            let uppercasedLetter = firstLetter.uppercased()
            
            if var separateNamesArray = contactNamesDictionary[uppercasedLetter] {
                separateNamesArray.append(name)
                contactNamesDictionary[uppercasedLetter] = separateNamesArray
            } else {
                contactNamesDictionary[uppercasedLetter] = [name]
            }
        }
        
        indexLettersInContactsArray = [String](contactNamesDictionary.keys)
        indexLettersInContactsArray = indexLettersInContactsArray.sorted()
        
        self.tblList.reloadData()
    }
    
    @IBAction func onCLickBtnAdd(_ sender: Any) {
        self.gotoAddContact()
    }
}

//MARK:
extension ContactListViewController {
    func gotoContactDetail(contact : TblUser) {
        let contactDetailVC = ContactDetailsViewController(nibName: "ContactDetailsViewController", bundle: nil)
        contactDetailVC.contact = contact
        self.navigationController?.pushViewController(contactDetailVC, animated: true)
    }
    
    func gotoAddContact() {
        let addContactVC = AddContactViewController(nibName: "AddContactViewController", bundle: nil)
        addContactVC.modalPresentationStyle = .fullScreen
        self.present(addContactVC, animated: true)
    }
}

//MARK: UITableViewDelegate & UITableViewDataSource
extension ContactListViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = Int()
        
        if resultSearchController.isActive && resultSearchController.searchBar.text != "" {
            count = 1
        } else {
            count = contactNamesDictionary.keys.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        
        if resultSearchController.isActive && resultSearchController.searchBar.text != "" {
            count = filteredContacts.count
        } else {
            let letter = indexLettersInContactsArray[section]
            
            if let names = contactNamesDictionary[letter] {
                count = names.count
            }
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        
        var text = String()
        
        if resultSearchController.isActive && resultSearchController.searchBar.text != "" {
            
            let contact = filteredContacts[indexPath.row]
            text = "\(contact.fname?.capitalized ?? "") \(contact.lname?.capitalized ?? "")"
            
        }else {
            
            let letter = indexLettersInContactsArray[indexPath.section]
            if var names = contactNamesDictionary[letter.uppercased()] {
                names = names.sorted()
                text = names[indexPath.row]
            }
        }
        
        cell.lblName.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        var rowNumber = indexPath!.row
        for i in 0..<indexPath!.section {
            rowNumber += self.tblList.numberOfRows(inSection: i)
        }
        
        var selectedContact = TblUser()
        
        if resultSearchController.isActive && resultSearchController.searchBar.text != ""  {
            selectedContact = filteredContacts[rowNumber]
        }else {
            selectedContact = contacts[rowNumber]
        }
        
        self.gotoContactDetail(contact: selectedContact)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionTitle = String()
        
        if resultSearchController.isActive && resultSearchController.searchBar.text != "" {
            sectionTitle = ""
        } else {
            sectionTitle = indexLettersInContactsArray[section]
        }
        
        return sectionTitle
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexLetters
    }
}

//MARK: UISearchResultDelegate
extension ContactListViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContacts(text: searchController.searchBar.text!)
    }
    
    func filterContacts(text: String, scope: String = "All") {
        
        filteredContacts = contacts.filter({ (contact) -> Bool in
            
            let fullName = "\(contact.fname?.lowercased() ?? "") \(contact.lname?.lowercased() ?? "")"
            return fullName.contains(text.lowercased())
        })
        
        self.tblList.reloadData()
    }
}
