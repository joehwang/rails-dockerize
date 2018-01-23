require 'net/ssh'
require 'yaml'

remote_adr=ENV["DEPLOY_HOST"]
remote_user=ENV["DEPLOY_USER"]
remote_git_repo="git@github.com:bptw/xxxx.git"
remote_project_name="xxxx"
Net::SSH.start(remote_adr, remote_user) do |ssh|
  output = ssh.exec!("hostname")
  puts "主機 : #{output}"
  #檢查佈署代號資料夾
  chk_color_folder = ssh.exec!("test -d \"#{remote_project_name}\" && echo true || echo false").to_s.strip
  if chk_color_folder == "true"
    puts "pull new source code"
    output = ssh.exec!("cd #{remote_project_name} && git pull")
  elsif chk_color_folder == "false"
    puts "git clone new source code"
    output = ssh.exec!("git clone #{remote_git_repo} #{remote_project_name}")
  end
  puts output
  #產生production環境的docker-compose.yml
  #命名為docker-compose-prod.yml
  puts "啟動mysql"
  task = ssh.exec!("cd #{remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml up -d db")
  puts "啟動redis"
  task = ssh.exec!("cd #{remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml up -d redis")
  puts "啟動sidekiq"
  task = ssh.exec!("cd #{remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml up -d sidekiq")
  puts "啟動nginx"
  task = ssh.exec!("cd #{remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml up -d web_serv")
  puts task
  puts "完成"
  puts "docker-compose logs -f 查看所有LOG"

end