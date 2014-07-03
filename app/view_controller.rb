class ViewController < UIViewController
  CellProgressBarTagValue = 1

  def viewDidLoad
    super

    @view = self.view

    initializeFileDownloadDataArray

    @table_view = UITableView.alloc.initWithFrame(@view.bounds).tap do |tbview|
      tbview.delegate = self
      tbview.dataSource = self
      self.view.addSubview(tbview)
    end


    sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfiguration "com.BGTransferDemo"
    @session = NSURLSession.sessionWithConfiguration(sessionConfiguration, delegate:self, delegateQueue:nil)


    self
  end





  def numberOfSectionsInTableView(tableView)
    1
  end


  def tableView(tableView, numberOfRowsInSection: section)
    return @arrFileDownloadData.count
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier "idCell"
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "idCell")

    fdi = @arrFileDownloadData[indexPath.row]


    displayedTitle = UILabel.alloc.initWithFrame(CGRectMake(20,19,208,21)).tap do |new_view|
      cell.contentView.addSubview(new_view)
    end
    startPauseButton = UIButton.buttonWithType(UIButtonTypeSystem).tap do |new_view|
      new_view.setFrame(CGRectMake(236,17,25,25))
      new_view.when_tapped { startOrPauseDownloadingSingleFile(cell) }
      # new_view.addTarget(self, action: 'startOrPauseDownloadingSingleFile:', forControlEvents: UIControlEventTouchUpInside)
      cell.contentView.addSubview(new_view)
    end
    stopButton = UIButton.buttonWithType(UIButtonTypeSystem).tap do |new_view|
      new_view.setFrame(CGRectMake(275,17,25,25))
      new_view.setImage(UIImage.imageNamed("images/stop-25"), forState: UIControlStateNormal)
      new_view.when_tapped { stopDownloading(cell) }
      # new_view.addTarget(self, action: 'stopDownloading:', forControlEvents: UIControlEventTouchUpInside)
      cell.contentView.addSubview(new_view)
    end
    progressView = UIProgressView.alloc.initWithProgressViewStyle(UIProgressViewStyleDefault).tap do |new_view|
      new_view.tag = CellProgressBarTagValue
      cell.contentView.addSubview(new_view)
    end
    readyLabel = UILabel.alloc.initWithFrame(CGRectMake(236,17,64,25)).tap do |new_view|
      cell.contentView.addSubview(new_view)
    end

    displayedTitle.text = fdi.title

    unless fdi.is_downloading
      # // Hide the progress view and disable the stop button.
      progressView.hidden = true
      stopButton.enabled = false

      # // Set a flag value depending on the downloadComplete property of the fdi object.
      # // Using it will be shown either the start and stop buttons, or the Ready label.
      hideControls = fdi.download_complete
      startPauseButton.hidden = hideControls;
      stopButton.hidden = hideControls
      readyLabel.hidden = !hideControls

      startPauseButtonImageName = "images/play-25"
    else
      # // Show the progress view and update its progress, change the image of the start button so it shows
      # // a pause icon, and enable the stop button.
      progressView.hidden = false
      progressView.progress = fdi.download_progress

      stopButton.enabled = true

      startPauseButtonImageName = "images/pause-25";
    end

    # // Set the appropriate image to the start button.
    startPauseButton.setImage(UIImage.imageNamed(startPauseButtonImageName), forState: UIControlStateNormal)

    return cell
  end


  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    return 60.0
  end





  # Action method implementation

  def startOrPauseDownloadingSingleFile(containerCell)
    p "startOrPauseDownloadingSingleFile #{containerCell}"
    # // Check if the parent view of the sender button is a table view cell.
    # if containerCell.isKindOfClass(UITableViewCell.class)
      # // Get the container cell.
      # containerCell = sender.superview.superview.superview

      # // Get the row (index) of the cell. We'll keep the index path as well, we'll need it later.
      cellIndexPath = @table_view.indexPathForCell(containerCell)
      cellIndex = cellIndexPath.row

      # // Get the FileDownloadInfo object being at the cellIndex position of the array.
      fdi = @arrFileDownloadData.objectAtIndex cellIndex

      # // The isDownloading property of the fdi object defines whether a downloading should be started
      # // or be stopped.
      unless fdi.is_downloading
        # // This is the case where a download task should be started.

        # // Create a new task, but check whether it should be created using a URL or resume data.
        if fdi.task_identifier == -1
          # // If the taskIdentifier property of the fdi object has value -1, then create a new task
          # // providing the appropriate URL as the download source.
          fdi.download_task = @session.downloadTaskWithURL(NSURL.URLWithString(fdi.download_link))

          # // Keep the new task identifier.
          fdi.task_identifier = fdi.download_task.taskIdentifier

          # // Start the task.
          fdi.download_task.resume
        else
          # // Create a new download task, which will use the stored resume data.
          fdi.download_task = @session.downloadTaskWithResumeData(fdi.task_resume_data)
          fdi.download_task.resume

          # // Keep the new download task identifier.
          fdi.task_identifier = fdi.download_task.taskIdentifier
        end
      else
        # // Pause the task by canceling it and storing the resume data.
        fdi.download_task.cancelByProducingResumeData -> (resumeData) do
          if resumeData.nil?
            fdi.task_resume_data = NSData.alloc.initWithData(resumeData)
          end
        end
      end

      # // Change the isDownloading property value.
      fdi.is_downloading = !fdi.is_downloading

      # // Reload the table view.
      @table_view.reloadRowsAtIndexPaths([cellIndexPath], withRowAnimation: UITableViewRowAnimationNone)
    # end
  end


  def stopDownloading(containerCell)
    # if containerCell.isKindOfClass(UITableViewCell.class)
      # // Get the container cell.
      # containerCell = sender.superview.superview.superview

      # // Get the row (index) of the cell. We'll keep the index path as well, we'll need it later.
      cellIndexPath = @table_view.indexPathForCell(containerCell)
      cellIndex = cellIndexPath.row

      # // Get the FileDownloadInfo object being at the cellIndex position of the array.
      fdi = @arrFileDownloadData.objectAtIndex cellIndex

      # // Cancel the task.
      fdi.download_task.cancel

      # // Change all related properties.
      fdi.is_downloading = false
      fdi.task_identifier = -1
      fdi.download_progress = 0.0

      # // Reload the table view.
      @table_view.reloadRowsAtIndexPaths([cellIndexPath], withRowAnimation: UITableViewRowAnimationNone)
    # end
  end


  def startAllDownloads(sender)
    NSLog 'startAllDownloads'
  end


  def stopAllDownloads(sender)
    NSLog 'stopAllDownloads'
  end


  def initializeAll(sender)
    NSLog 'initializeAll'
  end






  # NSURLSession Delegate method implementation

  def URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)

    error = Pointer.new(:object)
    fileManager = NSFileManager.defaultManager

    destinationFilename = downloadTask.originalRequest.URL.lastPathComponent
    uRLs = fileManager.URLsForDirectory(NSDocumentDirectory, inDomains: NSUserDomainMask)
    @docDirectoryURL = uRLs.objectAtIndex 0
    destinationURL = @docDirectoryURL.URLByAppendingPathComponent destinationFilename

    if fileManager.fileExistsAtPath(destinationURL.path)
      fileManager.removeItemAtURL(destinationURL, error:nil)
    end

    success = fileManager.copyItemAtURL(location, toURL: destinationURL, error: error)

    if success
      # // Change the flag values of the respective FileDownloadInfo object.
      index = self.getFileDownloadInfoIndexWithTaskIdentifier(downloadTask.taskIdentifier)
      fdi = @arrFileDownloadData[index]

      fdi.is_downloading = false
      fdi.download_complete = true

      # // Set the initial value to the taskIdentifier property of the fdi object,
      # // so when the start button gets tapped again to start over the file download.
      fdi.task_identifier = -1

      # // In case there is any resume data stored in the fdi object, just make it nil.
      fdi.task_resume_data = nil

      NSOperationQueue.mainQueue.addOperationWithBlock -> do
        # // Reload the respective table view row using the main thread.
        @table_view.reloadRowsAtIndexPaths([NSIndexPath.indexPathForRow(index, inSection: 0)], withRowAnimation: UITableViewRowAnimationNone)
      end
    else
      NSLog "Unable to copy temp file. Error: #{error.localizedDescription}"
    end
  end


  def URLSession(session, task: task, didCompleteWithError: error)
    if error
      NSLog "Download completed with error: #{error.localizedDescription}"
    else
      NSLog "Download finished successfully."
    end
  end


  def URLSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown
      NSLog "Unknown transfer size"
    else
      # // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
      index = self.getFileDownloadInfoIndexWithTaskIdentifier downloadTask.taskIdentifier
      p "index: #{index}"
      fdi = @arrFileDownloadData[index]

      NSOperationQueue.mainQueue.addOperationWithBlock -> do
        # // Calculate the progress.
        fdi.download_progress = totalBytesWritten.to_f/totalBytesExpectedToWrite.to_f

        # // Get the progress view of the appropriate cell and update its progress.
        cell = @table_view.cellForRowAtIndexPath(NSIndexPath.indexPathForRow(index, inSection: 0))
        progressView = cell.viewWithTag(CellProgressBarTagValue)
        progressView.progress = fdi.download_progress
      end
    end
  end


  def URLSessionDidFinishEventsForBackgroundURLSession(session)
    # // Check if all download tasks have been finished.
    @session.getTasksWithCompletionHandler -> (dataTasks, uploadTasks, downloadTasks) do
      if downloadTasks.count == 0
        unless App.delegate.backgroundTransferCompletionHandler.nil?
          # // Copy locally the completion handler.
          @completionHandler = App.delegate.backgroundTransferCompletionHandler

          # // Make nil the backgroundTransferCompletionHandler.
          App.delegate.backgroundTransferCompletionHandler = nil

          NSOperationQueue.mainQueue.addOperationWithBlock -> do
            # // Call the completion handler to tell the system that there are no other background transfers.
            @completionHandler.call

            # // Show a local notification when all downloads are over.
            localNotification = UILocalNotification.alloc.init
            localNotification.alertBody = "All files have been downloaded!"
            UIApplication.sharedApplication.presentLocalNotificationNow(localNotification)
          end
        end
      end
    end

  end





  def initializeFileDownloadDataArray
    @arrFileDownloadData = []
    url = "https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"
    @arrFileDownloadData << FileDownloadInfo.new(title: "iOS Programming Guide", download_link: url)
  end


  def getFileDownloadInfoIndexWithTaskIdentifier(taskIdentifier)
    index = nil
    @arrFileDownloadData.each_index do |i|
      if @arrFileDownloadData[i].task_identifier == taskIdentifier
        index = i
        break
      end
    end
    index
  end
end
