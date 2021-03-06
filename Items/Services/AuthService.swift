//
//  AuthService.swift
//  Items
//
//  Created by Kamil Skrzyński on 02/05/2021.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func signInAnonymously(handler: @escaping (_ success: Bool) -> ())
    func linkAccount(email: String, password: String, handler: @escaping (_ success: Bool) -> ())
    func logout()
    func login(email: String, password: String)
    func createUser(userID: String, email: String, dateCreated: Date, isPro: Bool)
    func updateUserAfterLink(userID: String, email: String)
}

let db = Firestore.firestore()

final class AuthService: AuthServiceProtocol {
    
    // MARK: Properties
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isOnboardingWatched") private var isOnboardingToWatch = true
    @AppStorage("isSignedIn") private var isSignedIn = false
    @AppStorage("userID") private var userID = ""
    
    
    let currentUser = Auth.auth().currentUser
    
    private var users = db.collection("users")
    
    
    // MARK: Authentication functions
    
    func linkAccount(email: String, password: String, handler: @escaping (_ success: Bool) -> ()) {
        let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().currentUser?.link(with: emailCredential, completion: { authResult, error in
            if let error = error {
                print("Unable to link account with credential: \(error)")
                handler(false)
                return
            }
            else if let user = authResult?.user {
                Auth.auth().updateCurrentUser(user) { error in
                    if let error = error {
                        print("Unable to update current user in Database: \(error)")
                        handler(false)
                        return
                    }
                    //Good to go
                    let id = user.uid
                    self.updateUserAfterLink(userID: id, email: email)
                    handler(true)
                }
            }
        })
    }
    
    func signInAnonymously(handler: @escaping (_ success: Bool) -> ()) {
        Auth.auth().signInAnonymously { [self] authResult, error in
            if let error = error {
                print("Error singing in anonymously: \(error)")
                return
            }
            else {
                guard let user = authResult?.user else { return }
                self.isSignedIn = true
                let id = user.uid
                self.userID = id
                let suggestedCollections = [
                    Collection(collectionID: UUID().uuidString, userID: id, title: "Clothes", subtitle: "Expand your wardrobe", isSuggested: true),
                    Collection(collectionID: UUID().uuidString, userID: id, title: "Tech", subtitle: "Save your tech essentials", isSuggested: true),
                    Collection(collectionID: UUID().uuidString, userID: id, title: "Home", subtitle: "Elevate your home's design", isSuggested: true)
                ]
                
                self.createUser(userID: id, email: "anonymous", dateCreated: Date(), isPro: false)
                let image = UIImage(named: "Placeholder")!
                suggestedCollections.forEach { collection in
                    DataService.instance.createCollection(userID: id, title: collection.title, subtitle: collection.subtitle, dateCreated: Date(), image: UIImage(named: collection.title) ?? image, isSuggested: collection.isSuggested)
                    
                    print("Successfully created suggested collections")
                }
                print("Successfully signed in anonymously")
                handler(true)
                return
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
            self.isDarkMode = false
            self.isOnboardingToWatch = true
        }
        catch {
            print("Error logging out: \(error)")
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in to Database: \(error)")
                return
            }
            else {
                guard let user = authResult?.user else { return }
                UserDefaults.standard.setValue(user.uid, forKey: "userID")
                self.isSignedIn = true
                print("Successfully logged in with email \(email)")
                return
            }
        }
    }
    
    // MARK: Firestore functions
    func createUser(userID: String, email: String, dateCreated: Date, isPro: Bool) {
        users.document("\(userID)").setData(
            [
                "user_id": userID,
                "email": email,
                "date_created": Date(),
                "is_pro": isPro
            ]
        )
    }
    
    func updateUserAfterLink(userID: String, email: String) {
        users.document("\(userID)").updateData(["email": email])
    }
}
