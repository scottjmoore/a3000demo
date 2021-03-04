#!/usr/bin/python3

import sys
import argparse
import ntpath

from pathlib import Path
from PIL import Image

parser = argparse.ArgumentParser(description='Convert indexed color PNG to assembler directives.')
parser.add_argument('-i', '--infile', type=argparse.FileType('rb'),default=sys.stdin)
parser.add_argument('-o', '--outfile', type=argparse.FileType('wt'),default=sys.stdout)
parser.add_argument('-sw', '--spritewidth', type=int,default=8)
parser.add_argument('-sh', '--spriteheight', type=int,default=8)
args = parser.parse_args()

filename = Path(ntpath.basename(args.outfile.name)).stem

image = Image.open(args.infile)
image_name = filename
image_width,image_height = image.size

sprite_width = args.spritewidth
sprite_height = args.spriteheight

palette_name = filename + "_palette"
palette_type,palette_data = image.palette.getdata()

f_out = args.outfile

image_pixels = image.load()

f_out.write(image_name+':\n')

print("png2asm: '"+args.infile.name+"' => '"+args.outfile.name+"'")
print("\tImage size : "+f'{image_width}'+"x"+f'{image_height}')
print("\tSprite size : "+f'{sprite_width}'+"x"+f'{sprite_height}')

y = 0
while y < sprite_height:
    x = 0
    while x < sprite_width:
        b0 = image_pixels[x + 0,y]
        b1 = image_pixels[x + 1,y]
        b2 = image_pixels[x + 2,y]
        b3 = image_pixels[x + 3,y]
        b4 = image_pixels[x + 4,y]
        b5 = image_pixels[x + 5,y]
        b6 = image_pixels[x + 6,y]
        b7 = image_pixels[x + 7,y]
        f_out.write('\t\t\t.byte\t'+f'0x{b0:0x},'+f'0x{b1:0x},'+f'0x{b2:0x},'+f'0x{b3:0x},'+f'0x{b4:0x},'+f'0x{b5:0x},'+f'0x{b6:0x},'+f'0x{b7:0x}\n')
        x += 8
    y += 1

f_out.write(image_name+'_end:\n\n')

f_out.close()