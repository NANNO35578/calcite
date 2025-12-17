# 251217
# init repository
git init
git remote add origin https://github.com/NANNO35578/calcite.git
git pull origin main # pull license

git branch docs
# add Readme&commands.sh
git add .
git commit -m "docs: init repository"
git checkout main
git merge docs --no-ff
git push origin main

git checkout docs
# add  last para&this para
git add .
git commit -m "docs: add last&this para"
git checkout main
git merge docs --no-ff
git push -u origin main

# add server subrepo
git submodule add https://github.com/NANNO35578/calcite_server.git calcite_server
git commit -m "Add module: server"
# 弄错了, 撤销一次
git reset --soft HEAD~1
git add .
git commit -m "Add module: server"
# 在calcite拉取最新的server:
git submodule update --init --recursive


