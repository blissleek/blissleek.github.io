#!/bin/bash

git add .
git commit -m "$1"
git push -u origin master
echo "代码上传GitHub成功！"
hexo generate --deploy
hexo deploy --generate
echo "站点部署成功！"

