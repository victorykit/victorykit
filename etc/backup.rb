Model.new(:rsvk_backup, 'Backup Vk postgresql db') do

  split_into_chunks_of(1000)

  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = "rsvk_prod"
    db.username           = "XXXXX"
    db.password           = "XXXXX"
    db.host               = "localhost"
    db.port               = 5432
  end

  Compressor::Custom.defaults do |compressor|
    compressor.command = 'xz'
    compressor.extension = '.xz'
  end

  encrypt_with OpenSSL do |encryption|
    encryption.password_file = '/home/admin/vk/shared/config/backup-key.txt'
    encryption.base64        = true
    encryption.salt          = true
  end

  store_with S3 do |s3|
    s3.keep = 30

    # AWS Credentials
    s3.access_key_id     = "XXXXX"
    s3.secret_access_key = "XXXXX"

    s3.region            = 'us-east-1'
    s3.bucket            = 'vk.rootstrikers.org'
    s3.path              = '/backups'

    s3.max_retries       = 10
    s3.retry_waitsec     = 30

  end

  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = 'backup@vk.rootstrikers.org'
    mail.to                   = 'tech+rsvk-admin@engagementlab.org'
    mail.address              = 'localhost'
    mail.port                 = 25
    mail.domain               = 'rootstrikers.org'
  end

end
