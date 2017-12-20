//
//  LoginViewController.swift
//  GroupThink
//
//  Created by Teddy Burns on 11/22/17.
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Spotify.instance.addObserver(self)
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Spotify.instance.isAuthenticated() {
            performSegue(withIdentifier: "LoginSegue", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openAuthPressed(_ sender: UIButton) {
        Spotify.instance.openLogin()
        self.performSegue(withIdentifier: "LoginSegue", sender: nil)
    }
    
    
    
}

extension LoginViewController: Observer {
    func notify() {
        if self.viewIfLoaded?.window != nil {
            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        }
    }
}

