import Foundation
import FirebaseAuth
import AuthenticationServices

// MARK: - AlertItem
// Единая модель для показа алертов в SwiftUI через .alert(item:)

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String

    static func from(_ error: Error) -> AlertItem {
        if let bpError = error as? BPError {
            return AlertItem(title: "Ошибка", message: bpError.localizedDescription)
        }
        // Firebase и прочие ошибки — показываем локализованное сообщение
        return AlertItem(title: "Ошибка", message: error.localizedDescription)
    }

    static let sessionExpired = AlertItem(
        title: "Сессия истекла",
        message: "Пожалуйста, войдите снова."
    )
    static let passwordResetSent = AlertItem(
        title: "Письмо отправлено",
        message: "Проверьте почту для сброса пароля."
    )
    static let emailVerificationSent = AlertItem(
        title: "Подтверждение отправлено",
        message: "Проверьте почту для подтверждения нового адреса."
    )
    static let accountDeleted = AlertItem(
        title: "Аккаунт удалён",
        message: "Ваш аккаунт был успешно удалён."
    )
}
