import SwiftUI

// MARK: - Theme
struct Theme {
    static let bg        = Color(hex: "#0d0d0d")
    static let bgAlt     = Color(hex: "#111114")
    static let panel     = Color(hex: "#16161c")
    static let panelHi   = Color(hex: "#1e1e28")
    static let border    = Color(hex: "#3a3020")
    static let gold      = Color(hex: "#c8cdd4")
    static let goldDim   = Color(hex: "#7a8490")
    static let goldPale  = Color(hex: "#eef0f4")
    static let red       = Color(hex: "#7a1515")
    static let redHi     = Color(hex: "#b02020")
    static let parchment = Color(hex: "#e8dcc8")
    static let muted     = Color(hex: "#8a8070")
    static let dimmed    = Color(hex: "#555045")
    static let green     = Color(hex: "#3a6030")
    static let greenHi   = Color(hex: "#5a9848")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - SkyTitle
struct SkyTitle: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            Text(icon).font(.title3)
            Text(label)
                .font(.system(.subheadline, design: .serif))
                .tracking(3)
                .textCase(.uppercase)
                .foregroundColor(Theme.goldPale)
            Spacer()
        }
        .padding(.bottom, 6)
    }
}

// MARK: - SkyPanel
struct SkyPanel<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(14)
        .background(Theme.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Theme.border, lineWidth: 1)
        )
        .overlay(
            VStack {
                Rectangle()
                    .fill(Theme.gold.opacity(0.4))
                    .frame(height: 2)
                Spacer()
            }
        )
        .cornerRadius(2)
        .padding(.bottom, 12)
    }
}

// MARK: - SkyButton
struct SkyButton: View {
    let title: String
    var variant: ButtonVariant = .default
    var disabled: Bool = false
    let action: () -> Void

    enum ButtonVariant { case `default`, primary, danger }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .serif))
                .tracking(1)
                .foregroundColor(textColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(bgColor)
                .overlay(RoundedRectangle(cornerRadius: 1).stroke(borderColor, lineWidth: 1))
                .cornerRadius(1)
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }

    var textColor: Color {
        switch variant {
        case .primary: return Theme.goldPale
        case .danger:  return Theme.parchment
        default:       return Theme.parchment
        }
    }
    var bgColor: Color {
        switch variant {
        case .primary: return Theme.red.opacity(0.8)
        case .danger:  return Theme.red.opacity(0.4)
        default:       return Theme.panelHi
        }
    }
    var borderColor: Color {
        switch variant {
        case .primary: return Theme.gold
        case .danger:  return Theme.redHi
        default:       return Theme.border
        }
    }
}

// MARK: - SkyTextField
struct SkyTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .foregroundColor(Theme.parchment)
            .font(.system(.body, design: .serif))
            .padding(10)
            .background(Color(hex: "#0a0a0e"))
            .overlay(
                VStack {
                    Spacer()
                    Rectangle().fill(Theme.gold.opacity(0.35)).frame(height: 1)
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 1).stroke(Theme.border, lineWidth: 1))
            .cornerRadius(1)
    }
}

// MARK: - Divider Ornament
struct OrnamentDivider: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, Theme.gold.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
            Text("◈").foregroundColor(Theme.gold.opacity(0.7)).font(.caption)
            Rectangle()
                .fill(LinearGradient(colors: [Theme.gold.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - MacroBar
struct MacroBar: View {
    let label: String
    let current: Double
    let goal: Double
    let color: Color

    var pct: Double { min(current / max(goal, 1), 1.0) }
    var over: Bool { current > goal }
    var unit: String { label == "Calories" ? " kcal" : "g" }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label.uppercased())
                    .font(.caption2).tracking(1).foregroundColor(Theme.muted)
                Spacer()
                Text("\(Int(current))/\(Int(goal))\(unit)\(over ? " ▲" : "")")
                    .font(.caption).foregroundColor(over ? Theme.redHi : color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(hex: "#222218")).frame(height: 6)
                    Rectangle().fill(over ? Theme.redHi : color)
                        .frame(width: geo.size.width * pct, height: 6)
                        .animation(.easeInOut(duration: 0.4), value: pct)
                }
                .cornerRadius(1)
                .overlay(RoundedRectangle(cornerRadius: 1).stroke(Theme.border, lineWidth: 0.5))
            }
            .frame(height: 6)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Achievement Banner
struct AchievementBanner: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Text(achievement.icon).font(.system(size: 36))
                VStack(alignment: .leading, spacing: 2) {
                    Text("᛫ ACHIEVEMENT UNLOCKED ᛫")
                        .font(.system(size: 9)).tracking(4).foregroundColor(Theme.goldDim)
                    Text(achievement.title)
                        .font(.system(.callout, design: .serif)).tracking(1).foregroundColor(Theme.goldPale)
                    Text(achievement.desc)
                        .font(.caption).foregroundColor(Theme.muted)
                }
                Spacer()
            }
            .padding(14)
            .background(
                LinearGradient(colors: [Color(hex: "#1a1208"), Theme.panel],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.gold, lineWidth: 2))
            .cornerRadius(2)
            .shadow(color: Theme.gold.opacity(0.2), radius: 12)
            .padding(.horizontal, 16)
            .onTapGesture { onDismiss() }
            Spacer()
        }
        .padding(.top, 60)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
