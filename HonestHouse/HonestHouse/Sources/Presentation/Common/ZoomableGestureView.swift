//
//  ZoomableGestureView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/11/25.
//

import SwiftUI

struct ZoomableGestureView<Content: View>: View {
    let content: Content
    let minZoomScale: CGFloat
    let maxZoomScale: CGFloat
    let doubleTapZoomScale: CGFloat
    
    @State private var contentSize: CGSize = .zero
    @State private var viewID = UUID()
    
    init(
        minZoomScale: CGFloat = 1.0,
        maxZoomScale: CGFloat = 3.0,
        doubleTapZoomScale: CGFloat = 3.0,
        @ViewBuilder content: () -> Content
    ) {
        self.minZoomScale = minZoomScale
        self.maxZoomScale = maxZoomScale
        self.doubleTapZoomScale = doubleTapZoomScale
        self.content = content()
    }
    
    var body: some View {
        ZoomScrollViewRepresentable(
            content: content,
            minZoomScale: minZoomScale,
            maxZoomScale: maxZoomScale,
            doubleTapZoomScale: doubleTapZoomScale
        )
        .background(
            // 실제 컨텐츠 크기 측정
            GeometryReader { geometry in
                Color.clear
                    .onAppear { // 처음 나타날 때 사이즈
                        contentSize = geometry.size
                    }
                    .onChange(of: geometry.size) { _, newSize in // 크기 변경 시 사이즈
                        contentSize = newSize
                    }
            }
        )
        .id(viewID)  // 뷰 재생성
        .onDisappear {
            // TabView 전환 시 ID 변경
            DispatchQueue.main.async {
                viewID = UUID()
            }
        }
    }
}

// MARK: - UIViewRepresentable Implementation
private struct ZoomScrollViewRepresentable<Content: View>: UIViewRepresentable {
    let content: Content
    let minZoomScale: CGFloat
    let maxZoomScale: CGFloat
    let doubleTapZoomScale: CGFloat
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false // tabView 스와이프 허용
        scrollView.backgroundColor = .clear
        
        // SwiftUI 컨텐츠를 UIHostingController로 래핑
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = true
        hostingController.view.backgroundColor = .clear
        
        // sizeToFit()으로 실제 컨텐츠 크기 계산
        hostingController.view.sizeToFit()
        
        scrollView.addSubview(hostingController.view)
        
        context.coordinator.hostingController = hostingController
        context.coordinator.scrollView = scrollView
        
        // 더블 탭 제스처
        let doubleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // 초기 레이아웃
        DispatchQueue.main.async {
            context.coordinator.layoutContent()
        }
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.minimumZoomScale = minZoomScale
        uiView.maximumZoomScale = maxZoomScale
        context.coordinator.hostingController?.rootView = content
        
        // 레이아웃 업데이트
        DispatchQueue.main.async {
            context.coordinator.layoutContent()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            doubleTapZoomScale: doubleTapZoomScale,
            maxZoomScale: maxZoomScale,
            minZoomScale: minZoomScale
        )
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>?
        weak var scrollView: UIScrollView?
        let doubleTapZoomScale: CGFloat
        let maxZoomScale: CGFloat
        let minZoomScale: CGFloat
        
        init(doubleTapZoomScale: CGFloat, maxZoomScale: CGFloat, minZoomScale: CGFloat) {
            self.doubleTapZoomScale = doubleTapZoomScale
            self.maxZoomScale = maxZoomScale
            self.minZoomScale = minZoomScale
        }
        
        // 줌할 뷰 반환
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController?.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContent(in: scrollView)
        }
        
        // 레이아웃 업데이트
        func layoutContent() {
            guard let hostingView = hostingController?.view,
                  let scrollView = scrollView else { return }
            
            // 컨텐츠 실제 크기 계산
            let contentSize = hostingView.systemLayoutSizeFitting(
                scrollView.bounds.size,
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: .fittingSizeLevel
            )
            
            // 컨텐츠 크기 설정
            hostingView.frame.size = contentSize
            scrollView.contentSize = contentSize
            
            // 중앙 정렬
            centerContent(in: scrollView)
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = scrollView,
                  let hostingView = hostingController?.view else { return }
            
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                let location = gesture.location(in: hostingView)
                let zoomScale = min(doubleTapZoomScale, maxZoomScale)
                
                // 탭한 위치를 중심으로 하는 사각형 계산
                let size = scrollView.bounds.size
                let w = size.width / zoomScale
                let h = size.height / zoomScale
                // 사각형 중심이 탭 위치가 되도록
                let x = location.x - (w / 2.0)
                let y = location.y - (h / 2.0)
                
                let rectToZoom = CGRect(x: x, y: y, width: w, height: h)
                scrollView.zoom(to: rectToZoom, animated: true)
            }
        }
        
        private func centerContent(in scrollView: UIScrollView) {
            guard let view = hostingController?.view else { return }
            
            let boundsSize = scrollView.bounds.size // 화면 크기
            var frameToCenter = view.frame // 컨텐츠 프레임
            
            // 수평 중앙 정렬
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            // 수직 중앙 정렬
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            
            view.frame = frameToCenter
        }
    }
}
