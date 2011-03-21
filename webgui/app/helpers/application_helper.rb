# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def has_stats_file(pool_id)
    @has_stats_file ||= begin
      path = File.expand_path(File.join(RAILS_ROOT, 'db', ReportsController::STATS_DATAFILE_NAME % pool_id))
      File.exist?(path) ? :true : :false
    end
    @has_stats_file == :true
  end
end
