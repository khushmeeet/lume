//
//  MainLoadingView.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/4/25.
//

import SwiftUI

struct MainLoadingView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()

            VStack(spacing: PastelSpacing.large) {
                // Animated circles
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.pastelLavender, .pastelPeach],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 60, height: 60)
                            .scaleEffect(isAnimating ? 1.5 : 1.0)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(
                                Animation
                                    .easeOut(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.3),
                                value: isAnimating
                            )
                    }

                    // Center gradient circle
                    Circle()
                        .fill(PastelGradient.primary)
                        .frame(width: 50, height: 50)
                        .shadow(
                            color: PastelShadow.medium.color,
                            radius: PastelShadow.medium.radius,
                            x: PastelShadow.medium.x,
                            y: PastelShadow.medium.y
                        )
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.pastelWhite)
                                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 2).repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        )
                }

                VStack(spacing: PastelSpacing.small) {
                    Text("Discovering Wikipedia...")
                        .font(PastelTypography.headline)
                        .foregroundColor(.primaryText)

                    Text("Finding amazing articles for you")
                        .font(PastelTypography.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .padding(PastelSpacing.extraLarge)
            .background(
                RoundedRectangle(cornerRadius: PastelCornerRadius.large)
                    .fill(Color.cardBackground.opacity(0.95))
                    .shadow(
                        color: PastelShadow.strong.color,
                        radius: PastelShadow.strong.radius,
                        x: PastelShadow.strong.x,
                        y: PastelShadow.strong.y
                    )
            )
            .padding(.horizontal, PastelSpacing.extraLarge)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
