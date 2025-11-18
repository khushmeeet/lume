import SwiftUI

// MARK: - Pastel Color Palette
extension Color {
    // Primary Pastel Colors
    static let pastelLavender = Color(red: 0.8, green: 0.75, blue: 0.95)      // Soft purple
    static let pastelPeach = Color(red: 1.0, green: 0.85, blue: 0.8)          // Warm peach
    static let pastelMint = Color(red: 0.7, green: 0.95, blue: 0.85)          // Fresh mint
    static let pastelBlush = Color(red: 1.0, green: 0.8, blue: 0.85)          // Pink blush
    static let pastelSky = Color(red: 0.7, green: 0.85, blue: 0.98)           // Sky blue
    static let pastelLemon = Color(red: 1.0, green: 0.98, blue: 0.7)          // Soft yellow
    static let pastelRose = Color(red: 0.98, green: 0.75, blue: 0.8)          // Rose pink
    static let pastelPeriwinkle = Color(red: 0.8, green: 0.8, blue: 0.98)    // Periwinkle

    // Neutral Pastel Colors
    static let pastelCream = Color(red: 0.98, green: 0.96, blue: 0.92)        // Cream background
    static let pastelGray = Color(red: 0.85, green: 0.85, blue: 0.88)         // Soft gray
    static let pastelCharcoal = Color(red: 0.3, green: 0.3, blue: 0.35)       // Dark text
    static let pastelWhite = Color(red: 0.99, green: 0.99, blue: 1.0)         // Pure white

    // Gradient Colors
    static let gradientStart = pastelLavender
    static let gradientEnd = pastelPeach

    // Semantic Colors
    static let primaryBackground = pastelCream
    static let secondaryBackground = pastelWhite
    static let cardBackground = pastelWhite
    static let primaryText = pastelCharcoal
    static let secondaryText = pastelCharcoal.opacity(0.6)
    static let accentColor = pastelLavender
    static let favoriteColor = pastelRose
    static let shareColor = pastelSky
}

// MARK: - Custom Gradients
struct PastelGradient {
    static let primary = LinearGradient(
        colors: [.pastelLavender, .pastelPeach],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondary = LinearGradient(
        colors: [.pastelMint, .pastelSky],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = LinearGradient(
        colors: [.pastelBlush, .pastelRose],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let card = LinearGradient(
        colors: [.pastelWhite, .pastelCream.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography
struct PastelTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 17, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 14, weight: .regular, design: .rounded)
    static let captionMedium = Font.system(size: 14, weight: .medium, design: .rounded)
}

// MARK: - Spacing
struct PastelSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

// MARK: - Corner Radius
struct PastelCornerRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 20
    static let large: CGFloat = 28
    static let extraLarge: CGFloat = 36
}

// MARK: - Shadow Styles
struct PastelShadow {
    static let soft = (color: Color.pastelCharcoal.opacity(0.08), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
    static let medium = (color: Color.pastelCharcoal.opacity(0.12), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(6))
    static let strong = (color: Color.pastelCharcoal.opacity(0.15), radius: CGFloat(20), x: CGFloat(0), y: CGFloat(8))
}

// MARK: - Custom Button Styles
struct PastelButtonStyle: ButtonStyle {
    var backgroundColor: Color = .pastelLavender
    var foregroundColor: Color = .primaryText

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PastelTypography.bodyMedium)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, PastelSpacing.large)
            .padding(.vertical, PastelSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PastelCornerRadius.medium)
                    .fill(backgroundColor)
                    .shadow(
                        color: configuration.isPressed ? Color.clear : PastelShadow.soft.color,
                        radius: configuration.isPressed ? 0 : PastelShadow.soft.radius,
                        x: PastelShadow.soft.x,
                        y: configuration.isPressed ? 2 : PastelShadow.soft.y
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct PastelIconButtonStyle: ButtonStyle {
    var backgroundColor: Color = .pastelWhite
    var size: CGFloat = 56

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.primaryText)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .shadow(
                        color: configuration.isPressed ? Color.clear : PastelShadow.soft.color,
                        radius: configuration.isPressed ? 0 : PastelShadow.soft.radius,
                        x: PastelShadow.soft.x,
                        y: configuration.isPressed ? 2 : PastelShadow.soft.y
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Custom Card View
struct PastelCard<Content: View>: View {
    let content: Content
    var backgroundColor: Color = .cardBackground
    var cornerRadius: CGFloat = PastelCornerRadius.large
    var padding: CGFloat = PastelSpacing.medium

    init(
        backgroundColor: Color = .cardBackground,
        cornerRadius: CGFloat = PastelCornerRadius.large,
        padding: CGFloat = PastelSpacing.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(
                        color: PastelShadow.medium.color,
                        radius: PastelShadow.medium.radius,
                        x: PastelShadow.medium.x,
                        y: PastelShadow.medium.y
                    )
            )
    }
}

// MARK: - Custom Tag View
struct PastelTag: View {
    let text: String
    var backgroundColor: Color = .pastelLavender

    var body: some View {
        Text(text)
            .font(PastelTypography.captionMedium)
            .foregroundColor(.primaryText)
            .padding(.horizontal, PastelSpacing.medium)
            .padding(.vertical, PastelSpacing.small)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                .pastelLavender.opacity(0.3),
                .pastelPeach.opacity(0.3),
                .pastelMint.opacity(0.3),
                .pastelSky.opacity(0.3)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Custom Divider
struct PastelDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.pastelGray.opacity(0.5))
            .frame(height: 1)
    }
}

// MARK: - Custom Toggle Style
struct PastelToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.pastelLavender : Color.pastelGray)
                .frame(width: 51, height: 31)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
