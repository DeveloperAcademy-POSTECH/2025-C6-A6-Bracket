//
//  TrishotCapsuleView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/9/25.
//

import SwiftUI

struct TrishotCapsuleView: View {
    let preset: Preset
    let isOccupied: Bool
    let occupiedOrder: Int?

    private let iconCircleSize: CGFloat = 32
    private let iconContentSize: CGFloat = 24
    private let iconSpacing: CGFloat = 4
    private let horizontalPadding: CGFloat = 37
    private let verticalPadding: CGFloat = 22
    
    private let disabledColor: Color = .g9

    init(preset: Preset, isOccupied: Bool = false, occupiedOrder: Int? = nil) {
        self.preset = preset
        self.isOccupied = isOccupied
        self.occupiedOrder = occupiedOrder
    }

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 14) {
                firstRowView()
                secondRowView()
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)

            if isOccupied, let order = occupiedOrder {
                occupiedOverlayView(order: order)
            }
        }
    }

    private func occupiedOverlayView(order: Int) -> some View {
        Text("Preset \(order + 1)에 선택됨")
            .fontStyle(.num5)
            .foregroundColor(Color.g0)
            .shadow(color: Color.black, radius: 20, x: 0, y: 0)
    }

    private func firstRowView() -> some View {
        HStack(spacing: 19) {
            iconWithTextView(icon: .picturestyleIcon, text: preset.pictureStyle.displayValue, hasValue: hasPictureStyleValue)
            iconWithTextView(icon: .colortemperatureIcon, text: preset.displayColorTemperature, hasValue: hasColorTemperatureValue)
            iconWithTextView(icon: .wbshiftIcon, text: wbShiftText, hasValue: hasWbShiftValue)
        }
    }

    private func secondRowView() -> some View {
        HStack(spacing: 19) {
            shootingModeWithIsoView()
            iconWithTextView(icon: .exposureIcon, text: preset.displayExposureCompensation, hasValue: hasExposureValue)
        }
    }

    private func shootingModeWithIsoView() -> some View {
        HStack(spacing: 10) {
            iconWithCircleBackground(icon: shootingModeIcon, hasValue: true) // Shooting mode는 무조건 true
            HStack(spacing: 8) {
                if let modeText = shootingModeText {
                    Text(modeText)
                        .fontStyle(.num6)
                        .foregroundColor(isOccupied ? disabledColor : Color.g0)
                }
                Text(isoText)
                    .fontStyle(.num6)
                    .foregroundColor(isOccupied ? disabledColor : Color.g0)
            }
        }
    }

    private var shootingModeText: String? {
        let apertureValue = preset.aperture ?? "Auto"
        let shutterSpeedValue = preset.shutterSpeed ?? "Auto"

        switch preset.shootingMode {
        case .av:
            return "f:\(apertureValue)"
        case .tv:
            return "S:\(shutterSpeedValue)"
        case .p:
            return nil
        }
    }
    
    private var isoText: String {
        let isoValue = preset.iso ?? "Auto"
        
        return "ISO:[\(isoValue)]"
    }

    private func iconWithTextView(icon: ImageResource, text: String, hasValue: Bool) -> some View {
        HStack(spacing: 10) {
            iconWithCircleBackground(icon: icon, hasValue: hasValue)
            Text(text)
                .fontStyle(.num6)
                .foregroundColor(textColor(hasValue: hasValue))
        }
    }

    private func textColor(hasValue: Bool) -> Color {
        if isOccupied {
            return disabledColor
        } else {
            return hasValue ? Color.g0 : disabledColor
        }
    }

    private func iconWithCircleBackground(icon: ImageResource, hasValue: Bool) -> some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color.g12)
                .frame(width: iconCircleSize, height: iconCircleSize)

            Image(icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: iconContentSize, height: iconContentSize)
                .foregroundColor(iconColor(hasValue: hasValue))
        }
    }

    private func iconColor(hasValue: Bool) -> Color {
        if isOccupied {
            return hasValue ? Color.yellow2 : disabledColor
        } else {
            return hasValue ? Color.yellow1 : disabledColor
        }
    }

    private var wbShiftText: String {
        // 현재는 magentaGreen만 사용
        let mg = preset.tintMagentaGreen ?? 0

        if mg == 0 {
            return "±0"
        }

        let mgSign = mg >= 0 ? "+" : ""
        return "\(mgSign)\(mg)"
    }

    private var shootingModeIcon: ImageResource {
        switch preset.shootingMode {
        case .av: return .shootingmodeAVIcon
        case .tv: return .shootingmodeTVIcon
        case .p: return .shootingmodePIcon
        }
    }

    private var hasPictureStyleValue: Bool {
        preset.pictureStyle != .auto
    }

    private var hasColorTemperatureValue: Bool {
        guard let colorTemp = preset.colorTemperature else { return false }
        return colorTemp != 5000
    }

    private var hasExposureValue: Bool {
        guard let exposure = preset.exposureCompensation else { return false }
        return exposure != "+0.0"
    }

    private var hasWbShiftValue: Bool {
        // 현재는 magentaGreen만 사용
        let mg = preset.tintMagentaGreen ?? 0
        return mg != 0
    }
}
