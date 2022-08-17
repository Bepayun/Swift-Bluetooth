//
//  compressuntil.c
//  BluetoothDemo
//
//  Created by apple on 2021/12/20.
//

#include "compressuntil.h"

#include <stdlib.h>

#include "minilzo.h"

#define HEAP_ALLOC(var,size) \
    lzo_align_t __LZO_MMODEL var [ ((size) + (sizeof(lzo_align_t) - 1)) / sizeof(lzo_align_t) ]

static HEAP_ALLOC(wrkmem, LZO1X_1_MEM_COMPRESS);

unsigned char * compress_until(unsigned char *origin_data,unsigned long origin_length,unsigned long * compressed_length) {
    
    int r; // 压缩结果
    lzo_uint in_len; // 输入指令的长度
//    lzo_uint out_len; // 输出指令的长度
    unsigned char __LZO_MMODEL *buf;
    unsigned char __LZO_MMODEL *out; // 输出的指令

    if (lzo_init() != LZO_E_OK) {
        printf("internal error - lzo_init() failed !!!\n");
        printf("(this usually indicates a compiler bug - try recompiling\nwithout optimizations, and enable '-DLZO_DEBUG' for diagnostics)\n");
        return NULL;
     }
    in_len = origin_length;
//    printf("%lu\n", in_len);
    
    // 分配内存
    buf = malloc(in_len + in_len / 16 + 64 + 3);
    
    // 压缩
    r = lzo1x_1_compress(origin_data,in_len,buf,compressed_length,wrkmem);
    if (r == LZO_E_OK) {
        out = malloc(*compressed_length);
//        printf("compressed %lu bytes into %lu bytes\n",
//            (unsigned long) in_len, (unsigned long) *compressed_length);
        
         for(int loop = 0; loop < *compressed_length; loop++) {
           out[loop] = buf[loop];
             if (loop == *compressed_length -1) {
                 break;
             }
         }
//        printf("out: %s\n", out);
    } else {
        /* this should NEVER happen */
        printf("internal error - compression failed: %d\n", r);
        out =  NULL;
    }

    if (*compressed_length >= in_len) {
        printf("This block contains incompressible data.\n");
        out = NULL;
    }
    free(buf);

    return out;
}

// 不常用 没写完善 慎用！
unsigned char * decompress_until(unsigned char *compressed_data,unsigned long compressed_length,unsigned long origin_length) {
    int r; // 压缩结果
    lzo_uint origin_len; // 原始长度
    lzo_uint compressed_len; // 压缩后长度
    lzo_uint new_len;
    unsigned char __LZO_MMODEL *decompressed_data = NULL; // 解压后数据

    origin_len = origin_length;
    new_len = origin_len;
    compressed_len = compressed_length;
    r = lzo1x_decompress(compressed_data,compressed_len,decompressed_data,&new_len,NULL);
    
    if (r == LZO_E_OK && new_len == origin_len)
        printf("decompressed %lu bytes back into %lu bytes\n",
            (unsigned long) compressed_len, (unsigned long) origin_len);
    else {
        /* this should NEVER happen */
        printf("internal error - decompression failed: %d\n", r);
        return 0;
    }

    printf("\nminiLZO simple compression test passed.\n");
    return 0;
}


