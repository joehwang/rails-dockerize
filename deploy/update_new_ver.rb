require 'net/ssh'
require 'yaml'

remote_adr=ENV["DEPLOY_HOST"]
remote_user=ENV["DEPLOY_USER"]
remote_git_repo="<your git repo>"
@remote_project_name="<your project name>"

def after_start_rails_app(ssh,color)
  #產生production環境的docker-compose.yml
  #命名為docker-compose-prod.yml
    puts "bundle install"
    task = ssh.exec!("cd #{@remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml run --no-deps --rm app_serv_#{color} bundle install")
    puts task
    puts "db:migrate"
    task = ssh.exec!("cd #{@remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml run --no-deps --rm app_serv_#{color} rails db:migrate  RAILS_ENV=production")
    puts task
    puts "assets:precompile"
    task = ssh.exec!("cd #{@remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml run --no-deps --rm app_serv_#{color} rails assets:precompile RAILS_ENV=production")
    puts task
 #指定設定檔docker-compose-prod.yml啟動本次deploy容器
 stdout=""
  task= ssh.exec!("cd #{@remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml up --no-deps -d app_serv_#{color}") do |channel, stream, data|
    stdout << data if stream == :stdout
  end
  puts stdout
  puts "容器代碼 :: #{color} 已啟動"
end

def stop_rails_app(ssh,color)
    task = ssh.exec!("cd #{@remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml stop  app_serv_#{color}")
    puts task
end

def reload_nginx_cfg(ssh,color)
  #修改nginx 設定檔並reload
  #取得代碼容器的port
  doc  = YAML.load_file("#{File.expand_path("..",File.dirname(__FILE__))}/docker-compose.yml")
  port = doc["services"]["app_serv_#{color}"]["ports"].first.to_s.split(":").first
  task = ssh.exec("cd #{@remote_project_name} && docker-compose -f docker-compose.yml -f prod.yml exec web_serv sh /tmp/replace_nginx_template.sh #{color} #{port}")
  puts "完成"
end

Net::SSH.start(remote_adr, remote_user) do |ssh|
  output = ssh.exec!("hostname")
  puts "主機 : #{output}"

  #檢查佈署代號資料夾
  chk_color_folder = ssh.exec!("test -d \"#{@remote_project_name}\" && echo true || echo false").to_s.strip
  if chk_color_folder == "true"
    puts "pull new source code"
    output = ssh.exec!("cd #{@remote_project_name} && git pull")
  elsif chk_color_folder == "false"
    puts "git clone new source code"
    output = ssh.exec!("git clone #{remote_git_repo} #{@remote_project_name}")
  end
  puts output

  #檢查機器中運行的部署代號(blue or green)
  current_runing_code = ""
  if ssh.exec!("docker ps | grep -ohE  'blue|green' | head -1").to_s.strip == "blue"
    puts "現正運行 blue"
    current_runing_code ="blue"
    after_start_rails_app(ssh,"green")
    stop_rails_app(ssh,"blue")
    reload_nginx_cfg(ssh,"green")
  elsif ssh.exec!("docker ps | grep -ohE  'blue|green' | head -1").to_s.strip == "green"
    puts "現正運行 green"
    current_runing_code ="green"
    after_start_rails_app(ssh,"blue")
    stop_rails_app(ssh,"green")
    reload_nginx_cfg(ssh,"blue")
  else
    puts "目前沒有執行任何rails容器"
    puts "開始啟動代碼 green "
    after_start_rails_app(ssh,"green")
    stop_rails_app(ssh,"blue")
    reload_nginx_cfg(ssh,"green")
  end

end
