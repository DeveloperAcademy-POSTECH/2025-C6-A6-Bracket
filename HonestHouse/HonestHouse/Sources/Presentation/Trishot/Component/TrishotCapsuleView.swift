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

    private let iconSize: CGFloat = 32
    private let iconSpacing: CGFloat = 4
    private let horizontalPadding: CGFloat = 37
    private let verticalPadding: CGFloat = 22

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
        Text("프리셋\(order + 1)에 선택됨")
            .font(.num5)
            .foregroundColor(Color.g0)
            .shadow(color: Color.black, radius: 20, x: 0, y: 0)
    }

    private func firstRowView() -> some View {
        HStack(spacing: 19) {
            iconWithTextView(icon: pictureStyleIcon, text: preset.pictureStyle.displayValue)
            iconWithTextView(icon: colorTemperatureIcon, text: preset.displayColorTemperature)
            iconWithTextView(icon: wbShiftIcon, text: wbShiftText)
        }
    }

    private func secondRowView() -> some View {
        HStack(spacing: 19) {
            shootingModeWithIsoView()
            iconWithTextView(icon: exposureIcon, text: preset.displayExposureCompensation)
        }
    }

    private func shootingModeWithIsoView() -> some View {
        HStack(spacing: 10) {
            Image(shootingModeIcon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            HStack(spacing: 8) {
                if let modeText = shootingModeText {
                    Text(modeText)
                        .font(.num6)
                        .foregroundColor(isOccupied ? Color.g9 : Color.g0)
                }
                Text(isoText)
                    .font(.num6)
                    .foregroundColor(isOccupied ? Color.g9 : Color.g0)
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

    private func iconWithTextView(icon: ImageResource, text: String) -> some View {
        HStack(spacing: 10) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            Text(text)
                .font(.num6)
                .foregroundColor(isOccupied ? Color.g9 : Color.g0)
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

    private var pictureStyleIcon: ImageResource {
        if isOccupied {
            return .picturestyleCircleIconGray
        }
        let isAuto = preset.pictureStyle == .auto
        return isAuto ? .picturestyleCircleIconGray : .picturestyleCircleIconYellow
    }

    private var shootingModeIcon: ImageResource {
        if isOccupied {
            switch preset.shootingMode {
            case .av: return .shootingmodeAVCircleIconGray
            case .tv: return .shootingmodeTVCircleIconGray
            case .p: return .shootingmodePCircleIconGray
            }
        }

        switch preset.shootingMode {
        case .av: return .shootingmodeAVCircleIconYellow
        case .tv: return .shootingmodeTVCircleIconYellow
        case .p: return .shootingmodePCircleIconYellow
        }
    }

    private var colorTemperatureIcon: ImageResource {
        if isOccupied {
            return .colortemperatureCircleIconGray
        }
        let isDefault = preset.colorTemperature == nil || preset.colorTemperature == 5000
        return isDefault ? .colortemperatureCircleIconGray : .colortemperatureCircleIconYellow
    }

    private var exposureIcon: ImageResource {
        if isOccupied {
            return .exposureCircleIconGray
        }
        let isDefault = preset.exposureCompensation == nil || preset.exposureCompensation == "+0.0"
        return isDefault ? .exposureCircleIconGray : .exposureCircleIconYellow
    }

    private var wbShiftIcon: ImageResource {
        if isOccupied {
            return .wbshiftCircleIconGray
        }
        let ba = preset.tintBlueAmber ?? 0
        let mg = preset.tintMagentaGreen ?? 0
        let isDefault = ba == 0 && mg == 0
        return isDefault ? .wbshiftCircleIconGray : .wbshiftCircleIconYellow
    }
}
