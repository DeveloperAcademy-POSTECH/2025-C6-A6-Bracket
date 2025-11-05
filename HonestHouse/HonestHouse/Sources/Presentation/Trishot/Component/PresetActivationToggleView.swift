//
//  PresetActivationToggleView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/5/25.
//

import SwiftUI

struct PresetActivationToggleView: View {
    let preset: Preset
    let presetNumber: Int
    let isActivated: Bool
    let onToggle: () -> Void

    @GestureState private var dragTranslation: CGFloat = 0
    @State private var isDragging = false

    private let circleSize: CGFloat = 110
    private let totalHeight: CGFloat = 122
    private let horizontalPadding: CGFloat = 8
    private let dragThreshold: CGFloat = 50
    private let minDragDistance: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack(alignment: .leading) {
                settingsContentView()
                    .offset(x: settingsOffset(width: width))
                    
                circleContentView()
                    .offset(x: circleOffset(width: width))
            }
            .frame(maxWidth: .infinity)
            .frame(height: totalHeight)
            .contentShape(Rectangle())
        }
        .frame(height: totalHeight)
    }

    private func circleOffset(width: CGFloat) -> CGFloat {
        let leftPosition = horizontalPadding
        let rightPosition = width - circleSize - horizontalPadding
        let baseOffset = isActivated ? rightPosition : leftPosition

        let constrainedDrag = calculateConstrainedDragOffset(
            baseOffset: baseOffset,
            dragOffset: dragTranslation,
            leftBound: leftPosition,
            rightBound: rightPosition
        )

        return baseOffset + constrainedDrag
    }

    private func settingsOffset(width: CGFloat) -> CGFloat {
        let leftPosition = horizontalPadding
        let rightPosition = width - circleSize - horizontalPadding

        let currentCircleX = circleOffset(width: width)
        let progress = (currentCircleX - leftPosition) / (rightPosition - leftPosition)

        let settingsLeftWhenCircleRight: CGFloat = 31
        let settingsLeftWhenCircleLeft = circleSize + horizontalPadding + 8

        return settingsLeftWhenCircleLeft + (progress * (settingsLeftWhenCircleRight - settingsLeftWhenCircleLeft))
    }

    private func calculateConstrainedDragOffset(
        baseOffset: CGFloat,
        dragOffset: CGFloat,
        leftBound: CGFloat,
        rightBound: CGFloat
    ) -> CGFloat {
        let targetPosition = baseOffset + dragOffset

        if targetPosition < leftBound {
            return leftBound - baseOffset
        } else if targetPosition > rightBound {
            return rightBound - baseOffset
        }

        return dragOffset
    }

    private func handleDragEnded(_ translation: CGFloat) {
        if isActivated && translation < -dragThreshold {
            onToggle()
        } else if !isActivated && translation > dragThreshold {
            onToggle()
        }
    }

    private func circleContentView() -> some View {
        ZStack {
            Circle()
                .fill(Color.g12)
                .overlay(
                    Circle()
                        .stroke(
                            isActivated ? Color.yellow1 : Color.clear,
                            lineWidth: 0.5
                        )
                )

            Text("\(presetNumber)")
                .font(.num1)
                .foregroundColor(
                    isActivated ? Color.yellow1 : Color.g7
                )
        }
        .frame(width: circleSize, height: circleSize)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActivated)
        .animation(isDragging ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: dragTranslation)
        .zIndex(1)
        .onTapGesture {
            onToggle()
        }
        .gesture(
            DragGesture(minimumDistance: minDragDistance)
                .updating($dragTranslation) { value, state, _ in
                    let horizontalDrag = abs(value.translation.width)
                    let verticalDrag = abs(value.translation.height)

                    if horizontalDrag > verticalDrag {
                        state = value.translation.width
                        if !isDragging {
                            isDragging = true
                        }
                    }
                }
                .onEnded { value in
                    handleDragEnded(value.translation.width)
                    isDragging = false
                }
        )
    }

    private func settingsContentView() -> some View {
        let iconSize: CGFloat = 32
        let iconSpacing: CGFloat = 4
        let leadingPadding: CGFloat = 31

        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .center) {
                HStack(spacing: iconSpacing) {
                    Image(pictureStyleIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)

                    Image(shootingModeIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)

                    Image(colorTemperatureIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)

                    Image(exposureIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)

                    Image(wbShiftIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                }
                HStack(spacing: 19) {
                    if let modeDescription = preset.modeDescription {
                        Text(modeDescription)
                            .font(.num6)
                            .foregroundColor(isActivated ? Color.g0 : Color.g7)
                            .frame(alignment: .center)
                    }
                    Text(preset.isoDescription)
                        .font(.num6)
                        .foregroundColor(isActivated ? Color.g0 : Color.g7)
                        .frame(alignment: .center)
                }
            }
            .padding(.leading, leadingPadding)
            Spacer()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActivated)
        .animation(isDragging ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: dragTranslation)
        .zIndex(0)
        .allowsHitTesting(false)
    }

    private var pictureStyleIcon: ImageResource {
        guard isActivated else { return .picturestyleCircleIconGray }
        let isAuto = preset.pictureStyle == .auto
        return isAuto ? .picturestyleCircleIconGray : .picturestyleCircleIconYellow
    }

    private var shootingModeIcon: ImageResource {
        guard isActivated else {
            switch preset.shootingMode {
            case .av: return .shootingmodeAVCircleIconGray
            case .tv: return .shootingmodeTVCircleIconGray
            case .p: return .shootingmodePCircleIconGray
            }
        }

        switch preset.shootingMode {
        case .av:
            return .shootingmodeAVCircleIconYellow
        case .tv:
            return .shootingmodeTVCircleIconYellow
        case .p:
            return .shootingmodePCircleIconYellow
        }
    }

    private var colorTemperatureIcon: ImageResource {
        guard isActivated else { return .colortemperatureCircleIconGray }
        let isDefault = preset.colorTemperature == nil || preset.colorTemperature == 5000
        return isDefault ? .colortemperatureCircleIconGray : .colortemperatureCircleIconYellow
    }

    private var exposureIcon: ImageResource {
        guard isActivated else { return .exposureCircleIconGray }
        let isDefault = preset.exposureCompensation == nil || preset.exposureCompensation == "+0.0"
        return isDefault ? .exposureCircleIconGray : .exposureCircleIconYellow
    }

    private var wbShiftIcon: ImageResource {
        guard isActivated else { return .wbshiftCircleIconGray }
        let ba = preset.tintBlueAmber ?? 0
        let mg = preset.tintMagentaGreen ?? 0
        let isDefault = ba == 0 && mg == 0
        return isDefault ? .wbshiftCircleIconGray : .wbshiftCircleIconYellow
    }
}

#Preview {
    TrishotSettingView(vm: .init(container: .stub))
}
