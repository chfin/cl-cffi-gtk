;;; ----------------------------------------------------------------------------
;;; cairo.transformations.lisp
;;;
;;; The documentation of this file is taken from the Cairo Reference Manual
;;; Version 1.12.14 and modified to document the Lisp binding to the Cairo
;;; library. See <http://cairographics.org>. The API documentation of the Lisp
;;; binding is available from <http://www.crategus.com/books/cl-cffi-gtk/>.
;;;
;;; Copyright (C) 2013 Dieter Kaiser
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU Lesser General Public License for Lisp
;;; as published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version and with a preamble to
;;; the GNU Lesser General Public License that clarifies the terms for use
;;; with Lisp programs and is referred as the LLGPL.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this program and the preamble to the Gnu Lesser
;;; General Public License.  If not, see <http://www.gnu.org/licenses/>
;;; and <http://opensource.franz.com/preamble.html>.
;;; ----------------------------------------------------------------------------
;;;
;;; Transformations
;;;
;;; Manipulating the current transformation matrix
;;;
;;; Synopsis
;;;
;;;     cairo_translate
;;;     cairo_scale
;;;     cairo_rotate
;;;     cairo_transform
;;;     cairo_set_matrix
;;;     cairo_get_matrix
;;;     cairo_identity_matrix
;;;     cairo_user_to_device
;;;     cairo_user_to_device_distance
;;;     cairo_device_to_user
;;;     cairo_device_to_user_distance
;;;
;;; Description
;;;
;;; The current transformation matrix, ctm, is a two-dimensional affine
;;; transformation that maps all coordinates and other drawing instruments from
;;; the user space into the surface's canonical coordinate system, also known as
;;; the device space.
;;; ----------------------------------------------------------------------------

(in-package :cairo)

;;; ----------------------------------------------------------------------------
;;; cairo_translate ()
;;; ----------------------------------------------------------------------------

(defcfun ("cairo_translate" %cairo-translate) :void
  (cr (:pointer (:struct cairo-t)))
  (tx :double)
  (ty :double))

