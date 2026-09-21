# -*- coding: utf-8 -*-
import re, json
from PIL import Image, ImageDraw, ImageFont

# ---------- 数据 ----------
s=open('手册预览_V34_20260921.html',encoding='utf-8').read()
shops=[]
for m in re.finditer(r'id="(shop-[\w-]+)"(.*?)</article>', s, re.S):
    seg=m.group(2)
    g=lambda p: (re.search(p,seg).group(1).strip() if re.search(p,seg) else '')
    name=g(r'class="name">([^<]*)<'); tag=g(r'class="tag">([^<]*)<')
    y=g(r'class="y">([^<]*)<'); so=g(r'class="s">([^<]*)<')
    tel=re.search(r"tel:(\d+)",seg); tel=tel.group(1) if tel else ''
    pills=re.findall(r'class="pill">([^<]*)</span>',seg)
    # 卖点优先 y > s > pills前2
    sell = y or so or ' · '.join(pills[:2])
    if not sell: sell='联盟品牌 · 欢迎到店'
    sell = sell.replace('(','（').replace(')','）')
    shops.append({'name':name.replace('👑 ','').replace('👑',''),'tag':tag,'sell':sell,'tel':tel})

RED=(210,35,30); REDD=(168,20,16); INK=(43,18,0); BG=(255,246,229)
GOLD=(245,179,1); GOLDL=(255,212,94); GRAY=(122,102,82); WHITE=(255,255,255)
CREAM=(255,251,240)

FB='/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc'
FR='/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc'
F=lambda p,sz: ImageFont.truetype(p,sz)
W=1080; M=36; CW=W-2*M

def fit(d,txt,font,maxw):
    if d.textlength(txt,font=font)<=maxw: return txt
    while txt and d.textlength(txt+'…',font=font)>maxw: txt=txt[:-1]
    return txt+'…'

def rr(d,box,r,fill,outline=None,w=3):
    d.rounded_rectangle(box,radius=r,fill=fill,outline=outline,width=w)

# ---------- 预算高度 ----------
head_h=660
card_hs=[]
for sh in shops: card_hs.append(196 if sh['tel'] else 170)
gap=16
cards_h=sum(card_hs)+gap*(len(shops)-1)+M  # 尾部留白
foot_h=830
H=head_h+cards_h+foot_h
print('总高',H)

img=Image.new('RGB',(W,H),BG); d=ImageDraw.Draw(img)

# ---------- 头部 ----------
d.rectangle([0,0,W,64],fill=GOLD)
t='绍兴建材装饰联合会'
f=F(FB,30); tw=d.textlength(t,font=f)
d.text(((W-tw)/2,15),t,font=f,fill=INK)
d.rectangle([0,64,W,68],fill=INK)

# 红底头部（金条下方）
head_h=640
d.rectangle([0,68,W,head_h],fill=RED)
top=120
t='双节家装狂欢节'; f=F(FB,92); tw=d.textlength(t,font=f)
d.text(((W-tw)/2,top),t,font=f,fill=GOLDL,stroke_width=3,stroke_fill=INK)
top+=148
t='22家品牌联盟 · 福利一次看全'; f=F(FB,42); tw=d.textlength(t,font=f)
d.text(((W-tw)/2,top),t,font=f,fill=WHITE)
top+=78
caps=['联盟价','进店就有礼','带单成交有补贴','装修一次跑齐']
f=F(FB,28); ws=[d.textlength(c,font=f) for c in caps]
pw=[w+56 for w in ws]; tot=sum(pw)+18*3
x=(W-tot)/2
for c,w,p in zip(caps,ws,pw):
    rr(d,[x,top,x+p,top+56],28,fill=GOLD)
    d.text((x+(p-w)/2,top+11),c,font=f,fill=INK)
    x+=p+18
top+=56+46
d.line([M,top,W-M,top],fill=GOLDL,width=3)
for px,py in [(80,100),(985,135),(60,420),(1015,470),(540,600)]:
    d.ellipse([px-8,py-8,px+8,py+8],fill=GOLDL)
y=head_h

# ---------- 22家卡片 ----------
fno=F(FB,26); fname=F(FB,35); fsell=F(FR,27); ftel=F(FB,31); ftag=F(FR,20)
for i,sh in enumerate(shops):
    ch=card_hs[i]
    rr(d,[M,y,W-M,y+ch],18,fill=CREAM,outline=INK,w=3)
    # 序号
    d.ellipse([M+22,y+24,M+22+58,y+24+58],fill=GOLD,outline=INK,width=3)
    n='%02d'%(i+1); tw=d.textlength(n,font=fno)
    d.text((M+22+29-tw/2,y+34),n,font=fno,fill=INK)
    # 名字
    nm=fit(d,sh['name'],fname,W-M-130)
    d.text((M+102,y+27),nm,font=fname,fill=INK)
    # 卖点
    sl=fit(d,sh['sell'],fsell,CW-140)
    d.text((M+102,y+82),sl,font=fsell,fill=(90,70,50))
    # 电话 / tag
    if sh['tel']:
        d.ellipse([M+104,y+139,M+118,y+153],fill=REDD)
        d.text((M+132,y+130),sh['tel'],font=ftel,fill=REDD)
    else:
        tt=sh['tag'] if sh['tag'] else '到店详询'
        tt=fit(d,tt,F(FR,18),CW-150)
        d.text((M+102,y+126),tt,font=F(FR,18),fill=GRAY)
    y+=ch+gap
y+=M

# ---------- 底部 ----------
d.rectangle([0,y,W,H],fill=RED)
d.rectangle([0,y,W,y+6],fill=GOLD)
fy=y+44
t='想看每家的详细介绍？'; f=F(FB,40); tw=d.textlength(t,font=f)
d.text(((W-tw)/2,fy),t,font=f,fill=GOLDL)
fy+=70
# 二维码
import qrcode
qimg=qrcode.make('https://sj.xiaohangkeji.com/').convert('RGB')
QS=330; qimg=qimg.resize((QS,QS),Image.NEAREST)
bx=(W-380)/2
rr(d,[bx,fy,bx+380,fy+436],18,fill=WHITE,outline=INK,w=3)
img.paste(qimg,(int(bx)+25,int(fy)+24))
d.text((bx+25+QS/2-d.textlength('长按识别 · 看完整手册',font=F(FB,25))/2, fy+24+QS+12),'长按识别 · 看完整手册',font=F(FB,25),fill=INK)
fy+=436+34
t='手机打开 sj.xiaohangkeji.com 同样直达'; f=F(FR,24); tw=d.textlength(t,font=f)
d.text(((W-tw)/2,fy),t,font=f,fill=(255,220,180))
fy+=44
t='绍兴建材装饰联合会 · 22家品牌联盟'; f=F(FB,28); tw=d.textlength(t,font=f)
d.text(((W-tw)/2,fy),t,font=f,fill=WHITE)
fy+=48
t='浙ICP备2025219535号-2'; f=F(FR,17); tw=d.textlength(t,font=f)
d.text(((W-tw)/2,min(fy,H-30)),t,font=f,fill=(255,205,195))

out='_deploy/宣传长图_V1_20260921.png'
img.save(out,optimize=True)
import os; print(out, os.path.getsize(out))
