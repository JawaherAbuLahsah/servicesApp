//
//  HamburgerMenuViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 01/06/1443 AH.
//

import UIKit
import Firebase
protocol HamburgerMenuControllerDelegate{
    func hideHamburgerMenu()
}
class HamburgerMenuViewController: UIViewController {
    @IBOutlet weak var arButton: UIButton!{
        didSet{
            arButton.layer.borderColor = UIColor(named: "Color-1")?.cgColor
            arButton.setTitle("ع", for: .normal)
            arButton.layer.borderWidth = 5
            arButton.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var enButton: UIButton!{
        didSet{
            enButton.layer.borderColor = UIColor(named: "Color-1")?.cgColor
            enButton.setTitle("E", for: .normal)
            enButton.layer.borderWidth = 5
            enButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var editButton: UIButton!{
        didSet{
            editButton.setTitle("edit".localizes, for: .normal)
            editButton.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var languageButton: UIButton!{
        didSet{
        languageButton.setTitle("language".localizes, for: .normal)
    languageButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var logoutButton: UIButton!
    var delegate :HamburgerMenuControllerDelegate?
    var lang:String?
    var isClick = true
    var arabicButtonCenter:CGPoint!
    var englishButtonCenter:CGPoint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        arabicButtonCenter = arButton.center
        englishButtonCenter = enButton.center
        arButton.center = languageButton.center
        enButton.center = languageButton.center
    }
    
    @IBAction func changeLanguage(_ sender: UIButton) {
        if sender.tag == 0 {
            lang = "ar"
        }else{
            lang = "en"
        }
        if let lang = lang{
           
            UserDefaults.standard.setValue([lang], forKey: "AppleLanguages")
            UserDefaults.standard.set(lang, forKey: "currentLanguage")
            Bundle.setLanguage(lang)
            exit(0)
            }
        }
    @IBAction func showLanguages(_ sender: Any) {
        if isClick{
            UIView.animate(withDuration: 0.3) {
                self.arButton.alpha = 1
                self.enButton.alpha = 1
                self.arButton.center = self.arabicButtonCenter
                self.enButton.center = self.englishButtonCenter
            }
            isClick = false
        }else{
            UIView.animate(withDuration: 0.3) {
                self.arButton.alpha = 0
                self.enButton.alpha = 0
                self.arButton.center = self.languageButton.center
                self.enButton.center = self.languageButton.center
            }
            isClick = true
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandingNavigationController") as? UINavigationController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } catch  {
            print("ERROR in signout",error.localizedDescription)
        }
    }
    
}
