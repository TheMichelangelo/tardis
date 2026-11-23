"""Render the original friction diagrams/rebuses (requires Pillow)."""

from pathlib import Path
import textwrap

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
LESSON = 'lesson-12-syla-tertya-shcho-stanetsya-yakshcho-von'
OUT = ROOT / 'src/data' / LESSON
INK, TEAL, GOLD = '#17364b', '#147d82', '#efab39'


def font(size, bold=False):
    name = 'NotoSans-Bold.ttf' if bold else 'NotoSans-Regular.ttf'
    return ImageFont.truetype(str(ROOT / 'assets/fonts' / name), size)


def label(d, xy, text, size=32, color=INK, bold=False):
    d.text(xy, text.replace('−', '-'), font=font(size, bold), fill=color)


def lines(d, xy, text, width=50, size=29):
    for i, line in enumerate(textwrap.wrap(text, width)):
        label(d, (xy[0], xy[1] + i * (size + 13)), line, size)


def arrow(d, start, end, color=TEAL):
    d.line([start, end], fill=color, width=9)
    x, y = end
    direction = 1 if end[0] > start[0] else -1
    d.polygon([(x, y), (x - direction * 22, y - 13),
               (x - direction * 22, y + 13)], fill=color)


def icon(d, kind, x, y):
    """Draw clear picture clues in a 170 x 140 area."""
    if kind == 'thermos':
        d.rounded_rectangle((x+40,y+15,x+120,y+135), 18, fill=TEAL)
        d.rectangle((x+45,y,x+115,y+25), fill=INK)
        d.rectangle((x+54,y+45,x+107,y+102), fill='#dff3ef')
    elif kind == 'leaves':
        d.line((x+30,y+125,x+135,y+15), fill=TEAL, width=7)
        for a,b in [(45,85),(80,45),(108,10)]:
            d.ellipse((x+a-25,y+b,x+a+28,y+b+35), fill='#6dab64')
            d.ellipse((x+a+10,y+b+20,x+a+63,y+b+55), fill='#90bf67')
    elif kind == 'blanket':
        d.rounded_rectangle((x+10,y+15,x+160,y+130), 12, fill=TEAL)
        for a in range(35,160,35):
            d.line((x+a,y+18,x+a,y+128), fill='#a9dcd6', width=6)
        for b in range(40,130,35):
            d.line((x+12,y+b,x+158,y+b), fill='#a9dcd6', width=6)
    elif kind == 'rabbit':
        d.ellipse((x+20,y+65,x+135,y+137), fill='#a8b7c2')
        d.ellipse((x+85,y+28,x+145,y+90), fill='#a8b7c2')
        d.ellipse((x+91,y,x+108,y+48), fill='#a8b7c2')
        d.ellipse((x+119,y,x+137,y+49), fill='#a8b7c2')
        d.ellipse((x+128,y+49,x+135,y+56), fill=INK)
        d.ellipse((x+8,y+90,x+40,y+120), fill='#dae4e9')
    elif kind == 'wheat':
        d.line((x+85,y+15,x+85,y+140), fill=GOLD, width=7)
        for b in range(15,110,23):
            d.ellipse((x+48,y+b,x+85,y+b+24), fill=GOLD)
            d.ellipse((x+85,y+b,x+122,y+b+24), fill=GOLD)
    elif kind == 'turtle':
        for a,b in [(35,100),(100,100),(35,35),(100,35)]:
            d.ellipse((x+a,y+b,x+a+28,y+b+30), fill='#6dab64')
        d.ellipse((x+15,y+30,x+140,y+120), fill=TEAL)
        d.arc((x+35,y+44,x+118,y+110), 0,360, fill='#a9dcd6', width=6)
        d.ellipse((x+125,y+52,x+165,y+90), fill='#6dab64')
        d.ellipse((x+151,y+60,x+157,y+66), fill=INK)
    elif kind == 'frog':
        d.ellipse((x+20,y+40,x+150,y+125), fill='#6dab64')
        for a in [40,105]:
            d.ellipse((x+a,y+20,x+a+35,y+62), fill='#6dab64')
            d.ellipse((x+a+12,y+31,x+a+24,y+45), fill=INK)
        d.arc((x+53,y+62,x+118,y+100), 0,180, fill=INK, width=4)
    elif kind == 'ice':
        d.rounded_rectangle((x+30,y+20,x+140,y+130), 15,
                            fill='#b9e6f5', outline=TEAL, width=4)
        d.line((x+45,y+75,x+80,y+40), fill='white', width=8)
    elif kind == 'lion':
        d.ellipse((x+20,y+5,x+155,y+140), fill=GOLD)
        d.ellipse((x+45,y+30,x+132,y+120), fill='#fce1a6')
        for a in [66,105]:
            d.ellipse((x+a,y+60,x+a+8,y+68), fill=INK)
        d.polygon([(x+79,y+82),(x+101,y+82),(x+90,y+94)], fill=INK)
    elif kind == 'slide':
        d.line((x+35,y+10,x+140,y+120,x+165,y+120), fill=GOLD, width=15)
        d.line((x+35,y+10,x+35,y+130), fill=TEAL, width=7)
        d.line((x+5,y+130,x+35,y+10), fill=TEAL, width=7)
        for b in [45,75,105]:
            d.line((x+14,y+b,x+35,y+b), fill=TEAL, width=5)
    elif kind == 'ring':
        d.ellipse((x+30,y+25,x+140,y+135), outline=GOLD, width=18)
        d.polygon([(x+65,y+5),(x+105,y+5),(x+118,y+25),
                   (x+85,y+52),(x+52,y+25)], fill='#a4dce8')
    elif kind == 'roll':
        d.ellipse((x+15,y+35,x+125,y+130), fill='#e5bb75')
        d.ellipse((x+85,y+35,x+155,y+130), fill='#f6d899', outline=GOLD, width=5)
        d.arc((x+98,y+52,x+143,y+113), 20,300, fill=GOLD, width=5)


