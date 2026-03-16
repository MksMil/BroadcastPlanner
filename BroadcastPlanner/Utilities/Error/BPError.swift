import Foundation
import Firebase

// MARK: - BPError
// Централизованные ошибки приложения.
// Добавлены новые кейсы под нужды аутентификации.

enum BPError: LocalizedError {

    case unableToComplete
    case invalidData
    case authError
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(Error)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .unableToComplete:
            return "Не удалось выполнить операцию. Попробуйте ещё раз."
        case .invalidData:
            return "Получены некорректные данные."
        case .authError:
            return "Ошибка авторизации. Пожалуйста, войдите снова."
        case .invalidEmail:
            return "Введите корректный адрес электронной почты."
        case .weakPassword:
            return "Пароль слишком простой. Используйте не менее 8 символов."
        case .emailAlreadyInUse:
            return "Этот email уже используется другим аккаунтом."
        case .userNotFound:
            return "Пользователь с таким email не найден."
        case .wrongPassword:
            return "Неверный пароль."
        case .networkError:
            return "Нет подключения к интернету. Проверьте сеть."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    // MARK: - Firebase error mapping
    // Используется для конвертации AuthErrorCode → BPError

    static func from(_ error: Error) -> BPError {
        let nsError = error as NSError
      guard let authError = AuthErrorCode.Code(rawValue: nsError.code) else {
            return .unknown(error)
        }
        switch authError {
        case .invalidEmail:             return .invalidEmail
        case .weakPassword:             return .weakPassword
        case .emailAlreadyInUse:        return .emailAlreadyInUse
        case .userNotFound:             return .userNotFound
        case .wrongPassword:            return .wrongPassword
        case .networkError:             return .networkError
        default:                        return .unknown(error)
        }
    }
}
