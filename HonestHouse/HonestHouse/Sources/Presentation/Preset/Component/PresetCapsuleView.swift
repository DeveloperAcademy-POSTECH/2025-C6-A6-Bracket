//
//  PresetCapsuleView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/13/25.
//

import SwiftUI

enum PresetCapsuleDisplayType {
    case `default`
    case selected
    case currentlyApplied
}

struct PresetCapsuleView: View {
    let preset: Preset
    let displayType: PresetCapsuleDisplayType

    private let iconCircleSize: CGFloat = 32
    private let iconContentSize: CGFloat = 24
    private let iconSpacing: CGFloat = 4
    private let horizontalPadding: CGFloat = 37
    private let verticalPadding: CGFloat = 22

    private let disabledColor: Color = .g9

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            firstRowView()
            secondRowView()
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: .infinity)
        .background(
            Capsule()
                .fill(Color.g11)
        )
        .overlay(
            Capsule()
                .strokeBorder(strokeColor, lineWidth: 1)
        )
        .contentShape(Capsule())
    }

    private var strokeColor: Color {
        switch displayType {
        case .default:
            return .clear
        case .selected, .currentlyApplied:
            return .yellow1
        }
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
            iconWithCircleBackground(icon: shootingModeIcon, hasValue: true)
            HStack(spacing: 8) {
                if let modeText = shootingModeText {
                    Text(modeText)
                        .font(.num6)
                        .foregroundColor(Color.g0)
                }
                Text(isoText)
                    .font(.num6)
                    .foregroundColor(Color.g0)
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
                .font(.num6)
                .foregroundColor(hasValue ? Color.g0 : disabledColor)
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
                .foregroundColor(hasValue ? Color.yellow1 : disabledColor)
        }
    }

    private var wbShiftText: String {
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
        let mg = preset.tintMagentaGreen ?? 0
        return mg != 0
    }
}
