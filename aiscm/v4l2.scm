(define-module (aiscm v4l2)
  #:use-module (oop goops)
  #:use-module (ice-9 optargs)
  #:use-module (srfi srfi-1)
  #:use-module (aiscm util)
  #:use-module (aiscm mem)
  #:use-module (aiscm int)
  #:use-module (aiscm image)
  #:use-module (aiscm sequence)
  #:use-module (system foreign)
  #:export (<v4l2> <meta<v4l2>> grab))
(load-extension "libguile-v4l2" "init_v4l2")
(define-class <meta<v4l2>> (<class>))
(define-class <v4l2> ()
  (videodev2 #:init-keyword #:videodev2 #:getter get-videodev2)
  #:metaclass <meta<v4l2>>)
(define formats
  (list (cons 'RGB  V4L2_PIX_FMT_RGB24)
        (cons 'BGR  V4L2_PIX_FMT_BGR24)
        (cons 'I420 V4L2_PIX_FMT_YUV420)
        (cons 'UYVY V4L2_PIX_FMT_UYVY)
        (cons 'YUY2 V4L2_PIX_FMT_YUYV)
        (cons 'GRAY V4L2_PIX_FMT_GREY)
        (cons 'MJPG V4L2_PIX_FMT_MJPEG)))
(define symbols (alist-invert formats))
(define (sym->fmt sym) (assq-ref formats sym))
(define (fmt->sym fmt) (assq-ref symbols fmt))
(define (supported? fmt)
  (or (fmt->sym (car fmt))
      (begin (warn (format #f "Unsupported V4L2 format 0x~x" (car fmt))) #f)))
(define format-order (map car formats))
(define (format< x y)
  (let [(ord-x (index (car x) format-order))
        (ord-y (index (car y) format-order))
        (size-x (apply * (cdr x)))
        (size-y (apply * (cdr y)))]
    (or (< ord-x ord-y) (and (= ord-x ord-y) (< size-x size-y)))))
(define-method (initialize (self <v4l2>) initargs)
  (let-keywords initargs #f (device channel select)
    (let* [(device    (or device "/dev/video0"))
           (channel   (or channel 0))
           (select    (or select last))
           (decode    (lambda (f) (cons (fmt->sym (car f)) (cdr f))))
           (encode    (lambda (f) (cons (sym->fmt (car f)) (cdr f))))
           (selection (lambda (formats)
                        (encode (select (sort (map decode (filter supported? formats)) format<)))))]
      (next-method self (list #:videodev2 (make-videodev2 device channel selection))))))
(define-method (destroy (self <v4l2>)) (videodev2-destroy (get-videodev2 self)))
(define-method (grab (self <v4l2>))
  (let [(picture (videodev2-grab (get-videodev2 self)))]
    (make <image>
          #:format (fmt->sym (car picture))
          #:shape  (cadr picture)
          #:mem    (make <mem> #:base (caddr picture) #:size (cadddr picture)))))
