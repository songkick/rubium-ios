module UIAutomation
  class Logger < RemoteProxy
    def self.logger(driver)
      from_javascript(driver, 'UIALogger')
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
