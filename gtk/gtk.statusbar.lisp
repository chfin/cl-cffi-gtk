;;; ----------------------------------------------------------------------------
;;; gtk.statusbar.lisp
;;;
;;; This file contains code from a fork of cl-gtk2.
;;; See http://common-lisp.net/project/cl-gtk2/
;;;
;;; The documentation has been copied from the GTK+ 3 Reference Manual
;;; Version 3.2.3. See http://www.gtk.org.
;;;
;;; Copyright (C) 2009 - 2011 Kalyanov Dmitry
;;; Copyright (C) 2011 - 2012 Dr. Dieter Kaiser
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
;;; GtkStatusbar
;;; 
;;; Report messages of minor importance to the user
;;; 
;;; Synopsis
;;; 
;;;     GtkStatusbar
;;;
;;;     gtk_statusbar_new
;;;     gtk_statusbar_get_context_id
;;;     gtk_statusbar_push
;;;     gtk_statusbar_pop
;;;     gtk_statusbar_remove
;;;     gtk_statusbar_remove_all
;;;     gtk_statusbar_get_message_area
;;; 
;;; Object Hierarchy
;;; 
;;;   GObject
;;;    +----GInitiallyUnowned
;;;          +----GtkWidget
;;;                +----GtkContainer
;;;                      +----GtkBox
;;;                            +----GtkStatusbar
;;; 
;;; Implemented Interfaces
;;; 
;;; GtkStatusbar implements AtkImplementorIface, GtkBuildable and GtkOrientable.
;;;
;;; Style Properties
;;; 
;;;   "shadow-type"              GtkShadowType         : Read
;;; 
;;; Signals
;;; 
;;;   "text-popped"                                    : Run Last
;;;   "text-pushed"                                    : Run Last
;;; 
;;; Description
;;; 
;;; A GtkStatusbar is usually placed along the bottom of an application's main
;;; GtkWindow. It may provide a regular commentary of the application's status
;;; (as is usually the case in a web browser, for example), or may be used to
;;; simply output a message when the status changes, (when an upload is complete
;;; in an FTP client, for example).
;;; 
;;; Status bars in GTK+ maintain a stack of messages. The message at the top of
;;; the each bar's stack is the one that will currently be displayed.
;;; 
;;; Any messages added to a statusbar's stack must specify a context id that is
;;; used to uniquely identify the source of a message. This context id can be
;;; generated by gtk_statusbar_get_context_id(), given a message and the
;;; statusbar that it will be added to. Note that messages are stored in a
;;; stack, and when choosing which message to display, the stack structure is
;;; adhered to, regardless of the context identifier of a message.
;;; 
;;; One could say that a statusbar maintains one stack of messages for display
;;; purposes, but allows multiple message producers to maintain sub-stacks of
;;; the messages they produced (via context ids).
;;; 
;;; Status bars are created using gtk_statusbar_new().
;;; 
;;; Messages are added to the bar's stack with gtk_statusbar_push().
;;; 
;;; The message at the top of the stack can be removed using
;;; gtk_statusbar_pop(). A message can be removed from anywhere in the stack if
;;; its message id was recorded at the time it was added. This is done using
;;; gtk_statusbar_remove().
;;;
;;; ----------------------------------------------------------------------------
;;;
;;; Style Property Details
;;;
;;; ----------------------------------------------------------------------------
;;; The "shadow-type" style property
;;; 
;;;   "shadow-type"              GtkShadowType         : Read
;;; 
;;; Style of bevel around the statusbar text.
;;; 
;;; Default value: GTK_SHADOW_IN
;;;
;;; ----------------------------------------------------------------------------
;;;
;;; Signal Details
;;;
;;; ----------------------------------------------------------------------------
;;; The "text-popped" signal
;;; 
;;; void user_function (GtkStatusbar *statusbar,
;;;                     guint         context_id,
;;;                     gchar        *text,
;;;                     gpointer      user_data)       : Run Last
;;; 
;;; Is emitted whenever a new message is popped off a statusbar's stack.
;;; 
;;; statusbar :
;;;     the object which received the signal
;;; 
;;; context_id :
;;;     the context id of the relevant message/statusbar
;;; 
;;; text :
;;;     the message that was just popped
;;; 
;;; user_data :
;;;     user data set when the signal handler was connected.
;;;
;;; ----------------------------------------------------------------------------
;;; The "text-pushed" signal
;;; 
;;; void user_function (GtkStatusbar *statusbar,
;;;                     guint         context_id,
;;;                     gchar        *text,
;;;                     gpointer      user_data)       : Run Last
;;; 
;;; Is emitted whenever a new message gets pushed onto a statusbar's stack.
;;; 
;;; statusbar :
;;;     the object which received the signal
;;; 
;;; context_id :
;;;     the context id of the relevant message/statusbar
;;; 
;;; text :
;;;     the message that was pushed
;;; 
;;; user_data :
;;;     user data set when the signal handler was connected.
;;; ----------------------------------------------------------------------------

