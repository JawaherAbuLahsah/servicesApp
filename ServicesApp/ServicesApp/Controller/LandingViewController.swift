//
//  ViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 20/05/1443 AH.
//

import UIKit
import Lottie
class LandingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var informationCollectionView: UICollectionView!{
        didSet{
            informationCollectionView.delegate = self
            informationCollectionView.dataSource = self
        }
    }
    // MARK: - Outlet
    @IBOutlet weak var languageView: UIView!{
        didSet{
            languageView.layer.cornerRadius = 40
            languageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            languageView.layer.shadowRadius = 30
            languageView.layer.shadowOpacity = 0.5
        }
    }
//    @IBOutlet weak var infoImage: UIImageView!{
//        didSet{
//            if UserDefaults.standard.object(forKey: "currentLanguage") as? String == "ar"{
//                infoImage.image = UIImage(named: "a")
//            }else{
//                infoImage.image = UIImage(named: "e")
//            }
//        }
//    }
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
            arabicButton.layer.borderColor = UIColor(named: "Color-1")?.cgColor
            arabicButton.setTitle("ع", for: .normal)
            arabicButton.layer.borderWidth = 5
            arabicButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var englishButton: UIButton!{
        didSet{
            englishButton.layer.borderColor = UIColor(named: "Color-1")?.cgColor
            englishButton.setTitle("E", for: .normal)
            englishButton.layer.borderWidth = 5
            englishButton.layer.cornerRadius = 10
        }
    }
    
    // MARK: - Definitions
    var arabicButtonCenter:CGPoint!
    var englishButtonCenter:CGPoint!
    var lang:String?
    var isClick = true
    var informations = [Information(animationView: "choose", info: "choose".localizes),Information(animationView: "send", info: "sendService".localizes),Information(animationView: "conversation", info: "conversation".localizes)]
    var currentPage = 0
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arabicButtonCenter = arabicButton.center
        englishButtonCenter = englishButton.center
        arabicButton.center = languageButton.center
        englishButton.center = languageButton.center
        
        
        startTimer()
        
    }
    
    // MARK: - Change language action
    @IBAction func changeLanguage(_ sender: UIButton) {
        if sender.tag == 0 {
            lang = "ar"
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//            infoImage.image = UIImage(named: "a")
        }else{
            lang = "en"
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
//            infoImage.image = UIImage(named: "e")
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
    
    // MARK: - Animation > to show button language
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
    
    
    @objc func scrollToNextCell(_ timer1: Timer){
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)

           //get current content Offset of the Collection view
           let contentOffset = informationCollectionView.contentOffset;

           if informationCollectionView.contentSize.width <= informationCollectionView.contentOffset.x + cellSize.width
           {
               informationCollectionView.scrollRectToVisible(CGRect(x: 0, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
               currentPage = 0
           } else {
               informationCollectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
               currentPage = currentPage + 1
           }
        pageControl.currentPage = currentPage
        }
        func startTimer() {

            _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true);


        }
    
}
extension LandingViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return informations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellInfo", for: indexPath) as! ServiceCollectionViewCell
        
        cell.setup(informations[indexPath.row])
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let width = scrollView.frame.width
//        currentPage = Int(scrollView.contentOffset.x / width)
//        pageControl.currentPage = currentPage
    }
}
