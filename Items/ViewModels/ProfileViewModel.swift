//
//  ProfileViewModel.swift
//  Items
//
//  Created by Kamil Skrzyński on 17/04/2021.
//

import Foundation
import SwiftUI

final class ProfileViewModel: ObservableObject {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Published private(set) var itemViewModels: [ProfileItemViewModel] = []
    @Published var loginSignupPushed = false
    @Published var itemsBoughtPushed = false
    @Published var termsPushed = false
    @Published var usagePushed = false
    @Published var showLogoutAlert = false
    let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func onAppear() {
        buildItems()
    }
    
    private func buildItems() {
        itemViewModels = [
            .init(name: authService.currentUser?.email ?? "Create Account", image: "person.fill", type: .account),
            .init(name: "Data", image: "doc.fill", type: .usage),
            .init(name: "Bought", image: "bag.fill", type: .bought),
            .init(name: "Switch to \(isDarkMode ? "Light" : "Dark") Mode", image: "lightbulb.fill", type: .mode),
            .init(name: "Privacy Policy", image: "shield.lefthalf.fill", type: .privacy)
        ]
        
        if authService.currentUser?.email != nil {
            itemViewModels += [.init(name: "Logout", image: "figure.walk", type: .logout)]
        }
    }
    
    func tappedItem(at index: Int) {
        switch itemViewModels[index].type {
        case .mode:
            isDarkMode = !isDarkMode
            buildItems()
        case .bought:
            itemsBoughtPushed = true
        case .account:
            guard authService.currentUser?.email == nil else { return }
            loginSignupPushed = true
        case .logout:
            showLogoutAlert = true
        case .privacy:
            termsPushed = true
        case .usage:
            usagePushed = true
        default:
            break
        }
    }
    
    let title = "Profile"
    let subtitle = "Manage your profile"
    let chevron = "chevron.right"
}
