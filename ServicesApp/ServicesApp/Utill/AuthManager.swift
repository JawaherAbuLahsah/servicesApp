//
//  AuthManager.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 01/06/1443 AH.
//

//import Foundation
//import FirebaseAuth
//
//class AuthManager{
//    static let shared = AuthManager()
//    let auth = Auth.auth()
//    var verificationId: String?
//    func startAuth(phoneNumber:String, completion: @escaping (Bool)->Void){
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
//            guard let verificationId = verificationId,error == nil else{
//                completion(false)
//                return
//            }
//            self?.verificationId = verificationId
//            completion(true)
//        }
//    }
//    func verifyCode(smsCode:String, completion: @escaping (Bool)->Void){
//        guard let verificationId = verificationId else{
//            completion(false)
//            return
//        }
//        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
//        auth.signIn(with: credential) { result, error in
//            guard result != nil , error == nil else{
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//}
