#!/bin/bash
# ===== 绍兴建材装饰联合会·电子手册 一键部署 v6（7家版·全jpg图·IP直连版） =====
set -e
BASE=/usr/share/nginx/html
mkdir -p $BASE/images
cd $BASE
V=20260905b
REPO="twetwe1/sx-federation-handbook"
COZE="https://www.coze.cn/s"

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

echo ">>> [1/3] 下载手册页面（7家版 V6）..."
dl index.html "o68fphVdDSk" "index.html"
grep -q "绍兴建材装饰联合会" index.html || { echo "!! 页面异常，截图发闺女"; exit 1; }
grep -q "HANDBOOK-V6-7SHOPS" index.html && echo "  ✅ 7家版页面确认" || echo "  ⚠️ 页面版本可能不是最新，截图发闺女"

echo ">>> [2/3] 下载16张商家图（全jpg）..."
dl images/nq01.jpg "5vbXUt620vc" "images/nq01.jpg"
dl images/nq02.jpg "-wpdRyDNt9g" "images/nq02.jpg"
dl images/nq04.jpg "8mZxLTi5i58" "images/nq04.jpg"
dl images/hw01.jpg "85gEr_ZCghA" "images/hw01.jpg"
dl images/hw02.jpg "AaaRXSyyea8" "images/hw02.jpg"
dl images/nfl01.jpg "8qgMFlFEy0A" "images/nfl01.jpg"
dl images/nfl05.jpg "90Qct608k1o" "images/nfl05.jpg"
dl images/nfl12.jpg "8h4U2At8b9s" "images/nfl12.jpg"
dl images/df01.jpg "g4kHdfbwt4w" "images/df01.jpg"
dl images/df02.jpg "kazyy6ad4qo" "images/df02.jpg"
dl images/mgd01.jpg "fBwrMdTLOhU" "images/mgd01.jpg"
dl images/mgd02.jpg "gQ2QNZRst0U" "images/mgd02.jpg"
dl images/sd01.jpg "gx8qgWT0QT0" "images/sd01.jpg"
dl images/sd02.jpg "f0DCKtoZGww" "images/sd02.jpg"
dl images/fdl01.jpg "oBe3xpd692M" "images/fdl01.jpg"
dl images/fdl02.jpg "o5AlXrmRO5Y" "images/fdl02.jpg"

echo ">>> [3/3] 权限与重载..."
chmod -R 755 $BASE
chown -R nginx:nginx $BASE 2>/dev/null || chown -R www-data:www-data $BASE 2>/dev/null || true
nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || nginx -s reload 2>/dev/null || true

echo ""
echo "============================================"
echo "✅ 部署完成！微信扫码即可访问"
echo "   手册地址（IP直连，微信内可直接打开）："
echo "   http://111.231.6.213/"
echo "============================================"
