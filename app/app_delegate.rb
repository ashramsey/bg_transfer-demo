class AppDelegate
  attr_accessor :backgroundTransferCompletionHandler

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = ViewController.new

    @window.makeKeyAndVisible
    true
  end


  def application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    @backgroundTransferCompletionHandler = completionHandler
  end
end
