#!/usr/bin/env python
r"""Generate favicon.png
========================
"""

import sys

import numpy as np
from PIL import Image


def output(base_path, watermark_path, output_path):
    # https://neovim.io/logos/neovim-logos.zip
    base_img = Image.open(base_path).convert("RGBA")
    # https://cdnlogo.com/icon/zhihu_292675.html
    watermark = Image.open(watermark_path).convert("RGBA")
    # ========== 将非白色区域设为透明 ==========
    watermark_np = np.array(watermark)
    watermark_w, watermark_h = watermark.size
    _w = int(watermark_w * 0.2)
    # outline
    watermark_np[:_w, :, 3] = 255
    watermark_np[:, :_w, 3] = 255
    watermark_np[-_w:, :, 3] = 255
    watermark_np[:, -_w:, 3] = 255
    # toggle alpha
    watermark_np[:, :, 3] = 255 - watermark_np[:, :, 3]
    # set non-alpha range to white
    white_mask = watermark_np[:, :, 3] > 100
    watermark_np[white_mask] = [255, 255, 255, 255]

    watermark = Image.fromarray(watermark_np, mode="RGBA")
    # =========================================

    base_w, base_h = base_img.size

    x_ratio = 0
    y_ratio = 0.6
    ratio = 0.25

    x = int(base_w * x_ratio)
    y = int(base_h * y_ratio)
    target_w = int(base_w * ratio)
    target_h = target_w

    watermark = watermark.resize((target_w, target_h), Image.LANCZOS)

    base_img.paste(watermark, (x, y), watermark)
    base_img.save(output_path)


if __name__ == "__main__":
    if len(sys.argv) < 4:
        output_path = "assets/images/favicon.png"
    else:
        output_path = sys.argv[3]
    if len(sys.argv) < 3:
        watermark_path = "assets/images/zhihu-1024x1024.png"
    else:
        watermark_path = sys.argv[2]
    if len(sys.argv) < 2:
        base_path = "assets/images/neovim-mark.png"
    else:
        base_path = sys.argv[1]
    output(base_path, watermark_path, output_path)
