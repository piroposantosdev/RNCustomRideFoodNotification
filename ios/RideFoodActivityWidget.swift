import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct RideFoodActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RideFoodActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            RideFoodActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.type == "ride" ? "car.fill" : "fork.knife")
                        .foregroundColor(Color(hex: context.state.primaryColorHex))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedTime)
                        .font(.caption)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading) {
                        Text(context.state.statusTitle)
                            .font(.headline)
                        Text(context.state.statusDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Progress Bar
                        ProgressView(value: context.state.progress)
                            .tint(Color(hex: context.state.primaryColorHex))
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.type == "ride" ? "car.fill" : "fork.knife")
                    .foregroundColor(Color(hex: context.state.primaryColorHex))
            } compactTrailing: {
                Text(context.state.estimatedTime)
                    .font(.caption2)
            } minimal: {
                Image(systemName: context.attributes.type == "ride" ? "car.fill" : "fork.knife")
                    .foregroundColor(Color(hex: context.state.primaryColorHex))
            }
        }
    }
}

@available(iOS 16.1, *)
struct RideFoodActivityView: View {
    let context: ActivityViewContext<RideFoodActivityAttributes>
    
    var body: some View {
        if context.attributes.type == "ride" {
            RideView(state: context.state)
        } else {
            FoodView(state: context.state)
        }
    }
}

@available(iOS 16.1, *)
struct RideView: View {
    let state: RideFoodActivityAttributes.ContentState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ride")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(state.statusTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(state.statusDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Custom Progress Bar with Car
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * state.progress, height: 4)
                    
                    if !state.iconName.isEmpty {
                        // Tenta carregar imagem dos Assets (Customizada)
                        if UIImage(named: state.iconName) != nil {
                            Image(state.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                                .foregroundColor(.white)
                                .offset(x: (geo.size.width * state.progress) - 15, y: 0)
                        } else {
                            // Fallback para SF Symbols
                            Image(systemName: state.iconName)
                                .font(.title2)
                                .foregroundColor(.white)
                                .offset(x: (geo.size.width * state.progress) - 15, y: 0)
                        }
                    } else {
                        Image(systemName: "car.side.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .offset(x: (geo.size.width * state.progress) - 15, y: 0)
                    }
                }
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color.black)
    }
}

@available(iOS 16.1, *)
struct FoodView: View {
    let state: RideFoodActivityAttributes.ContentState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Delivery Estimate")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(state.estimatedTime)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
                if !state.iconName.isEmpty {
                    if UIImage(named: state.iconName) != nil {
                        Image(state.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(hex: state.primaryColorHex))
                    } else {
                        Image(systemName: state.iconName)
                            .font(.title)
                            .foregroundColor(Color(hex: state.primaryColorHex))
                    }
                } else {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(hex: state.primaryColorHex))
                }
            }
            
            // Segmented Progress Bar (Simulated)
            HStack(spacing: 4) {
                ForEach(0..<4) { index in
                    Capsule()
                        .fill(index < Int(state.progress * 4) ? Color(hex: state.primaryColorHex) : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            
            HStack {
                Image(systemName: "cube.box.fill")
                    .foregroundColor(Color(hex: state.primaryColorHex))
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(state.statusTitle)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(state.statusDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
            
            // Footer: Establishment & Order Info
            HStack(spacing: 8) {
                if !state.secondaryIconName.isEmpty {
                    if UIImage(named: state.secondaryIconName) != nil {
                        Image(state.secondaryIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: state.secondaryIconName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(state.driverOrRestaurantName)
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("#\(state.orderNumber)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color.black)
    }
}

// Helper for Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
