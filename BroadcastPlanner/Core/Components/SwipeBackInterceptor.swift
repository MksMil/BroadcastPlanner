import SwiftUI
struct SwipeBackInterceptor: UIViewControllerRepresentable {
    let onSwipeBack: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let navController = uiViewController.navigationController else { return }
            navController.interactivePopGestureRecognizer?.delegate = context.coordinator
            context.coordinator.onSwipeBack = onSwipeBack
            context.coordinator.navController = navController
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onSwipeBack: (() -> Void)?
        weak var navController: UINavigationController?

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            // перехватываем — вызываем свой обработчик вместо стандартного pop
            onSwipeBack?()
            return false // false = отменяем стандартный свайп
        }
    }
}
