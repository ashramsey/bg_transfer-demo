class FileDownloadInfo
  attr_accessor :title, :download_link, :download_task, :task_resume_data, :download_progress, :is_downloading, :download_complete, :task_identifier


  def initialize(opts)
    @title = opts[:title]
    @download_link = opts[:download_link]
    @download_progress = 0.0
    @is_downloading = false
    @download_complete = false
    @task_identifier = -1

    self
  end
end