(in-package :gtk)

;;; ----------------------------------------------------------------------------
;;; struct GtkStatusbar
;;; 
;;; struct GtkStatusbar;
;;; ----------------------------------------------------------------------------

(eval-when (:compile-toplevel :load-toplevel :execute)
  (register-object-type "GtkStatusbar" 'gtk-statusbar))

(define-g-object-class "GtkStatusbar" gtk-statusbar
  (:superclass gtk-h-box
   :export t
   :interfaces ("AtkImplementorIface" "GtkBuildable" "GtkOrientable")
   :type-initializer "gtk_statusbar_get_type")
  ((has-resize-grip
    gtk-statusbar-has-resize-grip
    "has-resize-grip" "gboolean" t t)))

;;; ----------------------------------------------------------------------------

(define-child-property "GtkStatusbar"
                       gtk-statusbar-child-expand
                       "expand" "gboolean" t t t)

(define-child-property "GtkStatusbar"
                       gtk-statusbar-child-fill
                       "fill" "gboolean" t t t)

(define-child-property "GtkStatusbar" 
                       gtk-statusbar-child-padding
                       "padding" "guint" t t t)

(define-child-property "GtkStatusbar"
                       gtk-statusbar-child-pack-type
                       "pack-type" "GtkPackType" t t t)

(define-child-property "GtkStatusbar"
                       gtk-statusbar-child-position
                       "position" "gint" t t t)

;;; ----------------------------------------------------------------------------
;;; gtk_statusbar_new ()
;;; 
;;; GtkWidget * gtk_statusbar_new (void);
;;; 
;;; Creates a new GtkStatusbar ready for messages.
;;; 
;;; Returns :
;;;     the new GtkStatusbar
;;; ----------------------------------------------------------------------------

(defun gkt-statusbar-new ()
  (make-instance 'gtk-statusbar))

(export 'gtk-statusbar)

;;; ----------------------------------------------------------------------------
;;; gtk_statusbar_get_context_id ()
;;; 
;;; guint gtk_statusbar_get_context_id (GtkStatusbar *statusbar,
;;;                                     const gchar *context_description);
;;; 
;;; Returns a new context identifier, given a description of the actual context.
;;; Note that the description is not shown in the UI.
;;; 
;;; statusbar :
;;;     a GtkStatusbar
;;; 
;;; context_description :
;;;     textual description of what context the new message is being used in
;;; 
;;; Returns :
;;;     an integer id
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_statusbar_get_context_id" %gtk-statusbar-get-context-id) :uint
  (statusbar (g-object gtk-statusbar))
  (context-description :string))

(defun gtk-statusbar-get-context-id (statusbar context)
  (etypecase context
    (integer context)
    (string (%gtk-statusbar-get-context-id statusbar context))))

(export 'gtk-statusbar-get-context-id)

;;; ----------------------------------------------------------------------------
;;; gtk_statusbar_push ()
;;; 
;;; guint gtk_statusbar_push (GtkStatusbar *statusbar,
;;;                           guint context_id,
;;;                           const gchar *text);
;;; 
;;; Pushes a new message onto a statusbar's stack.
;;; 
;;; statusbar :
;;;     a GtkStatusbar
;;; 
;;; context_id :
;;;     the message's context id, as returned by gtk_statusbar_get_context_id()
;;; 
;;; text :
;;;     the message to add to the statusbar
;;; 
;;; Returns :
;;;     a message id that can be used with gtk_statusbar_remove()
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_statusbar_push" %gtk-statusbar-push) :uint
  (statusbar (g-object gtk-statusbar))
  (context-id :uint)
  (text :string))

(defun gtk-statusbar-push (statusbar context text)
  (%gtk-statusbar-push statusbar
                       (gtk-statusbar-get-context-id statusbar context)
                       text))

(export 'gtk-statusbar-push)

;;; ----------------------------------------------------------------------------
;;; gtk_statusbar_pop ()
;;; 
;;; void gtk_statusbar_pop (GtkStatusbar *statusbar, guint context_id);
;;; 
;;; Removes the first message in the GtkStatusBar's stack with the given
;;; context id.
;;; 
;;; Note that this may not change the displayed message, if the message at the
;;; top of the stack has a different context id.
;;; 
;;; statusbar :
;;;     a GtkStatusBar
;;; 
;;; context_id :
;;;     a context identifier
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_statusbar_pop" %gtk-statusbar-pop) :void
  (statusbar (g-object gtk-statusbar))
  (context-id :uint))

(defun gtk-statusbar-pop (statusbar context)
  (%gtk-statusbar-pop statusbar
                      (gtk-statusbar-get-context-id statusbar context)))

(export 'gtk-statusbar-pop)

;;; ----------------------------------------------------------------------------
;;; gtk_statusbar_remove ()
;;; 
;;; void gtk_statusbar_remove (GtkStatusbar *statusbar,
;;;                            guint context_id,
;;;                            guint message_id);
;;; 
;;; Forces the removal of a message from a statusbar's stack. The exact
;;; context_id and message_id must be specified.
;;; 
;;; statusbar :
;;;     a GtkStatusBar
;;; 
;;; context_id :
;;;     a context identifier
;;; 
;;; message_id :
;;;     a message identifier, as returned by gtk_statusbar_push()
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_statusbar_remove" %gtk-statusbar-remove) :void
  (statusbar (g-object gtk-statusbar))
  (context-id :uint)
  (message-id :uint))

(defun gtk-statusbar-remove (statusbar context message-id)
  (%gtk-statusbar-remove statusbar
                         (gtk-statusbar-get-context-id statusbar context)
                         message-id))

(export 'gtk-statusbar-remove)

;;; ----------------------------------------------------------------------------
;;; gtk_statusbar_remove_all ()
;;; 
;;; void gtk_statusbar_remove_all (GtkStatusbar *statusbar, guint context_id);
;;; 
;;; Forces the removal of all messages from a statusbar's stack with the exact
;;; context_id.
;;; 
;;; statusbar :
;;;     a GtkStatusBar
;;; 
;;; context_id :
;;;     a context identifier
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_statusbar_remove_all" %gtk-statusbar-remove-all) :void
  (statusbar (g-object gtk-statusbar))
  (conext-id :uint))

(defun gtk-statusbar-remove-all (statusbar context)
  (%gtk-statusbar-remove-all statusbar
                             (gtk-statusbar-get-context-id statusbar context)))

(export 'gtk-statusbar-remove-all)

;;; ----------------------------------------------------------------------------
;;; gtk_statusbar_get_message_area ()
;;; 
;;; GtkWidget * gtk_statusbar_get_message_area (GtkStatusbar *statusbar);
;;; 
;;; Retrieves the box containing the label widget.
;;; 
;;; statusbar :
;;;     a GtkStatusBar
;;; 
;;; Returns :
;;;     a GtkBox
;;; 
;;; Since 2.20
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_statusbar_get_message_area" gtk-statusbar-get-message-area)
    (g-object gtk-widget)
  (statusbar (g-object gtk-statusbar)))

(export 'gtk-statusbar-get-message-area)

;;; --- End of file gtk.statusbar.lisp -----------------------------------------