def diagram(lang):
    image = Image.new('RGB', (1400, 1150), 'white')
    d = ImageDraw.Draw(image)
    label(d, (70,35), 'ТРИ ВИДИ СИЛИ ТЕРТЯ' if lang=='ua'
          else 'THREE TYPES OF FRICTION', 48, bold=True)
    label(d, (70,110), 'Порівняй взаємодію поверхонь' if lang=='ua'
          else 'Compare surfaces in contact', 30, TEAL)
    entries = [
        ('Тертя спокою', 'Static friction',
         'Поверхні не ковзають одна відносно одної.',
         'Surfaces do not slide relative to each other.',
         'Приклад: штовхаєш коробку, а вона не рухається.',
         'Example: you push a box, but it stays in place.'),
        ('Тертя ковзання', 'Sliding friction',
         'Одна поверхня ковзає по іншій.',
         'One surface slides over the other.',
         'Приклад: санчата ковзають по снігу.',
         'Example: a sled slides over snow.'),
        ('Тертя кочення', 'Rolling friction',
         'Тіло котиться по поверхні.',
         'An object rolls over a surface.',
         'Приклад: колесо візка котиться по доріжці.',
         'Example: a trolley wheel rolls along a path.'),
    ]
    for i, e in enumerate(entries):
        y = 190+i*285
        d.rounded_rectangle((65,y,1335,y+260), 24, fill='#edf7f6')
        label(d, (100,y+15), str(i+1), 30, TEAL, True)
        label(d, (355,y+20), e[0 if lang=='ua' else 1], 39, TEAL, True)
        lines(d, (355,y+85), e[2 if lang=='ua' else 3], 53, 30)
        lines(d, (355,y+165), e[4 if lang=='ua' else 5], 53, 29)
        d.line((120,y+213,310,y+213), fill=INK, width=6)
        if i==0:
            d.rectangle((165,y+105,270,y+208), fill=GOLD)
            arrow(d,(115,y+150),(162,y+150))
        elif i==1:
            d.rectangle((145,y+140,275,y+160), fill=GOLD)
            d.line((162,y+160,162,y+210,287,y+210,300,y+197), fill=TEAL, width=7)
            arrow(d,(165,y+105),(285,y+105))
        else:
            d.ellipse((155,y+94,270,y+209), outline=TEAL, width=15)
            d.line((213,y+106,213,y+197), fill=GOLD, width=5)
            d.line((167,y+151,259,y+151), fill=GOLD, width=5)
            arrow(d,(165,y+65),(285,y+65))
    label(d, (70,1080), 'Назви свій приклад для кожного виду тертя.' if lang=='ua'
          else 'Give your own example of each type of friction.', 31, TEAL)
    image.save(OUT / f'{LESSON}-ex-diagram{suffix(lang)}.png')


def suffix(lang):
    return '' if lang=='ua' else '.en'


def rebus(lang):
    image = Image.new('RGB', (1400, 1150), 'white')
    d = ImageDraw.Draw(image)
    label(d, (65,35), 'РЕБУСИ ПРО ТЕРТЯ' if lang=='ua'
          else 'FRICTION PICTURE REBUSES', 46, bold=True)
    label(d, (65,108), 'Вилучи вказані літери та з’єднай частини.' if lang=='ua'
          else 'Remove the letters shown, then join the parts.', 30, TEAL)
    rows = [
        [('thermos','ТЕРМОС','− МОС'),('leaves','ЛИСТЯ','− ЛИС')],
        [('blanket','КОВДРА','− ДРА'),('rabbit','ЗАЄЦЬ','− ЄЦЬ'),(None,'ННЯ','')],
        [('wheat','КОЛОС','− ЛОС'),('turtle','ЧЕРЕПАХА','− РЕПАХА'),(None,'ННЯ','')],
    ] if lang=='ua' else [
        [('frog','FROG','− OG'),('ice','ICE','− E'),(None,'T',''),('lion','LION','− L')],
        [('slide','SLIDE','− E'),('ring','RING','− R')],
        [('roll','ROLL',''),('ring','RING','− R')],
    ]
    for i, row in enumerate(rows):
        y = 180+i*310
        d.rounded_rectangle((55,y,1345,y+285), 24, fill='#f4f7fb')
        label(d, (78,y+15), str(i+1), 29, TEAL, True)
        step = 1180/len(row)
        for j,(kind,word,remove) in enumerate(row):
            x = 130+j*step
            if kind:
                icon(d,kind,x+12,y+15)
                label(d,(x,y+158),word,29,bold=True)
                label(d,(x,y+205),remove,31,TEAL,True)
            else:
                label(d,(x+20,y+70),word,46,TEAL,True)
            if j<len(row)-1:
                label(d,(x+step-50,y+75),'+',44,TEAL,True)
        label(d,(1120,y+230),'= …',34,TEAL,True)
    image.save(OUT / f'{LESSON}-ex-rebus{suffix(lang)}.png')


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    for language in ['ua', 'en']:
        diagram(language)
        rebus(language)
