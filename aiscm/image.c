#include <libswscale/swscale.h>
#include <yuv4mpeg.h>
#include <jpegutils.h>
#include <libguile.h>

void scm_to_array(SCM source, int dest[])
{
  if (!scm_is_null_and_not_nil(source)) {
    *dest = scm_to_int(scm_car(source));
    scm_to_array(scm_cdr(source), dest + 1);
  };
}

void image_setup(SCM scm_type, enum PixelFormat *format, int *width, int *height,
                 uint8_t *data[], int pitches[], void *ptr)
{
  int i;
  int offsets[8];
  memset(offsets, 0, sizeof(offsets));
  *format = scm_to_int(scm_car(scm_type));
  *width = scm_to_int(scm_caadr(scm_type)),
  *height = scm_to_int(scm_cadadr(scm_type));
  scm_to_array(scm_caddr(scm_type), offsets);
  scm_to_array(scm_cadddr(scm_type), pitches);
  for (i=0; i<8; i++) data[i] = (uint8_t *)ptr + offsets[i];
}

SCM image_convert(SCM scm_ptr, SCM scm_source_type, SCM scm_dest_ptr, SCM scm_dest_type)
{
  enum PixelFormat format;
  int width, height;
  void *ptr = scm_to_pointer(scm_ptr);
  uint8_t *source_data[8];
  int source_pitches[8];
  memset(source_pitches, 0, sizeof(source_pitches));
  image_setup(scm_source_type, &format, &width, &height, source_data, source_pitches, ptr);

  enum PixelFormat dest_format;
  int dest_width, dest_height;
  void *dest_ptr = scm_to_pointer(scm_dest_ptr);
  uint8_t *dest_data[8];
  int dest_pitches[8];
  memset(dest_pitches, 0, sizeof(dest_pitches));
  image_setup(scm_dest_type, &dest_format, &dest_width, &dest_height, dest_data, dest_pitches, dest_ptr);

  struct SwsContext *sws_context = sws_getContext(width, height, format,
                                                  dest_width, dest_height, dest_format,
                                                  SWS_FAST_BILINEAR, 0, 0, 0);
  sws_scale(sws_context, (const uint8_t * const *)source_data, source_pitches, 0, height,
            dest_data, dest_pitches);

  sws_freeContext(sws_context);
  return SCM_UNDEFINED;
}

SCM mjpeg_to_yuv420p(SCM scm_source_ptr, SCM scm_width, SCM scm_height, SCM scm_dest_ptr, SCM scm_offsets)
{
  void *source_ptr = scm_to_pointer(scm_source_ptr);
  void *dest_ptr = scm_to_pointer(scm_dest_ptr);
  int width = scm_to_int(scm_width);
  int height = scm_to_int(scm_height);
  int offsets[3];
  memset(offsets, 0, sizeof(offsets));
  scm_to_array(scm_offsets, offsets);
  decode_jpeg_raw(source_ptr, width * height * 2, Y4M_ILACE_NONE, 0, width, height,
                  dest_ptr + offsets[0], dest_ptr + offsets[1], dest_ptr + offsets[2]);
  return SCM_UNDEFINED;
}

void init_image(void)
{
  scm_c_define("PIX_FMT_RGB24",   scm_from_int(PIX_FMT_RGB24));
  scm_c_define("PIX_FMT_BGR24",   scm_from_int(PIX_FMT_BGR24));
  scm_c_define("PIX_FMT_BGRA",    scm_from_int(PIX_FMT_BGRA));
  scm_c_define("PIX_FMT_GRAY8",   scm_from_int(PIX_FMT_GRAY8));
  scm_c_define("PIX_FMT_YUV420P", scm_from_int(PIX_FMT_YUV420P));
  scm_c_define("PIX_FMT_UYVY422", scm_from_int(PIX_FMT_UYVY422));
  scm_c_define("PIX_FMT_YUYV422", scm_from_int(PIX_FMT_YUYV422));
  scm_c_define_gsubr("image-convert", 4, 0, 0, image_convert);
  scm_c_define_gsubr("mjpeg-to-yuv420p", 5, 0, 0, mjpeg_to_yuv420p);
}
