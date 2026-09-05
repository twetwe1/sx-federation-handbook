#!/bin/bash
# ===== 绍兴建材装饰联合会·电子手册 一键部署 v7（备案域名版·阿里云服务器） =====
# 用法（备案通过后，闺女会把下面的备案号填好再给爸命令）：
#   备案号通过参数传入：bash deploy_aliyun.sh 浙ICP备XXXXXXXX号
set -e
BASE=/var/www/handbook
mkdir -p $BASE/images
cd $BASE
V=20260907a
REPO="twetwe1/sx-federation-handbook"
COZE="https://www.coze.cn/s"
BEIAN="$1"

dl(){  # dl <本地路径> <coze短链ID> <仓库相对路径>
  local out="$1" cid="$2" rel="$3" ok=0
  local urls=(
    "$COZE/$cid/"
    "https://cdn.jsdelivr.net/gh/$REPO@main/$rel?v=$V"
    "https://fastly.jsdelivr.net/gh/$REPO@main/$rel?v=$V"
    "https://raw.githubusercontent.com/$REPO/main/$rel"
  )
  for u in "${urls[@]}"; do
    if curl -fsSL --connect-timeout 15 --max-time 120 -o "$out.tmp" "$u"; then
      if [[ "$rel" == *.jpg ]] && ! file "$out.tmp" 2>/dev/null | grep -qi "JPEG"; then
        rm -f "$out.tmp"; continue
      fi
      mv "$out.tmp" "$out"; echo "  ✅ $rel"; ok=1; break
    fi
  done
  if [ $ok -ne 1 ]; then echo "  ⚠️ 下载失败: $rel（截图发闺女）"; rm -f "$out.tmp"; fi
}

echo ">>> [1/4] 下载手册页面（8家版 V8 备案版）..."
dl index.html "ZYxAGzh2Dv4" "index.html"
grep -q "绍兴建材装饰联合会" index.html || { echo "!! 页面异常，截图发闺女"; exit 1; }
grep -q "HANDBOOK-V8-8SHOPS-BEIAN" index.html && echo "  ✅ 备案版页面确认" || echo "  ⚠️ 页面版本可能不是最新，截图发闺女"

if [ -z "$BEIAN" ]; then
  echo "!! 缺备案号参数，页面先保留占位（备案号下来后重跑此脚本并带上备案号）"
else
  sed -i "s/__BEIAN_HAO__/${BEIAN}/g" index.html
  grep -q "$BEIAN" index.html && echo "  ✅ 备案号已挂到页脚：$BEIAN"
fi

echo ">>> [2/4] 下载16张商家图（全jpg）..."
dl images/nq01.jpg  "5vbXUt620vc"  "images/nq01.jpg"
dl images/nq02.jpg  "-wpdRyDNt9g"  "images/nq02.jpg"
dl images/nq04.jpg  "8mZxLTi5i58"  "images/nq04.jpg"
dl images/hw01.jpg  "85gEr_ZCghA"  "images/hw01.jpg"
dl images/hw02.jpg  "AaaRXSyyea8"  "images/hw02.jpg"
dl images/nfl01.jpg "-A7ENKabAC0"  "images/nfl01.jpg"
dl images/nfl05.jpg "90Qct608k1o"  "images/nfl05.jpg"
dl images/nfl12.jpg "8h4U2At8b9s"  "images/nfl12.jpg"
dl images/df01.jpg  "g4kHdfbwt4w"  "images/df01.jpg"
dl images/df02.jpg  "kazyy6ad4qo"  "images/df02.jpg"
dl images/mgd01.jpg "fBwrMdTLOhU"  "images/mgd01.jpg"
dl images/mgd02.jpg "gQ2QNZRst0U"  "images/mgd02.jpg"
dl images/sd01.jpg  "gx8qgWT0QT0"  "images/sd01.jpg"
dl images/sd02.jpg  "f0DCKtoZGww"  "images/sd02.jpg"
dl images/fdl01.jpg "oBe3xpd692M"  "images/fdl01.jpg"
dl images/fdl02.jpg "o5AlXrmRO5Y"  "images/fdl02.jpg"
dl images/sl01.jpg  "06ohYeJrw2s"  "images/sl01.jpg"
dl images/sl02.jpg  "4NnjA9-Bc4Y"  "images/sl02.jpg"

echo ">>> [3/4] 配置 nginx 站点（handbook.xiaohangkeji.com）..."
cat > /etc/nginx/conf.d/handbook.conf <<'NGINX'
server {
    listen 80;
    server_name handbook.xiaohangkeji.com xiaohangkeji.com;
    root /var/www/handbook;
    index index.html;
    location / { try_files $uri $uri/ =404; }
    location ~* \.(jpg|jpeg|png|css|js)$ { expires 7d; add_header Cache-Control "public"; }
}
NGINX
chmod -R 755 $BASE
chown -R www-data:www-data $BASE 2>/dev/null || true
nginx -t && systemctl reload nginx 2>/dev/null || nginx -s reload 2>/dev/null || true

echo ">>> [4/4] 本机自检..."
sleep 1
curl -s -m 8 -H "Host: handbook.xiaohangkeji.com" http://127.0.0.1/ | grep -q "绍兴建材装饰联合会" \
  && echo "  ✅ 本机访问手册正常" || echo "  ⚠️ 本机自检异常，截图发闺女"

echo ""
echo "============================================"
echo "✅ 阿里云部署完成！"
echo "   手册域名：http://handbook.xiaohangkeji.com/"
echo "   （DNS解析由闺女在阿里云配置，配好后微信扫码直开）"
echo "============================================"
