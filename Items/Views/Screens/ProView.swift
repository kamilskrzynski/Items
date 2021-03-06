//
//  ProView.swift
//  Items
//
//  Created by Kamil Skrzyński on 17/04/2021.
//

import SwiftUI

struct ProView: View {
    
    @StateObject private var viewModel = ProViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedOption = 0
    
    
    var proBenefits: some View {
        VStack {
            ForEach(viewModel.benefits, id: \.self) { benefit in
                HStack {
                    ZStack {
                        ZStack {
                            Image(systemName: viewModel.benefitImageName)
                                .foregroundColor(.appColor)
                        }
                    }
                    Text(benefit.title)
                    Spacer()
                }
                .padding(.bottom)
            }
        }
    }
    
    var buttons: some View {
        ForEach(viewModel.subscriptionButtons, id: \.self) { subscriptionButton in
            
            VStack {
                ZStack {
                    VStack {
                        HStack {
                            Text(subscriptionButton.valuePerMonth)
                                .font(.footnote)
                            Spacer()
                            Text(subscriptionButton.savePercentage)
                                .font(.footnote)
                        }
                        HStack {
                            Text(subscriptionButton.subscriptionLength)
                                .font(.headline)
                            Spacer()
                            Text(subscriptionButton.payAmount)
                                .font(.headline)
                        }
                    }
                    .foregroundColor(selectedOption == subscriptionButton.selectedOption ? .mainColor : .secondaryColor)
                    .accentColor(.primary)
                    .padding()
                    .background(Color.appColor)
                }
                .frame(height: 60)
            }
            .padding(.bottom)
            .accentColor(.primary)
            .opacity(selectedOption == subscriptionButton.selectedOption ? 1.0 : 0.1)
            .onTapGesture {
                selectedOption = subscriptionButton.selectedOption
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    Text(viewModel.subtitle)
                        .font(.headline)
                    Spacer()
                }
                .padding(.bottom)
                
                proBenefits
                
                Text(viewModel.trialText)
                    .padding(.bottom)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                buttons
                
                HStack {
                    Spacer()
                    Text("Privacy Policy")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .underline()
                    Spacer()
                    Text("Terms of Use")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .underline()
                    Spacer()
                }.padding(.bottom)
                
                Button(action: {
                    
                }, label: {
                    VStack {
                            Text(viewModel.buttonTitle)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                        .background(Color.green)
                })
                
                Spacer()
                Spacer()
            }
            .padding()
        }
        .navigationTitle(viewModel.title)
        .navigationBarItems(leading:
                                Button(action: {
                                    self.presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    Image(systemName: viewModel.closeIconImage)
                                        .foregroundColor(.primary)
                                }))
    }
}

struct ProView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProView()
                .preferredColorScheme(.dark)
        }
        
        NavigationView {
            ProView()
                .preferredColorScheme(.light)
        }
        
        
        ProView().previewDevice("iPhone 8")
        
    }
}
