//
//  ViewController.swift
//  Real-Time-Chat-App
//
//  Created by Zijia Zhai on 10/10/18.
//  Copyright © 2018 cognitiveAI. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }

    @objc func handleLogout(){
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    
}