(defun cairo-translate (cr tx ty)
 #+cl-cffi-gtk-documentation
 "@version{2013-10-5}
  @argument[cr]{a cairo context}
  @argument[tx]{amount to translate in the x direction}
  @argument[ty]{amount to translate in the y direction}
  @begin{short}
    Modifies the current transformation matrix (CTM) by translating the
    user-space origin by (@arg{tx}, @arg{ty}).
  @end{short}
  This offset is interpreted as a user-space coordinate according to the CTM in
  place before the new call to the function @sym{cairo-translate}. In other
  words, the translation of the user-space origin takes place after any existing
  transformation.

  Since 1.0
  @see-symbol{cairo-t}"
  (%cairo-translate cr
                    (coerce tx 'double-float)
                    (coerce ty 'double-float)))

(export 'cairo-translate)

;;; ----------------------------------------------------------------------------
;;; cairo_scale ()
;;; ----------------------------------------------------------------------------

(defcfun ("cairo_scale" %cairo-scale) :void
  (cr (:pointer (:struct cairo-t)))
  (sx :double)
  (sy :double))

(defun cairo-scale (cr sx sy)
 #+cl-cffi-gtk-documentation
 "@version{2013-10-3}
  @argument[cr]{a cairo context}
  @argument[sx]{scale factor for the x dimension}
  @argument[sy]{scale factor for the y dimension}
  @begin{short}
    Modifies the current transformation matrix (CTM) by scaling the x and y
    user-space axes by @arg{sx} and @arg{sy} respectively.
  @end{short}
  The scaling of the axes takes place after any existing transformation of user
  space.

  Since 1.0
  @see-symbol{cairo-t}"
  (%cairo-scale cr (coerce sx 'double-float) (coerce sy 'double-float)))

(export 'cairo-scale)

;;; ----------------------------------------------------------------------------
;;; cairo_rotate ()
;;; ----------------------------------------------------------------------------

(defcfun ("cairo_rotate" %cairo-rotate) :void
  (cr (:pointer (:struct cairo-t)))
  (angle :double))

(defun cairo-rotate (cr angle)
 #+cl-cffi-gtk-documentation
 "@version{2013-10-5}
  @argument[cr]{a cairo context}
  @argument[angle]{angle (in radians) by which the user-space axes will be
    rotated}
  @begin{short}
    Modifies the current transformation matrix (CTM) by rotating the user-space
    axes by @arg{angle} radians.
  @end{short}
  The rotation of the axes takes places after any existing transformation of
  user space. The rotation direction for positive angles is from the positive x
  axis toward the positive y axis.

  Since 1.0
  @see-symbol{cairo-t}"
  (%cairo-rotate cr (coerce angle 'double-float)))

(export 'cairo-rotate)

;;; ----------------------------------------------------------------------------
;;; cairo_transform ()
;;;
;;; void cairo_transform (cairo_t *cr, const cairo_matrix_t *matrix);
;;;
;;; Modifies the current transformation matrix (CTM) by applying matrix as an
;;; additional transformation. The new transformation of user space takes place
;;; after any existing transformation.
;;;
;;; cr :
;;;     a cairo context
;;;
;;; matrix :
;;;     a transformation to be applied to the user-space axes
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; cairo_set_matrix ()
;;;
;;; void cairo_set_matrix (cairo_t *cr, const cairo_matrix_t *matrix);
;;;
;;; Modifies the current transformation matrix (CTM) by setting it equal to
;;; matrix.
;;;
;;; cr :
;;;     a cairo context
;;;
;;; matrix :
;;;     a transformation matrix from user space to device space
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; cairo_get_matrix ()
;;;
;;; void cairo_get_matrix (cairo_t *cr, cairo_matrix_t *matrix);
;;;
;;; Stores the current transformation matrix (CTM) into matrix.
;;;
;;; cr :
;;;     a cairo context
;;;
;;; matrix :
;;;     return value for the matrix
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; cairo_identity_matrix ()
;;;
;;; void cairo_identity_matrix (cairo_t *cr);
;;;
;;; Resets the current transformation matrix (CTM) by setting it equal to the
;;; identity matrix. That is, the user-space and device-space axes will be
;;; aligned and one user-space unit will transform to one device-space unit.
;;;
;;; cr :
;;;     a cairo context
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; cairo_user_to_device ()
;;;
;;; void cairo_user_to_device (cairo_t *cr, double *x, double *y);
;;;
;;; Transform a coordinate from user space to device space by multiplying the
;;; given point by the current transformation matrix (CTM).
;;;
;;; cr :
;;;     a cairo context
;;;
;;; x :
;;;     X value of coordinate (in/out parameter)
;;;
;;; y :
;;;     Y value of coordinate (in/out parameter)
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; cairo_user_to_device_distance ()
;;;
;;; void cairo_user_to_device_distance (cairo_t *cr, double *dx, double *dy);
;;;
;;; Transform a distance vector from user space to device space. This function
;;; is similar to cairo_user_to_device() except that the translation components
;;; of the CTM will be ignored when transforming (dx,dy).
;;;
;;; cr :
;;;     a cairo context
;;;
;;; dx :
;;;     X component of a distance vector (in/out parameter)
;;;
;;; dy :
;;;     Y component of a distance vector (in/out parameter)
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; cairo_device_to_user ()
;;;
;;; void cairo_device_to_user (cairo_t *cr, double *x, double *y);
;;;
;;; Transform a coordinate from device space to user space by multiplying the
;;; given point by the inverse of the current transformation matrix (CTM).
;;;
;;; cr :
;;;     a cairo
;;;
;;; x :
;;;     X value of coordinate (in/out parameter)
;;;
;;; y :
;;;     Y value of coordinate (in/out parameter)
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; cairo_device_to_user_distance ()
;;;
;;; void cairo_device_to_user_distance (cairo_t *cr, double *dx, double *dy);
;;;
;;; Transform a distance vector from device space to user space. This function
;;; is similar to cairo_device_to_user() except that the translation components
;;; of the inverse CTM will be ignored when transforming (dx,dy).
;;;
;;; cr :
;;;     a cairo context
;;;
;;; dx :
;;;     X component of a distance vector (in/out parameter)
;;;
;;; dy :
;;;     Y component of a distance vector (in/out parameter)
;;;
;;; Since 1.0
;;; ----------------------------------------------------------------------------

;;; --- End of file cairo.transformations.lisp ---------------------------------