//
//  MainLoadingView.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/4/25.
//

import SwiftUI

struct MainLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 5)
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                Text("Discovering Wikipedia...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.6))
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}
