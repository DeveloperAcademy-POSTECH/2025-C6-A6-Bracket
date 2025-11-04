import SwiftUI

struct ApertureScrollPicker: View {
    // MARK: - Properties
    @State private var selectedIndex: Int = 0
    @State private var scrollViewID: Int? = 0  // 스크롤 위치 추적용
    var config = ApertureData()
    var apertureData = ApertureData.standardApertures
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    @State private var isLoaded: Bool = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let horizontalPadding = size.width / 2 - config.itemSize.width / 2
            
//            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: config.spacing) {
                        // 시작 패딩
                    
                        
                        ForEach(ApertureData.standardApertures.indices, id: \.self) { index in
                            Text(ApertureData.standardApertures[index])
                                .font(.num4)
                                .foregroundColor(
                                    selectedIndex == index ? .yellow1 : .g0
                                )
                                .frame(width: config.itemSize.width)
                                .contentShape(Rectangle())
                                .id(index)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedIndex = index
//                                        proxy.scrollTo(index)
//                                        hapticFeedback.impactOccurred()
                                    }
                                }
                        }
                        
                        
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .scrollTargetLayout()
                    
                }
    
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(
                    CenterSnapScrollTargetBehavior2(
                        itemWidth: config.itemSize.width,
                        spacing: config.spacing
                    )
                )
                .scrollPosition(id: .init(get: {
                    let position: Int? = isLoaded ? selectedIndex : nil
//                    print(position)
                    return position
                }, set: { newValue in
                    if let newValue = newValue
                    {
                        selectedIndex = newValue
                        hapticFeedback.impactOccurred()
                    }
                    
                    print(selectedIndex)
                }))
                
//            }
        }
        .frame(height: 52)
        .overlay(alignment: .center) {
            // 중앙 세로선 인디케이터
            VStack(spacing: 36) {
                Rectangle().frame(width: 1, height: 8)
                Rectangle().frame(width: 1, height: 8)
            }
            .foregroundStyle(Color.g0)
        }
        .background(Color.g12)
        .overlay {
            gradientOverlay(width: 120)
        }
        .clipShape(RoundedRectangle(cornerRadius: 100))
        .overlay {
            RoundedRectangle(cornerRadius: 100)
                .strokeBorder(Color.g0, lineWidth: 0.5)
        }
        .onAppear {
            if !isLoaded {
                isLoaded = true
                // 초기 위치 설정
                
            }
        }
    }
    
    // MARK: - Gradient Overlay
    private func gradientOverlay(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            // 좌측 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0)
                    // 커스텀 색상이 있다면 아래 주석을 해제하고 사용
                    // Color.g12,
                    // Color.g12.opacity(0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 120)
            
            Spacer()
            
            // 우측 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0),
                    Color.black
                    // 커스텀 색상이 있다면 아래 주석을 해제하고 사용
                    // Color.g12.opacity(0),
                    // Color.g12
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 120)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Aperture Data
struct ApertureData {
    // 일반적인 조리개 값 배열 (f/1.0 ~ f/22)
    // 실제 카메라에서 사용되는 표준 조리개 값
    static let standardApertures: [String] = [
        "f1.0",
        "f1.1",
        "f1.2",
        "f1.4",
        "f1.6",
        "f1.8",  // 인덱스 5
        "f2.0",
        "f2.2",
        "f2.5",
        "f2.8",
        "f3.2",
        "f3.5",
        "f4.0",
        "f4.5",
        "f5.0",
        "f5.6",
        "f6.3",
        "f7.1",
        "f8.0",
        "f9.0",
        "f10",
        "f11",
        "f13",
        "f14",
        "f16",
        "f18",
        "f20",
        "f22"
    ]
    
    var numberOfDisplays: Int = standardApertures.count
    var spacing: CGFloat = 22
    var itemSize: CGSize = .init(width: 40, height: 24)
}

#Preview {
    ApertureScrollPicker()
}


