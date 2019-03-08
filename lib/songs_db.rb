# Song-related info
class SongsDb
  def historylist
    sql("SELECT * FROM #{tables[:history]}")
  end

  private

  def tables
    { songs: 'songlist',
      queue: 'queuelist',
      branches: 'tblbranches',
      history: 'historylist',
      settings: 'tblsettings' }
  end

  def options
    { host: ENV['SONGS_DB_HOSTNAME'],
      username: ENV['SONGS_DB_USER'],
      password: ENV['SONGS_DB_PWD'],
      database: ENV['SONGS_DB_NAME'] }
  end

  def sql(query)
    Mysql2::Client.new(options).query(query)
  rescue => error
    @wait_time.nil? ? @wait_time = 10 : @wait_time += 10
    puts error.message + "\n#{query}\n\nRetrying in #{@wait_time}..."
    sleep @wait_time
    abort("Givin' up.") if @wait_time > 190
    retry
  end
end
