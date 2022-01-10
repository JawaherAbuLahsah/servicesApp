//
//  ViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 20/05/1443 AH.
//

import UIKit

class LandingViewController: UIViewController {
    

    @IBOutlet weak var infoImage: UIImageView!{
        didSet{
            if UserDefaults.standard.object(forKey: "currentLanguage") as? String == "ar"{
                infoImage.image = UIImage(named: "a")
            }else{
                infoImage.image = UIImage(named: "e")
            }
        }
    }
    @IBOutlet weak var languageButton: UIButton!{
        didSet{
            languageButton.setTitle("language".localizes, for: .normal)
            languageButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var signInButton: UIButton!{
        didSet{
            signInButton.setTitle("signIn".localizes, for: .normal)
            signInButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var arabicButton: UIButton!{
        didSet{
            arabicButton.layer.borderColor = UIColor.systemTeal.cgColor
            arabicButton.layer.borderWidth = 5
            arabicButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var englishButton: UIButton!{
        didSet{
            englishButton.layer.borderColor = UIColor.systemTeal.cgColor
            englishButton.layer.borderWidth = 5
            englishButton.layer.cornerRadius = 10
        }
    }
    
    var arabicButtonCenter:CGPoint!
    var englishButtonCenter:CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        arabicButtonCenter = arabicButton.center
        englishButtonCenter = englishButton.center
        arabicButton.center = languageButton.center
        englishButton.center = languageButton.center
    }
    
    var lang:String?
    @IBAction func changeLanguage(_ sender: UIButton) {
        if sender.tag == 0 {
            lang = "ar"
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            infoImage.image = UIImage(named: "a")
        }else{
            lang = "en"
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            infoImage.image = UIImage(named: "e")
        }
        if let lang = lang{
            UserDefaults.standard.set(lang, forKey: "currentLanguage")
            Bundle.setLanguage(lang)
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
            }
        }
    }
    var isClick = true
    @IBAction func showView(_ sender: Any) {
        if isClick{
            UIView.animate(withDuration: 0.3) {
                self.arabicButton.alpha = 1
                self.englishButton.alpha = 1
                self.arabicButton.center = self.arabicButtonCenter
                self.englishButton.center = self.englishButtonCenter
            }
            isClick = false
        }else{
            UIView.animate(withDuration: 0.3) {
                self.arabicButton.alpha = 0
                self.englishButton.alpha = 0
                self.arabicButton.center = self.languageButton.center
                self.englishButton.center = self.languageButton.center
            }
            isClick = true
        }
    }
    
}
