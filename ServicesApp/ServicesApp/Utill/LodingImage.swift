//
//  LodingImage.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import Foundation
import UIKit
let imageCache = NSCache<NSString,UIImage>()
extension UIImageView{
    func lodingImage(_ urlString:String){
        if let cacheImage = imageCache.object(forKey: urlString as NSString){
            self.image = cacheImage
        }else{
            if let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url){
                        DispatchQueue.main.async {
                            if let downloadedImage = UIImage(data: data){
                                imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                                self.image = downloadedImage
                            }
                        }
                    }
                }
            }
        }
    }
}
