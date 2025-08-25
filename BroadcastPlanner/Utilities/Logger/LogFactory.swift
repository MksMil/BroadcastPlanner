import OSLog

  enum LogCategory: String {
      case network = "Network"
      case database = "Database"
      case images = "ImageManagment"
      case ui = "UI"
  }

  struct LoggerFactory {
      static func logger(for category: LogCategory) -> Logger {
          Logger(subsystem: "com.broadcastPlanner.app", category: category.rawValue)
      }
  }

//  // Использование
//  let networkLogger = LoggerFactory.logger(for: .network)
//  networkLogger.info("Network request started")
