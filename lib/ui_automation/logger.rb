module UIAutomation
  # A RemoteProxy to UIALogger objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIALoggerClassReference/
  #
  class Logger < RemoteProxy
    def self.logger(executor)
      from_javascript(executor, 'UIALogger')
    end
    
    def start(message)
      perform :logStart, message
    end
    
    def pass(message)
      perform :logPass, message
    end
    
    def fail(message)
      perform :logFail, message
    end
    
    def issue(message)
      perform :logIssue, message
    end
    
    def debug(message)
      perform :logDebug, message
    end
    
    def error(message)
      perform :logError, message
    end
    
    def message(message)
      perform :logMessage, message
    end
    
    def warning(message)
      perform :logWarning, message
    end
  end
end
