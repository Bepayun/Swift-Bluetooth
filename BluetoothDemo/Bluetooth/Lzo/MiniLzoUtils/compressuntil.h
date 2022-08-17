//
//  compressuntil.h
//  Runner
//
//  Created by 十间鱼 on 2020/9/18.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#ifndef compressuntil_h
#define compressuntil_h

#include <stdio.h>

// 压缩
unsigned char * compress_until(unsigned char *origin_data,unsigned long origin_length,unsigned long * compressed_length);

// 解压缩
unsigned char * decompress_until(unsigned char *compressed_data,unsigned long compressed_length,unsigned long origin_length);

#endif /* compressuntil_h */
