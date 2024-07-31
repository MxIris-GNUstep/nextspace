/* tiff.c - load TIFF image from file
 *
 * Raster graphics library
 *
 * Copyright (c) 1997-2003 Alfredo K. Kojima
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
 *  MA 02110-1301, USA.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <tiff.h>
#include <tiffio.h>
#include <tiffvers.h>

#include <config.h>
#include "wraster.h"
#include "imgformat.h"
#include "wr_i18n.h"

static RImage *convert_data(unsigned char *data, int width, int height, uint16_t alpha,
                            uint16_t amode)
{
  RImage *image = NULL;
  TIFF *tif;
  int i, ch;
  unsigned char *r, *g, *b, *a;

  /* convert data */
  image = RCreateImage(width, height, alpha);

  if (alpha)
    ch = 4;
  else
    ch = 3;

  if (image) {
    int x, y;

    r = image->data;
    g = image->data + 1;
    b = image->data + 2;
    a = image->data + 3;

    /* data seems to be stored upside down */
    data += width * (height - 1);
    for (y = 0; y < height; y++) {
      for (x = 0; x < width; x++) {
        *(r) = (*data) & 0xff;
        *(g) = (*data >> 8) & 0xff;
        *(b) = (*data >> 16) & 0xff;

        if (alpha) {
          *(a) = (*data >> 24) & 0xff;

          if (amode && (*a > 0)) {
            *r = (*r * 255) / *(a);
            *g = (*g * 255) / *(a);
            *b = (*b * 255) / *(a);
          }

          a += 4;
        }

        r += ch;
        g += ch;
        b += ch;
        data++;
      }
      data -= 2 * width;
    }
  }
}

RImage *RLoadTIFF(const char *file, int index)
{
  RImage *image = NULL;
  TIFF *tif;
  int i;
#if TIFFLIB_VERSION < 20210416
  uint16 alpha, amode, extrasamples;
  uint16 *sampleinfo;
  uint32 width, height;
  uint32 *data, *ptr;
#else
  uint16_t alpha, amode, extrasamples;
  uint16_t *sampleinfo;
  uint32_t width, height;
  uint32_t *data, *ptr;
#endif

  tif = TIFFOpen(file, "r");
  if (!tif)
    return NULL;

  /* seek index */
  i = index;
  while (i > 0) {
    if (!TIFFReadDirectory(tif)) {
      RErrorCode = RERR_BADINDEX;
      TIFFClose(tif);
      return NULL;
    }
    i--;
  }

  /* get info */
  TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &width);
  TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &height);

  TIFFGetFieldDefaulted(tif, TIFFTAG_EXTRASAMPLES, &extrasamples, &sampleinfo);

  alpha = (extrasamples == 1 && ((sampleinfo[0] == EXTRASAMPLE_ASSOCALPHA) ||
                                 (sampleinfo[0] == EXTRASAMPLE_UNASSALPHA)));
  amode = (extrasamples == 1 && sampleinfo[0] == EXTRASAMPLE_ASSOCALPHA);

  if (width < 1 || height < 1) {
    RErrorCode = RERR_BADIMAGEFILE;
    TIFFClose(tif);
    return NULL;
  }

  /* read data */
#if TIFFLIB_VERSION < 20210416
  ptr = data = (uint32 *)_TIFFmalloc(width * height * sizeof(uint32));
#else
  ptr = data = (uint32_t *)_TIFFmalloc(width * height * sizeof(uint32_t));
#endif

  if (!data) {
    RErrorCode = RERR_NOMEMORY;
  } else {
    image = RCreateImage(width, height, alpha);
    if (!TIFFReadRGBAImageOriented(tif, width, height, data, ORIENTATION_TOPLEFT, 0)) {
      RErrorCode = RERR_BADIMAGEFILE;
      RReleaseImage(image);
      image = NULL;
    } else if (data) {
      memcpy(image->data, data, width * height * sizeof(uint32_t));
    }
    _TIFFfree(ptr);
  }

  TIFFClose(tif);

  return image;
}
